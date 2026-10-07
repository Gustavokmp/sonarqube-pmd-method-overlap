# Validação sintética — 2026-10-01

`run_id`: `synthetic-2026-10-01`

Esta execução NÃO faz parte dos projetos reais do experimento (Apache Commons
Lang, Hibernate ORM, Spring Framework, Quarkus). Valida apenas a implementação
do pipeline (PROTOCOLO.md seção 16), usando fixtures sintéticos em
`scripts/fixtures/`.

## Comandos executados

### Inventário de métodos (ferramenta própria, JavaParser 3.28.2)

```powershell
cd scripts/method-inventory
javac -cp lib/javaparser-core-3.28.2.jar -d out src/MethodInventoryExtractor.java
java -cp "out;lib/javaparser-core-3.28.2.jar" MethodInventoryExtractor --self-test
java -cp "out;lib/javaparser-core-3.28.2.jar" MethodInventoryExtractor `
  --project exp-mestrado-fixtures --commit synthetic `
  --root ../fixtures/inventory --out ../../runs/synthetic-2026-10-01/inventories/inventory-fixtures.jsonl
```

### PMD 7.27.0

```powershell
cd sources/pmd-bin-7.27.0/bin
./pmd.bat check -d <repo>/scripts/fixtures `
  -R <repo>/configs/pmd-ruleset-exp-mestrado-long-smells.xml `
  -f text --no-cache -r <repo>/runs/synthetic-2026-10-01/raw/pmd-fixtures-output.txt
```

### SonarQube 26.9.0.129388 (via SonarScanner CLI 8.1.0.6389)

```powershell
cd scripts/fixtures/boundary
sonar-scanner.bat -Dsonar.projectKey=exp-mestrado-boundary-fixtures `
  -Dsonar.sources=. -Dsonar.host.url=$baseUrl -Dsonar.token=$token `
  -Dsonar.java.binaries=. -Dsonar.sourceEncoding=UTF-8
```

O Quality Profile `exp-mestrado-long-smells` foi associado ao projeto via
`POST /api/qualityprofiles/add_project` antes da análise. Após a coleta dos
issues (`GET /api/issues/search?componentKeys=exp-mestrado-boundary-fixtures&rules=java:S138,java:S107`),
o projeto efêmero foi removido via `POST /api/projects/delete`.

### Associação por localização (Associator) e deduplicação (Deduplicator)

```powershell
cd scripts/method-inventory
javac -cp lib/javaparser-core-3.28.2.jar -d out src/Associator.java src/Deduplicator.java src/Metrics.java
java -cp "out;lib/javaparser-core-3.28.2.jar" Associator --self-test
java -cp "out" Deduplicator --self-test
java -cp "out" Metrics --self-test

java -cp "out;lib/javaparser-core-3.28.2.jar" Associator `
  --project exp-mestrado-fixtures --commit synthetic `
  --root ../fixtures/inventory `
  --occurrences ../fixtures/association/occorrencias-sinteticas.csv `
  --out ../../runs/synthetic-2026-10-01/inventories/association-results.jsonl

java -cp "out;lib/javaparser-core-3.28.2.jar" Associator `
  --project exp-mestrado-fixtures --commit synthetic `
  --root ../fixtures/association `
  --occurrences ../fixtures/association/occorrencias-ambiguas.csv `
  --out ../../runs/synthetic-2026-10-01/inventories/association-results-ambiguous.jsonl

java -cp "out" Deduplicator `
  --in ../fixtures/association/alertas-duplicados-exemplo.jsonl `
  --out ../../runs/synthetic-2026-10-01/inventories/dedup-results.jsonl
```

Reprocessamento determinístico: os dois comandos acima (Associator e
Deduplicator, com saída para `*-rerun.jsonl`) foram reexecutados sobre as
mesmas entradas e comparados via `Get-FileHash -Algorithm SHA256` — saídas
byte-idênticas.

### Paginação SonarQube (fixture com 150 métodos violando S107)

```powershell
cd scripts/fixtures/pagination
sonar-scanner.bat -Dsonar.projectKey=exp-mestrado-pagination-fixtures `
  -Dsonar.sources=. -Dsonar.host.url=$baseUrl -Dsonar.token=$token `
  -Dsonar.java.binaries=. -Dsonar.sourceEncoding=UTF-8

cd ../../..
./scripts/sonarqube/export-issues-paginated.ps1 `
  -ProjectKey exp-mestrado-pagination-fixtures -Rules "java:S138,java:S107" `
  -OutFile runs/synthetic-2026-10-01/raw/sonarqube-issues-pagination.jsonl
```

Projeto efêmero `exp-mestrado-pagination-fixtures` removido via
`POST /api/projects/delete` após a coleta (não é um projeto do experimento).

## Resultado resumido

Ver `docs/DIARIO-EXECUCAO.md` seção 4 para o checklist completo (13/13 — CONCLUÍDA) e
`raw/`/`inventories/` para as saídas brutas preservadas.
