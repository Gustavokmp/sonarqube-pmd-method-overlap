$invIds = [System.Collections.Generic.HashSet[string]]::new()
$invLines = Get-Content "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/inventory-methods.jsonl"
foreach ($line in $invLines) {
    $o = $line | ConvertFrom-Json
    [void]$invIds.Add([string]$o.method_id)
}
$dedup = Get-Content "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/dedup-results.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$missingObjs = @($dedup | Where-Object { -not $invIds.Contains([string]$_.method_id) })
$sample = $missingObjs | Select-Object -First 10 -ExpandProperty method_id
Set-Content -Path "runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/invariantes-missing-sample.txt" -Value $sample -Encoding utf8
