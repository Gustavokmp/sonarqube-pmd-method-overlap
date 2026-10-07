# Monta um diretorio de staging com JUNCTIONS (Windows) apontando, para cada
# diretorio src/main/java de producao do Quarkus, diretamente ao seu
# conteudo, com o link nomeado pelo caminho real do modulo dentro do
# repositorio (preservando esse caminho no relative_path calculado pelo
# MethodInventoryExtractor, que usa root.relativize). Mesmo padrao usado no
# Hibernate ORM e no Spring Framework, adaptado para o numero muito maior de
# modulos do Quarkus (574 diretorios src/main/java de producao, contra 17 no
# Hibernate e 23+1 no Spring).
#
# A lista de diretorios incluidos (runs/quarkus-3.32.1-2026-10-01/inventories/
# scope-src-main-java-included.txt) e excluidos (scope-src-main-java-excluded.txt)
# foi gerada e revisada manualmente (ver STATUS.md secao 8/Escopo para a
# justificativa completa de cada exclusao): arquetipos Maven
# (archetype-resources), templates de codestarts (resources/codestarts),
# fixtures de teste aninhadas (src/test/.../src/main/java), TCKs do ArC,
# regras de enforcer do proprio build, extensao JUnit de virtual threads,
# modulo de testing do devtools, bibliotecas de apoio a TESTES publicadas
# (quarkus-security-test-utils, quarkus-arc-test-supplement[-decorator],
# quarkus-panache-mock) e o modulo de benchmarks JMH do bootstrap.
#
# Staging e artefato derivado/efemero (nao versionado, nao preservado como
# resultado) - decisao de engenharia, nao metodologica.

$ErrorActionPreference = "Stop"
$repo = (Resolve-Path "sources/quarkus-3.32.1").Path
$stage = Join-Path $env:TEMP "quarkus-scope-stage"
$includedListPath = (Resolve-Path "runs/quarkus-3.32.1-2026-10-01/inventories/scope-src-main-java-included.txt").Path

if (Test-Path $stage) {
    Remove-Item -Recurse -Force $stage
}
New-Item -ItemType Directory -Force -Path $stage | Out-Null

$modules = Get-Content $includedListPath | Where-Object { $_.Trim().Length -gt 0 }

$count = 0
foreach ($m in $modules) {
    $target = Join-Path $repo $m
    if (-not (Test-Path $target)) {
        throw "Diretorio nao encontrado: $target"
    }
    # Nome do link = caminho do modulo sem o sufixo "\src\main\java", para
    # preservar o caminho do modulo (nao do source root) no relative_path.
    $modRel = $m -replace '\\src\\main\\java$', ''
    $link = Join-Path $stage $modRel
    New-Item -ItemType Directory -Force -Path (Split-Path $link -Parent) | Out-Null
    cmd /c mklink /J "$link" "$target" | Out-Null
    $count++
}

Write-Output "STAGE=$stage"
Write-Output "MODULES_LINKED=$count"
