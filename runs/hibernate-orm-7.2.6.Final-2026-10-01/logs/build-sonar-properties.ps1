<#
Gera o sonar-project.properties para a analise do Hibernate ORM, listando
os 17 modulos de producao (src/main/java e target/classes de cada um),
sem modificar nada dentro do checkout em sources/hibernate-orm-7.2.6.Final.
#>

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\")).Path
$hibernateRoot = (Join-Path $repoRoot "sources\hibernate-orm-7.2.6.Final").Replace('\','/')

$modules = @(
    'hibernate-core',
    'hibernate-envers',
    'hibernate-spatial',
    'hibernate-community-dialects',
    'hibernate-vector',
    'hibernate-c3p0',
    'hibernate-hikaricp',
    'hibernate-agroal',
    'hibernate-jcache',
    'hibernate-micrometer',
    'hibernate-graalvm',
    'hibernate-jfr',
    'hibernate-scan-jandex',
    'tooling/metamodel-generator',
    'tooling/hibernate-gradle-plugin',
    'tooling/hibernate-maven-plugin',
    'tooling/hibernate-ant'
)

$sources = ($modules | ForEach-Object { "$hibernateRoot/$_/src/main/java" }) -join ','
$binaries = ($modules | ForEach-Object { "$hibernateRoot/$_/target/classes" }) -join ','

$lines = @(
    "sonar.projectKey=hibernate-orm-7-2-6-final",
    "sonar.projectName=Hibernate ORM 7.2.6.Final",
    "sonar.projectVersion=7.2.6.Final",
    "sonar.projectBaseDir=$hibernateRoot",
    "sonar.sourceEncoding=UTF-8",
    "sonar.java.source=17",
    "sonar.sources=$sources",
    "sonar.java.binaries=$binaries"
)

$outPath = Join-Path $PSScriptRoot "..\config\sonar-project.properties"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllLines($outPath, $lines, $utf8NoBom)
Write-Host "WROTE=$outPath"
Write-Host "MODULOS=$($modules.Count)"
