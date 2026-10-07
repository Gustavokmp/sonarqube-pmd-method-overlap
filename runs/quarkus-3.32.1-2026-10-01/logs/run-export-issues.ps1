$ErrorActionPreference = "Stop"
$envLines = Get-Content .env
$env:SONARQUBE_URL = ($envLines | Where-Object { $_ -match '^SONARQUBE_URL=' }) -replace '^SONARQUBE_URL=', ''
$env:SONARQUBE_TOKEN = (($envLines | Where-Object { $_ -match '^SONARQUBE_TOKEN=' }) -replace '^SONARQUBE_TOKEN=', '').Trim()
./scripts/sonarqube/export-issues-paginated.ps1 -ProjectKey "quarkus-3-32-1" -Rules "java:S138,java:S107" -OutFile "runs/quarkus-3.32.1-2026-10-01/raw/sonarqube-issues.jsonl" *>&1 | Tee-Object -FilePath runs/quarkus-3.32.1-2026-10-01/logs/export-issues-output.txt
