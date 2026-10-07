$ErrorActionPreference = "Stop"
$envLines = Get-Content .env
$url = (($envLines | Where-Object { $_ -match '^SONARQUBE_URL=' }) -replace '^SONARQUBE_URL=', '').Trim()
$token = (($envLines | Where-Object { $_ -match '^SONARQUBE_TOKEN=' }) -replace '^SONARQUBE_TOKEN=', '').Trim()
$headers = @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Method Post -Uri "$url/api/projects/delete" -Headers $headers -Body @{ project = "exp-mestrado-s107-annotation-validation" }
Write-Output "PROJECT_DELETED"
