$ErrorActionPreference = "Stop"
Set-Location "c:\Users\gusta\Documents\gustavo\mestrado\tese\exp-mestrado"

$universeList = Get-Content runs\commons-lang-3.20.0-2026-10-01\inventories\inventory-methods.jsonl | ForEach-Object { ($_ | ConvertFrom-Json).method_id }
$universe = New-Object System.Collections.Generic.HashSet[string]
foreach ($x in $universeList) { [void]$universe.Add($x) }
Write-Host "universe_size=$($universe.Count)"

$dedup = Get-Content runs\commons-lang-3.20.0-2026-10-01\inventories\dedup-results.jsonl | ForEach-Object { $_ | ConvertFrom-Json }

function Compute-Metrics($smell) {
    $a = $dedup | Where-Object { $_.tool -eq "sonarqube" -and $_.smell -eq $smell } | ForEach-Object { $_.method_id }
    $b = $dedup | Where-Object { $_.tool -eq "pmd" -and $_.smell -eq $smell } | ForEach-Object { $_.method_id }
    if ($null -eq $a) { $a = @() }
    if ($null -eq $b) { $b = @() }
    $aSet = New-Object System.Collections.Generic.HashSet[string]
    foreach ($x in $a) { [void]$aSet.Add($x) }
    $bSet = New-Object System.Collections.Generic.HashSet[string]
    foreach ($x in $b) { [void]$bSet.Add($x) }
    $inter = New-Object System.Collections.Generic.HashSet[string]($aSet)
    $inter.IntersectWith($bSet)
    $union = New-Object System.Collections.Generic.HashSet[string]($aSet)
    $union.UnionWith($bSet)
    $onlyA = New-Object System.Collections.Generic.HashSet[string]($aSet)
    $onlyA.ExceptWith($bSet)
    $onlyB = New-Object System.Collections.Generic.HashSet[string]($bSet)
    $onlyB.ExceptWith($aSet)

    $u = $universe.Count
    $ic = [System.Globalization.CultureInfo]::InvariantCulture
    $percentSonar = if ($u -eq 0) { "N/A" } else { (100.0 * $aSet.Count / $u).ToString("F4", $ic) }
    $percentPmd = if ($u -eq 0) { "N/A" } else { (100.0 * $bSet.Count / $u).ToString("F4", $ic) }
    $jaccard = if ($union.Count -eq 0) { "N/A" } elseif ($aSet.Count -eq 0 -or $bSet.Count -eq 0) { (0.0).ToString("F4", $ic) } else { (1.0 * $inter.Count / $union.Count).ToString("F4", $ic) }

    [pscustomobject]@{
        smell = $smell
        U = $u
        A = $aSet.Count
        B = $bSet.Count
        PercentSonar = $percentSonar
        PercentPmd = $percentPmd
        Intersection = $inter.Count
        OnlySonar = $onlyA.Count
        OnlyPmd = $onlyB.Count
        Union = $union.Count
        Jaccard = $jaccard
    }
}

$resultLM = Compute-Metrics "long_method"
$resultLPL = Compute-Metrics "long_parameter_list"
$resultLM, $resultLPL | Format-Table -AutoSize | Out-String | Write-Host
$resultLM, $resultLPL | ConvertTo-Json | Set-Content -Encoding utf8 runs\commons-lang-3.20.0-2026-10-01\inventories\metrics-resultado.json
