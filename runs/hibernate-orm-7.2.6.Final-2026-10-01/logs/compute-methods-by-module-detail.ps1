$ErrorActionPreference = "Stop"
$path = "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/inventory-methods.jsonl"
$lines = Get-Content $path
$modules = $lines | ForEach-Object {
    $rp = ($_ | ConvertFrom-Json).relative_path
    $parts = $rp -split '/'
    if ($parts[0] -eq 'tooling') { "$($parts[0])/$($parts[1])" } else { $parts[0] }
}
$summary = $modules | Group-Object | Sort-Object Count -Descending | ForEach-Object { "$($_.Name)`t$($_.Count)" }
$out = "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/metodos-por-modulo-detalhado.txt"
"TOTAL_METODOS=$($lines.Count)" | Set-Content $out
$summary | Add-Content $out
Write-Output "DONE"
