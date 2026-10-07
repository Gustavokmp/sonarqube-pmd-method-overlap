<#
Atividade 2 (analise complementar pos-protocolo) - PROTOCOLO.md nao e
alterado. Recalcula as metricas de Long Method / Long Parameter List do
Hibernate ORM 7.2.6.Final restritas a U_common = metodos elegiveis
pertencentes a arquivos processados com SUCESSO pelas 3 ferramentas
(SonarQube, PMD, JavaParser), reaproveitando os artefatos ja gerados
(inventory-methods.jsonl, dedup-results.jsonl, falhas-parsing.txt,
falhas-processamento-pmd.txt) sem reexecutar SonarQube/PMD. Formulas
identicas a Metrics.java (PROTOCOLO.md secao 15).
#>
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\")).Path
$runDir = Join-Path $repoRoot "runs\hibernate-orm-7.2.6.Final-2026-10-01\inventories"
$outDir = Join-Path $repoRoot "results\analises-complementares"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# SonarQube processou 6605/6605 (100%) - nenhum arquivo excluido por este motivo.
# JavaParser: 1 falha de parsing (falhas-parsing.txt).
# PMD: 4 falhas de processamento (falhas-processamento-pmd.txt).
$excludedFiles = New-Object System.Collections.Generic.HashSet[string]
[void]$excludedFiles.Add("hibernate-core/org/hibernate/dialect/Dialect.java")
[void]$excludedFiles.Add("hibernate-envers/org/hibernate/envers/boot/model/Attribute.java")
[void]$excludedFiles.Add("hibernate-envers/org/hibernate/envers/boot/model/Column.java")
[void]$excludedFiles.Add("hibernate-envers/org/hibernate/envers/boot/model/Key.java")
[void]$excludedFiles.Add("hibernate-envers/org/hibernate/envers/boot/model/TypeSpecification.java")

# --- Universo (U) ---
$inventoryLines = Get-Content (Join-Path $runDir "inventory-methods.jsonl")
$allMethods = New-Object System.Collections.Generic.List[object]
foreach ($line in $inventoryLines) {
    if ($line.Trim().Length -eq 0) { continue }
    $allMethods.Add(($line | ConvertFrom-Json))
}

$uOriginalIds = New-Object System.Collections.Generic.HashSet[string]
$uCommonIds = New-Object System.Collections.Generic.HashSet[string]
$removedMethodsCount = 0
foreach ($m in $allMethods) {
    [void]$uOriginalIds.Add($m.method_id)
    if ($excludedFiles.Contains($m.relative_path)) {
        $removedMethodsCount++
    } else {
        [void]$uCommonIds.Add($m.method_id)
    }
}

# --- Alertas (A = sonarqube, B = pmd), ja normalizados/deduplicados ---
$dedupLines = Get-Content (Join-Path $runDir "dedup-results.jsonl")
$alerts = New-Object System.Collections.Generic.List[object]
foreach ($line in $dedupLines) {
    if ($line.Trim().Length -eq 0) { continue }
    $alerts.Add(($line | ConvertFrom-Json))
}

function Get-Set($smell, $tool, $universeIds) {
    $set = New-Object System.Collections.Generic.HashSet[string]
    foreach ($a in $alerts) {
        if ($a.smell -eq $smell -and $a.tool -eq $tool -and $universeIds.Contains($a.method_id)) {
            [void]$set.Add($a.method_id)
        }
    }
    Write-Output -NoEnumerate $set
}

function Copy-Set($source) {
    $copy = New-Object System.Collections.Generic.HashSet[string]
    foreach ($item in $source) { [void]$copy.Add($item) }
    Write-Output -NoEnumerate $copy
}

function Compute-Metrics($universeIds, $sonarSet, $pmdSet) {
    $u = $universeIds.Count
    $a = $sonarSet.Count
    $b = $pmdSet.Count

    $intersection = Copy-Set $sonarSet
    $intersection.IntersectWith([string[]]$pmdSet)

    $union = Copy-Set $sonarSet
    foreach ($item in $pmdSet) { [void]$union.Add($item) }

    $onlySonar = Copy-Set $sonarSet
    $onlySonar.ExceptWith([string[]]$pmdSet)

    $onlyPmd = Copy-Set $pmdSet
    $onlyPmd.ExceptWith([string[]]$sonarSet)

    if ($u -eq 0) {
        $sonarPct = "N/A"; $pmdPct = "N/A"
    } else {
        $sonarPct = (100.0 * $a / $u).ToString("F4", [System.Globalization.CultureInfo]::InvariantCulture)
        $pmdPct = (100.0 * $b / $u).ToString("F4", [System.Globalization.CultureInfo]::InvariantCulture)
    }

    if ($union.Count -eq 0) {
        $jaccard = "N/A"
    } elseif ($a -eq 0 -or $b -eq 0) {
        $jaccard = (0.0).ToString("F4", [System.Globalization.CultureInfo]::InvariantCulture)
    } else {
        $jaccard = (1.0 * $intersection.Count / $union.Count).ToString("F4", [System.Globalization.CultureInfo]::InvariantCulture)
    }

    return [ordered]@{
        U = $u; A = $a; B = $b
        sonarPct = $sonarPct; pmdPct = $pmdPct
        intersection = $intersection.Count
        sonarOnly = $onlySonar.Count
        pmdOnly = $onlyPmd.Count
        union = $union.Count
        jaccard = $jaccard
    }
}

$result = [ordered]@{}
$impactPerSmell = [ordered]@{}
foreach ($smell in @("long_method", "long_parameter_list")) {
    $sonarOrig = Get-Set $smell "sonarqube" $uOriginalIds
    $pmdOrig = Get-Set $smell "pmd" $uOriginalIds
    $sonarCommon = Get-Set $smell "sonarqube" $uCommonIds
    $pmdCommon = Get-Set $smell "pmd" $uCommonIds

    $result[$smell] = [ordered]@{
        original = Compute-Metrics $uOriginalIds $sonarOrig $pmdOrig
        u_common = Compute-Metrics $uCommonIds $sonarCommon $pmdCommon
    }
    $impactPerSmell[$smell] = [ordered]@{
        sonar_alerts_removed = ($sonarOrig.Count - $sonarCommon.Count)
        pmd_alerts_removed = ($pmdOrig.Count - $pmdCommon.Count)
    }
}

$summary = [ordered]@{
    excluded_files = @($excludedFiles)
    excluded_files_count = $excludedFiles.Count
    excluded_methods_count = $removedMethodsCount
    impact_per_smell = $impactPerSmell
    metrics = $result
}

$jsonOut = Join-Path $outDir "hibernate-common-coverage-sensitivity.json"
$summary | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonOut -Encoding UTF8

$csvOut = Join-Path $outDir "hibernate-common-coverage-sensitivity.csv"
$csvRows = New-Object System.Collections.Generic.List[object]
foreach ($smell in $result.Keys) {
    foreach ($variant in @("original", "u_common")) {
        $m = $result[$smell][$variant]
        $csvRows.Add([pscustomobject]@{
            smell = $smell; variant = $variant
            U = $m.U; A = $m.A; B = $m.B
            sonarPct = $m.sonarPct; pmdPct = $m.pmdPct
            intersection = $m.intersection; sonarOnly = $m.sonarOnly; pmdOnly = $m.pmdOnly
            union = $m.union; jaccard = $m.jaccard
        })
    }
}
$csvRows | Export-Csv -Path $csvOut -NoTypeInformation -Encoding UTF8

Write-Host "EXCLUDED_FILES=$($excludedFiles.Count)"
Write-Host "EXCLUDED_METHODS=$removedMethodsCount"
($summary | ConvertTo-Json -Depth 10)
