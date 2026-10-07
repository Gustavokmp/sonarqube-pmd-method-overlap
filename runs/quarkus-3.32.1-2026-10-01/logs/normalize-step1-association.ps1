# Normalizacao (secao 13/14) do Quarkus: gera occurrences CSV para
# SonarQube e PMD a partir dos relatorios brutos ja preservados, roda
# Associator (AST) + Deduplicator (mesmas ferramentas validadas na secao 4,
# usadas no piloto, Hibernate ORM e Spring Framework), sem reexecutar
# sonar-scanner/pmd.
#
# Diferente do Hibernate/Spring: tanto o SonarQube quanto o PMD analisaram
# o MESMO diretorio de staging (junctions) usado pelo inventario de
# metodos, entao o "component" do SonarQube (relativo a
# sonar.projectBaseDir=staging) e o "name" de arquivo do PMD (apos remover
# o prefixo do staging) ja vem exatamente no mesmo formato do
# relative_path do inventario - sem necessidade de mapeamento de caminho
# especial (ex.: MRJAR do Spring).

$ErrorActionPreference = "Stop"
$runDir = "runs/quarkus-3.32.1-2026-10-01"
$inv = "$runDir/inventories"
$project = "quarkus"
$commit = "058b0b546fe033547d4d42afb7766a9e00b0329b"

# --- 1. Staging (junctions) para o --root do Associator (mesmo esquema do inventario) ---
./runs/quarkus-3.32.1-2026-10-01/logs/build-scope-staging.ps1 | Out-Null
$stageRoot = Join-Path $env:TEMP "quarkus-scope-stage"
$stageRootEscaped = [regex]::Escape($stageRoot + "\")

# --- 2. Occurrences SonarQube ---
$sqIssues = Get-Content "$runDir/raw/sonarqube-issues.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$sqOccLines = New-Object System.Collections.Generic.List[string]
$sqAlertIds = New-Object System.Collections.Generic.List[string]
foreach ($i in $sqIssues) {
    # component: "<projectKey>:<relative_path>" (ja relativo ao staging, igual ao inventario)
    $relPath = $i.component.Substring($i.component.IndexOf(':') + 1)
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
    $relPath = ($file.name -replace $stageRootEscaped, '') -replace '\\', '/'
    $viol = $file.violation
    if ($null -eq $viol) { continue }
    foreach ($v in @($viol)) {
        $pmdOccLines.Add("$relPath,$($v.beginline),pmd:$($v.rule)")
        $pmdAlertIds.Add("pmd::$relPath::$($v.beginline)::$($v.rule)")
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
