<#
Gera o sonar-project.properties para a analise do Quarkus 3.32.1.

Diferente do Hibernate ORM/Spring Framework (17/23 modulos, caminhos
listados explicitamente), o Quarkus tem 574 diretorios src/main/java de
producao (ver STATUS.md secao 8/Escopo) - grande demais para listar um por
um sem risco de erro de transcricao. sonar.sources aponta para o MESMO
diretorio de staging com junctions ja usado pelo MethodInventoryExtractor
(runs/quarkus-3.32.1-2026-10-01/logs/build-scope-staging.ps1), garantindo
que SonarQube, PMD e o inventario de metodos analisem exatamente o mesmo
conjunto de 7510 arquivos .java. sonar.java.binaries nao pode usar o
staging (build gera target/classes dentro de cada modulo real, nao
espelhado no staging) - lista os 574 diretorios target/classes reais,
gerados a partir da mesma lista de escopo.
#>

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\")).Path
$quarkusRoot = (Join-Path $repoRoot "sources\quarkus-3.32.1").Replace('\','/')
$stage = Join-Path $env:TEMP "quarkus-scope-stage"
$includedListPath = Join-Path $PSScriptRoot "..\inventories\scope-src-main-java-included.txt"

$modules = Get-Content $includedListPath | Where-Object { $_.Trim().Length -gt 0 } | ForEach-Object { ($_ -replace '\\src\\main\\java$', '').Replace('\','/') }

# Caso especial: devtools/gradle/* e um projeto Gradle aninhado dentro do
# reactor Maven (gradlew/build.gradle.kts proprios) - saida em
# build/classes/java/main (padrao Gradle), nao target/classes (padrao Maven).
$gradleBuildModules = @('devtools/gradle/gradle-application-plugin', 'devtools/gradle/gradle-extension-plugin', 'devtools/gradle/gradle-model')

$binaries = ($modules | ForEach-Object {
    if ($gradleBuildModules -contains $_) {
        "$quarkusRoot/$_/build/classes/java/main"
    } else {
        "$quarkusRoot/$_/target/classes"
    }
}) -join ','

$lines = @(
    "sonar.projectKey=quarkus-3-32-1",
    "sonar.projectName=Quarkus 3.32.1",
    "sonar.projectVersion=3.32.1",
    "sonar.projectBaseDir=$($stage.Replace('\','/'))",
    "sonar.sourceEncoding=UTF-8",
    "sonar.java.source=17",
    "sonar.sources=.",
    "sonar.java.binaries=$binaries"
)

$outPath = Join-Path $PSScriptRoot "..\config\sonar-project.properties"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllLines($outPath, $lines, $utf8NoBom)
Write-Host "WROTE=$outPath"
Write-Host "MODULOS=$($modules.Count)"
