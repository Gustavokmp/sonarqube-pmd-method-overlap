$invIds = [System.Collections.Generic.HashSet[string]]::new()
$invLines = Get-Content "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/inventory-methods.jsonl"
foreach ($line in $invLines) {
    $o = $line | ConvertFrom-Json
    [void]$invIds.Add([string]$o.method_id)
}
$dedupIds = Get-Content "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/dedup-results.jsonl" | ForEach-Object { [string]($_ | ConvertFrom-Json).method_id }
$missing = @($dedupIds | Where-Object { -not $invIds.Contains($_) })
$noDup = ($invIds.Count -eq $invLines.Count)
$lines = @(
    "INVENTORY_TOTAL=$($invIds.Count)",
    "INVENTORY_LINES=$($invLines.Count)",
    "NO_DUPLICATE_METHOD_IDS=$noDup",
    "A_UNION_B_SUBSET_OF_U_VIOLATIONS=$($missing.Count)"
)
Set-Content -Path "runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/invariantes-check.txt" -Value $lines -Encoding utf8
