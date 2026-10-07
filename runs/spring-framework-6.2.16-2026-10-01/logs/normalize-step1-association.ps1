# Normalizacao (secao 13/14) do Spring Framework: gera occurrences CSV para
# SonarQube e PMD a partir dos relatorios brutos ja preservados, roda
# Associator (AST) + Deduplicator (mesmas ferramentas validadas na secao 4,
# usadas no piloto e no Hibernate ORM), sem reexecutar sonar-scanner/pmd.
#
# Caso especial (MRJAR do spring-core): tanto o componente do SonarQube
# quanto o "name" de arquivo do PMD referenciam o caminho real do
# repositorio "spring-core/src/main/java21/...", que precisa ser mapeado
# para o relative_path "spring-core-java21/..." usado pelo inventario
# (mesma convencao de junction de "build-scope-staging.ps1").

$ErrorActionPreference = "Stop"
$runDir = "runs/spring-framework-6.2.16-2026-10-01"
$inv = "$runDir/inventories"
$project = "spring-framework-6.2.16"
$commit = "053d8e25f424bae9c5a597c4b248af137dce264f"

# --- 1. Staging (junctions) para o --root do Associator (mesmo esquema do inventario) ---
./runs/spring-framework-6.2.16-2026-10-01/logs/build-scope-staging.ps1 | Out-Null
$stageRoot = Join-Path $env:TEMP "spring-framework-scope-stage"

function Convert-ToRelativePath($rawPath) {
    $p = $rawPath -replace '\\', '/'
    if ($p -match '^spring-core/src/main/java21/(.*)$') {
        return "spring-core-java21/$($matches[1])"
    }
    return ($p -replace '/src/main/java/', '/')
}

# --- 2. Occurrences SonarQube ---
$sqIssues = Get-Content "$runDir/raw/sonarqube-issues.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$sqOccLines = New-Object System.Collections.Generic.List[string]
$sqAlertIds = New-Object System.Collections.Generic.List[string]
foreach ($i in $sqIssues) {
    # component: "<projectKey>:<modulo>/src/main/java[21]/<pacote>/Classe.java"
    $compPath = $i.component.Substring($i.component.IndexOf(':') + 1)
    $relPath = Convert-ToRelativePath $compPath
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
    # fname: ".../spring-framework-6.2.16/<modulo...>/src/main/java[21]/<pacote>/Classe.java"
    $afterRoot = $fname -replace '^.*spring-framework-6\.2\.16/', ''
    $relPath = Convert-ToRelativePath $afterRoot
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
