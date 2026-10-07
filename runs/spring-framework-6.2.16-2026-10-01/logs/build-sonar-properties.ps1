<#
Gera o sonar-project.properties para a analise do Spring Framework 6.2.16,
listando os 23 modulos de producao (src/main/java e bytecode compilado de
cada um) mais o caso especial MRJAR do spring-core (src/main/java21),
sem modificar nada dentro do checkout em sources/spring-framework-6.2.16.

Bytecode: a maioria dos modulos usa build/classes/java/main (javac via
toolchain BellSoft 17); spring-aspects usa build/classes/aspectj/main
(compilador AspectJ ajc, plugin io.freefair.aspectj); spring-core tem um
segundo par fonte/bytecode para o sourceSet java21 (MRJAR).
#>

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\")).Path
$springRoot = (Join-Path $repoRoot "sources\spring-framework-6.2.16").Replace('\','/')

$modules = @(
    "spring-aop",
    "spring-beans",
    "spring-context",
    "spring-context-indexer",
    "spring-context-support",
    "spring-core",
    "spring-core-test",
    "spring-expression",
    "spring-instrument",
    "spring-jcl",
    "spring-jdbc",
    "spring-jms",
    "spring-messaging",
    "spring-orm",
    "spring-oxm",
    "spring-r2dbc",
    "spring-test",
    "spring-tx",
    "spring-web",
    "spring-webflux",
    "spring-webmvc",
    "spring-websocket"
)

$sources = ($modules | ForEach-Object { "$springRoot/$_/src/main/java" }) -join ','
$binaries = ($modules | ForEach-Object { "$springRoot/$_/build/classes/java/main" }) -join ','

# Caso especial spring-aspects (compilador AspectJ, nao javac).
$sources += ",$springRoot/spring-aspects/src/main/java"
$binaries += ",$springRoot/spring-aspects/build/classes/aspectj/main"

# Caso especial MRJAR do spring-core (sourceSet java21).
$sources += ",$springRoot/spring-core/src/main/java21"
$binaries += ",$springRoot/spring-core/build/classes/java/java21"

$lines = @(
    "sonar.projectKey=spring-framework-6-2-16",
    "sonar.projectName=Spring Framework 6.2.16",
    "sonar.projectVersion=6.2.16",
    "sonar.projectBaseDir=$springRoot",
    "sonar.sourceEncoding=UTF-8",
    "sonar.java.source=17",
    "sonar.sources=$sources",
    "sonar.java.binaries=$binaries"
)

$outPath = Join-Path $PSScriptRoot "..\config\sonar-project.properties"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllLines($outPath, $lines, $utf8NoBom)
Write-Host "WROTE=$outPath"
Write-Host "MODULOS=$($modules.Count + 1)"
