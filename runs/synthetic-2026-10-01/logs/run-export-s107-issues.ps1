$ErrorActionPreference = "Stop"
$envLines = Get-Content .env
$env:SONARQUBE_URL = (($envLines | Where-Object { $_ -match '^SONARQUBE_URL=' }) -replace '^SONARQUBE_URL=', '').Trim()
$env:SONARQUBE_TOKEN = (($envLines | Where-Object { $_ -match '^SONARQUBE_TOKEN=' }) -replace '^SONARQUBE_TOKEN=', '').Trim()
./scripts/sonarqube/export-issues-paginated.ps1 -ProjectKey "exp-mestrado-s107-annotation-validation" -Rules "java:S107" -OutFile "runs/synthetic-2026-10-01/raw/sonarqube-issues-s107-annotation-validation.jsonl" *>&1 | Tee-Object -FilePath runs/synthetic-2026-10-01/logs/export-issues-s107-annotation-validation-output.txt
