# Monta um diretorio de staging com JUNCTIONS (Windows) apontando, para cada
# modulo de producao do Hibernate ORM, diretamente ao seu src/main/java,
# nomeadas com o caminho do modulo (preservando o prefixo do modulo no
# relative_path calculado pelo MethodInventoryExtractor, que usa
# root.relativize(file)). Isso garante relative_path globalmente unico entre
# modulos (ex.: "hibernate-core/org/hibernate/...") em uma UNICA execucao da
# ferramenta (1 unico universo para checagem de colisao), sem alterar a
# ferramenta ja validada e sem copiar nenhum arquivo fisicamente.
#
# Staging e artefato derivado/efemero (nao versionado, nao preservado como
# resultado) - decisao de engenharia, nao metodologica.

$ErrorActionPreference = "Stop"
$repo = (Resolve-Path "sources/hibernate-orm-7.2.6.Final").Path
$stage = Join-Path $env:TEMP "hibernate-orm-scope-stage"

if (Test-Path $stage) {
    Remove-Item -Recurse -Force $stage
}
New-Item -ItemType Directory -Force -Path $stage | Out-Null

$prodModules = @(
    "hibernate-core",
    "hibernate-envers",
    "hibernate-spatial",
    "hibernate-community-dialects",
    "hibernate-vector",
    "hibernate-c3p0",
    "hibernate-hikaricp",
    "hibernate-agroal",
    "hibernate-jcache",
    "hibernate-micrometer",
    "hibernate-graalvm",
    "hibernate-jfr",
    "hibernate-scan-jandex",
    "tooling/metamodel-generator",
    "tooling/hibernate-gradle-plugin",
    "tooling/hibernate-maven-plugin",
    "tooling/hibernate-ant"
)

foreach ($m in $prodModules) {
    $target = Join-Path $repo "$m/src/main/java"
    if (-not (Test-Path $target)) {
        throw "Diretorio nao encontrado: $target"
    }
    # Preserva o caminho real do modulo (ex.: tooling/metamodel-generator)
    # para que relative_path reflita o caminho do repositorio.
    $link = Join-Path $stage $m
    New-Item -ItemType Directory -Force -Path (Split-Path $link -Parent) | Out-Null
    cmd /c mklink /J "$link" "$target" | Out-Null
}

Write-Output "STAGE=$stage"
Get-ChildItem $stage | ForEach-Object { Write-Output ("LINK: " + $_.Name + " -> " + (Get-Item $_.FullName).Target) }
