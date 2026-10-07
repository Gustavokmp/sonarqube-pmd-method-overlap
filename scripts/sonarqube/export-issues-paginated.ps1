param(
    [string]$ProjectKey = "exp-mestrado-pagination-fixtures",
    [string]$Rules = "java:S138,java:S107",
    [string]$OutFile = "runs/synthetic-2026-10-01/raw/sonarqube-issues-pagination.jsonl"
)

<#
Exporta TODOS os issues de um componente SonarQube, paginando pela API
/api/issues/search ate que a soma de itens coletados seja igual ao
paging.total informado pela API (PROTOCOLO.md secao 11: "exportar TODOS os
issues com suporte a paginacao; verificar total exportado vs total
reportado pela API").

Uso:
  ./export-issues-paginated.ps1 -ProjectKey <key> -Rules <rule1,rule2> -OutFile <saida.jsonl>

Requer SONARQUBE_URL e SONARQUBE_TOKEN definidos no ambiente (carregados de .env).
#>

$ErrorActionPreference = "Stop"

if (-not $env:SONARQUBE_URL -or -not $env:SONARQUBE_TOKEN) {
    throw "SONARQUBE_URL / SONARQUBE_TOKEN nao definidos no ambiente. Carregue o .env antes."
}

$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($env:SONARQUBE_TOKEN):"))
$headers = @{ Authorization = "Basic $auth" }

$pageSize = 100
$page = 1
$collected = New-Object System.Collections.Generic.List[object]
$reportedTotal = $null

do {
    $uri = "$($env:SONARQUBE_URL)/api/issues/search?componentKeys=$ProjectKey&rules=$Rules&ps=$pageSize&p=$page"
    $resp = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers

    if ($null -eq $reportedTotal) {
        $reportedTotal = $resp.paging.total
    } elseif ($resp.paging.total -ne $reportedTotal) {
        throw "paging.total mudou entre paginas ($reportedTotal -> $($resp.paging.total)); dados instaveis durante a exportacao"
    }

    foreach ($issue in $resp.issues) {
        $collected.Add($issue)
    }

    Write-Host "pagina $page/$([Math]::Ceiling($reportedTotal / $pageSize)): $($resp.issues.Count) issues (acumulado: $($collected.Count)/$reportedTotal)"
    $page++
} while ($collected.Count -lt $reportedTotal)

New-Item -ItemType Directory -Force -Path (Split-Path $OutFile) | Out-Null
$collected | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 10 } | Set-Content -Path $OutFile -Encoding UTF8

$uniqueKeys = ($collected | Select-Object -ExpandProperty key -Unique).Count

Write-Host "REPORTED_TOTAL=$reportedTotal"
Write-Host "EXPORTED_TOTAL=$($collected.Count)"
Write-Host "UNIQUE_KEYS=$uniqueKeys"
Write-Host "PAGES_FETCHED=$($page - 1)"

if ($collected.Count -ne $reportedTotal) {
    Write-Host "VALIDACAO_TOTAL_EXPORTADO=FAIL (exportado != reportado)"
    exit 1
}
if ($uniqueKeys -ne $collected.Count) {
    Write-Host "VALIDACAO_TOTAL_EXPORTADO=FAIL (ha issues duplicados entre paginas)"
    exit 1
}
Write-Host "VALIDACAO_TOTAL_EXPORTADO=PASS"
