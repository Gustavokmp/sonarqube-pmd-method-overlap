# Lista, por método, as linhas físicas (line_end - line_start + 1) dos métodos
# PMD-only de Long Method nos 4 projetos, a partir de artefatos já preservados
# (dedup-results.jsonl e inventory-methods.jsonl). Não reexecuta SonarQube/PMD.
#
# Saída: results/analises-complementares/long-method-pmd-only-physical-lines.csv
# Uso (a partir da raiz do repositório): ./scripts/analises-complementares/long-method-pmd-only-physical-lines.ps1

$ErrorActionPreference = "Stop"
$runs = @(
    @{ project = "commons-lang"; dir = "runs/commons-lang-3.20.0-2026-10-01" },
    @{ project = "hibernate-orm"; dir = "runs/hibernate-orm-7.2.6.Final-2026-10-01" },
    @{ project = "spring-framework"; dir = "runs/spring-framework-6.2.16-2026-10-01" },
    @{ project = "quarkus"; dir = "runs/quarkus-3.32.1-2026-10-01" }
)
$threshold = 75
$rows = New-Object System.Collections.Generic.List[object]

foreach ($r in $runs) {
    $sonar = [System.Collections.Generic.HashSet[string]]::new()
    $pmd = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($line in [System.IO.File]::ReadLines("$($r.dir)/inventories/dedup-results.jsonl")) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $d = $line | ConvertFrom-Json
        if ($d.smell -ne "long_method") { continue }
        if ($d.tool -eq "sonarqube") { [void]$sonar.Add([string]$d.method_id) }
        if ($d.tool -eq "pmd") { [void]$pmd.Add([string]$d.method_id) }
    }
    $pmdOnly = [System.Collections.Generic.HashSet[string]]::new($pmd)
    $pmdOnly.ExceptWith($sonar)

    foreach ($line in [System.IO.File]::ReadLines("$($r.dir)/inventories/inventory-methods.jsonl")) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $m = $line | ConvertFrom-Json
        if (-not $pmdOnly.Contains([string]$m.method_id)) { continue }
        $physical = [int]$m.line_end - [int]$m.line_start + 1
        $rows.Add([PSCustomObject]@{
            project = $r.project
            relative_path = $m.relative_path
            method_name = $m.method_name
            line_start = $m.line_start
            line_end = $m.line_end
            physical_lines = $physical
            bucket = $(if ($physical -lt $threshold) { "<75" } else { ">=75" })
        })
    }
}

$out = "results/analises-complementares/long-method-pmd-only-physical-lines.csv"
$rows | Sort-Object project, physical_lines | Export-Csv -Path $out -NoTypeInformation -Encoding UTF8
$below = @($rows | Where-Object { $_.bucket -eq "<75" }).Count
$above = @($rows | Where-Object { $_.bucket -eq ">=75" }).Count
Write-Output "PMD_ONLY_TOTAL=$($rows.Count) ABAIXO_75=$below IGUAL_OU_ACIMA_75=$above"
