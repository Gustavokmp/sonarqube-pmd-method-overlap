$ErrorActionPreference = "Stop"
$c = Get-Content runs/spring-framework-6.2.16-2026-10-01/logs/pmd-output.txt -Encoding Unicode
Write-Output "--- Found ---"
$c | Select-String "Found"
Write-Output "--- EXITCODE ---"
$c | Select-String "EXITCODE"
Write-Output "--- Error (first 15) ---"
$c | Select-String "Error" | Select-Object -First 15
