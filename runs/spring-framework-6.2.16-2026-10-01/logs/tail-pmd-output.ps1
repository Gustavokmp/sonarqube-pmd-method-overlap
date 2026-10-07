$ErrorActionPreference = "Stop"
$c = Get-Content runs/spring-framework-6.2.16-2026-10-01/logs/pmd-output.txt -Encoding Unicode
Write-Output "TOTAL_LINES=$($c.Count)"
$c | Select-Object -Last 15
