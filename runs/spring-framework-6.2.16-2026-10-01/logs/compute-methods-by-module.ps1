$ErrorActionPreference = "Stop"
$lines = Get-Content runs/spring-framework-6.2.16-2026-10-01/inventories/inventory-methods.jsonl
$counts = @{}
foreach ($l in $lines) {
    if ($l -match '"relative_path"\s*:\s*"([^"]+)"') {
        $rp = $matches[1]
        $module = $rp.Split('/')[0]
        if (-not $counts.ContainsKey($module)) { $counts[$module] = 0 }
        $counts[$module]++
    }
}
$counts.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object { "{0,6} : {1}" -f $_.Value, $_.Key } | Tee-Object -FilePath runs/spring-framework-6.2.16-2026-10-01/inventories/metodos-por-modulo-detalhado.txt
$total = ($counts.Values | Measure-Object -Sum).Sum
Write-Output "TOTAL=$total"
