$invIds = [System.Collections.Generic.HashSet[string]]::new()
$invLines = Get-Content "runs/commons-lang-3.20.0-2026-10-01/inventories/inventory-methods.jsonl"
foreach ($line in $invLines) {
    $o = $line | ConvertFrom-Json
    [void]$invIds.Add([string]$o.method_id)
}
$dedupIds = Get-Content "runs/commons-lang-3.20.0-2026-10-01/inventories/dedup-results.jsonl" | ForEach-Object { [string]($_ | ConvertFrom-Json).method_id }
$missing = @($dedupIds | Where-Object { -not $invIds.Contains($_) })
$lines = @(
    "INVENTORY_TOTAL=$($invIds.Count)",
    "A_UNION_B_SUBSET_OF_U_VIOLATIONS=$($missing.Count)"
)
Set-Content -Path "runs/commons-lang-3.20.0-2026-10-01/logs/invariantes-check.txt" -Value $lines -Encoding utf8
