$ErrorActionPreference = "Stop"
$path = "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/inventory-methods.jsonl"
$lines = Get-Content $path
$modules = $lines | ForEach-Object { ($_ | ConvertFrom-Json).relative_path -split '/' | Select-Object -First 1 }
$summary = $modules | Group-Object | Sort-Object Count -Descending | ForEach-Object { "$($_.Name)`t$($_.Count)" }
$out = "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/metodos-por-modulo.txt"
"TOTAL_METODOS=$($lines.Count)" | Set-Content $out
$summary | Add-Content $out
Write-Output "DONE"
