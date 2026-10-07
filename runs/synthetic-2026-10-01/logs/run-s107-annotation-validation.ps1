# Atividade 3 (analise complementar pos-protocolo): valida experimentalmente
# se as excecoes nativas de java:S107 (TooManyParametersCheck) continuam
# sendo reconhecidas no MESMO ambiente do experimento (mesmo SonarQube,
# mesmo SonarScanner, mesmo Quality Profile exp-mestrado-long-smells),
# SEM sonar.java.libraries (como nas 4 execucoes reais). Fixture isolada em
# scripts/fixtures/s107-annotations/, nao faz parte dos 4 projetos
# estudados. Projeto efemero criado e removido ao final (nao e um projeto
# do experimento).
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\")).Path
Set-Location $repoRoot

$envLines = Get-Content .env
$url = (($envLines | Where-Object { $_ -match '^SONARQUBE_URL=' }) -replace '^SONARQUBE_URL=', '').Trim()
$token = (($envLines | Where-Object { $_ -match '^SONARQUBE_TOKEN=' }) -replace '^SONARQUBE_TOKEN=', '').Trim()
$headers = @{ Authorization = "Bearer $token" }

$projectKey = "exp-mestrado-s107-annotation-validation"
$projectName = "exp-mestrado S107 annotation validation (fixture sintetica)"
$fixtureDir = Join-Path $repoRoot "scripts\fixtures\s107-annotations"
$outDir = Join-Path $repoRoot "runs\synthetic-2026-10-01"
$logFile = Join-Path $outDir "logs\s107-annotation-validation-output.txt"

"=== projects/create ===" | Out-File -FilePath $logFile -Encoding utf8
try {
    $body = @{ project = $projectKey; name = $projectName }
    $resp = Invoke-RestMethod -Method Post -Uri "$url/api/projects/create" -Headers $headers -Body $body
    ($resp | ConvertTo-Json -Depth 6) | Out-File -FilePath $logFile -Append -Encoding utf8
} catch {
    "ERROR projects/create: $($_.Exception.Message)" | Out-File -FilePath $logFile -Append -Encoding utf8
}

"=== qualityprofiles/add_project ===" | Out-File -FilePath $logFile -Append -Encoding utf8
try {
    $body2 = @{ project = $projectKey; qualityProfile = "exp-mestrado-long-smells"; language = "java" }
    Invoke-RestMethod -Method Post -Uri "$url/api/qualityprofiles/add_project" -Headers $headers -Body $body2
    "OK" | Out-File -FilePath $logFile -Append -Encoding utf8
} catch {
    "ERROR qualityprofiles/add_project: $($_.Exception.Message)" | Out-File -FilePath $logFile -Append -Encoding utf8
}

"=== sonar-scanner ===" | Out-File -FilePath $logFile -Append -Encoding utf8
Push-Location $fixtureDir
try {
    $scanner = Join-Path $repoRoot "sources\sonar-scanner-8.1.0.6389-windows-x64\bin\sonar-scanner.bat"
    & $scanner `
        "-Dsonar.projectKey=$projectKey" `
        "-Dsonar.projectName=$projectName" `
        "-Dsonar.sources=." `
        "-Dsonar.host.url=$url" `
        "-Dsonar.token=$token" `
        "-Dsonar.java.binaries=." `
        "-Dsonar.sourceEncoding=UTF-8" *> (Join-Path $outDir "raw\s107-annotation-validation-scanner-output.txt")
    "EXITCODE=$LASTEXITCODE" | Out-File -FilePath $logFile -Append -Encoding utf8
} finally {
    Pop-Location
}

Write-Output "DONE_SCAN"
