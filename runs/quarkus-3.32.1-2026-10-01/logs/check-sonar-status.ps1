# Faz polling do status da tarefa do Compute Engine do SonarQube ate
# SUCCESS/FAILED ou um deadline, em vez de Start-Sleep solto.
$ErrorActionPreference = "Stop"

$envLines = Get-Content .env
$url = ($envLines | Where-Object { $_ -match '^SONARQUBE_URL=' }) -replace '^SONARQUBE_URL=', ''
$token = (($envLines | Where-Object { $_ -match '^SONARQUBE_TOKEN=' }) -replace '^SONARQUBE_TOKEN=', '').Trim()
$headers = @{ Authorization = "Bearer $token" }

$taskId = "263a7ceb-7b9d-472e-b39f-261d34a44074"
$outFile = "runs/quarkus-3.32.1-2026-10-01/logs/check-sonar-status-output.txt"

$deadline = (Get-Date).AddMinutes(15)
$status = "IN_PROGRESS"
while ((Get-Date) -lt $deadline) {
    $resp = Invoke-RestMethod -Uri "$url/api/ce/task?id=$taskId" -Headers $headers
    $status = $resp.task.status
    if ($status -eq "SUCCESS" -or $status -eq "FAILED" -or $status -eq "CANCELED") {
        break
    }
    Start-Sleep -Seconds 15
}
($resp | ConvertTo-Json -Depth 6) | Out-File -FilePath $outFile -Encoding utf8
Write-Output "FINAL_STATUS=$status"
