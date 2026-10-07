# Cria o projeto no SonarQube para o Quarkus 3.32.1 e associa o mesmo
# Quality Profile dos projetos anteriores (exp-mestrado-long-smells,
# somente java:S138 max=75 e java:S107 max=7).
$ErrorActionPreference = "Stop"

$envLines = Get-Content .env
$url = ($envLines | Where-Object { $_ -match '^SONARQUBE_URL=' }) -replace '^SONARQUBE_URL=', ''
$token = (($envLines | Where-Object { $_ -match '^SONARQUBE_TOKEN=' }) -replace '^SONARQUBE_TOKEN=', '').Trim()
$headers = @{ Authorization = "Bearer $token" }

$projectKey = "quarkus-3-32-1"
$projectName = "Quarkus 3.32.1"

$outFile = "runs/quarkus-3.32.1-2026-10-01/logs/create-sonar-project-output.txt"
"=== projects/create ===" | Out-File -FilePath $outFile -Encoding utf8
try {
    $body = @{ project = $projectKey; name = $projectName }
    $resp = Invoke-RestMethod -Method Post -Uri "$url/api/projects/create" -Headers $headers -Body $body
    ($resp | ConvertTo-Json -Depth 6) | Out-File -FilePath $outFile -Append -Encoding utf8
} catch {
    "ERROR projects/create: $($_.Exception.Message)" | Out-File -FilePath $outFile -Append -Encoding utf8
}

"=== qualityprofiles/add_project ===" | Out-File -FilePath $outFile -Append -Encoding utf8
try {
    $body2 = @{ project = $projectKey; qualityProfile = "exp-mestrado-long-smells"; language = "java" }
    Invoke-RestMethod -Method Post -Uri "$url/api/qualityprofiles/add_project" -Headers $headers -Body $body2
    "OK" | Out-File -FilePath $outFile -Append -Encoding utf8
} catch {
    "ERROR qualityprofiles/add_project: $($_.Exception.Message)" | Out-File -FilePath $outFile -Append -Encoding utf8
}

"=== qualityprofiles/search (confirmacao) ===" | Out-File -FilePath $outFile -Append -Encoding utf8
try {
    $qp = Invoke-RestMethod -Uri "$url/api/qualityprofiles/search?project=$projectKey" -Headers $headers
    ($qp | ConvertTo-Json -Depth 6) | Out-File -FilePath $outFile -Append -Encoding utf8
} catch {
    "ERROR qualityprofiles/search: $($_.Exception.Message)" | Out-File -FilePath $outFile -Append -Encoding utf8
}

Write-Output "DONE"
Get-Content $outFile
