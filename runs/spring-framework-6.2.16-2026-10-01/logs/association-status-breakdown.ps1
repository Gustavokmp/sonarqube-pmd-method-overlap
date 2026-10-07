$ErrorActionPreference = "Stop"
$inv = "runs/spring-framework-6.2.16-2026-10-01/inventories"
foreach ($tool in @("sonarqube", "pmd")) {
    $lines = Get-Content "$inv/association-$tool.jsonl"
    $counts = @{}
    foreach ($l in $lines) {
        if ($l -match '"status"\s*:\s*"([^"]+)"') {
            $s = $matches[1]
            if (-not $counts.ContainsKey($s)) { $counts[$s] = 0 }
            $counts[$s]++
        }
    }
    Write-Output "=== $tool ==="
    $counts.GetEnumerator() | Sort-Object Name | ForEach-Object { "{0,6} : {1}" -f $_.Value, $_.Name }
}
