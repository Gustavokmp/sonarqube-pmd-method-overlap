# Gera arquivos-incluidos.txt / arquivos-excluidos.txt para o Hibernate ORM
# 7.2.6.Final (PROTOCOLO.md secao 6), a partir da lista de arquivos VERSIONADOS
# (git ls-files - exclui automaticamente .git/.gradle/build, que nao sao
# versionados).
#
# Modulos de producao (src/main/java), decididos por inspecao manual (ver
# STATUS.md secao 6 / Escopo):
#   - hibernate-core, hibernate-envers, hibernate-spatial,
#     hibernate-community-dialects, hibernate-vector, hibernate-c3p0,
#     hibernate-hikaricp, hibernate-agroal, hibernate-jcache,
#     hibernate-micrometer, hibernate-graalvm, hibernate-jfr,
#     hibernate-scan-jandex
#   - tooling/metamodel-generator, tooling/hibernate-gradle-plugin,
#     tooling/hibernate-maven-plugin, tooling/hibernate-ant
# Todos sao artefatos Java publicados pelo proprio projeto Hibernate ORM
# (confirmado via plugins maven-publish/com.gradle.plugin-publish nos
# arquivos .gradle correspondentes), diferentemente de local-build-plugins/
# local-build-asciidoctor-extensions (tooling interno de build, nao
# publicado) e hibernate-testing/hibernate-integrationtest-java-modules
# (bibliotecas de suporte a testes).

$ErrorActionPreference = "Stop"
$repo = "sources/hibernate-orm-7.2.6.Final"
$outDir = "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories"

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
$prodPrefixes = $prodModules | ForEach-Object { "$_/src/main/java/" }

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
