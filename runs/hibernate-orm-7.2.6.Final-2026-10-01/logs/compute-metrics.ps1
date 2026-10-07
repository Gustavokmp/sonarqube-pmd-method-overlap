$d = Get-Content "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/dedup-results.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$U = 48102

function Compute-Metrics($smell) {
    $A = [System.Collections.Generic.HashSet[string]]::new()
    $B = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($r in $d) {
        if ($r.smell -ne $smell) { continue }
        if ($r.tool -eq 'sonarqube') { [void]$A.Add([string]$r.method_id) }
        if ($r.tool -eq 'pmd') { [void]$B.Add([string]$r.method_id) }
    }
    $inter = [System.Collections.Generic.HashSet[string]]::new($A)
    $inter.IntersectWith($B)
    $union = [System.Collections.Generic.HashSet[string]]::new($A)
    $union.UnionWith($B)
    $sonarOnly = $A.Count - $inter.Count
    $pmdOnly = $B.Count - $inter.Count
    $jaccard = if ($union.Count -eq 0) { "N/A" } else { [math]::Round(($inter.Count / $union.Count), 4).ToString("F4", [System.Globalization.CultureInfo]::InvariantCulture) }
    $sonarPct = ($A.Count / $U * 100).ToString("F4", [System.Globalization.CultureInfo]::InvariantCulture)
    $pmdPct = ($B.Count / $U * 100).ToString("F4", [System.Globalization.CultureInfo]::InvariantCulture)
    [PSCustomObject]@{
        smell = $smell
        U = $U
        A = $A.Count
        B = $B.Count
        sonarPct = $sonarPct
        pmdPct = $pmdPct
        intersection = $inter.Count
        sonarOnly = $sonarOnly
        pmdOnly = $pmdOnly
        union = $union.Count
        jaccard = $jaccard
    }
}

$lm = Compute-Metrics "long_method"
$lp = Compute-Metrics "long_parameter_list"

$result = @{ long_method = $lm; long_parameter_list = $lp }
$result | ConvertTo-Json -Depth 5 | Set-Content -Path "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/metrics-resultado.json" -Encoding utf8

$lines = @(
    "LONG_METHOD: U=$($lm.U) A=$($lm.A) B=$($lm.B) sonarPct=$($lm.sonarPct) pmdPct=$($lm.pmdPct) inter=$($lm.intersection) sonarOnly=$($lm.sonarOnly) pmdOnly=$($lm.pmdOnly) union=$($lm.union) jaccard=$($lm.jaccard)",
    "LONG_PARAMETER_LIST: U=$($lp.U) A=$($lp.A) B=$($lp.B) sonarPct=$($lp.sonarPct) pmdPct=$($lp.pmdPct) inter=$($lp.intersection) sonarOnly=$($lp.sonarOnly) pmdOnly=$($lp.pmdOnly) union=$($lp.union) jaccard=$($lp.jaccard)"
)
Set-Content -Path "runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/metrics-summary.txt" -Value $lines -Encoding utf8
