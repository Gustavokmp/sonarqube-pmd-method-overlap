<#
Atividade 4.1 (analise complementar pos-protocolo) - PROTOCOLO.md nao e
alterado. Calcula a sobreposicao direcional (SQ->PMD = |A ∩ B| / |A|;
PMD->SQ = |A ∩ B| / |B|) para os 8 casos (4 projetos x 2 smells), a partir
exclusivamente das metricas finais ja publicadas (metrics-resultado.json
de cada projeto / RESULTADOS-FINAIS.md) - nao reexecuta SonarQube/PMD nem
recalcula interseccao/uniao (ja validadas).
#>
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\")).Path
$outDir = Join-Path $repoRoot "results\analises-complementares"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Fmt($v) {
    if ($null -eq $v) { return "N/A" }
    return $v.ToString("F4", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Compute-Directional($project, $smell, $a, $b, $inter) {
    $sqToPmd = if ($a -gt 0) { 1.0 * $inter / $a } else { $null }
    $pmdToSq = if ($b -gt 0) { 1.0 * $inter / $b } else { $null }
    return [ordered]@{
        project = $project; smell = $smell
        A = $a; B = $b; intersection = $inter
        sq_to_pmd = Fmt $sqToPmd
        pmd_to_sq = Fmt $pmdToSq
    }
}

# Valores retirados diretamente de metrics-resultado.json / RESULTADOS-FINAIS.md
# de cada projeto (sem recalculo de A/B/intersecao - apenas razoes novas).
$cases = @(
    (Compute-Directional "commons-lang-3.20.0" "long_method" 13 12 11),
    (Compute-Directional "commons-lang-3.20.0" "long_parameter_list" 1 0 0),
    (Compute-Directional "hibernate-orm-7.2.6.Final" "long_method" 260 126 125),
    (Compute-Directional "hibernate-orm-7.2.6.Final" "long_parameter_list" 126 64 47),
    (Compute-Directional "spring-framework-6.2.16" "long_method" 101 81 74),
    (Compute-Directional "spring-framework-6.2.16" "long_parameter_list" 10 0 0),
    (Compute-Directional "quarkus-3.32.1" "long_method" 348 169 161),
    (Compute-Directional "quarkus-3.32.1" "long_parameter_list" 292 170 156)
)

$jsonOut = Join-Path $outDir "directional-overlap.json"
$cases | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonOut -Encoding UTF8

$csvOut = Join-Path $outDir "directional-overlap.csv"
$cases | ForEach-Object { [pscustomobject]$_ } | Export-Csv -Path $csvOut -NoTypeInformation -Encoding UTF8

$cases | ConvertTo-Json -Depth 5
