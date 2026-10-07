# Reprocessamento deterministico (PROTOCOLO.md secao 20): reexecuta
# associacao + deduplicacao + metricas a partir dos MESMOS relatorios
# brutos ja preservados (raw/sonarqube-issues.jsonl, raw/pmd-output.xml),
# SEM reinvocar sonar-scanner/pmd, e compara byte-a-byte contra os
# artefatos ja gerados em inventories/.

$ErrorActionPreference = "Stop"
$runDir = "runs/spring-framework-6.2.16-2026-10-01"
$inv = "$runDir/inventories"
$check = "$runDir/reprocess-check"
New-Item -ItemType Directory -Force -Path $check | Out-Null
$project = "spring-framework-6.2.16"
$commit = "053d8e25f424bae9c5a597c4b248af137dce264f"

./runs/spring-framework-6.2.16-2026-10-01/logs/build-scope-staging.ps1 | Out-Null
$stageRoot = Join-Path $env:TEMP "spring-framework-scope-stage"

function Convert-ToRelativePath($rawPath) {
    $p = $rawPath -replace '\\', '/'
    if ($p -match '^spring-core/src/main/java21/(.*)$') {
        return "spring-core-java21/$($matches[1])"
    }
    return ($p -replace '/src/main/java/', '/')
}

# --- occurrences (repete a mesma transformacao do step1) ---
$sqIssues = Get-Content "$runDir/raw/sonarqube-issues.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$sqOccLines = New-Object System.Collections.Generic.List[string]
$sqAlertIds = New-Object System.Collections.Generic.List[string]
foreach ($i in $sqIssues) {
    $compPath = $i.component.Substring($i.component.IndexOf(':') + 1)
    $relPath = Convert-ToRelativePath $compPath
    $ruleShort = $i.rule -replace '^java:', ''
    $sqOccLines.Add("$relPath,$($i.line),sonar:$ruleShort")
    $sqAlertIds.Add([string]$i.key)
}
Set-Content -Path "$check/occurrences-sonarqube.csv" -Value $sqOccLines -Encoding UTF8
Set-Content -Path "$check/raw-alert-ids-sonarqube.txt" -Value $sqAlertIds -Encoding UTF8

[xml]$pmdXml = Get-Content "$runDir/raw/pmd-output.xml" -Raw
$pmdOccLines = New-Object System.Collections.Generic.List[string]
$pmdAlertIds = New-Object System.Collections.Generic.List[string]
foreach ($file in $pmdXml.pmd.file) {
    $fname = $file.name -replace '\\', '/'
    $afterRoot = $fname -replace '^.*spring-framework-6\.2\.16/', ''
    $relPath = Convert-ToRelativePath $afterRoot
    $viol = $file.violation
    if ($null -eq $viol) { continue }
    foreach ($v in @($viol)) {
        $pmdOccLines.Add("$relPath,$($v.beginline),pmd:$($v.rule)")
        $pmdAlertIds.Add("pmd::$relPath::$($v.beginline)::$($v.rule)")
    }
}
Set-Content -Path "$check/occurrences-pmd.csv" -Value $pmdOccLines -Encoding UTF8
Set-Content -Path "$check/raw-alert-ids-pmd.txt" -Value $pmdAlertIds -Encoding UTF8

# --- Associator ---
Push-Location scripts/method-inventory
try {
    & java -cp "out;lib/javaparser-core-3.28.2.jar" Associator `
        --project $project --commit $commit --root $stageRoot `
        --occurrences "../../$check/occurrences-sonarqube.csv" `
        --out "../../$check/association-sonarqube.jsonl"
    & java -cp "out;lib/javaparser-core-3.28.2.jar" Associator `
        --project $project --commit $commit --root $stageRoot `
        --occurrences "../../$check/occurrences-pmd.csv" `
        --out "../../$check/association-pmd.jsonl"
} finally {
    Pop-Location
}

# --- dedup-input + Deduplicator ---
function Rule-To-Smell($label) {
    if ($label -match 'S138$' -or $label -match 'NcssCount$') { return 'long_method' }
    if ($label -match 'S107$' -or $label -match 'ExcessiveParameterList$') { return 'long_parameter_list' }
    throw "regra desconhecida: $label"
}
# NAO usar ConvertTo-Json aqui: escapa '<'/'>' como \u003c/\u003e por padrao,
# e o parser minimo do Deduplicator.java nao desfaz \uXXXX (corromperia
# method_id de metodos genericos). Construir o JSON manualmente, mesma
# convencao de escape do Associator.java.
function Json-Escape($s) {
    $s = $s -replace '\\', '\\\\'
    $s = $s -replace '"', '\"'
    $s = $s -replace "`r", '\r'
    $s = $s -replace "`n", '\n'
    $s = $s -replace "`t", '\t'
    return $s
}
function Build-DedupInput($tool, $assocFile, $alertIdsFile, $outFile) {
    $assoc = Get-Content $assocFile | ForEach-Object { $_ | ConvertFrom-Json }
    $alertIds = Get-Content $alertIdsFile
    $lines = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $assoc.Count; $i++) {
        $a = $assoc[$i]
        if ($a.status -ne 'eligible_method') { continue }
        $smell = Rule-To-Smell $a.label
        $json = '{"tool":"' + (Json-Escape $tool) + '","project":"' + (Json-Escape $project) + '","smell":"' + (Json-Escape $smell) + '","method_id":"' + (Json-Escape ([string]$a.method_id)) + '","raw_alert_id":"' + (Json-Escape ([string]$alertIds[$i])) + '"}'
        $lines.Add($json)
    }
    Set-Content -Path $outFile -Value $lines -Encoding UTF8
}
Build-DedupInput "sonarqube" "$check/association-sonarqube.jsonl" "$check/raw-alert-ids-sonarqube.txt" "$check/dedup-input-sonarqube.jsonl"
Build-DedupInput "pmd" "$check/association-pmd.jsonl" "$check/raw-alert-ids-pmd.txt" "$check/dedup-input-pmd.jsonl"
Get-Content "$check/dedup-input-sonarqube.jsonl","$check/dedup-input-pmd.jsonl" | Set-Content -Path "$check/dedup-input-all.jsonl" -Encoding UTF8

Push-Location scripts/method-inventory
try {
    & java -cp "out;lib/javaparser-core-3.28.2.jar" Deduplicator --in "../../$check/dedup-input-all.jsonl" --out "../../$check/dedup-results.jsonl"
} finally {
    Pop-Location
}

# --- metricas ---
$d = Get-Content "$check/dedup-results.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$U = 35236
function Compute-Metrics($smell) {
    $A = [System.Collections.Generic.HashSet[string]]::new()
    $B = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($r in $d) {
        if ($r.smell -ne $smell) { continue }
        if ($r.tool -eq 'sonarqube') { [void]$A.Add([string]$r.method_id) }
        if ($r.tool -eq 'pmd') { [void]$B.Add([string]$r.method_id) }
    }
    $inter = [System.Collections.Generic.HashSet[string]]::new($A); $inter.IntersectWith($B)
    $union = [System.Collections.Generic.HashSet[string]]::new($A); $union.UnionWith($B)
    $jaccard = if ($union.Count -eq 0) { "N/A" } else { ($inter.Count / $union.Count).ToString("F4", [System.Globalization.CultureInfo]::InvariantCulture) }
    [PSCustomObject]@{ smell=$smell; U=$U; A=$A.Count; B=$B.Count
        sonarPct=($A.Count/$U*100).ToString("F4",[System.Globalization.CultureInfo]::InvariantCulture)
        pmdPct=($B.Count/$U*100).ToString("F4",[System.Globalization.CultureInfo]::InvariantCulture)
        intersection=$inter.Count; sonarOnly=($A.Count-$inter.Count); pmdOnly=($B.Count-$inter.Count)
        union=$union.Count; jaccard=$jaccard }
}
$result = @{ long_method = (Compute-Metrics "long_method"); long_parameter_list = (Compute-Metrics "long_parameter_list") }
$result | ConvertTo-Json -Depth 5 | Set-Content -Path "$check/metrics-resultado.json" -Encoding utf8

# --- comparacao byte-a-byte ---
$pairs = @(
    @{a="$inv/association-sonarqube.jsonl"; b="$check/association-sonarqube.jsonl"},
    @{a="$inv/association-pmd.jsonl"; b="$check/association-pmd.jsonl"},
    @{a="$inv/dedup-input-all.jsonl"; b="$check/dedup-input-all.jsonl"},
    @{a="$inv/dedup-results.jsonl"; b="$check/dedup-results.jsonl"},
    @{a="$inv/metrics-resultado.json"; b="$check/metrics-resultado.json"}
)
$allMatch = $true
$report = New-Object System.Collections.Generic.List[string]
foreach ($p in $pairs) {
    $h1 = (Get-FileHash $p.a -Algorithm SHA256).Hash
    $h2 = (Get-FileHash $p.b -Algorithm SHA256).Hash
    $match = $h1 -eq $h2
    if (-not $match) { $allMatch = $false }
    $report.Add("$($p.a) vs $($p.b): MATCH=$match")
}
$report.Add("REPROCESSAMENTO_DETERMINISTICO=$allMatch")
Set-Content -Path "$runDir/logs/reprocess-check-output.txt" -Value $report -Encoding utf8
Get-Content "$runDir/logs/reprocess-check-output.txt"
