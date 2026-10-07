$envLines = Get-Content .env
$url = ($envLines | Where-Object { $_ -match '^SONARQUBE_URL=' }) -replace '^SONARQUBE_URL=', ''
$token = (($envLines | Where-Object { $_ -match '^SONARQUBE_TOKEN=' }) -replace '^SONARQUBE_TOKEN=', '').Trim()
$headers = @{ Authorization = "Bearer $token" }

$outFile = "runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/check-sonar-status-output.txt"
"=== components/show ===" | Out-File -FilePath $outFile -Encoding utf8

try {
  $proj = Invoke-RestMethod -Uri "$url/api/components/show?component=hibernate-orm-7-2-6-final" -Headers $headers
  ($proj | ConvertTo-Json -Depth 6) | Out-File -FilePath $outFile -Append -Encoding utf8
} catch {
  "ERROR components/show: $($_.Exception.Message)" | Out-File -FilePath $outFile -Append -Encoding utf8
}

"=== ce/component (queue+history) ===" | Out-File -FilePath $outFile -Append -Encoding utf8
try {
  $ce = Invoke-RestMethod -Uri "$url/api/ce/component?component=hibernate-orm-7-2-6-final" -Headers $headers
  ($ce | ConvertTo-Json -Depth 6) | Out-File -FilePath $outFile -Append -Encoding utf8
} catch {
  "ERROR ce/component: $($_.Exception.Message)" | Out-File -FilePath $outFile -Append -Encoding utf8
}

"=== project_analyses/search ===" | Out-File -FilePath $outFile -Append -Encoding utf8
try {
  $analyses = Invoke-RestMethod -Uri "$url/api/project_analyses/search?project=hibernate-orm-7-2-6-final" -Headers $headers
  ($analyses | ConvertTo-Json -Depth 6) | Out-File -FilePath $outFile -Append -Encoding utf8
} catch {
  "ERROR project_analyses/search: $($_.Exception.Message)" | Out-File -FilePath $outFile -Append -Encoding utf8
}

"=== qualityprofiles assigned ===" | Out-File -FilePath $outFile -Append -Encoding utf8
try {
  $qp = Invoke-RestMethod -Uri "$url/api/qualityprofiles/search?project=hibernate-orm-7-2-6-final" -Headers $headers
  ($qp | ConvertTo-Json -Depth 6) | Out-File -FilePath $outFile -Append -Encoding utf8
} catch {
  "ERROR qualityprofiles/search: $($_.Exception.Message)" | Out-File -FilePath $outFile -Append -Encoding utf8
}

"DONE" | Out-File -FilePath $outFile -Append -Encoding utf8
