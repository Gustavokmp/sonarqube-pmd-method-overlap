$ErrorActionPreference = "Stop"
Set-Location "c:\Users\gusta\Documents\gustavo\mestrado\tese\exp-mestrado"

# CORRECAO DE AUDITORIA (2026-10-01): nao usar ConvertTo-Json aqui - por
# padrao escapa '<'/'>' como \u003c/\u003e, e o parser minimo do
# Deduplicator.java nao desfaz escapes \uXXXX (corrompia method_id de
# metodos genericos, ex.: "List<String>" virava "Listu003cStringu003e").
# Construir o JSON manualmente, mesma convencao de escape do Associator.java
# (apenas " \ \n \r \t). Mesmo bug encontrado e corrigido no Hibernate ORM.
function Json-Escape($s) {
  $s = $s -replace '\\', '\\\\'
  $s = $s -replace '"', '\"'
  $s = $s -replace "`r", '\r'
  $s = $s -replace "`n", '\n'
  $s = $s -replace "`t", '\t'
  return $s
}

$sonarRaw = Get-Content runs\commons-lang-3.20.0-2026-10-01\raw\sonarqube-issues.jsonl | ForEach-Object { $_ | ConvertFrom-Json }
$sonarAssoc = Get-Content runs\commons-lang-3.20.0-2026-10-01\inventories\association-sonarqube.jsonl | ForEach-Object { $_ | ConvertFrom-Json }
$out = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $sonarRaw.Count; $i++) {
  $r = $sonarRaw[$i]; $a = $sonarAssoc[$i]
  if ($a.status -ne "eligible_method") { continue }
  $smell = if ($r.rule -eq "java:S138") { "long_method" } else { "long_parameter_list" }
  $json = '{"tool":"sonarqube","project":"apache-commons-lang","smell":"' + $smell + '","method_id":"' + (Json-Escape ([string]$a.method_id)) + '","raw_alert_id":"' + (Json-Escape ([string]$r.key)) + '"}'
  $out.Add($json)
}
$out | Set-Content -Encoding utf8 runs\commons-lang-3.20.0-2026-10-01\inventories\dedup-input-sonarqube.jsonl
Write-Host "sonarqube_dedup_input=$($out.Count)"

$pmdAssoc = Get-Content runs\commons-lang-3.20.0-2026-10-01\inventories\association-pmd.jsonl | ForEach-Object { $_ | ConvertFrom-Json }
$out2 = New-Object System.Collections.Generic.List[string]
$idx = 0
foreach ($a in $pmdAssoc) {
  $idx++
  if ($a.status -ne "eligible_method") { continue }
  $smell = if ($a.label -eq "pmd:NcssCount") { "long_method" } else { "long_parameter_list" }
  $rawId = "pmd::" + $a.relative_path + "::" + $a.line
  $json = '{"tool":"pmd","project":"apache-commons-lang","smell":"' + $smell + '","method_id":"' + (Json-Escape ([string]$a.method_id)) + '","raw_alert_id":"' + (Json-Escape $rawId) + '"}'
  $out2.Add($json)
}
$out2 | Set-Content -Encoding utf8 runs\commons-lang-3.20.0-2026-10-01\inventories\dedup-input-pmd.jsonl
Write-Host "pmd_dedup_input=$($out2.Count)"

Get-Content runs\commons-lang-3.20.0-2026-10-01\inventories\dedup-input-sonarqube.jsonl, runs\commons-lang-3.20.0-2026-10-01\inventories\dedup-input-pmd.jsonl | Set-Content -Encoding utf8 runs\commons-lang-3.20.0-2026-10-01\inventories\dedup-input-all.jsonl
Write-Host "combined=$((Get-Content runs\commons-lang-3.20.0-2026-10-01\inventories\dedup-input-all.jsonl).Count)"
