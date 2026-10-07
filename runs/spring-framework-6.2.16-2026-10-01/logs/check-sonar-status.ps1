$ErrorActionPreference = "Stop"
$envLines = Get-Content .env
$url = ($envLines | Where-Object { $_ -match '^SONARQUBE_URL=' }) -replace '^SONARQUBE_URL=', ''
$token = (($envLines | Where-Object { $_ -match '^SONARQUBE_TOKEN=' }) -replace '^SONARQUBE_TOKEN=', '').Trim()
$headers = @{ Authorization = "Bearer $token" }
$project = "spring-framework-6-2-16"

$outFile = "runs/spring-framework-6.2.16-2026-10-01/logs/check-sonar-status-output.txt"
"=== ce/component (queue+history) ===" | Out-File -FilePath $outFile -Encoding utf8
try {
  $ce = Invoke-RestMethod -Uri "$url/api/ce/component?component=$project" -Headers $headers
  ($ce | ConvertTo-Json -Depth 6) | Out-File -FilePath $outFile -Append -Encoding utf8
} catch {
  "ERROR ce/component: $($_.Exception.Message)" | Out-File -FilePath $outFile -Append -Encoding utf8
}
Get-Content $outFile
