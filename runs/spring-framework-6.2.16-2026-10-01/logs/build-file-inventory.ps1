# Gera arquivos-incluidos.txt / arquivos-excluidos.txt para o Spring
# Framework 6.2.16 (PROTOCOLO.md secao 6), a partir da lista de arquivos
# VERSIONADOS (git ls-files - exclui automaticamente .git/.gradle/build,
# que nao sao versionados).
#
# Modulos de producao (src/main/java), decididos por inspecao manual (ver
# STATUS.md secao 7 / Escopo): os 23 subprojetos "spring-*" declarados em
# settings.gradle (moduleProjects = subprojects com prefixo "spring-"),
# todos com o plugin de publicacao aplicado via gradle/spring-module.gradle
# (apply from: ".../gradle/publications.gradle") e com src/main/java real.
# Excluidos (sem prefixo "spring-" e/ou sem publicacao de biblioteca):
# framework-api, framework-bom, framework-platform (plugin java-platform,
# sem nenhum arquivo .java - apenas agregacao de javadoc/BOM/constraints de
# versao), framework-docs (jar/javadoc explicitamente desabilitados no
# proprio build file - src/main contem somente snippets de codigo incluidos
# na documentacao de referencia, nao biblioteca publicada - analogo a
# "exemplos", excluido pela secao 6 do protocolo), integration-tests
# (contem somente src/test, nenhum src/main). Dentro dos 23 modulos de
# producao, tambem excluidos (fora de src/main/java): src/test,
# src/testFixtures (biblioteca de apoio a testes), src/jmh (benchmarks,
# excluidos explicitamente pela secao 6), src/main/kotlin e src/main/resources
# (protocolo restringe a analise a codigo Java).
#
# Caso especial (protocolo secao 6: "Nao assumir que todo codigo de
# producao esta em src/main/java"): o modulo spring-core usa o plugin MRJAR
# (me.champeau.mrjar, multiRelease { targetVersions 17, 21 }) e possui um
# SEGUNDO diretorio de codigo de producao, src/main/java21, com variantes
# Java 21 de classes publicadas no mesmo jar (multi-release JAR). Incluido
# explicitamente abaixo. Nenhum outro modulo usa o plugin MRJAR (confirmado
# por busca textual em todos os arquivos .gradle do repositorio).

$ErrorActionPreference = "Stop"
$repo = "sources/spring-framework-6.2.16"
$outDir = "runs/spring-framework-6.2.16-2026-10-01/inventories"

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
$prodPrefixes = $prodModules | ForEach-Object { "$_/src/main/java/" }
# Caso especial MRJAR do spring-core (ver nota acima).
$prodPrefixes += "spring-core/src/main/java21/"

$allFiles = git -C $repo ls-files
Write-Output "TOTAL_VERSIONADO=$($allFiles.Count)"

$included = New-Object System.Collections.Generic.List[string]
$excluded = New-Object System.Collections.Generic.List[string]

foreach ($f in $allFiles) {
    $isProd = $false
    if ($f.EndsWith(".java")) {
        foreach ($prefix in $prodPrefixes) {
            if ($f.StartsWith($prefix)) {
                $isProd = $true
                break
            }
        }
    }
    if ($isProd) {
        $included.Add($f)
    }
    else {
        $excluded.Add($f)
    }
}

$included | Sort-Object | Set-Content -Encoding utf8 "$outDir/arquivos-incluidos.txt"
$excluded | Sort-Object | Set-Content -Encoding utf8 "$outDir/arquivos-excluidos.txt"

Write-Output "ARQUIVOS_INCLUIDOS=$($included.Count)"
Write-Output "ARQUIVOS_EXCLUIDOS=$($excluded.Count)"
Write-Output "SOMA_OK=$($included.Count + $excluded.Count -eq $allFiles.Count)"
