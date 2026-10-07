$ErrorActionPreference = "Stop"
Set-Location "c:\Users\gusta\Documents\gustavo\mestrado\tese\exp-mestrado"
$base = "runs\commons-lang-3.20.0-2026-10-01"
$reprocessDir = "$base\reprocess-check"
New-Item -ItemType Directory -Force -Path $reprocessDir | Out-Null

# 1) Reconstruir occurrences a partir dos relatorios brutos JA ARMAZENADOS
#    (sonarqube-issues.jsonl, pmd-output.txt) -- sem reexecutar sonar-scanner/pmd.
$sonarLines = Get-Content "$base\raw\sonarqube-issues.jsonl"
$outSonar = New-Object System.Collections.Generic.List[string]
$outSonar.Add("# relative_path,line,label (reprocessado a partir de sonarqube-issues.jsonl armazenado)")
foreach ($l in $sonarLines) {
    $o = $l | ConvertFrom-Json
    $rel = $o.component -replace '^apache-commons-lang-3-20-0:src/main/java/', ''
    $rule = $o.rule -replace '^java:', ''
    $outSonar.Add("$rel,$($o.line),sonar:$rule")
}
$outSonar | Set-Content -Encoding utf8 "$reprocessDir\occurrences-sonarqube.csv"

$pmdLines = Get-Content "$base\raw\pmd-output.txt"
$outPmd = New-Object System.Collections.Generic.List[string]
$outPmd.Add("# relative_path,line,label (reprocessado a partir de pmd-output.txt armazenado)")
foreach ($l in $pmdLines) {
    if ($l -match '^(.*?):(\d+):\s*(\S+):\s*(.*)$') {
        $path = $matches[1]
        $rel = ($path -replace [regex]::Escape('..\..\commons-lang-3.20.0\src\main\java\'), '') -replace '\\','/'
        $outPmd.Add("$rel,$($matches[2]),pmd:$($matches[3])")
    }
}
$outPmd | Set-Content -Encoding utf8 "$reprocessDir\occurrences-pmd.csv"

Write-Host "--- Diff occurrences-sonarqube.csv ---"
Compare-Object (Get-Content "$base\inventories\occurrences-sonarqube.csv") (Get-Content "$reprocessDir\occurrences-sonarqube.csv")
Write-Host "--- Diff occurrences-pmd.csv ---"
Compare-Object (Get-Content "$base\inventories\occurrences-pmd.csv") (Get-Content "$reprocessDir\occurrences-pmd.csv")
Write-Host "(sem saida acima = identico)"
