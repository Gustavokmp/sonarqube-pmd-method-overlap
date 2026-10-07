<#
Atividade 4.2 (analise complementar pos-protocolo) - PROTOCOLO.md nao e
alterado. Para os metodos exclusivos (so-Sonar / so-PMD) de Long Parameter
List em cada projeto, obtem automaticamente a quantidade de parametros (a
partir de parameter_types em inventory-methods.jsonl - nao reexecuta
SonarQube/PMD) e classifica em <8, 8-9, >=10. Para exclusivos PMD com
>=10, localiza o arquivo-fonte real (mapeamento modulo->src/main/java ja
usado no staging de cada projeto) e usa AnnotationLookup.java (AST
JavaParser) para listar as anotacoes presentes no metodo/construtor.
#>
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\")).Path
$outDir = Join-Path $repoRoot "results\analises-complementares"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# Mapeamento modulo -> caminho real (igual aos scripts de staging originais
# de cada projeto, build-scope-staging.ps1 / scope-src-main-java-included.txt).
$hibernateModules = @(
    "hibernate-core","hibernate-envers","hibernate-spatial",
    "hibernate-community-dialects","hibernate-vector","hibernate-c3p0",
    "hibernate-hikaricp","hibernate-agroal","hibernate-jcache",
    "hibernate-micrometer","hibernate-graalvm","hibernate-jfr",
    "hibernate-scan-jandex","tooling/metamodel-generator",
    "tooling/hibernate-gradle-plugin","tooling/hibernate-maven-plugin",
    "tooling/hibernate-ant"
) | Sort-Object -Property Length -Descending

$quarkusIncludedRaw = Get-Content (Join-Path $repoRoot "runs\quarkus-3.32.1-2026-10-01\inventories\scope-src-main-java-included.txt")
$quarkusModules = $quarkusIncludedRaw | Where-Object { $_.Trim().Length -gt 0 } | ForEach-Object {
    ($_ -replace '\\src\\main\\java$', '').Replace('\','/')
} | Sort-Object -Property Length -Descending

$projects = @(
    @{ key = "commons-lang-3.20.0"; dir = "commons-lang-3.20.0-2026-10-01"; sourcesDir = "commons-lang-3.20.0"; modules = $null },
    @{ key = "hibernate-orm-7.2.6.Final"; dir = "hibernate-orm-7.2.6.Final-2026-10-01"; sourcesDir = "hibernate-orm-7.2.6.Final"; modules = $hibernateModules },
    @{ key = "spring-framework-6.2.16"; dir = "spring-framework-6.2.16-2026-10-01"; sourcesDir = "spring-framework-6.2.16"; modules = $null },
    @{ key = "quarkus-3.32.1"; dir = "quarkus-3.32.1-2026-10-01"; sourcesDir = "quarkus-3.32.1"; modules = $quarkusModules }
)

function Resolve-RealPath($sourcesDir, $modules, $relativePath) {
    if ($null -eq $modules) { return $null }
    foreach ($m in $modules) {
        if ($relativePath -eq $m -or $relativePath.StartsWith("$m/")) {
            $rest = $relativePath.Substring($m.Length + 1)
            return (Join-Path $repoRoot "sources\$sourcesDir\$m\src\main\java\$rest").Replace('/', '\')
        }
    }
    return $null
}

function Bucket($paramCount) {
    if ($paramCount -lt 8) { return "<8" }
    elseif ($paramCount -le 9) { return "8-9" }
    else { return ">=10" }
}

$allBreakdown = [ordered]@{}
$annotationLookupRows = New-Object System.Collections.Generic.List[string]
$annotationLookupMeta = @{}

foreach ($proj in $projects) {
    $invDir = Join-Path $repoRoot "runs\$($proj.dir)\inventories"
    $inventoryLines = Get-Content (Join-Path $invDir "inventory-methods.jsonl")
    $inventoryByMethodId = @{}
    foreach ($line in $inventoryLines) {
        if ($line.Trim().Length -eq 0) { continue }
        $m = $line | ConvertFrom-Json
        $inventoryByMethodId[$m.method_id] = $m
    }

    $dedupLines = Get-Content (Join-Path $invDir "dedup-results.jsonl")
    $sonarSet = New-Object System.Collections.Generic.HashSet[string]
    $pmdSet = New-Object System.Collections.Generic.HashSet[string]
    foreach ($line in $dedupLines) {
        if ($line.Trim().Length -eq 0) { continue }
        $a = $line | ConvertFrom-Json
        if ($a.smell -ne "long_parameter_list") { continue }
        if ($a.tool -eq "sonarqube") { [void]$sonarSet.Add($a.method_id) }
        elseif ($a.tool -eq "pmd") { [void]$pmdSet.Add($a.method_id) }
    }

    $onlySonar = New-Object System.Collections.Generic.List[string]
    foreach ($id in $sonarSet) { if (-not $pmdSet.Contains($id)) { $onlySonar.Add($id) } }
    $onlyPmd = New-Object System.Collections.Generic.List[string]
    foreach ($id in $pmdSet) { if (-not $sonarSet.Contains($id)) { $onlyPmd.Add($id) } }

    $sonarBuckets = [ordered]@{ "<8" = 0; "8-9" = 0; ">=10" = 0 }
    $pmdBuckets = [ordered]@{ "<8" = 0; "8-9" = 0; ">=10" = 0 }
    $pmdOnlyDetails = New-Object System.Collections.Generic.List[object]
    $sonarOnlyDetails = New-Object System.Collections.Generic.List[object]

    foreach ($id in $onlySonar) {
        $m = $inventoryByMethodId[$id]
        $count = $m.parameter_types.Count
        $b = Bucket $count
        $sonarBuckets[$b]++
        $sonarOnlyDetails.Add([pscustomobject]@{ method_id = $id; param_count = $count; bucket = $b })
    }
    foreach ($id in $onlyPmd) {
        $m = $inventoryByMethodId[$id]
        $count = $m.parameter_types.Count
        $b = Bucket $count
        $pmdBuckets[$b]++
        $realPath = Resolve-RealPath $proj.sourcesDir $proj.modules $m.relative_path
        $pmdOnlyDetails.Add([pscustomobject]@{
            method_id = $id; param_count = $count; bucket = $b
            relative_path = $m.relative_path; line_start = $m.line_start; method_name = $m.method_name
            real_path = $realPath
        })
        if ($b -eq ">=10" -and $null -ne $realPath) {
            $label = "$($proj.key)|$id"
            $annotationLookupRows.Add("$label`t$realPath`t$($m.line_start)`t$($m.method_name)")
            $annotationLookupMeta[$label] = $id
        }
    }

    $allBreakdown[$proj.key] = [ordered]@{
        sonar_only_total = $onlySonar.Count
        sonar_only_buckets = $sonarBuckets
        pmd_only_total = $onlyPmd.Count
        pmd_only_buckets = $pmdBuckets
        pmd_only_details = $pmdOnlyDetails
        sonar_only_details = $sonarOnlyDetails
    }
}

# --- AnnotationLookup (AST) para exclusivos PMD com >=10 parametros ---
$tsvIn = Join-Path $outDir "lpl-exclusives-pmd-annotation-lookup-input.tsv"
$tsvOut = Join-Path $outDir "lpl-exclusives-pmd-annotation-lookup-output.tsv"
$annotationLookupRows | Set-Content -Path $tsvIn -Encoding UTF8

$annotationResults = @{}
if ($annotationLookupRows.Count -gt 0) {
    $jarPath = Join-Path $repoRoot "scripts\method-inventory\lib\javaparser-core-3.28.2.jar"
    $outClasses = Join-Path $repoRoot "scripts\analises-complementares\out"
    & java -cp "$outClasses;$jarPath" AnnotationLookup --in $tsvIn --out $tsvOut
    foreach ($line in (Get-Content $tsvOut)) {
        if ($line.Trim().Length -eq 0) { continue }
        $parts = $line -split "`t", 2
        $annotationResults[$parts[0]] = $parts[1]
    }
}

# Anexa resultado de anotacoes aos detalhes pmd_only
foreach ($projKey in $allBreakdown.Keys) {
    foreach ($detail in $allBreakdown[$projKey].pmd_only_details) {
        $label = "$projKey|$($detail.method_id)"
        if ($annotationResults.ContainsKey($label)) {
            $detail | Add-Member -NotePropertyName annotations -NotePropertyValue $annotationResults[$label] -Force
        } else {
            $detail | Add-Member -NotePropertyName annotations -NotePropertyValue "N/A (nao verificado - fora do bucket >=10 ou arquivo nao resolvido)" -Force
        }
    }
}

$jsonOut = Join-Path $outDir "lpl-exclusives-breakdown.json"
$allBreakdown | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonOut -Encoding UTF8

Write-Host "=== RESUMO ==="
foreach ($projKey in $allBreakdown.Keys) {
    $d = $allBreakdown[$projKey]
    Write-Host "${projKey}: sonarOnly=$($d.sonar_only_total) [$($d.sonar_only_buckets['<8'])/$($d.sonar_only_buckets['8-9'])/$($d.sonar_only_buckets['>=10'])] pmdOnly=$($d.pmd_only_total) [$($d.pmd_only_buckets['<8'])/$($d.pmd_only_buckets['8-9'])/$($d.pmd_only_buckets['>=10'])]"
}
