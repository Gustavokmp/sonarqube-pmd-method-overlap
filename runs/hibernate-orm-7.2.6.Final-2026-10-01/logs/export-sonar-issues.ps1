$envLines = Get-Content .env
$env:SONARQUBE_URL = (($envLines | Where-Object { $_ -match '^SONARQUBE_URL=' }) -replace '^SONARQUBE_URL=', '').Trim()
$env:SONARQUBE_TOKEN = (($envLines | Where-Object { $_ -match '^SONARQUBE_TOKEN=' }) -replace '^SONARQUBE_TOKEN=', '').Trim()

./scripts/sonarqube/export-issues-paginated.ps1 `
  -ProjectKey "hibernate-orm-7-2-6-final" `
  -Rules "java:S138,java:S107" `
  -OutFile "runs/hibernate-orm-7.2.6.Final-2026-10-01/raw/sonarqube-issues.jsonl" `
  *>&1 | Out-File -FilePath "runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/export-issues-output.txt" -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath "runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/export-issues-output.txt" -Append -Encoding utf8
