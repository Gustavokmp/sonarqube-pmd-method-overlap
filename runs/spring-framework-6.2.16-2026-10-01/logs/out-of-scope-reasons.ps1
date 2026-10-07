$ErrorActionPreference = "Stop"
$inv = "runs/spring-framework-6.2.16-2026-10-01/inventories"
foreach ($tool in @("sonarqube", "pmd")) {
    $lines = Get-Content "$inv/association-$tool.jsonl"
    $counts = @{}
    foreach ($l in $lines) {
        if ($l -match '"status"\s*:\s*"out_of_scope"') {
            if ($l -match '"reason"\s*:\s*"([^"]*)"') {
                $r = $matches[1]
            } else { $r = "(sem reason)" }
            if (-not $counts.ContainsKey($r)) { $counts[$r] = 0 }
            $counts[$r]++
        }
    }
    Write-Output "=== $tool out_of_scope reasons ==="
    $counts.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object { "{0,6} : {1}" -f $_.Value, $_.Name }
}
