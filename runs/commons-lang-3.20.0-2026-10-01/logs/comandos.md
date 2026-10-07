# Comandos — Piloto Apache Commons Lang 3.20.0

## Checkout

```powershell
git clone --branch rel/commons-lang-3.20.0 --depth 1 https://github.com/apache/commons-lang.git sources/commons-lang-3.20.0
git -C sources/commons-lang-3.20.0 rev-parse HEAD   # 598dfc163b8b410fb3bb8794521206ec8dcec82a
```

## Escopo (inventários)

```powershell
cd scripts/method-inventory
javac --release 8 -encoding ISO-8859-1 ...           # ver seção Build
java -cp "out;lib/javaparser-core-3.28.2.jar" MethodInventoryExtractor `
  --project apache-commons-lang --commit 598dfc163b8b410fb3bb8794521206ec8dcec82a `
  --root ../../sources/commons-lang-3.20.0/src/main/java `
  --out ../../runs/commons-lang-3.20.0-2026-10-01/inventories/inventory-methods.jsonl
# arquivos_java_encontrados=259 falhas_de_parsing=0 metodos_elegiveis=3829 colisoes_de_identificador=0
```

Correção de engenharia aplicada antes desta execução final: `MethodInventoryExtractor`
e `Associator` passaram a resolver parâmetros cujo tipo é uma variável de tipo
genérica para o texto do seu bound (erasure), corrigindo 5 colisões reais
encontradas na primeira execução (`Validate.notEmpty`, `Validate.validIndex`,
`ExceptionUtils.throwUnchecked`). Ver `docs/DIARIO-EXECUCAO.md` seção 5/Escopo para detalhes.

## Build

```powershell
cd sources/commons-lang-3.20.0
Get-ChildItem -Recurse -Path src/main/java -Filter *.java | % { $_.FullName } | Set-Content sources.txt
javac --release 8 -encoding ISO-8859-1 -d target/classes "@sources.txt"
# EXITCODE=0, 403 .class gerados, apenas avisos (sem erros)
```

## SonarQube

```powershell
# sonar-project.properties: projectKey=apache-commons-lang-3-20-0, sources=src/main/java,
# java.binaries=target/classes, sourceEncoding=ISO-8859-1
POST /api/projects/create  project=apache-commons-lang-3-20-0
POST /api/qualityprofiles/add_project  project=apache-commons-lang-3-20-0 qualityProfile=exp-mestrado-long-smells language=java
sonar-scanner.bat -Dsonar.host.url=... -Dsonar.token=...
# taskId=21f94fd6-3e31-4604-a5ae-2a961733e3e6 analysisId=c61c2cea-a8ff-4835-bcde-1bcf32c94241 status=SUCCESS
scripts/sonarqube/export-issues-paginated.ps1 -ProjectKey apache-commons-lang-3-20-0 `
  -Rules "java:S138,java:S107" -OutFile runs/commons-lang-3.20.0-2026-10-01/raw/sonarqube-issues.jsonl
# REPORTED_TOTAL=14 EXPORTED_TOTAL=14 UNIQUE_KEYS=14 VALIDACAO_TOTAL_EXPORTADO=PASS
```

## PMD

```powershell
cd sources/pmd-bin-7.27.0/bin
./pmd.bat check -d ../../commons-lang-3.20.0/src/main/java `
  -R ../../../configs/pmd-ruleset-exp-mestrado-long-smells.xml `
  -f text --no-cache -r ../../../runs/commons-lang-3.20.0-2026-10-01/raw/pmd-output.txt
# [INFO] Found 14 violations. (exit=4)

# Correção de auditoria (2026-10-01): relatório estruturado adicional (XML),
# preservado ao lado do .txt original — PROTOCOLO.md seção 12 exige
# "relatório estruturado".
./pmd.bat check -d ../../commons-lang-3.20.0/src/main/java `
  -R ../../../configs/pmd-ruleset-exp-mestrado-long-smells.xml `
  -f xml --no-cache -r ../../../runs/commons-lang-3.20.0-2026-10-01/raw/pmd-output.xml
# [INFO] Found 14 violations. (exit=4) — mesmas 14 violações do .txt, confirmado
# via contagem de "<violation " no XML.
```

## Reprocessamento determinístico de ponta a ponta (auditoria 2026-10-01)

Reconstrução completa de ocorrências → associação → dedup → métricas a
partir **apenas** dos relatórios brutos já armazenados (`raw/sonarqube-issues.jsonl`,
`raw/pmd-output.txt`), sem reexecutar `sonar-scanner`/`pmd.bat`:

```powershell
runs/commons-lang-3.20.0-2026-10-01/logs/reprocess-check.ps1             # occurrences-*.csv
# + reexecução de Associator (SonarQube e PMD) para runs/.../reprocess-check/
runs/commons-lang-3.20.0-2026-10-01/logs/reprocess-check-dedup-input.ps1 # dedup-input-all.jsonl
# + reexecução de Deduplicator para runs/.../reprocess-check/dedup-results.jsonl
runs/commons-lang-3.20.0-2026-10-01/logs/reprocess-check-metrics.ps1     # metrics-resultado.json
```

Todas as etapas produziram saída idêntica (`Compare-Object` sem diferenças)
às dos artefatos originais em `inventories/`. Ver `docs/DIARIO-EXECUCAO.md` seção 5 ("Reprocessamento
determinístico") para o relato completo, incluindo a correção de um bug de
formatação de número dependente de cultura (`InvariantCulture`) encontrado
no script de reprocessamento.


## Normalização (associação + dedup)

```powershell
# Conversão dos alertas brutos para CSV de ocorrências (relative_path,line,label)
# ver runs/commons-lang-3.20.0-2026-10-01/inventories/occurrences-{sonarqube,pmd}.csv

java -cp "out;lib/javaparser-core-3.28.2.jar" Associator `
  --project apache-commons-lang --commit 598dfc163b8b410fb3bb8794521206ec8dcec82a `
  --root ../../sources/commons-lang-3.20.0/src/main/java `
  --occurrences ../../runs/commons-lang-3.20.0-2026-10-01/inventories/occurrences-sonarqube.csv `
  --out ../../runs/commons-lang-3.20.0-2026-10-01/inventories/association-sonarqube.jsonl
# 14/14 eligible_method

java -cp "out;lib/javaparser-core-3.28.2.jar" Associator ... occurrences-pmd.csv ... association-pmd.jsonl
# 12 eligible_method, 2 out_of_scope (NcssCount de nivel de classe)

# runs/commons-lang-3.20.0-2026-10-01/logs/build-dedup-input.ps1 monta o JSONL de entrada do Deduplicator
java -cp out Deduplicator --in dedup-input-all.jsonl --out dedup-results.jsonl
# raw_total=26 unique_total=26
```

## Métricas

```powershell
runs/commons-lang-3.20.0-2026-10-01/logs/compute-metrics.ps1
# Long Method: U=3829 A=13 B=12 intersecao=11 uniao=14 Jaccard=0.7857
# Long Parameter List: U=3829 A=1 B=0 intersecao=0 uniao=1 Jaccard=0.0000
```

## Reprocessamento determinístico

`MethodInventoryExtractor` reexecutado contra o mesmo `src/main/java`: saída
idêntica byte-a-byte (`Compare-Object` sem diferenças).

## Resultado resumido

Ver `docs/DIARIO-EXECUCAO.md` seção 5 para o checklist completo (piloto APROVADO).
