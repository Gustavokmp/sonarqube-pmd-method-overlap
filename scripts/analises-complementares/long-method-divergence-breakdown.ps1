<#
Atividade 4.3 (analise complementar pos-protocolo) - PROTOCOLO.md nao e
alterado. Para os metodos Long Method (comuns, so-Sonar, so-PMD) de cada
um dos 4 projetos, extrai linhas fisicas (line_end - line_start + 1, de
inventory-methods.jsonl) para todos os casos, e NCSS (da mensagem bruta
das violacoes NcssCount em pmd-output.xml, ja existente - nao reexecuta
PMD) para os metodos que o PMD realmente sinalizou (comuns + so-PMD).
Nao reexecuta SonarQube/PMD; nao afirma qual ferramenta esta correta.
#>
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\")).Path
$outDir = Join-Path $repoRoot "results\analises-complementares"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Normalize-CommonsLangPath($fileName) {
    # "..\..\commons-lang-3.20.0\src\main\java\org\apache\...\X.java" -> "org/apache/.../X.java"
    $marker = "commons-lang-3.20.0\src\main\java\"
    $idx = $fileName.IndexOf($marker)
    if ($idx -lt 0) { return $null }
    $rest = $fileName.Substring($idx + $marker.Length)
    return $rest.Replace('\', '/')
}

function Normalize-SourcesModulePath($fileName, $sourcesDirName) {
    # "sources\<sourcesDirName>\<modulo>\src\main\java\<rest>.java" -> "<modulo>/<rest>.java"
    $marker = "sources\$sourcesDirName\"
    $idx = $fileName.IndexOf($marker)
    if ($idx -lt 0) { return $null }
    $afterSources = $fileName.Substring($idx + $marker.Length)
    $afterSources = $afterSources -replace '\\src\\main\\java(21)?\\', '/'
    return $afterSources.Replace('\', '/')
}

function Normalize-QuarkusStagePath($fileName) {
    # "<TEMP>\quarkus-scope-stage\<modulo>\<rest>.java" -> "<modulo>/<rest>.java"
    $marker = "quarkus-scope-stage\"
    $idx = $fileName.IndexOf($marker)
    if ($idx -lt 0) { return $null }
    $rest = $fileName.Substring($idx + $marker.Length)
    return $rest.Replace('\', '/')
}

$projects = @(
    @{ key = "commons-lang-3.20.0"; runDir = "commons-lang-3.20.0-2026-10-01"; normalizer = "commonslang" },
    @{ key = "hibernate-orm-7.2.6.Final"; runDir = "hibernate-orm-7.2.6.Final-2026-10-01"; normalizer = "sourcesmodule"; sourcesDirName = "hibernate-orm-7.2.6.Final" },
    @{ key = "spring-framework-6.2.16"; runDir = "spring-framework-6.2.16-2026-10-01"; normalizer = "sourcesmodule"; sourcesDirName = "spring-framework-6.2.16" },
    @{ key = "quarkus-3.32.1"; runDir = "quarkus-3.32.1-2026-10-01"; normalizer = "quarkus" }
)

function Get-NcssByRelLine($xmlPath, $normalizer, $sourcesDirName) {
    # Mapa (relative_path|beginline) -> NCSS, extraido da mensagem bruta das
    # violacoes NcssCount (pmd-output.xml, ja existente - nao reexecuta PMD).
    [xml]$xml = Get-Content -Path $xmlPath -Raw
    $map = @{}
    foreach ($file in $xml.pmd.file) {
        $rawName = $file.name
        $relPath = switch ($normalizer) {
            "commonslang" { Normalize-CommonsLangPath $rawName }
            "sourcesmodule" { Normalize-SourcesModulePath $rawName $sourcesDirName }
            "quarkus" { Normalize-QuarkusStagePath $rawName }
        }
        if ($null -eq $relPath) { continue }
        foreach ($violation in $file.violation) {
            if ($violation.rule -ne "NcssCount") { continue }
            if ([string]::IsNullOrEmpty($violation.method)) { continue }  # pula violacoes de classe (out_of_scope)
            $msg = $violation.'#text'
            if ($msg -match 'NCSS line count of (\d+)') {
                $ncss = [int]$Matches[1]
                $beginLine = [int]$violation.beginline
                $key = "$relPath|$beginLine"
                $map[$key] = $ncss
            }
        }
    }
    return $map
}

function Get-NcssByMethodId($invDir, $ncssByRelLine) {
    # Ponte (relative_path|line) -> method_id usando association-pmd.jsonl, o
    # MESMO artefato de associacao por AST ja validado na coleta original
    # (Associator.java) - evita reimplementar/assumir que beginline da
    # violacao PMD equivale a line_start do inventario (metodos com
    # anotacoes antes da assinatura tem line_start != beginline reportado
    # pelo PMD).
    $map = @{}
    foreach ($line in (Get-Content (Join-Path $invDir "association-pmd.jsonl"))) {
        if ($line.Trim().Length -eq 0) { continue }
        $a = $line | ConvertFrom-Json
        if ($a.label -ne "pmd:NcssCount") { continue }
        if ($a.status -ne "eligible_method") { continue }
        $key = "$($a.relative_path)|$($a.line)"
        if ($ncssByRelLine.ContainsKey($key)) {
            $map[$a.method_id] = $ncssByRelLine[$key]
        }
    }
    return $map
}

function Percentile($sortedValues, $p) {
    if ($sortedValues.Count -eq 0) { return $null }
    $idx = [Math]::Floor(($sortedValues.Count - 1) * $p)
    return $sortedValues[$idx]
}

function Stats($values) {
    if ($values.Count -eq 0) {
        return [ordered]@{ count = 0; min = $null; max = $null; mean = $null; median = $null }
    }
    $sorted = $values | Sort-Object
    $mean = ($values | Measure-Object -Average).Average
    return [ordered]@{
        count = $values.Count
        min = $sorted[0]
        max = $sorted[-1]
        mean = [Math]::Round($mean, 2)
        median = Percentile $sorted 0.5
    }
}

$allResults = [ordered]@{}

foreach ($proj in $projects) {
    $invDir = Join-Path $repoRoot "runs\$($proj.runDir)\inventories"
    $rawDir = Join-Path $repoRoot "runs\$($proj.runDir)\raw"

    $inventoryByMethodId = @{}
    foreach ($line in (Get-Content (Join-Path $invDir "inventory-methods.jsonl"))) {
        if ($line.Trim().Length -eq 0) { continue }
        $m = $line | ConvertFrom-Json
        $inventoryByMethodId[$m.method_id] = $m
    }

    $sonarSet = New-Object System.Collections.Generic.HashSet[string]
    $pmdSet = New-Object System.Collections.Generic.HashSet[string]
    foreach ($line in (Get-Content (Join-Path $invDir "dedup-results.jsonl"))) {
        if ($line.Trim().Length -eq 0) { continue }
        $a = $line | ConvertFrom-Json
        if ($a.smell -ne "long_method") { continue }
        if ($a.tool -eq "sonarqube") { [void]$sonarSet.Add($a.method_id) }
        elseif ($a.tool -eq "pmd") { [void]$pmdSet.Add($a.method_id) }
    }

    $ncssByRelLine = Get-NcssByRelLine (Join-Path $rawDir "pmd-output.xml") $proj.normalizer $proj.sourcesDirName
    $ncssByMethodId = Get-NcssByMethodId $invDir $ncssByRelLine

    $common = New-Object System.Collections.Generic.List[string]
    $onlySonar = New-Object System.Collections.Generic.List[string]
    $onlyPmd = New-Object System.Collections.Generic.List[string]
    foreach ($id in $sonarSet) {
        if ($pmdSet.Contains($id)) { $common.Add($id) } else { $onlySonar.Add($id) }
    }
    foreach ($id in $pmdSet) {
        if (-not $sonarSet.Contains($id)) { $onlyPmd.Add($id) }
    }

    function Collect-Data($ids) {
        $lines = New-Object System.Collections.Generic.List[int]
        $ncssValues = New-Object System.Collections.Generic.List[int]
        $ncssMissing = 0
        foreach ($id in $ids) {
            $m = $inventoryByMethodId[$id]
            $physLines = $m.line_end - $m.line_start + 1
            $lines.Add($physLines)
            if ($ncssByMethodId.ContainsKey($id)) {
                $ncssValues.Add($ncssByMethodId[$id])
            } else {
                $ncssMissing++
            }
        }
        return [ordered]@{
            physical_lines = Stats $lines
            ncss = Stats $ncssValues
            ncss_missing_count = $ncssMissing
        }
    }

    $allResults[$proj.key] = [ordered]@{
        common_count = $common.Count
        only_sonar_count = $onlySonar.Count
        only_pmd_count = $onlyPmd.Count
        common = Collect-Data $common
        only_sonar = Collect-Data $onlySonar
        only_pmd = Collect-Data $onlyPmd
    }
}

$jsonOut = Join-Path $outDir "long-method-divergence-breakdown.json"
$allResults | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonOut -Encoding UTF8

foreach ($k in $allResults.Keys) {
    $d = $allResults[$k]
    Write-Host "=== $k ==="
    Write-Host "  comuns=$($d.common_count) soSonar=$($d.only_sonar_count) soPmd=$($d.only_pmd_count)"
    Write-Host "  comuns.linhas: $($d.common.physical_lines | ConvertTo-Json -Compress)"
    Write-Host "  comuns.ncss: $($d.common.ncss | ConvertTo-Json -Compress) (faltantes=$($d.common.ncss_missing_count))"
    Write-Host "  soSonar.linhas: $($d.only_sonar.physical_lines | ConvertTo-Json -Compress)"
    Write-Host "  soSonar.ncss: $($d.only_sonar.ncss | ConvertTo-Json -Compress) (faltantes=$($d.only_sonar.ncss_missing_count))"
    Write-Host "  soPmd.linhas: $($d.only_pmd.physical_lines | ConvertTo-Json -Compress)"
    Write-Host "  soPmd.ncss: $($d.only_pmd.ncss | ConvertTo-Json -Compress) (faltantes=$($d.only_pmd.ncss_missing_count))"
}
