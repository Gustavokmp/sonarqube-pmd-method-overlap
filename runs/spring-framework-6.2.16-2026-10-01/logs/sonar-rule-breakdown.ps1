$ErrorActionPreference = "Stop"
$lines = Get-Content runs/spring-framework-6.2.16-2026-10-01/raw/sonarqube-issues.jsonl
$s138 = ($lines | Select-String '"rule":"java:S138"').Count
$s107 = ($lines | Select-String '"rule":"java:S107"').Count
Write-Output "S138=$s138 S107=$s107 TOTAL=$($lines.Count)"
