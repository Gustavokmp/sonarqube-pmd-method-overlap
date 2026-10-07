# Resultados finais do experimento

Consolidação exigida pelo PROTOCOLO.md seção 24, ao final das 4 execuções
reais (piloto aprovado + 3 projetos subsequentes). Este documento não
introduz nenhuma decisão metodológica nova — apenas sintetiza o que já
está registrado em `docs/DIARIO-EXECUCAO.md` (registro detalhado de
evidências por projeto; no momento da execução, o `STATUS.md`) e nos
artefatos em `runs/`.

Data de consolidação: 2026-10-01. Revisão documental posterior: 2026-10-07
(correções de redação, versões do ambiente e limitações; nenhum resultado
numérico foi alterado).

---

## 1. Resumo do que foi executado

Comparação da convergência/divergência entre SonarQube (`java:S138`,
`java:S107`) e PMD (`NcssCount`, `ExcessiveParameterList`) na detecção de
Long Method e Long Parameter List, em 4 projetos Java reais, com protocolo
congelado após aprovação do piloto (PROTOCOLO.md seção 2/17):

| Ordem | Projeto | Versão | Papel | Status |
|---|---|---|---|---|
| 1 | Apache Commons Lang | `3.20.0` | Piloto | CONCLUÍDO E APROVADO |
| 2 | Hibernate ORM | `7.2.6.Final` | Projeto real | CONCLUÍDO |
| 3 | Spring Framework | `6.2.16` | Projeto real | CONCLUÍDO |
| 4 | Quarkus | `3.32.1` | Projeto real | CONCLUÍDO |

Para cada projeto foi executado o pipeline completo: checkout → escopo/
inventário de métodos elegíveis (JavaParser) → build → SonarQube → PMD →
normalização (associação por AST + deduplicação) → cobertura → métricas →
validação final (invariantes + reprocessamento determinístico). Nenhuma
decisão metodológica (projeto, versão, regra, threshold, escopo, definição
de método elegível, ferramenta, critério de cálculo) foi alterada após a
aprovação do piloto — nenhum bloqueio foi necessário em nenhum dos 4
projetos.

---

## 2. Tabela de métricas por projeto e smell

| Projeto | Smell | \|U\| | \|A\| (Sonar) | \|B\| (PMD) | Sonar % | PMD % | Interseção | Só Sonar | Só PMD | União | Jaccard |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Commons Lang 3.20.0 | Long Method | 3829 | 13 | 12 | 0.3395% | 0.3134% | 11 | 2 | 1 | 14 | 0.7857 |
| Commons Lang 3.20.0 | Long Parameter List | 3829 | 1 | 0 | 0.0261% | 0.0000% | 0 | 1 | 0 | 1 | 0.0000 |
| Hibernate ORM 7.2.6.Final | Long Method | 48102 | 260 | 126 | 0.5405% | 0.2619% | 125 | 135 | 1 | 261 | 0.4789 |
| Hibernate ORM 7.2.6.Final | Long Parameter List | 48102 | 126 | 64 | 0.2619% | 0.1331% | 47 | 79 | 17 | 143 | 0.3287 |
| Spring Framework 6.2.16 | Long Method | 35236 | 101 | 81 | 0.2866% | 0.2299% | 74 | 27 | 7 | 108 | 0.6852 |
| Spring Framework 6.2.16 | Long Parameter List | 35236 | 10 | 0 | 0.0284% | 0.0000% | 0 | 10 | 0 | 10 | 0.0000 |
| Quarkus 3.32.1 | Long Method | 44165 | 348 | 169 | 0.7880% | 0.3827% | 161 | 187 | 8 | 356 | 0.4522 |
| Quarkus 3.32.1 | Long Parameter List | 44165 | 292 | 170 | 0.6612% | 0.3849% | 156 | 136 | 14 | 306 | 0.5098 |

Fórmulas aplicadas conforme PROTOCOLO.md seção 15 (validadas por
`Metrics --self-test` na seção 4 e aplicadas identicamente nos 4
projetos). Casos especiais de Jaccard: Commons Lang e Spring Framework
tiveram `B=0` para Long Parameter List (união ≠ 0) → Jaccard = `0` (caso
"apenas um conjunto vazio" da seção 15, não `N/A`); nenhum projeto teve
`|U|=0` ou `|A∪B|=0`.

Artefato tabular: [`metricas-finais.csv`](metricas-finais.csv).

**Interpretação (apenas descritiva — o protocolo seção 1/15 proíbe
inferir qual ferramenta é "melhor" ou mais "correta"):** a convergência
(Jaccard) variou de 0,00 (Long Parameter List quando PMD não sinalizou
nenhum método em 2 dos 4 projetos) a 0,79 (Long Method no piloto); em
nenhum projeto o PMD sinalizou mais métodos elegíveis do que o SonarQube.

---

## 3. Configuração efetiva de cada ferramenta

Idêntica nos 4 projetos (protocolo congelado após o piloto):

### SonarQube

- Versão: `26.9.0.129388` (SonarQube Community Build), confirmada via
  `/api/server/version` na validação da baseline (seção 3 do diário).
  Imagem Docker `sonarqube:26.9.0.129388-community`
  (`sha256:4905574ab8584dcac1a06c01cdc43a4ce9e369723ac4a7ab1d029c1bf71e6fe9`)
  com `sonar-java-plugin` `8.41.0.47177`, sem plugins adicionais nos volumes
  (evidência coletada a posteriori, em 2026-10-07 — ver
  `docs/ambiente-sonarqube.md`).
- Quality Profile exclusivo `exp-mestrado-long-smells`, contendo somente:
  - `java:S138` ("Methods should not have too many lines"): `max=75`.
    Comportamento de fronteira observado na fixture de fronteira (seção 4
    do diário): sinalizou método de 76 linhas e não sinalizou o de 75, isto
    é, atuou como limite estrito (`> 75`) nessa configuração. A definição
    interna da medida "lines" não foi estabelecida (ver
    `results/analises-complementares/assimetria-e-divergencias.md`).
  - `java:S107` ("Methods should not have too many parameters"):
    `max=7` (parâmetro `constructorMax` mantido no default, irrelevante —
    construtores fora da unidade de comparação). Sinalizou métodos com `8`
    parâmetros e não os de `7` (`> 7`). Na fixture sintética de 21 casos
    (`results/analises-complementares/s107-annotation-validation.md`), a
    regra deixou de sinalizar métodos com mais de 7 parâmetros quando eles
    tinham determinadas anotações (Jackson, JAX-RS, `@Inject`,
    `@Autowired`, `lombok.Builder`, Micronaut, `@RequestMapping` e atalhos
    Spring), anotação com símbolo não resolvido ou eram sobrescrita
    (override). Trata-se de comportamento observado empiricamente na
    configuração utilizada (sem `sonar.java.libraries`), não de definição
    geral da regra; o código-fonte da versão `8.41.0.47177` não explica a
    não sinalização de `@RequestMapping`/`@GetMapping`.
- `sonar.java.libraries` não configurado em nenhum dos 4 projetos (decisão
  consistente desde o piloto). A ausência não impediu a execução das
  análises, mas a validação complementar indicou que condições de
  resolução semântica (anotações e relações de sobrescrita) podem
  influenciar o comportamento observado de `java:S107`. Esse aspecto é
  tratado como ameaça à validade da comparação de Long Parameter List. O
  PROTOCOLO.md seção 10 prevê fornecer "bytecode e dependências sempre que
  a análise Java exigir"; a execução forneceu somente `sonar.java.binaries`
  (ver erratum no final do PROTOCOLO.md).

### PMD

- Versão: `7.27.0` (binário oficial, commit
  `360072ec0489c04167501c310e42f0af5d3cfd7b`), confirmada via
  `pmd.bat --version`.
- Ruleset exclusivo `configs/pmd-ruleset-exp-mestrado-long-smells.xml`,
  contendo somente:
  - `category/java/design.xml/NcssCount`: `methodReportLevel=60`.
    Comportamento de fronteira observado: sinalizou NCSS `60` (`>= 60`),
    confirmado também nos dados reais. Também gera ocorrências de
    classe/construtor (antecipado pela seção 13 do protocolo) —
    classificadas `out_of_scope` na normalização.
  - `category/java/design.xml/ExcessiveParameterList`: `minimum=10`.
    Sinalizou métodos com `10` parâmetros (`>= 10`). Também dispara para
    construtores (achado confirmado no piloto) — classificado `out_of_scope`.

**Assimetria relevante (seção 4 do diário, observada na fixture de
fronteira e nos dados dos 4 projetos):** nas configurações utilizadas, as
regras do SonarQube atuaram como limite exclusivo (`>`) e as do PMD como
limite inclusivo (`>=`).

### JavaParser (inventário de métodos elegíveis)

- `javaparser-core 3.28.2`, ferramenta própria
  (`scripts/method-inventory/src/MethodInventoryExtractor.java`), mesma
  implementação usada nos 4 projetos. Identificador de método:
  `project + commit + relative_path + qualified_type + method_signature(parameter_types)`
  (seção 8), com resolução de *erasure* de bounds genéricos (corrigida no
  piloto, sem regressão nos 3 projetos seguintes).

---

## 4. Cobertura alcançada

| Projeto | Arquivos `.java` de produção | SonarQube | PMD | JavaParser | Observação |
|---|---:|---:|---:|---:|---|
| Commons Lang 3.20.0 | 259 | 259/259 | 259/259 | 259/259 | Cobertura integral nos 3 componentes |
| Hibernate ORM 7.2.6.Final | 6605 | 6605/6605 | 6601/6605 | 6604/6605 | Cobertura efetiva diferente entre os componentes, embora o escopo lógico de entrada tenha sido o mesmo. 5/6605 arquivos (0,076%) não processados por pelo menos um componente, com causa raiz isolada e reproduzida (enum local no JavaParser; `Cloneable<T>` sombreado no PMD). Impacto avaliado na seção 11 |
| Spring Framework 6.2.16 | 5124 | 5124/5124 | 5124/5124 | 5124/5124 | Cobertura integral nos 3 componentes |
| Quarkus 3.32.1 | 7510 | 7510/7510 | 7510/7510 | 7510/7510 | Cobertura integral nos 3 componentes |

SonarQube, PMD e inventário receberam o mesmo escopo lógico de arquivos; a
cobertura efetiva foi reconciliada por projeto (PROTOCOLO.md seção 9/17) e
só no Hibernate ORM diferiu entre os componentes. As 6 ocorrências brutas do
`Dialect.java` (2 do SonarQube, 4 do PMD; 3 delas em métodos e 1 em nível de
classe, no PMD) permaneceram `unassociated`: como o arquivo não foi
parseado, seus métodos não integram `U`, e a análise de sensibilidade da
seção 11 (`U_common`) não os recupera.

Evidência da cobertura do SonarQube: `sonar-scanner-output.txt` (Commons
Lang, Spring, Quarkus: "Using ECJ batch to parse N Main java source files").
No Hibernate ORM não há log do scanner preservado; a cobertura de 6605
arquivos é inferida de `logs/check-sonar-status-output.txt` (aviso de
*blame* para 6605 arquivos) e da exportação das issues.

---

## 5. Arquivos e entidades excluídos (critérios por projeto)

Exclusões sempre objetivas e documentadas por inspeção do próprio build do
projeto (nunca por conveniência) — detalhamento completo em
`docs/DIARIO-EXECUCAO.md`, seções 5/6/7/8 (subseção Escopo de cada projeto):

- **Commons Lang 3.20.0:** projeto Maven de módulo único; excluídos
  `src/test/java`, `src/site`, `src/conf` (configs de linters do próprio
  projeto), `src/media`, `src/assembly`, raiz (docs/metadados), `.github`,
  `.mvn` — 354 arquivos excluídos de 613 versionados.
- **Hibernate ORM 7.2.6.Final:** 17 módulos de produção identificados por
  critério objetivo (módulo com plugin de publicação Gradle); excluídos
  módulos de tooling interno de build e `hibernate-testing` (biblioteca de
  apoio a testes). 6605 arquivos incluídos de 17673 versionados.
- **Spring Framework 6.2.16:** 23 módulos `spring-*` de produção por
  critério objetivo (`moduleProjects` do próprio `build.gradle`); excluídos
  `framework-api`/`framework-bom`/`framework-platform` (sem `.java`),
  `framework-docs`, `integration-tests`, `buildSrc`, além de
  `src/test`/`src/testFixtures`/`src/jmh`/`src/main/kotlin` dentro dos
  módulos incluídos. Caso especial incluído: `spring-core/src/main/java21`
  (MRJAR). 5124 arquivos incluídos de 10975 versionados.
- **Quarkus 3.32.1:** 574 de 630 diretórios `src/main/java` candidatos
  (dentro de `core/`, `extensions/`, `devtools/`, `independent-projects/`)
  classificados como produção; excluídos por subárvore inteira
  (`bom/*`, `build-parent`, `integration-tests`, `test-framework`, `tcks`,
  `docs`) e por módulo específico (56 diretórios, cada um com justificativa
  própria: arquétipos Maven, templates de Codestarts, TCKs, benchmarks
  JMH, bibliotecas de apoio a teste publicadas, ferramentas internas de
  build/doc). 7510 arquivos `.java` processados.

---

## 6. Erros e limitações

| Projeto | Falhas de parsing (JavaParser) | Erros de processamento (PMD) | Observação |
|---|---:|---:|---|
| Commons Lang 3.20.0 | 0 | 0 | — |
| Hibernate ORM 7.2.6.Final | 1 (`Dialect.java`, enum local — limitação do JavaParser 3.28.2) | 4 (`Cloneable<T>` local sombreando `java.lang.Cloneable` — bug de resolução de símbolos do PMD 7.27.0) | Ambas reproduzidas isoladamente em `scripts/fixtures/boundary/`; métodos afetados ficaram `unassociated`, nunca atribuídos a nenhuma ferramenta |
| Spring Framework 6.2.16 | 0 | 0 | — |
| Quarkus 3.32.1 | 0 | 0 | — |

Limitação geral registrada desde a validação da baseline (seção 3 do
diário): a `java:S107` deixou de sinalizar, na configuração utilizada,
métodos com anotações associadas a DI/frameworks (Spring/CDI/JAX-RS/
Micronaut), com anotação não resolvida ou com sobrescrita (ver seção 3 e
seção 11, item 3). Isso é relevante para a interpretação dos resultados de
Hibernate/Spring/Quarkus e foi observado empiricamente; não é uma falha de
execução.

---

## 7. Ocorrências pendentes

Nenhuma. Em todos os 4 projetos, 100% das ocorrências `ambiguous`/
`unassociated` foram resolvidas antes da liberação das métricas finais
(PROTOCOLO.md seção 13): Commons Lang e Spring Framework tiveram `0` em
ambos os estados; Hibernate ORM teve 2 (SonarQube) + 4 (PMD)
`unassociated`, todos com causa raiz identificada (seção 6 acima) e
corretamente excluídos de `A`/`B`; Quarkus teve `0` em ambos os estados
apesar da escala (574 módulos).

---

## 8. Caminhos dos artefatos

| Projeto | Diretório de execução (`run_id`) |
|---|---|
| Validação sintética | `runs/synthetic-2026-10-01/` |
| Commons Lang 3.20.0 (piloto) | `runs/commons-lang-3.20.0-2026-10-01/` |
| Hibernate ORM 7.2.6.Final | `runs/hibernate-orm-7.2.6.Final-2026-10-01/` |
| Spring Framework 6.2.16 | `runs/spring-framework-6.2.16-2026-10-01/` |
| Quarkus 3.32.1 | `runs/quarkus-3.32.1-2026-10-01/` |

Todos os diretórios têm `inventories/`, `logs/` e `raw/`; `reprocess-check/`
existe nos 4 projetos reais; `config/` existe apenas em Hibernate, Spring e
Quarkus (o piloto usou os parâmetros do SonarScanner diretamente, descritos
em `logs/comandos.md`). Os relatórios brutos foram preservados sem alteração
(`raw/sonarqube-issues.jsonl`, `raw/pmd-output.xml`/`.txt`), junto com os
inventários (`inventory-methods.jsonl`, `association-*.jsonl`,
`dedup-results.jsonl`, `metrics-resultado.json`) e os logs de cada etapa.

Diferenças reais de conteúdo entre os runs (limitações de rastreabilidade,
sem efeito sobre os resultados):

| Run | Particularidade |
|---|---|
| Commons Lang (piloto) | Scripts de normalização com nomes próprios (`build-dedup-input.ps1`, `compute-metrics.ps1`); comparação de reprocessamento feita com `Compare-Object` (os demais usam SHA-256); sem `config/`. |
| Hibernate ORM | `logs/comandos.md` cobre checkout, escopo, inventário e build; as etapas de SonarQube, PMD e normalização estão nos scripts de `logs/`. Sem `sonar-scanner-output.txt` (ver seção 4). |
| Spring Framework | Sem `logs/comandos.md`; comandos nos scripts de `logs/` (`run-pmd.ps1`, `create-sonar-project.ps1`, `normalize-step*.ps1`, etc.). |
| Quarkus | Sem `logs/comandos.md`; escopo registrado por diretórios (`scope-src-main-java-*.txt`) em vez de lista de arquivos. |
| Validação sintética | `raw/sonarqube-issues-boundary.json` é um resumo organizado das issues da fixture de fronteira (campos `nota` e `conclusao`), não a exportação bruta da API. As saídas dos `--self-test` não foram preservadas (os comandos estão em `logs/comandos.md`; podem ser reexecutados). |

Os scripts e as configurações dos runs contêm caminhos absolutos da máquina
de execução (`C:\Users\...`) e, no `raw/pmd-output.xml`, caminhos de
diretórios temporários de *staging*; foram preservados como registro e devem
ser adaptados em uma reexecução.

Configuração das ferramentas: `configs/sonarqube-quality-profile-exp-mestrado-long-smells.xml`,
`configs/pmd-ruleset-exp-mestrado-long-smells.xml`. Ferramentas de
pipeline: `scripts/method-inventory/` (inventário, associação, dedup),
`scripts/sonarqube/export-issues-paginated.ps1`.

---

## 9. Comandos completos para reprodução

Pré-requisitos comuns: JDK 21 (`C:\Program Files\Java\jdk-21`), PMD 7.27.0
em `sources/pmd-bin-7.27.0/`, SonarScanner CLI 8.1.0.6389 em
`sources/sonar-scanner-8.1.0.6389-windows-x64/`, SonarQube Community
Build `26.9.0.129388` acessível em `127.0.0.1:9000` (imagem Docker
`sonarqube:26.9.0.129388-community`, digest em `docs/ambiente-sonarqube.md`;
o comando exato de criação do container `sonarqube-pilot` não foi
preservado — porta publicada apenas em `127.0.0.1:9000` e volumes nomeados
`sonarqube_data`, `sonarqube_extensions` e `sonarqube_logs`), credenciais em
`.env` (`SONARQUBE_URL`/`SONARQUBE_TOKEN`, não versionado; modelo em
`.env.example`). O JavaParser (`javaparser-core-3.28.2.jar`) deve ser baixado
conforme `scripts/method-inventory/README.md`.

### Checkout (um comando por projeto, substituindo tag)

```powershell
git clone --depth 1 --branch <tag> <url> sources/<destino>
```

| Projeto | Tag | URL |
|---|---|---|
| Commons Lang | `rel/commons-lang-3.20.0` | `https://github.com/apache/commons-lang.git` |
| Hibernate ORM | `7.2.6` | `https://github.com/hibernate/hibernate-orm.git` |
| Spring Framework | `v6.2.16` | `https://github.com/spring-projects/spring-framework.git` |
| Quarkus | `3.32.1` | `https://github.com/quarkusio/quarkus.git` |

### Inventário de métodos elegíveis (por projeto, após montar o staging/escopo — ver scripts `build-scope-staging.ps1` de cada `run_id`)

```powershell
java -cp "scripts/method-inventory/out;scripts/method-inventory/lib/javaparser-core-3.28.2.jar" MethodInventoryExtractor `
  --project <nome> --commit <sha> --root <diretorio-ou-staging> --out <inventory-methods.jsonl>
```

### Build (um comando por projeto)

| Projeto | Comando |
|---|---|
| Commons Lang | `javac --release 8 -encoding ISO-8859-1 -d target/classes @sources.txt` |
| Hibernate ORM | `./gradlew compileJava -Dmain.jdk.version=21 -Dtest.jdk.version=21 --console=plain` |
| Spring Framework | `./gradlew.bat compileJava --console=plain` (+ `./gradlew.bat :spring-core:compileJava21Java` para o sourceSet MRJAR) |
| Quarkus | `./mvnw.cmd -Dquickly -B` |

### SonarQube (análise + exportação, por projeto)

```powershell
sonar-scanner "-Dproject.settings=<sonar-project.properties>" "-Dsonar.host.url=$url" "-Dsonar.token=$token"
./scripts/sonarqube/export-issues-paginated.ps1 -ProjectKey <key> -Rules "java:S138,java:S107" -OutFile <sonarqube-issues.jsonl>
```

### PMD (por projeto)

```powershell
pmd check -d <diretorio(s)> -R configs/pmd-ruleset-exp-mestrado-long-smells.xml -f xml -r <pmd-output.xml> --no-cache
```

### Normalização, cobertura, métricas e validação final

Scripts específicos de cada `run_id` em `logs/` (por exemplo
`normalize-step1-association.ps1`, `normalize-step2-dedup.ps1`,
`compute-metrics.ps1`, `check-invariantes.ps1` e `reprocess-check.ps1`; no
piloto, `build-dedup-input.ps1`, `compute-metrics.ps1` e
`reprocess-check*.ps1`) reutilizam as mesmas ferramentas (`Associator.java`,
`Deduplicator.java`), sem reexecutar SonarQube/PMD.

Reprocessamento: os cinco artefatos principais (`association-sonarqube.jsonl`,
`association-pmd.jsonl`, `dedup-input-all.jsonl`, `dedup-results.jsonl` e
`metrics-resultado.json`) foram regenerados e resultaram idênticos nos 4
projetos (Hibernate, Spring e Quarkus: SHA-256, resultado `MATCH=True` em
`logs/reprocess-check-output.txt`; Commons Lang: `Compare-Object`). Os
`occurrences-*.csv` do piloto diferem apenas na linha de comentário do
cabeçalho. Os valores dos hashes não foram gravados nos logs originais; o
arquivo `SHA256SUMS.txt` na raiz do repositório registra os hashes dos
artefatos na versão publicada. O reprocessamento usa os relatórios brutos
preservados, mas a associação reanalisa o código-fonte; portanto exige o
checkout do commit da Tabela 3.1, o JavaParser e os scripts do `run_id`
(que contêm caminhos absolutos e, nos scripts de reprocessamento, o
valor fixo de `|U|` do projeto).

---

## 10. Pacote exportável

Script de empacotamento: `scripts/export-package.ps1`. Gera um `.zip` com os
arquivos versionados do repositório (lista obtida do Git), com caminhos
internos portáveis (`/`), sem credenciais, caches, volumes Docker,
dependências baixadas ou `sources/` (re-clonável, gitignored). Não inclui o
próprio `.zip` nem o `SHA256SUMS.txt`. Script de conferência:
`scripts/generate-checksums.ps1`, que grava `SHA256SUMS.txt` (formato
compatível com `sha256sum -c`) com os hashes de todos os arquivos
versionados, inclusive do pacote. O `.gitattributes` (`* -text`) impede a conversão de fim de linha pelo Git, de modo que os hashes valem para qualquer clone do repositório.

---

## 11. Análises complementares de robustez

Após a consolidação acima (seções 1–10), 4 análises complementares/
sensibilidade pós-protocolo foram executadas (mesma data, 2026-10-01).
**Nenhuma delas altera os resultados das seções 1–10 deste documento** —
são adições, não substituições. Nenhum artefato original foi sobrescrito;
nenhuma decisão metodológica (projeto, versão, regra, threshold, escopo,
definição de método elegível) foi alterada; nenhum bloqueio foi
necessário. Detalhe completo em `results/analises-complementares/RESUMO.md`.

1. **Sensibilidade do escopo do Spring Framework** (exclusão de
   `spring-test`/`spring-core-test`, 331 arquivos / 3241 métodos
   elegíveis, −9,2% de `U`): não altera o padrão descritivo. Long Method
   Jaccard `0,6852 → 0,6792`; Long Parameter List permanece `0,0000` nas
   duas variantes. Ver `results/analises-complementares/spring-scope-sensitivity.md`.
2. **Sensibilidade de cobertura do Hibernate ORM** (`U_common` restrito a
   6600/6605 arquivos processados com sucesso pelas 3 ferramentas, 14
   métodos elegíveis removidos): impacto nulo em qualquer métrica de
   convergência — Jaccard idêntico em Long Method (`0,4789`) e Long
   Parameter List (`0,3287`), pois nenhum dos métodos removidos estava
   sinalizado por nenhuma ferramenta. Ver
   `results/analises-complementares/hibernate-common-coverage-sensitivity.md`.
3. **Validação experimental de `java:S107` com anotações** (fixture
   sintética isolada, 21 casos, mesmo SonarQube/SonarScanner/Quality
   Profile do experimento, sem `sonar.java.libraries`): na fixture, deixaram
   de ser sinalizados métodos com Jackson `@JsonCreator`, JAX-RS
   `@GET/@POST/@PUT/@PATCH`, `@Inject`, `@Autowired`, `lombok.Builder`,
   verbos Micronaut e também `@RequestMapping`/atalhos Spring (este último
   caso não é explicado pelo código-fonte da versão `8.41.0.47177` do
   SonarJava). Também não foram sinalizados métodos com anotação de símbolo
   não resolvido e métodos que são ou parecem ser *override* — fatores de
   interpretação (não de invalidação) dos resultados de Hibernate/Spring/
   Quarkus, dado que o experimento roda sem `sonar.java.libraries`. As
   anotações de terceiros são *stubs* locais. Ver
   `results/analises-complementares/s107-annotation-validation.md`.
4. **Assimetria e divergências** (sobreposição direcional nos 8 casos
   projeto×smell; decomposição de exclusivos de Long Parameter List por
   nº de parâmetros e anotações via AST; decomposição de divergências de
   Long Method por linhas físicas/NCSS): `PMD→SQ` é maior que `SQ→PMD`
   nos 6 casos com `B>0`. Os 226 métodos só-Sonar de Long Parameter List
   têm 8–9 parâmetros e os 31 só-PMD têm `>=10`, padrão compatível com os
   limiares; nenhum dos 31 só-PMD carrega anotação da lista de exceções
   observada na fixture (15 têm `@Override`, compatível com o mecanismo de
   override do item 3, e 16 permanecem sem explicação). Em Long Method, 10
   dos 17 métodos só-PMD têm 75 ou mais linhas físicas (os outros 7 têm
   menos), de modo que a diferença de limiar não explica a maioria dos
   casos; a definição interna da medida "lines" da S138 não foi
   estabelecida. Lista por método em
   `results/analises-complementares/long-method-pmd-only-physical-lines.csv`.
   Ver `results/analises-complementares/assimetria-e-divergencias.md`.

Em nenhum dos 4 casos a análise complementar alterou a interpretação
descritiva original das métricas publicadas na seção 2 deste documento.
