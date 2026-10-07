$ErrorActionPreference = "Stop"
Set-Location "c:\Users\gusta\Documents\gustavo\mestrado\tese\exp-mestrado"
$base = "runs\commons-lang-3.20.0-2026-10-01"
$reprocessDir = "$base\reprocess-check"

# CORRECAO DE AUDITORIA (2026-10-01): nao usar ConvertTo-Json (escapa
# '<'/'>' como \u003c/\u003e; o parser minimo do Deduplicator.java nao
# desfaz esses escapes). Construir o JSON manualmente (mesma convencao do
# Associator.java).
function Json-Escape($s) {
  $s = $s -replace '\\', '\\\\'
  $s = $s -replace '"', '\"'
  $s = $s -replace "`r", '\r'
  $s = $s -replace "`n", '\n'
  $s = $s -replace "`t", '\t'
  return $s
}

$sonarRaw = Get-Content "$base\raw\sonarqube-issues.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$sonarAssoc = Get-Content "$reprocessDir\association-sonarqube.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$out = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $sonarRaw.Count; $i++) {
  $r = $sonarRaw[$i]; $a = $sonarAssoc[$i]
  if ($a.status -ne "eligible_method") { continue }
  $smell = if ($r.rule -eq "java:S138") { "long_method" } else { "long_parameter_list" }
  $json = '{"tool":"sonarqube","project":"apache-commons-lang","smell":"' + $smell + '","method_id":"' + (Json-Escape ([string]$a.method_id)) + '","raw_alert_id":"' + (Json-Escape ([string]$r.key)) + '"}'
  $out.Add($json)
}
$out | Set-Content -Encoding utf8 "$reprocessDir\dedup-input-sonarqube.jsonl"

$pmdAssoc = Get-Content "$reprocessDir\association-pmd.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$out2 = New-Object System.Collections.Generic.List[string]
foreach ($a in $pmdAssoc) {
  if ($a.status -ne "eligible_method") { continue }
  $smell = if ($a.label -eq "pmd:NcssCount") { "long_method" } else { "long_parameter_list" }
  $rawId = "pmd::" + $a.relative_path + "::" + $a.line
  $json = '{"tool":"pmd","project":"apache-commons-lang","smell":"' + $smell + '","method_id":"' + (Json-Escape ([string]$a.method_id)) + '","raw_alert_id":"' + (Json-Escape $rawId) + '"}'
  $out2.Add($json)
}
$out2 | Set-Content -Encoding utf8 "$reprocessDir\dedup-input-pmd.jsonl"

Get-Content "$reprocessDir\dedup-input-sonarqube.jsonl", "$reprocessDir\dedup-input-pmd.jsonl" | Set-Content -Encoding utf8 "$reprocessDir\dedup-input-all.jsonl"

Write-Host "--- dedup-input-all diff ---"
Compare-Object (Get-Content "$base\inventories\dedup-input-all.jsonl") (Get-Content "$reprocessDir\dedup-input-all.jsonl")
Write-Host "(sem saida acima = identico)"
