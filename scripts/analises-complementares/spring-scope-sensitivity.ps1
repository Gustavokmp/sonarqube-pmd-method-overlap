<#
Atividade 1 (analise complementar pos-protocolo) - PROTOCOLO.md nao e
alterado. Recalcula as metricas de Long Method / Long Parameter List do
Spring Framework 6.2.16 excluindo os modulos spring-test/ e
spring-core-test/ do universo de metodos elegiveis (U) e dos conjuntos
sinalizados (A = SonarQube, B = PMD), reaproveitando os artefatos ja
gerados (inventory-methods.jsonl, dedup-results.jsonl) sem reexecutar
SonarQube/PMD. Formulas identicas a Metrics.java (PROTOCOLO.md secao 15).
#>
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\")).Path
$runDir = Join-Path $repoRoot "runs\spring-framework-6.2.16-2026-10-01\inventories"
$outDir = Join-Path $repoRoot "results\analises-complementares"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$excludedPrefixes = @("spring-test/", "spring-core-test/")

function Test-Excluded($relativePath) {
    foreach ($p in $excludedPrefixes) {
        if ($relativePath.StartsWith($p)) { return $true }
    }
    return $false
}

# --- Universo (U) ---
$inventoryLines = Get-Content (Join-Path $runDir "inventory-methods.jsonl")
$allMethods = New-Object System.Collections.Generic.List[object]
foreach ($line in $inventoryLines) {
    if ($line.Trim().Length -eq 0) { continue }
    $allMethods.Add(($line | ConvertFrom-Json))
}

$uOriginalIds = New-Object System.Collections.Generic.HashSet[string]
$uFilteredIds = New-Object System.Collections.Generic.HashSet[string]
$excludedFiles = New-Object System.Collections.Generic.HashSet[string]
foreach ($m in $allMethods) {
    [void]$uOriginalIds.Add($m.method_id)
    if (Test-Excluded $m.relative_path) {
        [void]$excludedFiles.Add($m.relative_path)
    } else {
        [void]$uFilteredIds.Add($m.method_id)
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
foreach ($smell in @("long_method", "long_parameter_list")) {
    $sonarOrig = Get-Set $smell "sonarqube" $uOriginalIds
    $pmdOrig = Get-Set $smell "pmd" $uOriginalIds
    $sonarFiltered = Get-Set $smell "sonarqube" $uFilteredIds
    $pmdFiltered = Get-Set $smell "pmd" $uFilteredIds

    $result[$smell] = [ordered]@{
        original = Compute-Metrics $uOriginalIds $sonarOrig $pmdOrig
        filtered_excluding_spring_test = Compute-Metrics $uFilteredIds $sonarFiltered $pmdFiltered
    }
}

$summary = [ordered]@{
    excluded_module_prefixes = $excludedPrefixes
    excluded_files_count = $excludedFiles.Count
    excluded_methods_count = ($uOriginalIds.Count - $uFilteredIds.Count)
    metrics = $result
}

$jsonOut = Join-Path $outDir "spring-scope-sensitivity.json"
$summary | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonOut -Encoding UTF8

$csvOut = Join-Path $outDir "spring-scope-sensitivity.csv"
$csvRows = New-Object System.Collections.Generic.List[object]
foreach ($smell in $result.Keys) {
    foreach ($variant in @("original", "filtered_excluding_spring_test")) {
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
Write-Host "EXCLUDED_METHODS=$($uOriginalIds.Count - $uFilteredIds.Count)"
($summary | ConvertTo-Json -Depth 10)
