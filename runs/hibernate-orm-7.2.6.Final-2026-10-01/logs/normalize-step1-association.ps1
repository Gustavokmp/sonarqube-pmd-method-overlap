# Normalizacao (secao 13/14) do Hibernate ORM: gera occurrences CSV para
# SonarQube e PMD a partir dos relatorios brutos ja preservados, roda
# Associator (AST) + Deduplicator (mesmas ferramentas validadas na secao 4
# e usadas no piloto), sem reexecutar sonar-scanner/pmd.

$ErrorActionPreference = "Stop"
$runDir = "runs/hibernate-orm-7.2.6.Final-2026-10-01"
$inv = "$runDir/inventories"
$project = "hibernate-orm"
$commit = "c549a5c5a0bdd05cbda5105c4fa899b466be365c"

# --- 1. Staging (junctions) para o --root do Associator (mesmo esquema do inventario) ---
./runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/build-scope-staging.ps1 | Out-Null
$stageRoot = Join-Path $env:TEMP "hibernate-orm-scope-stage"

# --- 2. Occurrences SonarQube ---
$sqIssues = Get-Content "$runDir/raw/sonarqube-issues.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$sqOccLines = New-Object System.Collections.Generic.List[string]
$sqAlertIds = New-Object System.Collections.Generic.List[string]
foreach ($i in $sqIssues) {
    # component: "<projectKey>:<modulo>/src/main/java/<pacote>/Classe.java"
    $compPath = $i.component.Substring($i.component.IndexOf(':') + 1)
    $relPath = $compPath -replace '/src/main/java/', '/'
    $ruleShort = $i.rule -replace '^java:', ''
    $sqOccLines.Add("$relPath,$($i.line),sonar:$ruleShort")
    $sqAlertIds.Add($i.key)
}
Set-Content -Path "$inv/occurrences-sonarqube.csv" -Value $sqOccLines -Encoding UTF8
Set-Content -Path "$runDir/logs/raw-alert-ids-sonarqube.txt" -Value $sqAlertIds -Encoding UTF8
Write-Output "SONARQUBE_OCCURRENCES=$($sqOccLines.Count)"

# --- 3. Occurrences PMD ---
[xml]$pmdXml = Get-Content "$runDir/raw/pmd-output.xml" -Raw
$pmdOccLines = New-Object System.Collections.Generic.List[string]
$pmdAlertIds = New-Object System.Collections.Generic.List[string]
foreach ($file in $pmdXml.pmd.file) {
    $fname = $file.name -replace '\\', '/'
    # fname: "sources/hibernate-orm-7.2.6.Final/<modulo...>/src/main/java/<pacote>/Classe.java"
    $relPath = $fname -replace '^.*?src/main/java/', ''
    # precisamos do prefixo do modulo (ex.: hibernate-core, tooling/metamodel-generator)
    $modPart = $fname -replace '/src/main/java/.*$', '' -replace '^.*hibernate-orm-7\.2\.6\.Final/', ''
    $fullRel = "$modPart/$relPath"
    $viol = $file.violation
    if ($null -eq $viol) { continue }
    foreach ($v in @($viol)) {
        $pmdOccLines.Add("$fullRel,$($v.beginline),pmd:$($v.rule)")
        $pmdAlertIds.Add("pmd::$fullRel::$($v.beginline)::$($v.rule)")
    }
}
Set-Content -Path "$inv/occurrences-pmd.csv" -Value $pmdOccLines -Encoding UTF8
Set-Content -Path "$runDir/logs/raw-alert-ids-pmd.txt" -Value $pmdAlertIds -Encoding UTF8
Write-Output "PMD_OCCURRENCES=$($pmdOccLines.Count)"

# --- 4. Associator ---
Push-Location scripts/method-inventory
try {
    & java -cp "out;lib/javaparser-core-3.28.2.jar" Associator `
        --project $project --commit $commit --root $stageRoot `
        --occurrences "../../$inv/occurrences-sonarqube.csv" `
        --out "../../$inv/association-sonarqube.jsonl"

    & java -cp "out;lib/javaparser-core-3.28.2.jar" Associator `
        --project $project --commit $commit --root $stageRoot `
        --occurrences "../../$inv/occurrences-pmd.csv" `
        --out "../../$inv/association-pmd.jsonl"
} finally {
    Pop-Location
}
Write-Output "ASSOCIATION_SONARQUBE=$((Get-Content "$inv/association-sonarqube.jsonl" | Measure-Object -Line).Lines)"
Write-Output "ASSOCIATION_PMD=$((Get-Content "$inv/association-pmd.jsonl" | Measure-Object -Line).Lines)"
