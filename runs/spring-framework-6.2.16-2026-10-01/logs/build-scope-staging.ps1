# Monta um diretorio de staging com JUNCTIONS (Windows) apontando, para cada
# modulo de producao do Spring Framework, diretamente ao seu src/main/java,
# nomeadas com o caminho do modulo (preservando o prefixo do modulo no
# relative_path calculado pelo MethodInventoryExtractor, que usa
# root.relativize(file)). Isso garante relative_path globalmente unico entre
# modulos (ex.: "spring-core/org/springframework/...") em uma UNICA execucao
# da ferramenta (1 unico universo para checagem de colisao), sem alterar a
# ferramenta ja validada e sem copiar nenhum arquivo fisicamente.
#
# Caso especial: spring-core usa o plugin MRJAR (multiRelease 17/21) e tem um
# SEGUNDO diretorio de producao, src/main/java21. Staged com um junction
# proprio "spring-core-java21", para que relative_path distinga claramente as
# duas variantes (nao ha colisao: sao compilation units fisicamente
# diferentes no repositorio, mesmo quando declaram o mesmo nome de classe).
#
# Staging e artefato derivado/efemero (nao versionado, nao preservado como
# resultado) - decisao de engenharia, nao metodologica (mesmo padrao usado no
# Hibernate ORM).

$ErrorActionPreference = "Stop"
$repo = (Resolve-Path "sources/spring-framework-6.2.16").Path
$stage = Join-Path $env:TEMP "spring-framework-scope-stage"

if (Test-Path $stage) {
    Remove-Item -Recurse -Force $stage
}
New-Item -ItemType Directory -Force -Path $stage | Out-Null

$prodModules = @(
    "spring-aop",
    "spring-aspects",
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

foreach ($m in $prodModules) {
    $target = Join-Path $repo "$m/src/main/java"
    if (-not (Test-Path $target)) {
        throw "Diretorio nao encontrado: $target"
    }
    $link = Join-Path $stage $m
    New-Item -ItemType Directory -Force -Path (Split-Path $link -Parent) | Out-Null
    cmd /c mklink /J "$link" "$target" | Out-Null
}

# Caso especial MRJAR do spring-core (ver nota acima).
$java21Target = Join-Path $repo "spring-core/src/main/java21"
if (-not (Test-Path $java21Target)) {
    throw "Diretorio nao encontrado: $java21Target"
}
$java21Link = Join-Path $stage "spring-core-java21"
cmd /c mklink /J "$java21Link" "$java21Target" | Out-Null

Write-Output "STAGE=$stage"
Get-ChildItem $stage | ForEach-Object { Write-Output ("LINK: " + $_.Name + " -> " + (Get-Item $_.FullName).Target) }
