# Executa o PMD 7.27.0 com o ruleset do experimento contra o diretorio de
# staging com junctions (os mesmos 574 modulos/7510 arquivos analisados pelo
# SonarQube e pelo MethodInventoryExtractor) - um unico "-d" evita o limite
# de tamanho de linha de comando do Windows que uma lista de 574 caminhos
# reais excederia.
#
# Sem "$ErrorActionPreference = Stop": o PMD escreve seu resumo ("[INFO]
# Found N violations.") em stderr, e com *>&1 + Tee-Object o PowerShell
# embrulha essas linhas como pseudo-NativeCommandError - com Stop ativo o
# script abortava antes de gravar a linha EXITCODE (mesmo com o relatorio
# XML completo e correto). Mesmo achado do mvnw (ver repo memory).

$stage = Join-Path $env:TEMP "quarkus-scope-stage"

$outXml = "runs/quarkus-3.32.1-2026-10-01/raw/pmd-output.xml"
$outLog = "runs/quarkus-3.32.1-2026-10-01/logs/pmd-output.txt"
New-Item -ItemType Directory -Force -Path (Split-Path $outXml) | Out-Null

& "sources/pmd-bin-7.27.0/bin/pmd.bat" check `
  -d $stage `
  -R "configs/pmd-ruleset-exp-mestrado-long-smells.xml" `
  -f xml -r $outXml --no-cache *>&1 | Tee-Object -FilePath $outLog
"EXITCODE=$LASTEXITCODE" | Out-File -FilePath $outLog -Append -Encoding utf8
