# Diário de execução do experimento

Registro histórico e detalhado da execução (preparação, validação da baseline,
validação sintética, quatro projetos e análises complementares), mantido com o
texto original de 2026-10-01. Os arquivos [`../STATUS.md`](../STATUS.md) e
[`../README.md`](../README.md) trazem apenas o resumo atual.

Observações de leitura:

- As numerações "seção N" citadas em `runs/`, `scripts/` e `results/` sob o
  nome "STATUS.md seção N" referem-se às seções deste diário, que na data da
  execução era o próprio `STATUS.md`.
- Termos como "nativo" e "exceção documentada" para `java:S107`/`java:S138`
  refletem a leitura da época. A interpretação vigente é a de
  [`../results/consolidado-2026-10-01/RESULTADOS-FINAIS.md`](../results/consolidado-2026-10-01/RESULTADOS-FINAIS.md)
  (seção 3): comportamento observado empiricamente na configuração utilizada.
- Referências a "seção 24" e demais seções do protocolo seguem o `PROTOCOLO.md`.

---

## Estado geral

**Fase atual:** piloto Apache Commons Lang (seção 5) CONCLUÍDO E APROVADO; Hibernate ORM (seção 6) CONCLUÍDO; Spring Framework (seção 7) CONCLUÍDO; Quarkus (seção 8) CONCLUÍDO; consolidação dos resultados finais (seção 24) CONCLUÍDA — **experimento completo**  
**Projeto atual:** nenhum — todos os 4 projetos concluídos; consolidação final em `results/consolidado-2026-10-01/`  
**Status do piloto:** APROVADO  
**Protocolo congelado:** SIM (PROTOCOLO.md seção 2: "O protocolo deve permanecer congelado após a aprovação do piloto")  
**Última atualização:** 2026-10-01 — Consolidação final dos resultados (PROTOCOLO.md seção 24) concluída em
`results/consolidado-2026-10-01/`: `RESULTADOS-FINAIS.md` (resumo do executado, tabela de métricas pelos 4 projetos × 2 smells, configuração efetiva das ferramentas, cobertura, exclusões, erros/limitações, ocorrências pendentes — nenhuma —, caminhos dos artefatos e comandos completos de reprodução), `metricas-finais.csv` (tabela tabular) e `exp-mestrado-pacote-exportavel-2026-10-01.zip` (pacote exportável gerado por `scripts/export-package.ps1`, 268 arquivos, sem `.env`/credenciais/`sources/`/binários baixados — validado automaticamente pelo script). **Experimento completo: os 4 projetos (Apache Commons Lang 3.20.0, Hibernate ORM 7.2.6.Final, Spring Framework 6.2.16, Quarkus 3.32.1) têm métricas finais validadas e consolidadas.** Nenhuma ação pendente. Em seguida (mesmo dia), 4 análises complementares/sensibilidade pós-protocolo foram executadas sem alterar o experimento original — ver seção "Análises complementares pós-protocolo" abaixo e `results/analises-complementares/RESUMO.md`.

---

## 1. Critério de registro

Este diário registrou o estado operacional de cada etapa: checklist, artefatos
produzidos, falhas e próximo passo, sem remover o histórico de bloqueios
relevantes. As decisões metodológicas permanentes pertencem ao `PROTOCOLO.md`.

---

## 2. Preparação do ambiente

- [x] Sistema operacional registrado
- [x] Docker verificado
- [x] Git verificado
- [x] JDKs disponíveis registrados
- [x] CPU/memória registradas
- [x] Portas relevantes verificadas
- [x] Containers existentes inspecionados
- [x] Estrutura de diretórios criada
- [x] `.gitignore` criado
- [x] `.env.example` criado
- [x] Ambiente isolado definido

### Observações

- **Sistema operacional:** Microsoft Windows 11 Pro, versão 10.0.26200, 64 bits.
- **CPU:** 13th Gen Intel(R) Core(TM) i7-13620H — 10 núcleos físicos / 16 processadores lógicos.
- **Memória:** 31,74 GB total, 15,62 GB livre no momento da coleta.
- **Docker:** versão `28.3.3` (build `980b856`), instalado e respondendo. Nenhum container existente (`docker ps -a` vazio).
- **Git:** versão `2.45.1.windows.1`.
- **JDKs disponíveis no host:**
  - JDK 21 (`21.0.9+7-LTS`) em `C:\Program Files\Java\jdk-21`, referenciado por `JAVA_HOME`.
  - JDK 1.8 (`jdk-1.8`) e JRE 1.8.0_461 disponíveis em `C:\Program Files (x86)\Java`.
  - JDK efetivo para build de cada projeto será decidido e registrado na etapa de build de cada projeto, conforme requisito mínimo do próprio projeto (seção 10 do protocolo).
- **Portas relevantes verificadas e livres no momento da coleta:** `9000` (SonarQube), `5432` (Postgres), `80`, `443`, `8080`.
- **Repositório git local:** inicializado em `exp-mestrado/` (commit inicial `5a44e2b`), sem remoto configurado. Nenhum push realizado.
- **Ambiente isolado:** SonarQube executado via Docker, container `sonarqube-pilot`, porta publicada apenas em `127.0.0.1:9000` (não exposta na rede). Dados persistidos em volumes Docker nomeados (`sonarqube_data`, `sonarqube_logs`, `sonarqube_extensions`), não versionados.
- **Estrutura de diretórios criada:** `configs/`, `scripts/`, `sources/`, `runs/`, `results/`, `docs/`, `README.md`, `.gitignore`, `.env.example`, `docs/fontes.md` (criado nesta etapa; fontes efetivamente consultadas são registradas progressivamente conforme usadas — ver `docs/fontes.md`).
- `sources/` foi adicionado ao `.gitignore` (repositórios dos projetos estudados são re-clonáveis e não devem ser versionados).

---

## 3. Validação da baseline

### SonarQube

- [x] Versão `26.9.0.129388` confirmada
- [x] `java:S138` disponível
- [x] parâmetro de `S138` confirmado
- [x] threshold `75` configurado
- [x] semântica do limite registrada (parcial — ver observações)
- [x] `java:S107` disponível
- [x] parâmetro de `S107` confirmado
- [x] threshold `7` configurado
- [x] comportamento referente a métodos confirmado

**Evidências (API do SonarQube em execução, `26.9.0.129388` confirmado via `/api/server/version`):**

- `java:S138` ("Methods should not have too many lines"): parâmetro único `max`, default `75`. Configurado no profile do experimento com `max=75`.
- `java:S107` ("Methods should not have too many parameters"): possui **dois** parâmetros — `max` (default `7`, aplica-se a métodos) e `constructorMax` (default `7`, aplica-se a construtores). Configurado `max=7`; `constructorMax` mantido no default (irrelevante, pois construtores estão fora da unidade de comparação — seção 7 do protocolo).
- `java:S107` documenta exceções nativas: métodos anotados com `@RequestMapping`/atalhos Spring, anotações JAX-RS, injeção de construtor `@Autowired`/`@Inject`, `@JsonCreator` e anotações Micronaut são ignorados pela regra independentemente da quantidade de parâmetros. Isso é comportamento nativo da regra (não configurado por nós) e deve ser documentado como fator de interpretação ao comparar com PMD nos projetos Spring/Quarkus.
- Semântica exata de `>` vs `>=` para S138/S107 ainda não testada em fronteira exata — fica para a seção 4 (validação sintética, boundary tests).
- Quality Profile Java `exp-mestrado-long-smells` criado vazio e populado somente com S138 (`max=75`) e S107 (`max=7`). Confirmado via API que somente essas 2 regras estão ativas. Backup XML exportado em `configs/sonarqube-quality-profile-exp-mestrado-long-smells.xml`.

### PMD

- [x] Versão `7.27.0` confirmada
- [x] `NcssCount` disponível
- [x] `methodReportLevel` confirmado
- [x] valor `60` configurado
- [x] semântica do limite registrada (parcial — ver observações)
- [x] `ExcessiveParameterList` disponível
- [x] propriedade `minimum` confirmada
- [x] valor `10` configurado
- [x] semântica do limite registrada (parcial — ver observações)

**Evidências (binário oficial `pmd-bin-7.27.0` baixado de GitHub Releases e executado localmente; `pmd.bat --version` confirma `PMD 7.27.0`, commit `360072ec0489c04167501c310e42f0af5d3cfd7b`):**

- `category/java/design.xml/NcssCount`: propriedades `methodReportLevel` (default `60`), `classReportLevel` (default `1500`), `ncssOptions`. Documentação oficial confirma que a regra mede NCSS de **classe, método ou construtor** — ou seja, gerará ocorrências para classes e construtores além de métodos elegíveis, exatamente como antecipado no protocolo (seção 13: devem ser classificadas `out_of_scope`).
- `category/java/design.xml/ExcessiveParameterList`: propriedade `minimum` (default `10`). **Achado relevante não antecipado explicitamente no protocolo:** teste de fumaça confirmou empiricamente que esta regra também dispara para **construtores** com muitos parâmetros, não apenas métodos. Como construtores estão fora da unidade de comparação (seção 7 do protocolo), essas ocorrências deverão ser classificadas `out_of_scope` na normalização (seção 13), de forma análoga ao caso já previsto para `NcssCount`/classes. Isto não é uma mudança metodológica (a definição de unidade de comparação não muda), apenas uma confirmação de que a camada de normalização precisa tratar esse caso.
- Teste de fumaça executado com ruleset `configs/pmd-ruleset-exp-mestrado-long-smells.xml` contra um arquivo Java sintético (`SmokeTest.java`, descartado após o teste): método com NCSS=64 foi sinalizado por `NcssCount` (64 > 60); método e construtor com 11 parâmetros foram sinalizados por `ExcessiveParameterList` (11 > 10); método com 2 parâmetros e método curto não foram sinalizados. **Atualização:** a semântica exata do operador nas fronteiras (NCSS=60, parâmetros=10) foi confirmada na seção 4 (validação sintética de boundary) — ambas as regras do PMD usam operador `>=` (disparam exatamente no valor configurado), diferente do SonarQube que usa `>` (estritamente maior). Ver seção 4 para a tabela completa.
- Ruleset do experimento salvo em `configs/pmd-ruleset-exp-mestrado-long-smells.xml`, contendo somente as duas regras com os parâmetros do protocolo.
- Distribuição oficial `pmd-bin-7.27.0` preservada em `sources/pmd-bin-7.27.0/` (ignorada pelo Git).

### Resultado da validação

**Status:** CONCLUÍDA (achados acima). Semântica exata de fronteira (`>` vs `>=`) confirmada posteriormente na seção 4 via execução real (SonarQube) e PMD contra fixtures de boundary.

**Diferenças encontradas:** nenhuma divergência em relação ao protocolo. Dois comportamentos nativos das ferramentas foram descobertos e documentados (exceções do S107 para DI/anotações; ExcessiveParameterList também cobre construtores) — não exigem alteração de protocolo, apenas tratamento correto na normalização (seção 13).

---

## 4. Validação sintética

- [x] Overloads
- [x] Tipos internos
- [x] Métodos × construtores
- [x] Métodos × classes
- [x] Associação por localização
- [x] Alertas duplicados
- [x] Boundary de Long Method
- [x] Boundary de Long Parameter List
- [x] Conjuntos vazios
- [x] Fórmulas das métricas
- [x] Paginação SonarQube
- [x] Validação do total exportado
- [x] Reprocessamento determinístico

**Status:** CONCLUÍDA (13/13) — decisão de engenharia e evidências abaixo.

### Decisão de engenharia (não é mudança metodológica)

Não há Maven/Gradle disponíveis no ambiente. O protocolo (seção 8) exige
parser/AST compatível com os projetos e proíbe regex como mecanismo
principal; os quatro projetos do experimento (Hibernate ORM, Spring
Framework, Quarkus, e em menor grau Commons Lang) usam sintaxe Java moderna
(records, sealed types, pattern matching), o que torna parsers antigos
(ex.: `javalang` em Python) inadequados. Decisão: implementar a extração do
inventário de métodos em Java puro usando **JavaParser 3.28.2** (baixado
diretamente do Maven Central, sem gerenciador de dependências), compilado e
executado com o próprio JDK 21 (`javac`/`java`), sem build tool. Ferramenta
em `scripts/method-inventory/` (ver `scripts/method-inventory/README.md`).
Isso é uma decisão operacional/de implementação, não uma decisão
metodológica do protocolo — não altera a definição de unidade de comparação,
regras, ferramentas ou parâmetros.

### Overloads / Tipos internos / Métodos × construtores / Métodos × classes

Fixture `scripts/fixtures/inventory/OverloadsAndInnerTypes.java` processado
pela ferramenta `MethodInventoryExtractor` (JavaParser). Resultado (10
métodos elegíveis, 0 colisões, 0 falhas de parsing — artefato completo em
`runs/synthetic-2026-10-01/inventories/inventory-fixtures.jsonl`):

- 4 overloads de `process(...)` com assinaturas distintas (`int`, `int,int`,
  `String`, `String,int...`) → identificadores únicos, sem colisão.
- Tipo membro `MemberType` e tipo membro aninhado `MemberType.DeeplyNestedMember`
  → métodos incluídos com `qualified_type` refletindo a cadeia de aninhamento
  (`OverloadsAndInnerTypes.MemberType.DeeplyNestedMember`).
- Tipo local (`LocalType`, declarado dentro de `localMethodHost()`) e tipo
  anônimo (`new Runnable(){...}` dentro de `anonymousMethodHost()`) →
  corretamente **excluídos** do inventário; apenas os métodos que os
  contêm (`localMethodHost`, `anonymousMethodHost`) aparecem.
- 2 construtores (`OverloadsAndInnerTypes()`, `OverloadsAndInnerTypes(int)`)
  → corretamente **excluídos**.
- Método de interface sem corpo (`abstractMethod`) → corretamente excluído;
  `defaultMethod`/`staticInterfaceMethod` (com corpo) → corretamente
  incluídos.
- Nenhum tipo (classe/interface) aparece como entrada do inventário — apenas
  seus métodos membros — confirmando a distinção métodos × classes na
  extração.
- Validação de colisão de identificadores exercida via modo `--self-test`
  da ferramenta (caso com IDs duplicados detectado corretamente; caso sem
  duplicatas retorna lista vazia). `SELF_TEST_RESULT=PASS`.

### Boundary de Long Method / Long Parameter List

Fixtures `scripts/fixtures/boundary/{LongMethodBoundary,NcssBoundary,ParamListBoundary}.java`,
processados pelo PMD 7.27.0 (ruleset do experimento) e por uma análise real
no SonarQube local (projeto efêmero `exp-mestrado-boundary-fixtures`, criado,
analisado com o Quality Profile `exp-mestrado-long-smells` e removido após a
coleta — não é um projeto do experimento). Evidências brutas em
`runs/synthetic-2026-10-01/raw/`.

**Semântica de fronteira confirmada empiricamente (corrige a nota "parcial"
da seção 3):**

| Regra | Parâmetro | Dispara em | Operador confirmado |
|---|---|---|---|
| `java:S138` | `max=75` | `76` linhas (75 linhas NÃO dispara) | estritamente maior (`>`) |
| `java:S107` | `max=7` | `8` parâmetros (7 parâmetros NÃO dispara) | estritamente maior (`>`) |
| PMD `NcssCount` | `methodReportLevel=60` | `60` (NCSS exatamente igual já dispara) | maior ou igual (`>=`) |
| PMD `ExcessiveParameterList` | `minimum=10` | `10` (parâmetros exatamente igual já dispara) | maior ou igual (`>=`) |

Ou seja: **SonarQube usa limite exclusivo (`>`) e PMD usa limite inclusivo
(`>=`)** para as quatro regras testadas. Essa assimetria é um achado
metodologicamente relevante para a normalização/comparação (seção 13/15) —
não é uma divergência de configuração, é o comportamento nativo documentado
de cada ferramenta, confirmado por execução real (não documentação).

Também confirmado nesta bateria: PMD reporta "NCSS line count" como
`(linhas_totais_do_metodo - 1)` quando cada statement ocupa uma linha
(a própria declaração do método conta como 1 unidade NCSS); SonarQube reporta
"lines" como a contagem literal de linhas físicas do método (assinatura até
chave de fechamento, inclusive).

### Associação por localização

Ferramenta `Associator` (`scripts/method-inventory/src/Associator.java`,
JavaParser) implementada seguindo estritamente a regra da seção 13: nunca
associa por nome ou linha isolada — resolve, para cada ocorrência
(arquivo + linha), o nó mais específico da AST que contém a linha, filtra
para as unidades mínimas (sem outra unidade candidata aninhada dentro dela)
e classifica a partir daí. `--self-test` cobre os 4 casos de aninhamento
(`SELF_TEST_RESULT=PASS`).

Validado com 12 ocorrências sintéticas contra
`scripts/fixtures/inventory/OverloadsAndInnerTypes.java`
(`scripts/fixtures/association/occorrencias-sinteticas.csv` →
`runs/synthetic-2026-10-01/inventories/association-results.jsonl`), cobrindo
os 4 estados da seção 13:

- `eligible_method`: linha dentro de `process(int)`, de `MemberType.memberMethod()`
  e de `MemberType.DeeplyNestedMember.deepMethod()` → resolvidos corretamente,
  com `method_id` íntegro.
- `out_of_scope`: linha da declaração da classe top-level (nível de classe,
  análogo ao `classReportLevel` do PMD); corpo do construtor; método
  abstrato de interface (sem corpo); **e o caso crítico de aninhamento**:
  linha dentro do método de um **tipo local** (`LocalType.localMethod`) e de
  uma **classe anônima** (`Runnable.run`), ambos fisicamente dentro de um
  método hospedeiro elegível (`localMethodHost`/`anonymousMethodHost`) — a
  ferramenta resolve corretamente para o nó mais específico (o tipo
  local/anônimo, não elegível), e não para o método hospedeiro que o contém.
- `unassociated`: linha fora de qualquer tipo declarado (antes da declaração
  da classe), linha além do fim do arquivo, e arquivo inexistente no raiz
  informado.
- `ambiguous`: fixture dedicado `scripts/fixtures/association/AmbiguousLocation.java`
  com dois métodos irmãos (sem relação de aninhamento) na mesma linha física
  — cenário em que o relato bruto (linha, sem coluna) não permite decidir
  qual dos dois foi de fato sinalizado. Resultado em
  `runs/synthetic-2026-10-01/inventories/association-results-ambiguous.jsonl`:
  `status=ambiguous` corretamente atribuído.

Também confirmado: duas ocorrências na mesma linha (`eligible_process_int` e
`eligible_process_int_duplicado`) resolvem para o **mesmo** `method_id` —
pré-requisito para a deduplicação funcionar corretamente.

### Alertas duplicados

Ferramenta `Deduplicator` (`scripts/method-inventory/src/Deduplicator.java`)
agrupa ocorrências normalizadas pela chave `tool+project+smell+method_id`
(seção 14), preservando a lista de `raw_alert_id` absorvidos por grupo.
`--self-test` cobre: duas ocorrências da mesma ferramenta/projeto/smell/método
(re-execução) colapsando em 1 grupo com 2 `raw_alert_id`; ferramenta
diferente não colapsa com a mesma combinação; método diferente e smell
diferente geram grupos próprios (`SELF_TEST_RESULT=PASS`).

Validado também com entrada em arquivo
(`scripts/fixtures/association/alertas-duplicados-exemplo.jsonl` → 3 alertas
brutos, sendo 2 do mesmo método/ferramenta/smell) →
`runs/synthetic-2026-10-01/inventories/dedup-results.jsonl`: `raw_total=3`,
`unique_total=2`, com o grupo duplicado preservando os 2 `raw_alert_id`
originais (`sq-issue-AAA`, `sq-issue-BBB`).

### Conjuntos vazios / Fórmulas das métricas

Ferramenta `Metrics` (`scripts/method-inventory/src/Metrics.java`) implementa
as fórmulas da seção 15 (|U|, |A|, |B|, %Sonar, %PMD, interseção,
diferenças, união, Jaccard) e os casos especiais de conjuntos vazios.
`--self-test` cobre (`SELF_TEST_RESULT=PASS`):

- Caso normal calculável à mão: `|U|=10`, `A={m1,m2,m3,m4}`, `B={m3,m4,m5}`
  → interseção=2, união=5, %Sonar=40%, %PMD=30%, Jaccard=0,4 — todos batendo
  com o cálculo manual.
- `A` e `B` ambos vazios → união=0 → **Jaccard = N/A** (não `0/0` silencioso).
- Apenas um dos conjuntos vazio (união ≠ 0) → **Jaccard = 0** (não `N/A`,
  caso distinto do anterior, exatamente como especificado na seção 15).
- `|U| = 0` → **percentuais = N/A** e problema marcado para registro.

### Paginação SonarQube / Validação do total exportado

Fixture sintético `scripts/fixtures/pagination/PaginationFixture.java` (150
métodos, cada um com 8 parâmetros `int` → todos violam `java:S107`,
`max=7`) analisado em projeto efêmero `exp-mestrado-pagination-fixtures`
(Quality Profile `exp-mestrado-long-smells`, removido do SonarQube após a
coleta — não é um projeto do experimento). Script
`scripts/sonarqube/export-issues-paginated.ps1` pagina
`/api/issues/search` com `ps=100` até que o total acumulado iguale
`paging.total`, e valida ausência de duplicatas entre páginas.

Resultado real (`runs/synthetic-2026-10-01/raw/sonarqube-issues-pagination.jsonl`):
`REPORTED_TOTAL=150`, `EXPORTED_TOTAL=150` (página 1: 100 issues; página 2:
50 issues), `UNIQUE_KEYS=150` (nenhuma chave duplicada entre páginas),
`VALIDACAO_TOTAL_EXPORTADO=PASS`. Confirma paginação correta (seção 11) e
reconciliação entre total exportado e total reportado pela API.

### Reprocessamento determinístico

`Associator` e `Deduplicator` executados duas vezes sobre as mesmas entradas
(`occorrencias-sinteticas.csv` e `alertas-duplicados-exemplo.jsonl`), sem
reexecutar PMD/SonarQube. Hashes SHA-256 das saídas comparados: saídas
byte-idênticas entre as duas execuções (`association_match=True`,
`dedup_match=True`) — confirma que o reprocessamento a partir dos mesmos
dados brutos produz resultados idênticos (seção 20).

---

## 5. Apache Commons Lang 3.20.0 — PILOTO

### Checkout

- [x] Repositório clonado
- [x] Tag `3.20.0` localizada
- [x] Commit SHA registrado
- [x] Integridade do checkout confirmada

**URL do repositório:** `https://github.com/apache/commons-lang.git` (mirror oficial Apache no GitHub)  
**Tag:** `rel/commons-lang-3.20.0`  
**Commit SHA:** `598dfc163b8b410fb3bb8794521206ec8dcec82a` (mensagem: "Prepare for the release candidate 3.20.0 RC2"; commit idêntico à tag `commons-lang-3.20.0-RC2^{}`, confirmando que o RC2 foi promovido à versão final)  
**Data da coleta:** 2026-10-01

**Evidência:** `git ls-remote --tags` no repositório oficial identificou duas tags
candidatas (`commons-lang-3.20.0-RC1`, `commons-lang-3.20.0-RC2`) além da tag
de release `rel/commons-lang-3.20.0`, cujo commit dereferenciado
(`598dfc163b8b410fb3bb8794521206ec8dcec82a`) é idêntico ao da RC2. Clone raso
(`--depth 1 --branch rel/commons-lang-3.20.0`) feito em
`sources/commons-lang-3.20.0/` (ignorado pelo Git, re-clonável). Integridade
confirmada via `git rev-parse HEAD` (bate com o commit esperado) e
`git status --short` (working tree limpo, nenhuma modificação local).

### Escopo

- [x] Módulos inspecionados
- [x] Fontes de produção identificadas
- [x] Exclusões identificadas
- [x] Inventário de arquivos incluídos gerado
- [x] Inventário de arquivos excluídos gerado
- [x] Inventário de métodos elegíveis gerado
- [x] Colisões de `method_id` verificadas

**Métodos elegíveis:** `3829` (0 colisões, 0 falhas de parsing)  
**Arquivos incluídos:** `259` (`.java` de produção)  
**Arquivos excluídos:** `354`

**Evidências** (artefatos em `runs/commons-lang-3.20.0-2026-10-01/inventories/`):

- **Módulos:** projeto Maven de módulo único — `pom.xml` não declara `<modules>`,
  `<packaging>` (default `jar`) nem `sourceDirectory`/plugins de geração de
  código customizados. Layout 100% padrão confirmado por inspeção do `pom.xml`
  e por busca recursiva: nenhum arquivo `.java` existe fora de `src/main/java`
  ou `src/test/java`.
- **Fontes de produção:** `src/main/java/org/apache/commons/lang3/**`
  (e subpacotes `arch`, `builder`, `compare`, `concurrent`, `event`,
  `exception`, `function`, `math`, `mutable`, `reflect`, `stream`, `text`,
  `time`, `tuple`, `util`) — único diretório de código de produção.
- **Exclusões (354 arquivos, com justificativa):** `src/test/java` (268 — código
  de teste); `src/site` (53 — documentação do site Maven); raiz do repositório
  (11 — `README`, `LICENSE`, `NOTICE`, `pom.xml`, changelogs, políticas,
  metadados não-código); `.github` (7 — configuração de CI); `src/conf`
  (4 — configs de checkstyle/PMD/spotbugs do próprio projeto, não código
  analisado); `src/media` (3 — imagens/logo); `src/assembly` (2 — descritores
  de empacotamento); `src/test/resources` (2 — fixtures de teste);
  `src/changes` (2 — changelog Maven); `src/main/java/.../doc-files/logo.png`
  (1 — asset não-Java embutido na árvore de produção, não é código);
  `.mvn` (1 — config do wrapper Maven).
- **Inventário de métodos elegíveis:** gerado com `MethodInventoryExtractor`
  (mesma ferramenta validada na seção 4) contra `src/main/java` →
  `3829` métodos elegíveis, `0` falhas de parsing, `259`/`259` arquivos
  processados.
- **Colisões de `method_id` — encontradas e corrigidas (correção de
  engenharia, não é mudança metodológica):** a primeira execução da validação
  de colisões (exigida pela seção 8 do protocolo) encontrou **5 colisões
  reais**: `Validate.notEmpty(T)` (×2), `Validate.validIndex(T,int)` (×2) e
  `ExceptionUtils.throwUnchecked(T)`. Causa raiz: esses são overloads válidos
  em Java que diferem apenas no *bound* do parâmetro de tipo genérico (ex.:
  `<T extends Collection<?>> T notEmpty(T collection)` vs.
  `<T extends Map<?,?>> T notEmpty(T map)` vs.
  `<T extends CharSequence> T notEmpty(T chars)`) — distintos na JVM após
  *erasure* (`Collection`, `Map`, `CharSequence` respectivamente), mas a
  ferramenta registrava o texto literal da variável de tipo (`"T"`) para
  todos, colidindo. **Correção:** `MethodInventoryExtractor` agora resolve
  cada parâmetro cujo tipo é uma variável de tipo visível (do método ou de
  tipo envolvente) para o texto do seu primeiro *bound* (ou `Object` se
  não declarado) antes de montar a assinatura — refletindo o *erasure* real
  da JVM, que é exatamente o que distingue os overloads. Validado por novo
  caso de self-test (`self_test_erasure_bounds_genericos_distintos=PASS`) e
  por reexecução real: `colisoes_de_identificador=0` após a correção. Isso
  não altera a definição de `method_id` da seção 8 (continua
  `project+commit+relative_path+qualified_type+signature`), apenas corrige
  como o texto da assinatura é derivado de parâmetros genéricos — exigido
  pela própria seção 8 ("Executar validação de colisões de identificadores").
  Fixture de regressão (`OverloadsAndInnerTypes.java`, sem genéricos)
  reexecutado após a correção: resultado idêntico byte-a-byte ao artefato já
  commitado (10 métodos, 0 colisões) — sem regressão na validação sintética.

### Build

- [x] JDK efetivo registrado
- [x] Comando de build registrado
- [x] Build concluído
- [x] Bytecode/dependências disponíveis para SonarQube

**Status:** CONCLUÍDA

**Evidências:**

- **JDK efetivo:** JDK 21 (`$env:JAVA_HOME`), mesmo JDK usado nas demais
  ferramentas do protocolo (JavaParser, PMD, SonarScanner).
- **Decisão de engenharia (ambiente sem Maven/Gradle):** o `pom.xml` do
  projeto não inclui wrapper Maven (`.mvn/` contém apenas `.gitignore`, sem
  `mvnw`/`mvnw.cmd`/`maven-wrapper.properties`), e não há Maven instalado no
  ambiente (constatação já registrada anteriormente no projeto). Inspeção do
  `pom.xml` confirma que **todas** as dependências declaradas são de escopo
  `test` (JUnit Jupiter, junit-pioneer, EasyMock, commons-text, JMH, jsr305)
  — o próprio `pom.xml` documenta isso explicitamente ("Lang should depend on
  very little"). Como a seção 6 do protocolo já exclui `src/test/java` do
  escopo de produção, o código de produção (`src/main/java`) não possui
  nenhuma dependência de compilação além do JDK. Por isso, optou-se por
  compilar diretamente com `javac`, replicando fielmente os parâmetros de
  linguagem declarados pelo próprio `pom.xml`
  (`maven.compiler.source=1.8`, `maven.compiler.target=1.8`,
  `project.build.sourceEncoding=ISO-8859-1`), em vez de instalar Maven.
  Isso não é uma mudança metodológica: nenhuma dependência de terceiros
  deixou de ser resolvida (porque nenhuma existe em escopo de compilação) e
  os parâmetros de linguagem/encoding usados são exatamente os que o próprio
  build Maven do projeto usaria.
- **Comando de build:** 
  `javac --release 8 -encoding ISO-8859-1 -d target/classes @sources.txt`
  (lista `sources.txt` com os 259 arquivos de `src/main/java`, gerada via
  `Get-ChildItem -Recurse -Filter *.java`).
- **Resultado:** `EXITCODE=0`; `403` arquivos `.class` gerados em
  `target/classes` (259 top-level + classes aninhadas/anônimas); apenas
  avisos (`options` sobre `--release 8` obsoleto nesta versão do JDK, e um
  aviso de varargs em `TypeUtils.java:361`), nenhum erro de compilação.
  Log completo em `sources/commons-lang-3.20.0/build.log` (não versionado,
  pertence a `sources/`).
- **Bytecode disponível para SonarQube:** `target/classes` populado e pronto
  para uso como `sonar.java.binaries` na análise.

### SonarQube

- [x] Quality Profile criado
- [x] Somente S138/S107 habilitadas
- [x] Análise executada
- [x] Tarefa concluída no servidor
- [x] `taskId` registrado
- [x] `analysisId` registrado
- [x] Issues exportados
- [x] Paginação validada
- [x] Total API × total exportado reconciliado
- [x] Logs preservados

**Issues S138:** `13`  
**Issues S107:** `1`  
**Falhas:** nenhuma registrada

**Evidências:**

- Projeto `apache-commons-lang-3-20-0` criado via `POST /api/projects/create`;
  Quality Profile `exp-mestrado-long-smells` associado via
  `POST /api/qualityprofiles/add_project` (mesmo profile validado na seção 4:
  somente `java:S138` max=75 e `java:S107` max=7 habilitadas).
- Análise executada com `sonar-scanner 8.1.0.6389` usando
  `sonar-project.properties` (`sonar.sources=src/main/java`,
  `sonar.java.binaries=target/classes`, `sonar.sourceEncoding=ISO-8859-1` —
  mesmo encoding declarado pelo `pom.xml`). `ANALYSIS SUCCESSFUL`;
  `taskId=21f94fd6-3e31-4604-a5ae-2a961733e3e6`,
  `analysisId=c61c2cea-a8ff-4835-bcde-1bcf32c94241`, `status=SUCCESS`
  (confirmado via `GET /api/ce/task`). Únicos avisos: *shallow clone* sem
  informação de *blame* (não afeta a detecção de S138/S107, apenas metadados
  de SCM/autoria).
- Issues exportados com `scripts/sonarqube/export-issues-paginated.ps1`:
  `REPORTED_TOTAL=14`, `EXPORTED_TOTAL=14`, `UNIQUE_KEYS=14`,
  `PAGES_FETCHED=1`, `VALIDACAO_TOTAL_EXPORTADO=PASS`.
- Log do scanner preservado em
  `runs/commons-lang-3.20.0-2026-10-01/logs/sonar-scanner-output.txt`; issues
  brutos em `runs/commons-lang-3.20.0-2026-10-01/raw/sonarqube-issues.jsonl`.

### PMD

- [x] Ruleset criado
- [x] Somente NcssCount/ExcessiveParameterList habilitadas
- [x] Execução concluída
- [x] Relatório estruturado preservado
- [x] Arquivos processados reconciliados
- [x] Erros de processamento registrados

**NcssCount:** `14` (12 de método + 2 de classe, ver Normalização)  
**ExcessiveParameterList:** `0`  
**Falhas:** nenhuma registrada

**Evidências:**

- Mesmo ruleset da seção 4
  (`configs/pmd-ruleset-exp-mestrado-long-smells.xml`): apenas `NcssCount`
  (`methodReportLevel=60`) e `ExcessiveParameterList` (`minimum=10`).
- Comando: `pmd check -d src/main/java -R
  configs/pmd-ruleset-exp-mestrado-long-smells.xml -f text --no-cache`.
  `[INFO] Found 14 violations.` (exit code `4`, esperado quando há
  violações). Nenhum erro de processamento de arquivo reportado.
- Relatório bruto preservado em
  `runs/commons-lang-3.20.0-2026-10-01/raw/pmd-output.txt`.
- **Correção de auditoria (2026-10-01):** o relatório original estava apenas
  em formato `text` (legível, mas não estruturado), o que não atendia
  literalmente ao requisito de "relatório estruturado" da seção 12 do
  protocolo. Regerado o mesmo relatório em formato `xml`
  (`pmd check ... -f xml -r .../raw/pmd-output.xml`), preservado em
  `runs/commons-lang-3.20.0-2026-10-01/raw/pmd-output.xml` ao lado do
  `.txt` original (nenhum artefato anterior removido). Confirmado:
  mesmas `14` violações em ambos os formatos (`Select-String -Pattern
  "<violation "` no XML = `14`), mesmo `package`/`class`/`method`/`line`
  por violação. Esta foi uma correção operacional de script (formato de
  saída), não uma mudança metodológica — não alterou nenhum resultado já
  reportado.

### Normalização

- [x] Alertas SonarQube associados
- [x] Alertas PMD associados
- [x] Out-of-scope classificados
- [x] Ambíguos tratados
- [x] Não associados tratados
- [x] Deduplicação executada
- [x] Vínculo com dados brutos preservado

| Estado | SonarQube | PMD |
|---|---:|---:|
| eligible_method | 14 | 12 |
| out_of_scope | 0 | 2 |
| ambiguous | 0 | 0 |
| unassociated | 0 | 0 |

**Evidências:**

- Associação feita por `Associator` (AST, por localização — PROTOCOLO.md
  seção 13), não por nome/linha isolado.
- Todos os 14 issues do SonarQube associados a `eligible_method` (nenhum
  `out_of_scope`/`ambiguous`/`unassociated`).
- Dos 14 alertas `NcssCount` do PMD, 12 associados a `eligible_method` e
  **2 classificados como `out_of_scope`** (razão:
  `"nivel de classe/tipo (ex.: NcssCount classReportLevel)"`) — são os
  alertas de NCSS de classe em `ArrayUtils` (2176) e `StringUtils` (1780),
  exatamente o caso previsto em PROTOCOLO.md seção 13 ("`NcssCount` pode
  gerar ocorrências para entidades que não sejam métodos elegíveis... devem
  ser classificadas e excluídas da comparação com justificativa"). Excluídos
  da comparação de métricas com essa justificativa registrada no próprio
  artefato de associação.
- Deduplicação (`Deduplicator`, chave `tool+project+smell+method_id`): 26
  alertas brutos de entrada (14 SonarQube + 12 PMD elegíveis) → 26 registros
  únicos (nenhuma deduplicação necessária — nenhum método recebeu mais de um
  alerta bruto da mesma ferramenta para o mesmo smell).
- Artefatos: `association-sonarqube.jsonl`, `association-pmd.jsonl`,
  `dedup-input-sonarqube.jsonl`, `dedup-input-pmd.jsonl`,
  `dedup-results.jsonl` (todos em `runs/commons-lang-3.20.0-2026-10-01/inventories/`),
  preservando o vínculo com o alerta bruto original (`raw_alert_id` = chave
  do issue do SonarQube ou `pmd::<relative_path>::<line>`).

### Cobertura

- [x] Conjunto de fontes SonarQube validado
- [x] Conjunto de fontes PMD validado
- [x] Diferenças de cobertura explicadas
- [x] Parsing failures reconciliados
- [x] Cobertura considerada comparável

**Status:** CONCLUÍDA

**Evidências:** SonarQube e PMD analisaram exatamente o mesmo conjunto de 259
arquivos de produção (`src/main/java`), com `0` falhas de parsing/análise em
ambas as ferramentas (`MethodInventoryExtractor`: `falhas_de_parsing=0`;
PMD: nenhum erro de processamento no relatório). Nenhuma diferença de
cobertura de arquivos entre as ferramentas — a única diferença observada é
de escopo de métodos elegíveis (2 alertas `NcssCount` de nível de classe no
PMD, já classificados como `out_of_scope` na normalização), não de arquivos
não processados.

### Métricas

| Smell | \|U\| | \|A\| | \|B\| | Sonar % | PMD % | Interseção | Sonar-only | PMD-only | União | Jaccard |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Long Method | 3829 | 13 | 12 | 0.3395% | 0.3134% | 11 | 2 | 1 | 14 | 0.7857 |
| Long Parameter List | 3829 | 1 | 0 | 0.0261% | 0.0000% | 0 | 1 | 0 | 1 | 0.0000 |

**Evidências:** `U` = `3829` métodos elegíveis (inventário completo, 0
colisões). `A` = métodos sinalizados pelo SonarQube (após associação,
excluindo não-elegíveis — não houve nenhum). `B` = métodos sinalizados pelo
PMD (após associação, excluindo os 2 `out_of_scope` de nível de classe).
Fórmulas aplicadas conforme PROTOCOLO.md seção 15 (mesmas validadas pelo
self-test de `Metrics` na seção 4): percentuais sobre `|U|`, Jaccard =
`|interseção|/|união|` (não há caso de união vazia ou universo vazio neste
piloto). Artefato: `runs/commons-lang-3.20.0-2026-10-01/inventories/metrics-resultado.json`.
Script de cálculo (usa os mesmos artefatos de inventário/dedup, não reusa a
classe `Metrics` diretamente por esta não expor um modo CLI de arquivo — a
fórmula é a mesma validada por `Metrics --self-test`):
`runs/commons-lang-3.20.0-2026-10-01/logs/compute-metrics.ps1`.

### Reprocessamento determinístico (piloto real)

`MethodInventoryExtractor` reexecutado contra o mesmo `src/main/java` do
piloto: saída idêntica byte-a-byte à primeira execução (`Compare-Object`
sem diferenças; `metodos_elegiveis=3829`, `colisoes_de_identificador=0` em
ambas as execuções).

**Correção de auditoria (2026-10-01) — reprocessamento de ponta a ponta sem
reexecutar as ferramentas:** o protocolo (seção 20) exige que o pipeline
permita reprocessar relatórios já coletados sem reexecutar SonarQube/PMD.
Isso havia sido validado apenas para a extração do inventário (acima), não
para as métricas finais. Reprocessamento completo executado a partir dos
relatórios brutos já armazenados (`raw/sonarqube-issues.jsonl`,
`raw/pmd-output.txt`), sem invocar `sonar-scanner` ou `pmd.bat` novamente:
ocorrências → associação (`Associator`) → entrada de deduplicação →
`Deduplicator` → métricas finais, tudo gerado em
`runs/commons-lang-3.20.0-2026-10-01/reprocess-check/` e comparado
(`Compare-Object`) contra os artefatos originais em `inventories/`. Resultado:
`occurrences-sonarqube.csv`, `occurrences-pmd.csv`, `association-sonarqube.jsonl`,
`association-pmd.jsonl`, `dedup-input-all.jsonl`, `dedup-results.jsonl`
(`raw_total=26 unique_total=26`, idêntico) e `metrics-resultado.json`
**idênticos** em todas as etapas (nenhuma diferença de conteúdo). Única
discrepância encontrada e corrigida: o script de reprocessamento usava
formatação de número dependente da cultura do shell (`"{0:N4}" -f`,
vírgula decimal) em vez de `InvariantCulture` (ponto decimal) — já usado
corretamente no script original `compute-metrics.ps1`; corrigido o script
de reprocessamento para usar `ToString("F4", [CultureInfo]::InvariantCulture)`,
após o que a comparação ficou 100% idêntica. Bug de script, não mudança
metodológica nem de resultado (os valores numéricos já eram os mesmos,
apenas a representação textual do separador decimal diferia). Scripts:
`runs/commons-lang-3.20.0-2026-10-01/logs/reprocess-check.ps1`,
`reprocess-check-dedup-input.ps1`, `reprocess-check-metrics.ps1`. Isto
confirma reprocessamento determinístico de ponta a ponta, não apenas do
inventário bruto.

### Critérios de aprovação

- [x] Versões/configurações confirmadas
- [x] Cobertura reconciliada
- [x] Associações potencialmente elegíveis resolvidas
- [x] Invariantes aprovadas
- [x] Métricas recalculáveis pelos artefatos
- [x] Reprocessamento determinístico aprovado

**DECISÃO DO PILOTO:** APROVADO

Todos os critérios de aprovação do piloto (PROTOCOLO.md) foram atendidos:
versões/configurações de SonarQube e PMD idênticas às validadas na seção 4;
cobertura de arquivos idêntica entre ferramentas, sem falhas de parsing;
todos os 26 alertas associados com estado definido (`eligible_method` ou
`out_of_scope` com justificativa — nenhum `ambiguous`/`unassociated`
pendente de decisão); métricas recalculáveis a partir dos artefatos
preservados (`inventory-methods.jsonl`, `association-*.jsonl`,
`dedup-results.jsonl`, `metrics-resultado.json`); reprocessamento
determinístico confirmado. A única correção de engenharia necessária
(erasure de bounds genéricos no cálculo de `method_id`) foi documentada na
seção de Escopo como decisão de engenharia, não metodológica, e não exigiu
abertura de bloqueio. **Piloto aprovado — liberado o avanço para Hibernate
ORM, Spring Framework e Quarkus (seções 6–8).**

**Correção de auditoria (2026-10-01, durante a validação do Hibernate
ORM):** ao implementar o invariante `A ∪ B ⊆ U` (PROTOCOLO.md seção 18)
para o Hibernate ORM, foi descoberto que os scripts PowerShell que montam
`dedup-input-*.jsonl` (`build-dedup-input.ps1`,
`reprocess-check-dedup-input.ps1`) usavam `ConvertTo-Json`, que por padrão
escapa `<`/`>` como `\u003c`/`\u003e`; o parser mínimo do
`Deduplicator.java` (formato "controlado por nós", documentado no próprio
javadoc da classe) não desfaz escapes `\uXXXX`, corrompendo o `method_id`
de métodos com parâmetros genéricos (ex.: `List<String>` virava
`Listu003cStringu003e`). No piloto isso afetou **1 dos 26** alertas
(`StrSubstitutor.substitute(StrBuilder,int,int,List<String>)`), violando
o invariante `A ∪ B ⊆ U` sem alterar nenhuma contagem (a corrupção era
determinística e idêntica para SonarQube e PMD, então interseção/união
batiam mesmo assim — só a correspondência com o `method_id` canônico do
inventário falhava). Corrigido construindo o JSON manualmente (mesma
convenção de escape do `Associator.java`) nos dois scripts; `dedup-input-*`,
`dedup-results.jsonl` e `metrics-resultado.json` regenerados. **Métricas
recalculadas após a correção são numericamente idênticas às já reportadas
acima** (Long Method: Jaccard=0.7857; Long Parameter List: Sonar=1/PMD=0) —
confirmado por recálculo e por reprocessamento determinístico (diff vazio
entre `reprocess-check/` e `inventories/`). Invariante `A ∪ B ⊆ U` validado
após a correção: `0` violações. Não é mudança metodológica nem alteração de
resultado — correção de um bug de serialização JSON em scripts auxiliares
de engenharia, documentada por exigência de auditoria/rastreabilidade.

---

## 6. Hibernate ORM 7.2.6.Final

**Execução permitida somente após aprovação do piloto.**

- [x] Checkout
- [x] Escopo/inventário
- [x] Build
- [x] SonarQube
- [x] PMD
- [x] Normalização
- [x] Cobertura
- [x] Métricas
- [x] Validação final

**Status:** CONCLUÍDO (2026-10-01) — todas as etapas da seção 6 finalizadas; liberado o avanço para Spring Framework (seção 7)

**Evidências (Checkout):**

- Repositório: `https://github.com/hibernate/hibernate-orm.git`.
- Tag utilizada: `7.2.6` (convenção do projeto: releases finais usam o
  número de versão sem o sufixo `.Final` como tag git; confirmado via
  `git ls-remote --tags` — tag `7.2.6` corresponde à release `7.2.6.Final`;
  tags com sufixo como `.CR1`/`.CR2` são pré-lançamentos).
- Commit SHA: `c549a5c5a0bdd05cbda5105c4fa899b466be365c`.
- Data da coleta: 2026-10-01.
- Comando: `git clone --branch 7.2.6 --depth 1
  https://github.com/hibernate/hibernate-orm.git
  sources/hibernate-orm-7.2.6.Final`.
- Observação operacional: a primeira tentativa de clone falhou com
  `Filename too long` em alguns caminhos de teste profundamente aninhados
  (ex.: `BytecodeEnhancementElementCollectionRecreateCollectionsInDefaultGroupTest.java`).
  Corrigido com `git config --global core.longpaths true`; reclone
  subsequente concluído sem erros (17673 arquivos). Bug de ambiente
  Windows, não decisão metodológica.
- Árvore de trabalho limpa após o clone (`git status --short` vazio,
  `STATUS_EXIT=0`).

**Evidências (Escopo/inventário):**

- **Módulos inspecionados:** lista completa de `include` em `settings.gradle`
  (29 módulos/subprojetos) e arquivo `.gradle` de cada um inspecionado
  individualmente. Critério objetivo adotado para distinguir "código de
  produção" (seção 6 do protocolo) de tooling interno: presença de plugin
  de publicação (`maven-publish`/`com.gradle.plugin-publish`, artefato
  publicado pelo projeto Hibernate ORM para uso externo) versus ausência
  dele (módulo usado somente para construir o próprio Hibernate ORM,
  análogo a um `buildSrc`). `sourceSets` customizados de cada módulo
  inspecionados para localizar diretórios de teste/demo/integração fora do
  padrão `src/test`.
- **Módulos de produção incluídos (17):** `hibernate-core`,
  `hibernate-envers`, `hibernate-spatial`, `hibernate-community-dialects`,
  `hibernate-vector`, `hibernate-c3p0`, `hibernate-hikaricp`,
  `hibernate-agroal`, `hibernate-jcache`, `hibernate-micrometer`,
  `hibernate-graalvm`, `hibernate-jfr`, `hibernate-scan-jandex`,
  `tooling/metamodel-generator` (publicado como `hibernate-processor`),
  `tooling/hibernate-gradle-plugin`, `tooling/hibernate-maven-plugin`,
  `tooling/hibernate-ant` — todos com plugin de publicação confirmado nos
  respectivos `.gradle` (ex.: `hibernate-gradle-plugin.gradle` aplica
  `com.gradle.plugin-publish` e `maven-publish`; `hibernate-maven-plugin`
  usa `org.gradlex.maven-plugin-development`). Somente `src/main/java` de
  cada um foi incluído.
- **Módulos/diretórios excluídos (com justificativa):**
  `hibernate-testing` (biblioteca cujo único propósito é dar suporte à
  escrita de testes — confirmado pelo próprio `README.adoc` do módulo:
  "defines utilities for writing tests easier"); `hibernate-platform` (BOM
  Gradle `java-platform`, sem nenhum arquivo `.java`);
  `hibernate-integrationtest-java-modules` (contém somente `src/test`);
  `local-build-plugins` e `local-build-asciidoctor-extensions` (plugins
  Gradle internos usados exclusivamente para construir o próprio
  repositório do Hibernate ORM — grupo `org.hibernate.build`, versão
  `1.0.0-SNAPSHOT`, sem nenhum plugin de publicação); `documentation`,
  `release`, `design`, `rules`, `ci`, `checkerstubs`, `drivers`, `edb`,
  `javadoc`, `shared` (nenhum contém `.java` de produção — Asciidoc,
  scripts, stubs de checker, Dockerfiles, configs). Dentro dos módulos de
  produção, também excluídos (sourceSets não wirados em `src/main`):
  `src/test`, `src/demo` e `src/test_legacy` (hibernate-envers — `demo`
  confirmado no próprio `.gradle` do módulo como parte do sourceSet `test`),
  `src/intTest`/`src/it` (hibernate-maven-plugin — testes de integração),
  `src/jakartaData`/`src/quarkusHrPanache`/`src/quarkusOrmPanache`
  (tooling/metamodel-generator — confirmado no `.gradle` como sourceSets
  dedicados a tasks `*Test`, ex.: `jakartaDataTestTask`). Nenhum diretório
  vendorizado/de terceiros encontrado (busca por `vendor`/`thirdparty`/
  `3rdparty`/`external` sem resultados). Nenhum código gerado presente na
  árvore versionada (checkout limpo, sem diretórios `build/` — confirmado
  por inspeção; geração ANTLR do `hibernate-core` ocorre em `build/`
  somente durante o build, fora da árvore analisada).
- **Inventário de arquivos** (via `git ls-files`, que já exclui `.git`,
  `.gradle` e `build/` por não serem versionados — script
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/build-file-inventory.ps1`):
  `17673` arquivos versionados no total; `6605` classificados como
  incluídos (`.java` sob `src/main/java` de um dos 17 módulos de produção);
  `11068` excluídos. Listas completas em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/arquivos-incluidos.txt`
  e `arquivos-excluidos.txt`.
- **Inventário de métodos elegíveis:** gerado com `MethodInventoryExtractor`
  (mesma ferramenta validada na seção 4 e usada no piloto) em uma única
  execução, usando um diretório de staging com *junctions* do Windows (uma
  por módulo, apontando diretamente para `<módulo>/src/main/java`) como
  `--root`, para que `relative_path` (calculado pela ferramenta como
  `root.relativize(arquivo)`) preserve o caminho real do módulo no
  repositório e fique **globalmente único entre módulos** em uma única
  checagem de colisão (script
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/build-scope-staging.ps1`).
  Decisão de engenharia (não metodológica): não altera a definição de
  `method_id` (continua `project+commit+relative_path+qualified_type+signature`),
  apenas garante que `relative_path` reflita o caminho real dentro do
  repositório multi-módulo, sem copiar nenhum arquivo fisicamente.
  Resultado: `arquivos_java_encontrados=6605` (reconciliado com o
  inventário de arquivos acima), `metodos_elegiveis=48102`,
  `colisoes_de_identificador=0`. Detalhamento por módulo em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/metodos-por-modulo-detalhado.txt`
  (`hibernate-core`=40984, `hibernate-community-dialects`=3294,
  `hibernate-envers`=1687, `tooling/metamodel-generator`=1185,
  `hibernate-vector`=276, `hibernate-spatial`=251,
  `tooling/hibernate-ant`=177, `hibernate-jfr`=71,
  `hibernate-scan-jandex`=36, `hibernate-jcache`=35,
  `tooling/hibernate-gradle-plugin`=28, `tooling/hibernate-maven-plugin`=21,
  `hibernate-c3p0`=15, `hibernate-hikaricp`=13, `hibernate-agroal`=13,
  `hibernate-micrometer`=10, `hibernate-graalvm`=6).
- **Falha de parsing registrada (1 de 6605 arquivos — seção 9 do
  protocolo):** `hibernate-core/org/hibernate/dialect/Dialect.java` não
  pôde ser parseado pelo JavaParser 3.28.2. Causa raiz confirmada: o
  arquivo contém uma declaração de **enum local** dentro de um corpo de
  método (`enum Unit { day, hour, minute }`, em
  `Dialect.appendIntervalLiteral`) — sintaxe válida em Java desde o JDK 16,
  mas não suportada pela gramática do JavaParser 3.28.2 (confirmado: é a
  versão mais recente disponível no Maven Central em 2026-10-01, não há
  atualização disponível). Reproduzido de forma isolada e mínima em
  `scripts/fixtures/boundary/LocalEnumRepro.java` (erro idêntico, mesma
  coluna). **Não é uma mudança metodológica nem exige bloqueio:** o arquivo
  continua listado em `arquivos-incluidos.txt` (é código de produção
  dentro do escopo), mas não contribui nenhum método para o universo `U`
  (AST não extraível); qualquer alerta do SonarQube/PMD que caia dentro
  deste arquivo será classificado `unassociated` na normalização (seção 13
  do protocolo), nunca atribuído automaticamente a nenhuma ferramenta.
  Detalhes completos em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/falhas-parsing.txt`.
- **Colisões de `method_id`:** `0` (checagem única sobre os 48102 métodos
  de todos os 17 módulos simultaneamente, via staging — ver acima).
- Comandos completos preservados em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/comandos.md`.

**Evidências (Build):**

- **Decisão de JDK:** `gradle.properties` do projeto define
  `orm.jdk.base=17` (bytecode produzido) e `orm.jdk.min=orm.jdk.max=25`
  (faixa exigida para o JDK que executa o Gradle, quando nenhuma versão é
  configurada explicitamente). Nenhum JDK 25 estava disponível no ambiente
  (maior instalado: JDK 24.0.2). Em vez de instalar um novo JDK, usou-se o
  mecanismo de override já documentado no próprio código de build do
  projeto (`JdkVersionConfig`/`JdkVersionSettingsPlugin`, cuja mensagem de
  aviso sugere exatamente essa combinação de propriedades): system
  properties `-Dmain.jdk.version=21 -Dtest.jdk.version=21`, resultando em
  `compiler: 21` / `release: 17` — o mesmo bytecode de saída que o
  caminho padrão (com JDK 25) produziria. **Não é mudança metodológica:**
  nenhum parâmetro de linguagem/bytecode do projeto foi alterado, apenas
  contornada a exigência de que o processo do Gradle rode sob um JDK
  específico. Nota à parte: `README.adoc` do projeto (linha 21) afirma
  "requires at least JDK 21", inconsistente com `orm.jdk.min=25` do
  `gradle.properties` desta tag — inconsistência da própria documentação
  do projeto, apenas registrada, não resolvida.
- **Achado (módulo `hibernate-jfr` ausente na 1ª execução):** a 1ª
  execução, com JDK 21 Oracle (`C:\Program Files\Java\jdk-21`), não
  processou o módulo `hibernate-jfr` (um dos 17 de produção). Causa:
  `settings.gradle` só inclui `hibernate-jfr` quando
  `System.getProperty("java.runtime.name")` é `"OpenJDK Runtime
  Environment"` — o JDK Oracle reporta `"Java(TM) SE Runtime
  Environment"`. Confirmado via `java -XshowSettings:properties`.
  Corrigido com uma 2ª execução usando Microsoft Build of OpenJDK 21.0.8
  (`C:\Users\gusta\.jdks\ms-21.0.8`, `java.runtime.name=OpenJDK Runtime
  Environment` confirmado), que compilou `hibernate-jfr` (demais módulos
  permaneceram `UP-TO-DATE`, incrementais).
- **Comando de build (wrapper do próprio projeto, por documentação
  oficial — PROTOCOLO.md seção 10):**
  `.\gradlew.bat compileJava "-Dmain.jdk.version=21" "-Dtest.jdk.version=21" --console=plain`
  (sem execução de testes, conforme seção 10 do protocolo — tarefa
  `compileJava` apenas, Gradle 9.1.0 via wrapper).
- **JDK efetivamente usado:** execução 1 — JDK 21 Oracle
  (`C:\Program Files\Java\jdk-21`, `21.0.9`); execução 2 (para incluir
  `hibernate-jfr`) — Microsoft Build of OpenJDK `21.0.8`
  (`C:\Users\gusta\.jdks\ms-21.0.8`).
- **Resultado:** `BUILD SUCCESSFUL` nas duas execuções, `EXITCODE=0`,
  sem erros de compilação; apenas avisos padrão do `javac`
  (`deprecation`/`removal`/`unchecked`, informativos) e um aviso do
  próprio Gradle sobre features incompatíveis com a futura versão 10
  (nível da ferramenta de build, não do código analisado).
- **Duração:** execução 1 — `2m 49s` (`169.6715156s` medidos
  independentemente via `Stopwatch` do PowerShell); execução 2 — `1m 3s`
  (`63.9751579s`).
- **Módulos processados:** todos os 17 módulos de produção do escopo
  geraram bytecode — `9156` arquivos `.class` no total (`hibernate-core`
  =8010, `hibernate-envers`=397, `hibernate-community-dialects`=329,
  `hibernate-spatial`=113, `hibernate-vector`=91, `hibernate-jfr`=22,
  `hibernate-scan-jandex`=14, `hibernate-processor`
  [`tooling/metamodel-generator`]=107, `hibernate-ant`
  [`tooling/hibernate-ant`]=38, `hibernate-gradle-plugin`
  [`tooling/hibernate-gradle-plugin`]=11, `hibernate-jcache`=8,
  `hibernate-hikaricp`=3, `hibernate-micrometer`=3, `hibernate-c3p0`=4,
  `hibernate-agroal`=2, `hibernate-graalvm`=2, `hibernate-maven-plugin`
  [`tooling/hibernate-maven-plugin`]=2). Bytecode disponível em
  `<módulo>/target/classes` de cada módulo, pronto para uso como
  `sonar.java.binaries` na análise.
- Logs completos preservados em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/build-run1-oraclejdk21.log`,
  `build-run2-openjdk21-jfr.log` e comandos reproduzíveis em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/comandos.md`.

**Evidências (SonarQube):**

- Projeto `hibernate-orm-7-2-6-final` criado no servidor e associado ao
  mesmo Quality Profile `exp-mestrado-long-smells` validado no piloto
  (confirmado via `GET /api/qualityprofiles/search?project=...`: perfil
  `exp-mestrado-long-smells`, linguagem `java`) — somente `java:S138`
  (max=75) e `java:S107` (max=7) habilitadas, mesma configuração da seção 3/4.
- Análise executada com `sonar-scanner` usando
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/config/sonar-project.properties`
  (`sonar.sources` e `sonar.java.binaries` apontando para os 17 módulos de
  produção e seus respectivos `target/classes`, `sonar.java.source=17` —
  mesmo bytecode/release da etapa de Build). Análise concluída e
  reportada diretamente pelo usuário como finalizada; confirmada de forma
  independente nesta sessão via API do servidor (`GET /api/ce/component`):
  `status=SUCCESS`, `analysisId=80dd5e3b-66b8-4201-be40-40fa89addbac`,
  `taskId=26e885fe-cf16-4e14-a57a-7aedb4717d77`, `executionTimeMs=49358`,
  `revision=c549a5c5a0bdd05cbda5105c4fa899b466be365c` (bate com o commit do
  checkout). Avisos do scanner (não bloqueantes, mesma natureza do piloto):
  ausência de `sonar.java.libraries` (análise menos precisa, mas não afeta
  detecção de S138/S107, que não dependem de resolução de tipos externos
  para contagem de linhas/parâmetros), *shallow clone* e blame ausente para
  6605 arquivos (afeta apenas metadados de SCM/autoria, não a detecção).
- Issues exportados com `scripts/sonarqube/export-issues-paginated.ps1`
  (mesmo script validado na seção 4 e usado no piloto):
  `REPORTED_TOTAL=456`, `EXPORTED_TOTAL=456`, `UNIQUE_KEYS=456`,
  `PAGES_FETCHED=5`, `VALIDACAO_TOTAL_EXPORTADO=PASS`. Quebra por regra:
  `java:S138=290`, `java:S107=166`.
- Issues brutos preservados em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/raw/sonarqube-issues.jsonl`;
  log da exportação em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/export-issues-output.txt`;
  verificação do status da análise via API preservada em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/check-sonar-status-output.txt`.

**Evidências (PMD):**

- Mesmo ruleset do piloto/seção 3-4
  (`configs/pmd-ruleset-exp-mestrado-long-smells.xml`): apenas `NcssCount`
  (`methodReportLevel=60`) e `ExcessiveParameterList` (`minimum=10`).
- Comando: `pmd check -d <17 diretórios `src/main/java`, um por módulo de
  produção, separados por vírgula> -R
  configs/pmd-ruleset-exp-mestrado-long-smells.xml -f xml -r
  runs/hibernate-orm-7.2.6.Final-2026-10-01/raw/pmd-output.xml --no-cache`
  (PMD 7.27.0 aceita múltiplos diretórios em `--dir` separados por vírgula,
  confirmado via `pmd check --help`; mesmos 17 diretórios usados em
  `sonar.sources`/`sonar.java.binaries`).
- `[INFO] Found 298 violations. There were 4 processing errors.` Quebra por
  regra (`runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/pmd-rule-breakdown.txt`):
  `NcssCount=150`, `ExcessiveParameterList=148`.
- **4 erros de processamento (não é falha geral do PMD — distinção exigida
  por PROTOCOLO.md seção 12):** 4 dos 6605 arquivos do escopo
  (`hibernate-envers/.../boot/model/{Attribute,Column,Key,TypeSpecification}.java`)
  não puderam ser analisados pelo PMD (`SemanticException: Cannot
  parameterize java/lang/Cloneable with [...], expecting 0 type
  arguments`). Causa raiz confirmada: esses arquivos implementam uma
  interface genérica **própria** `org.hibernate.envers.boot.model.Cloneable<T>`
  (definida no mesmo pacote), que deveria sombrear `java.lang.Cloneable`
  para referências não qualificadas — o resolvedor de símbolos do PMD
  7.27.0 resolve incorretamente para `java.lang.Cloneable` (0 parâmetros de
  tipo) em vez do tipo local (1 parâmetro de tipo), abortando a análise
  apenas desses 4 arquivos. Reproduzido isoladamente em
  `scripts/fixtures/boundary/pmd-cloneable-shadow-repro/` (mesmo erro exato
  confirmado). É o análogo, do lado do PMD, ao caso já documentado do lado
  do JavaParser (`Dialect.java`, seção de Escopo/inventário acima) — ambos
  são limitações de cobertura de resolução de tipos/gramática das
  respectivas ferramentas de parsing usadas no experimento, não decisões
  metodológicas nem erros de configuração do ruleset. Detalhamento completo
  em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/falhas-processamento-pmd.txt`.
  Tratamento: os 4 arquivos continuam em `arquivos-incluidos.txt` e seus
  métodos continuam em `U` (JavaParser parseia-os sem problema); nenhum
  alerta PMD pode existir para eles (análise abortada) — assimetria de
  cobertura PMD vs SonarQube a ser registrada/justificada na subseção de
  Cobertura, sem exigir bloqueio.
- Execução tecnicamente bem-sucedida (apenas 4/6605 falhas pontuais de
  processamento, não falha geral da ferramenta): relatório estruturado XML
  gerado com sucesso, preservado em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/raw/pmd-output.xml`; log
  completo (inclui as 4 mensagens de erro) em
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/pmd-output.txt`.

**Evidências (Normalização):**

- Associação feita por `Associator` (AST, por localização — PROTOCOLO.md
  seção 13; mesma ferramenta do piloto), nunca por nome/linha isolado.
  `--root` = diretório de staging com *junctions* (mesmo usado no
  inventário), garantindo `relative_path` idêntico entre inventário e
  associação.
- Conversão dos relatórios brutos para o formato de entrada do `Associator`
  (`relative_path,line,label`): `component` do SonarQube
  (`<projectKey>:<módulo>/src/main/java/<pacote>/Classe.java`) e `name` do
  arquivo no XML do PMD normalizados removendo o segmento `src/main/java/`
  para bater com o `relative_path` do inventário. Scripts:
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/normalize-step1-association.ps1`,
  `normalize-step2-dedup.ps1`.

| Estado | SonarQube (456) | PMD (298) |
|---|---:|---:|
| eligible_method | 386 | 190 |
| out_of_scope | 68 | 104 |
| ambiguous | 0 | 0 |
| unassociated | 2 | 4 |

- **`unassociated` (2 SonarQube + 4 PMD):** todas as ocorrências caem em
  `hibernate-core/org/hibernate/dialect/Dialect.java`, o único arquivo do
  escopo que o JavaParser não consegue parsear (enum local — já registrado
  na seção de Escopo/Inventário). Como o `Associator` também usa JavaParser
  para resolver a localização, qualquer alerta bruto dentro desse arquivo
  (vindo do SonarQube ou do PMD, que usam parsers próprios e não falham
  nele) não pode ser associado a um método — resultado esperado e
  consistente com o tratamento já documentado para esse arquivo, não uma
  ocorrência nova a resolver.
- **`out_of_scope` SonarQube (68):** construtores (fora da unidade de
  comparação) e métodos sem corpo (abstratos/interface) — nenhum "método
  pertence a tipo local ou anônimo" nesta base (não há ocorrências do
  SonarQube resolvidas para tipos locais/anônimos no Hibernate).
- **`out_of_scope` PMD (104):** mistura de níveis de classe/tipo
  (`NcssCount` em `classReportLevel`), construtores (`NcssCount` e
  `ExcessiveParameterList` também disparam para construtores, confirmado
  desde o piloto) e métodos sem corpo — mesmas categorias já previstas em
  PROTOCOLO.md seção 13 e observadas no piloto, nenhuma categoria nova.
- Deduplicação (`Deduplicator`, chave `tool+project+smell+method_id`): 576
  alertas de entrada (386 SonarQube elegíveis + 190 PMD elegíveis) → `576`
  registros únicos (nenhuma deduplicação necessária — nenhum método recebeu
  mais de um alerta bruto da mesma ferramenta para o mesmo smell).
  `raw_total=576 unique_total=576`.
- Artefatos (todos em `runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/`):
  `occurrences-sonarqube.csv`, `occurrences-pmd.csv`,
  `association-sonarqube.jsonl`, `association-pmd.jsonl`,
  `dedup-input-sonarqube.jsonl`, `dedup-input-pmd.jsonl`,
  `dedup-input-all.jsonl`, `dedup-results.jsonl` — todos preservando o
  vínculo com o alerta bruto original (`raw_alert_id` = chave do issue do
  SonarQube ou `pmd::<relative_path>::<beginline>::<rule>`).
- **Bug real encontrado e corrigido durante a validação do invariante
  `A ∪ B ⊆ U` (PROTOCOLO.md seção 18):** o script que monta
  `dedup-input-*.jsonl` usava `ConvertTo-Json` (PowerShell), que por
  padrão escapa `<`/`>` como `\u003c`/`\u003e`; o parser mínimo do
  `Deduplicator.java` não desfaz `\uXXXX`, corrompendo o `method_id` de
  métodos com parâmetros genéricos (`216` dos `576` alertas, ex.:
  `Class<?>` virava `Classu003c?u003e`). Corrigido construindo o JSON
  manualmente (mesma convenção de escape do `Associator.java`) em
  `normalize-step2-dedup.ps1` e `reprocess-check.ps1`; `dedup-input-*`,
  `dedup-results.jsonl` recalculados. **As métricas (contagens,
  interseção, união, Jaccard) não mudaram** — a corrupção era
  determinística e idêntica nas duas ferramentas para o mesmo método real,
  então a comparação cruzada SonarQube×PMD já batia mesmo com o
  `method_id` corrompido; o único efeito era a não-correspondência com o
  `method_id` canônico do inventário. Retroativamente, o mesmo bug foi
  encontrado e corrigido no piloto Commons Lang (seção 5), afetando 1 dos
  26 alertas, também sem mudança de métricas. Invariante `A ∪ B ⊆ U`
  validado após a correção: `0` violações (script
  `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/check-invariantes.ps1`).
  Não é mudança metodológica — correção de um bug de serialização JSON em
  script auxiliar de engenharia.

**Evidências (Cobertura):**

- Conjunto de arquivos em escopo: `6605` (mesma lista para SonarQube, PMD e
  inventário de métodos — `arquivos-incluidos.txt`).
- SonarQube: `6605`/`6605` arquivos analisados sem erro de processamento
  (nenhum erro de análise por arquivo reportado pelo scanner; avisos são
  globais — `sonar.java.libraries`, shallow clone/blame — não por arquivo).
- PMD: `6601`/`6605` (99,94%) — 4 falhas de processamento isoladas
  (`falhas-processamento-pmd.txt`, limitação de resolução de símbolos do
  PMD 7.27.0 com um tipo `Cloneable<T>` local que sombreia
  `java.lang.Cloneable`, reproduzida isoladamente).
- `MethodInventoryExtractor` (universo `U`): `6604`/`6605` (99,98%) — 1
  falha de parsing isolada (`Dialect.java`, enum local, limitação do
  JavaParser 3.28.2, já registrada na seção de Escopo/Inventário).
- **Diferenças de cobertura reconciliadas, não bloqueantes:** as três
  falhas pontuais (1 JavaParser + 4 PMD) atingem arquivos distintos e
  juntas representam `5` de `6605` arquivos (`0,076%`). Nenhuma delas
  esconde uma falha sistemática de configuração — cada uma tem causa raiz
  identificada e reproduzida isoladamente fora do projeto estudado. O
  efeito líquido já está refletido nos estados `unassociated` (para
  Dialect.java) e na ausência de qualquer alerta PMD possível para os 4
  arquivos com `Cloneable<T>` local (nenhum método desses 4 arquivos pode
  aparecer em `B`, mas podem aparecer em `A` se o SonarQube os sinalizar —
  não ocorreu neste caso real, nenhuma das 456 issues do SonarQube caiu
  nesses 4 arquivos). Nenhuma ocorrência potencialmente elegível ficou sem
  resolução (PROTOCOLO.md seção 13) — cobertura considerada comparável.

**Evidências (Métricas):**

| Smell | \|U\| | \|A\| | \|B\| | Sonar % | PMD % | Interseção | Sonar-only | PMD-only | União | Jaccard |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Long Method | 48102 | 260 | 126 | 0.5405% | 0.2619% | 125 | 135 | 1 | 261 | 0.4789 |
| Long Parameter List | 48102 | 126 | 64 | 0.2619% | 0.1331% | 47 | 79 | 17 | 143 | 0.3287 |

**Evidências:** `U` = `48102` métodos elegíveis (inventário completo, 0
colisões). `A`/`B` = métodos únicos sinalizados por SonarQube/PMD após
associação e deduplicação (excluindo `out_of_scope`/`ambiguous`/
`unassociated`). Fórmulas aplicadas conforme PROTOCOLO.md seção 15 (mesmas
validadas pelo self-test de `Metrics` na seção 4 e usadas no piloto):
percentuais sobre `|U|`, Jaccard = `|interseção|/|união|` (nenhum caso de
união vazia ou universo vazio neste projeto). Artefato:
`runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/metrics-resultado.json`.
Script de cálculo (mesma fórmula validada por `Metrics --self-test`,
conjuntos construídos a partir de `dedup-results.jsonl`):
`runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/compute-metrics.ps1`.

**Evidências (Validação final):**

- [x] Versões/configurações confirmadas (SonarQube `26.9.0.129388`,
      PMD `7.27.0`, mesmo Quality Profile/ruleset validados na seção 4).
- [x] Cobertura reconciliada (ver subseção Cobertura acima).
- [x] Falhas de parsing/processamento registradas (`falhas-parsing.txt`,
      `falhas-processamento-pmd.txt`).
- [x] Ocorrências potencialmente elegíveis resolvidas (0 `ambiguous`; 6
      `unassociated` todos com causa identificada em `Dialect.java`).
- [x] Invariantes mínimas (PROTOCOLO.md seção 18) validadas:
      `A ⊆ U` e `B ⊆ U` → `0` violações (após a correção do bug de
      escaping JSON acima); `|A∪B| = |A|+|B|-|A∩B|` conferido por
      construção aritmética dos `HashSet` (260+126-125=261;
      126+64-47=143); nenhum `method_id` duplicado no universo
      (`48102` IDs únicos = `48102` linhas do inventário).
- [x] Métricas recalculáveis a partir dos artefatos preservados
      (`inventory-methods.jsonl`, `association-*.jsonl`,
      `dedup-results.jsonl`, `metrics-resultado.json`).
- [x] Reprocessamento determinístico: `Associator`/`Deduplicator`/cálculo
      de métricas reexecutados a partir dos MESMOS relatórios brutos já
      salvos (`raw/sonarqube-issues.jsonl`, `raw/pmd-output.xml`), sem
      reinvocar SonarScanner/PMD — `association-sonarqube.jsonl`,
      `association-pmd.jsonl`, `dedup-input-all.jsonl`,
      `dedup-results.jsonl` e `metrics-resultado.json` **idênticos
      byte-a-byte** (SHA-256) entre `inventories/` e `reprocess-check/`.
      Script: `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/reprocess-check.ps1`;
      saída: `runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/reprocess-check-output.txt`.

**DECISÃO:** Hibernate ORM 7.2.6.Final — CONCLUÍDO. Todos os critérios
equivalentes aos do piloto (PROTOCOLO.md seção 17) foram atendidos. Duas
limitações de ferramenta (1 arquivo não parseável pelo JavaParser, 4
arquivos não processáveis pelo PMD) e 1 bug de engenharia (escaping JSON
no script de normalização, também corrigido retroativamente no piloto)
foram encontrados, documentados e tratados sem exigir alteração de
protocolo nem abertura de bloqueio — nenhum teve efeito sobre os valores
finais de métricas reportados.

---

## 7. Spring Framework 6.2.16

**Execução permitida somente após aprovação do piloto.**

- [x] Checkout
- [x] Escopo/inventário
- [x] Build
- [x] SonarQube
- [x] PMD
- [x] Normalização
- [x] Cobertura
- [x] Métricas
- [x] Validação final

**Status:** CONCLUÍDO (2026-10-01) — todas as etapas da seção 7 finalizadas; liberado o avanço para Quarkus (seção 8)

### Checkout

- [x] Repositório clonado
- [x] Tag `v6.2.16` localizada
- [x] Commit SHA registrado
- [x] Integridade do checkout confirmada

**URL do repositório:** `https://github.com/spring-projects/spring-framework.git`  
**Tag:** `v6.2.16`  
**Commit SHA:** `053d8e25f424bae9c5a597c4b248af137dce264f`  
**Data da coleta:** 2026-10-01

**Evidência:** `git ls-remote --tags` no repositório oficial confirmou uma
única tag correspondente à versão `6.2.16` (`refs/tags/v6.2.16`, tag leve —
aponta diretamente para o commit, sem objeto de tag anotada separado);
tags vizinhas (`v6.2.14`, `v6.2.15`, `v6.2.17`, `v6.2.18`) todas distintas,
sem ambiguidade. Clone raso (`--depth 1 --branch v6.2.16`) feito em
`sources/spring-framework-6.2.16/` (ignorado pelo Git, re-clonável;
`core.longpaths=true` já habilitado globalmente desde o checkout do
Hibernate ORM). Integridade confirmada via `git rev-parse HEAD` (bate com o
commit esperado) e `git status --short` (working tree limpo).

### Escopo

- [x] Módulos inspecionados
- [x] Fontes de produção identificadas
- [x] Exclusões identificadas
- [x] Inventário de arquivos incluídos gerado
- [x] Inventário de arquivos excluídos gerado
- [x] Inventário de métodos elegíveis gerado
- [x] Colisões de `method_id` verificadas

**Métodos elegíveis:** `35236` (0 colisões, 0 falhas de parsing)  
**Arquivos incluídos:** `5124` (`.java` de produção)  
**Arquivos excluídos:** `5851` (de `10975` versionados no total)

**Evidências** (artefatos em
`runs/spring-framework-6.2.16-2026-10-01/inventories/`):

- **Módulos inspecionados:** `settings.gradle` declara 28 subprojetos. O
  próprio `build.gradle` raiz já define o critério objetivo via
  `moduleProjects = subprojects.findAll { it.name.startsWith("spring-") }`
  — os 23 subprojetos com prefixo `spring-` recebem
  `gradle/spring-module.gradle` (que aplica
  `apply from: ".../gradle/publications.gradle"`, isto é, são publicados
  como artefatos Maven do próprio projeto Spring Framework), diferente dos
  5 subprojetos restantes.
- **Módulos de produção incluídos (23, todos com `src/main/java` real,
  confirmado por inspeção de diretório):** `spring-aop`, `spring-aspects`,
  `spring-beans`, `spring-context`, `spring-context-indexer`,
  `spring-context-support`, `spring-core`, `spring-core-test`,
  `spring-expression`, `spring-instrument`, `spring-jcl`, `spring-jdbc`,
  `spring-jms`, `spring-messaging`, `spring-orm`, `spring-oxm`,
  `spring-r2dbc`, `spring-test`, `spring-tx`, `spring-web`,
  `spring-webflux`, `spring-webmvc`, `spring-websocket`.
- **Caso especial não coberto apenas por `src/main/java` (protocolo seção
  6: "Não assumir que todo código de produção está em `src/main/java`"):**
  `spring-core` aplica o plugin MRJAR (`me.champeau.mrjar`,
  `multiRelease { targetVersions 17, 21 }`, confirmado também por busca
  textual — único módulo do repositório que usa esse plugin) e publica um
  **segundo** diretório de produção, `spring-core/src/main/java21`
  (variantes Java 21 das mesmas classes, embutidas no mesmo jar
  multi-release). Incluído explicitamente no escopo (3 métodos).
- **Módulos/diretórios excluídos (com justificativa):** `framework-api`,
  `framework-bom`, `framework-platform` — plugin `java-platform` (BOM/
  agregação de javadoc/constraints de versão), **sem nenhum arquivo `.java`
  na árvore** (confirmado por listagem de diretório — nenhum `src/`
  presente); `framework-docs` — possui `src/main/java` e `src/main/kotlin`,
  mas são **snippets de código incluídos na documentação de referência**
  (pacote `org.springframework.docs.*`), não uma biblioteca publicada: o
  próprio `framework-docs.gradle` desabilita explicitamente `jar.enabled =
  false` e `javadoc.enabled = false` — análogo a "exemplos", excluído pela
  seção 6 do protocolo; `integration-tests` — contém somente `src/test`
  (confirmado por inspeção de diretório), nenhum `src/main`, análogo ao
  caso já registrado do Hibernate ORM
  (`hibernate-integrationtest-java-modules`); `buildSrc` — tooling interno
  de build do próprio Gradle (convention plugins), análogo ao
  `local-build-plugins` do Hibernate ORM.
- **Dentro dos 23 módulos de produção, também excluídos** (sourceSets fora
  de `src/main/java`, confirmados por inspeção de diretório de cada
  módulo): `src/test` (4399 arquivos — testes); `src/testFixtures` (274 —
  biblioteca de apoio a testes, criada pelo plugin `java-test-fixtures`);
  `src/jmh` (25 — benchmarks, excluídos explicitamente pela seção 6);
  `src/main/kotlin` (60 — fora do escopo, protocolo restringe a análise a
  "código Java de produção"); `src/main/resources` (95 — não são `.java`).
  Também excluídos: 12 arquivos `.aj` (AspectJ) em `spring-aspects/src/main`
  — não são arquivos `.java` (sintaxe/gramática distinta do Java), mesmo
  critério já usado para excluir Kotlin.
- **Inventário de arquivos** (via `git ls-files`, que já exclui `.git` e
  `build/` por não serem versionados — script
  `runs/spring-framework-6.2.16-2026-10-01/logs/build-file-inventory.ps1`):
  `10975` arquivos versionados no total; `5124` incluídos; `5851`
  excluídos (`SOMA_OK=True`). Breakdown completo das exclusões por
  categoria (script
  `runs/spring-framework-6.2.16-2026-10-01/logs/compute-excluded-breakdown.ps1`):
  `src/test`=4399, `framework-docs`=847, `src/testFixtures`=274,
  `src/main/resources`=95, `src/main/kotlin`=60, `integration-tests`=45,
  outros arquivos de build/docs dentro dos módulos `spring-*`=37,
  `src/jmh`=25, raiz do repositório=23, `.github`=19, `buildSrc`=16,
  `gradle/`=7, `framework-bom`=1, `framework-api`=1, `framework-platform`=1,
  `.idea`=1 (soma = 5851). Listas completas em
  `runs/spring-framework-6.2.16-2026-10-01/inventories/arquivos-incluidos.txt`
  e `arquivos-excluidos.txt`.
- **Inventário de métodos elegíveis:** gerado com `MethodInventoryExtractor`
  (mesma ferramenta validada na seção 4, usada no piloto e no Hibernate
  ORM) em uma única execução, usando um diretório de staging com
  *junctions* do Windows — uma por módulo apontando para
  `<módulo>/src/main/java`, mais uma extra (`spring-core-java21`) para o
  caso especial MRJAR do `spring-core` — como `--root`, para que
  `relative_path` preserve o caminho real do módulo e fique globalmente
  único em uma única checagem de colisão (script
  `runs/spring-framework-6.2.16-2026-10-01/logs/build-scope-staging.ps1`).
  Mesma decisão de engenharia já aplicada no Hibernate ORM (não altera a
  definição de `method_id`, apenas o cálculo de `relative_path` a partir de
  um staging sem cópia física de arquivos). Resultado:
  `arquivos_java_encontrados=5124` (reconciliado com o inventário de
  arquivos acima), `metodos_elegiveis=35236`,
  `falhas_de_parsing=0`, `colisoes_de_identificador=0`. Detalhamento por
  módulo em
  `runs/spring-framework-6.2.16-2026-10-01/inventories/metodos-por-modulo-detalhado.txt`
  (`spring-core`=5623, `spring-web`=5455, `spring-webmvc`=3331,
  `spring-context`=3242, `spring-test`=2957, `spring-webflux`=2320,
  `spring-beans`=2313, `spring-messaging`=1642, `spring-jdbc`=1416,
  `spring-websocket`=1149, `spring-aop`=1115, `spring-jms`=913,
  `spring-tx`=788, `spring-expression`=759, `spring-orm`=692,
  `spring-context-support`=575, `spring-r2dbc`=313, `spring-core-test`=284,
  `spring-oxm`=165, `spring-jcl`=117, `spring-context-indexer`=53,
  `spring-aspects`=8, `spring-instrument`=3, `spring-core-java21`=3).
- **Falhas de parsing:** `0` de `5124` arquivos — diferente do Hibernate
  ORM (que teve 1 falha por enum local em `Dialect.java`), o JavaParser
  3.28.2 conseguiu parsear a totalidade do código de produção do Spring
  Framework 6.2.16 sem exceções.
- **Colisões de `method_id`:** `0` (checagem única sobre os 35236 métodos
  de todos os 23 módulos simultaneamente + variante MRJAR, via staging —
  ver acima).
- Comandos reproduzíveis preservados em
  `runs/spring-framework-6.2.16-2026-10-01/logs/` (`build-file-inventory.ps1`,
  `compute-excluded-breakdown.ps1`, `build-scope-staging.ps1`,
  `method-inventory-extractor-output.txt`, `compute-methods-by-module.ps1`).

### Build

- [x] JDK efetivo registrado
- [x] Comando de build registrado
- [x] Build concluído
- [x] Bytecode/dependências disponíveis para SonarQube

**Status:** CONCLUÍDA

**Evidências:**

- **Decisão de JDK (toolchain do próprio projeto, não contornada):**
  `buildSrc/src/main/java/org/springframework/build/JavaConventions.java`
  configura explicitamente, para toda a build, um Gradle Toolchain com
  vendor `BellSoft Liberica` e `JavaLanguageVersion.of(17)` — diferente do
  Hibernate ORM, aqui não há nenhum mecanismo de override por propriedade;
  é a única JDK aceita para compilar o código principal. Nenhuma JDK
  BellSoft 17 estava instalada localmente; em vez de alterar o projeto,
  usou-se o próprio mecanismo de autoprovisionamento de toolchains do
  Gradle (plugin `org.gradle.toolchains.foojay-resolver-convention`, já
  declarado em `settings.gradle`, com `auto-download`/`auto-detection`
  habilitados por padrão) — confirmado via `./gradlew javaToolchains` que
  o Gradle baixou e passou a listar `BellSoft Liberica JDK 17.0.20.1+1-LTS`
  (`Detected by: provisioned toolchain`,
  `C:\Users\gusta\.gradle\jdks\bellsoft-17-amd64-windows.2`). **Não é
  mudança metodológica nem edição do código estudado:** PROTOCOLO.md
  seção 5 permite preparar "dependências, JDKs e ferramentas externas...
  fora do código estudado"; aqui o próprio build já declarava o requisito
  de toolchain, e apenas disponibilizamos a JDK exigida via o mecanismo
  nativo do Gradle, sem tocar em nenhum arquivo do repositório.
- **JDK usada para executar o Gradle (daemon):** Oracle JDK 21
  (`C:\Program Files\Java\jdk-21`, `21.0.9`) — `JAVA_HOME` foi ajustado
  apenas na sessão do terminal (variável de ambiente, não arquivo do
  projeto) porque o valor global configurado no sistema aponta para
  `...\jdk-21\bin` (pasta `bin`, não a raiz do JDK — já registrado como
  armadilha conhecida do ambiente), o que impede o `gradlew.bat` de
  localizar `java.exe`.
- **JDK efetivamente usada para compilar `src/main/java`:** BellSoft
  Liberica JDK `17.0.20.1+1-LTS` (via toolchain, auto-provisionada).
- **Comando de build (wrapper do próprio projeto — PROTOCOLO.md seção 10):**
  `./gradlew.bat compileJava --console=plain` (Gradle `8.14.3` via
  wrapper, conforme `gradle/wrapper/gradle-wrapper.properties`; sem
  execução de testes).
- **Caso especial (MRJAR do `spring-core`):** a tarefa agregada
  `compileJava` não compila automaticamente o sourceSet adicional
  `java21` criado pelo plugin MRJAR (sourceSet próprio, só é amarrado à
  tarefa `jar` final, não à tarefa `compileJava`). Executado também, na
  mesma JDK toolchain (BellSoft 17 para o Gradle resolver o `java21`
  especificamente usando toolchain Java 21 — o plugin MRJAR seleciona a
  toolchain correta por sourceSet automaticamente), o comando dedicado
  `./gradlew.bat :spring-core:compileJava21Java --console=plain`. Isso não
  é uma mudança metodológica: é a execução de uma tarefa Gradle já
  definida pelo próprio projeto (`compileJava21Java`, listada em
  `./gradlew :spring-core:tasks --all`), necessária para que o código de
  produção localizado em `spring-core/src/main/java21` (parte do escopo —
  ver subseção Escopo) também gere bytecode.
- **Resultado:** `BUILD SUCCESSFUL` nas duas invocações (`compileJava`
  geral e `compileJava21Java` específico), `EXITCODE=0`, sem erros de
  compilação; apenas avisos informativos do próprio Gradle (uso de
  features obsoletas incompatíveis com o futuro Gradle 9, nível da
  ferramenta de build, não do código analisado) e um link para
  "Problems report" (relatório de incubação do Gradle, sem erros
  listados). Uma primeira invocação do `compileJava` geral foi
  interrompida pelo usuário antes de concluir (parte dos 23 módulos já
  havia sido compilada); a invocação seguinte reaproveitou o trabalho
  incremental já feito (tarefas `UP-TO-DATE`) e completou as pendentes
  (`spring-websocket`, `spring-test`, `framework-docs` — este último fora
  do escopo, mas compilado como efeito colateral de rodar a tarefa
  agregada `compileJava` na raiz do projeto multi-módulo; não afeta o
  escopo de análise, que usa apenas os diretórios dos 23 módulos de
  produção).
- **Duração:** invocação final do `compileJava` geral —
  `1m 21s` (relatada pelo próprio Gradle: "BUILD SUCCESSFUL in 1m 21s",
  58 tarefas, 20 executadas + 38 `UP-TO-DATE`); invocação dedicada do
  `compileJava21Java` — `6s` (11 tarefas, 2 executadas + 9 `UP-TO-DATE`).
- **Módulos processados:** todos os 23 módulos de produção (mais o
  sourceSet `java21` do `spring-core`) geraram bytecode — `7222` arquivos
  `.class` via `javac`/toolchain BellSoft 17 nos 22 módulos convencionais
  (`spring-web`=1217, `spring-core`=1101, `spring-context`=819,
  `spring-test`=566, `spring-webmvc`=538, `spring-webflux`=456,
  `spring-beans`=447, `spring-messaging`=322, `spring-jdbc`=301,
  `spring-websocket`=236, `spring-tx`=205, `spring-aop`=289,
  `spring-jms`=153, `spring-expression`=156, `spring-orm`=105,
  `spring-context-support`=104, `spring-r2dbc`=90, `spring-core-test`=56,
  `spring-oxm`=33, `spring-jcl`=15, `spring-context-indexer`=12,
  `spring-instrument`=1) **+** `33` arquivos `.class` do `spring-aspects`
  compilados pelo compilador **AspectJ** (`ajc`, não `javac` — tarefa
  `compileAspectj`, saída em `build/classes/aspectj/main`, diferente do
  padrão `build/classes/java/main` dos demais módulos — por isso
  `spring-aspects:compileJava` aparece como `SKIPPED` no log: o próprio
  plugin `io.freefair.aspectj` desvia a compilação para `ajc`) **+** `1`
  arquivo `.class` do sourceSet `java21` do `spring-core`
  (`build/classes/java/java21`). **Total: `7256` arquivos `.class`** nos
  23 módulos de produção.
- Logs completos preservados em
  `runs/spring-framework-6.2.16-2026-10-01/logs/build-run1.log`,
  `build-run2-java21.log`, `javatoolchains-output.txt`,
  `check-build-output.ps1`.
- **Bytecode disponível para SonarQube:** `<módulo>/build/classes/java/main`
  de cada um dos 22 módulos convencionais, `spring-aspects/build/classes/aspectj/main`
  e `spring-core/build/classes/java/java21`, prontos para uso como
  `sonar.java.binaries` na análise.

### SonarQube

- [x] Quality Profile criado
- [x] Somente S138/S107 habilitadas
- [x] Análise executada
- [x] Tarefa concluída no servidor
- [x] `taskId` registrado
- [x] `analysisId` registrado
- [x] Issues exportados
- [x] Paginação validada
- [x] Total API × total exportado reconciliado
- [x] Logs preservados

**Issues S138:** `102`  
**Issues S107:** `48`  
**Falhas:** nenhuma registrada

**Evidências:**

- Projeto `spring-framework-6-2-16` criado via `POST /api/projects/create`;
  Quality Profile `exp-mestrado-long-smells` associado via
  `POST /api/qualityprofiles/add_project` (mesmo profile validado na seção 4
  e usado no piloto/Hibernate ORM: somente `java:S138` max=75 e
  `java:S107` max=7 habilitadas — confirmado via
  `GET /api/qualityprofiles/search?project=spring-framework-6-2-16`,
  `activeRuleCount=2`, `projectCount=3`).
- Análise executada com `sonar-scanner 8.1.0.6389` usando
  `runs/spring-framework-6.2.16-2026-10-01/config/sonar-project.properties`
  (`sonar.sources`/`sonar.java.binaries` apontando para os 23 módulos de
  produção — incluindo os dois casos especiais, `spring-aspects`
  (bytecode AspectJ) e o sourceSet `java21` do `spring-core`;
  `sonar.java.source=17`, mesmo release do toolchain principal).
  `ANALYSIS SUCCESSFUL`; `taskId=cbd8a4bc-3061-43d7-93d8-a1bfe5cbfe7d`,
  `analysisId=2845ace7-10ea-408d-aaf5-e1f8b84a6d4c`, `status=SUCCESS`
  (confirmado via `GET /api/ce/component`), `executionTimeMs=22172`.
  Avisos do scanner (não bloqueantes, mesma natureza do piloto/Hibernate):
  ausência de `sonar.java.libraries` (não afeta detecção de S138/S107, que
  não depende de resolução de tipos externos para contagem de
  linhas/parâmetros), *shallow clone* e blame ausente para 5124 arquivos
  (afeta só metadados de SCM/autoria).
- Issues exportados com `scripts/sonarqube/export-issues-paginated.ps1`
  (mesmo script validado na seção 4, usado no piloto e no Hibernate ORM):
  `REPORTED_TOTAL=150`, `EXPORTED_TOTAL=150`, `UNIQUE_KEYS=150`,
  `PAGES_FETCHED=2`, `VALIDACAO_TOTAL_EXPORTADO=PASS`. Quebra por regra:
  `java:S138=102`, `java:S107=48`.
- Issues brutos preservados em
  `runs/spring-framework-6.2.16-2026-10-01/raw/sonarqube-issues.jsonl`;
  log do scanner em
  `runs/spring-framework-6.2.16-2026-10-01/logs/sonar-scanner-output.txt`;
  verificação do status da análise via API em
  `runs/spring-framework-6.2.16-2026-10-01/logs/check-sonar-status-output.txt`.

### PMD

- [x] Ruleset criado
- [x] Somente NcssCount/ExcessiveParameterList habilitadas
- [x] Execução concluída
- [x] Relatório estruturado preservado
- [x] Arquivos processados reconciliados
- [x] Erros de processamento registrados

**NcssCount:** `83`  
**ExcessiveParameterList:** `10`  
**Falhas:** nenhuma registrada

**Evidências:**

- Mesmo ruleset do piloto/Hibernate ORM/seção 3-4
  (`configs/pmd-ruleset-exp-mestrado-long-smells.xml`): apenas `NcssCount`
  (`methodReportLevel=60`) e `ExcessiveParameterList` (`minimum=10`).
- Comando: `pmd check -d <23 diretórios "src/main/java" de produção, um por
  módulo, mais o sourceSet "java21" do spring-core, separados por vírgula>
  -R configs/pmd-ruleset-exp-mestrado-long-smells.xml -f xml -r
  runs/spring-framework-6.2.16-2026-10-01/raw/pmd-output.xml --no-cache`.
  `[INFO] Found 93 violations.` `5124/5124` arquivos processados
  (reconciliado com o inventário de arquivos), `Errors:0` — nenhum erro de
  processamento de arquivo, diferente do Hibernate ORM (que teve 4 falhas
  pontuais de resolução de símbolos). Quebra por regra (script
  `runs/spring-framework-6.2.16-2026-10-01/logs/pmd-rule-breakdown.ps1`):
  `NcssCount=83`, `ExcessiveParameterList=10`.
- **Nota de script (não metodológica):** o log texto
  `runs/spring-framework-6.2.16-2026-10-01/logs/pmd-output.txt` teve sua
  última linha (`EXITCODE=...`) corrompida por mistura de encodings entre
  `Tee-Object` (UTF-16LE) e um `Out-File -Append -Encoding utf8`
  subsequente no mesmo arquivo — bug de script de log, sem efeito sobre o
  relatório estruturado (`pmd-output.xml`, parseado com sucesso, `93`
  violações e `0` erros confirmados diretamente do XML). Código de saída
  `4` (violações encontradas) inferido do padrão já estabelecido nos
  projetos anteriores (mesmo comportamento do PMD 7.27.0 quando há
  violações, sem erro), não da leitura literal do log corrompido.
- Relatório bruto estruturado preservado em
  `runs/spring-framework-6.2.16-2026-10-01/raw/pmd-output.xml`; log
  completo (com a ressalva acima) em
  `runs/spring-framework-6.2.16-2026-10-01/logs/pmd-output.txt`.

### Normalização

- [x] Alertas SonarQube associados
- [x] Alertas PMD associados
- [x] Out-of-scope classificados
- [x] Ambíguos tratados
- [x] Não associados tratados
- [x] Deduplicação executada
- [x] Vínculo com dados brutos preservado

| Estado | SonarQube (150) | PMD (93) |
|---|---:|---:|
| eligible_method | 111 | 81 |
| out_of_scope | 39 | 12 |
| ambiguous | 0 | 0 |
| unassociated | 0 | 0 |

**Evidências:**

- Associação feita por `Associator` (AST, por localização — PROTOCOLO.md
  seção 13; mesma ferramenta do piloto/Hibernate ORM), nunca por
  nome/linha isolado. `--root` = diretório de staging com *junctions*
  (mesmo usado no inventário, incluindo o junction extra
  `spring-core-java21` do caso MRJAR), garantindo `relative_path`
  idêntico entre inventário e associação.
- Conversão dos relatórios brutos para o formato de entrada do
  `Associator` (`relative_path,line,label`): `component` do SonarQube e
  `name` do arquivo no XML do PMD normalizados removendo o prefixo do
  projeto/módulo e mapeando `src/main/java` → `/` (e, caso especial,
  `spring-core/src/main/java21/...` → `spring-core-java21/...`, para
  bater com o `relative_path` do inventário). Scripts:
  `runs/spring-framework-6.2.16-2026-10-01/logs/normalize-step1-association.ps1`,
  `normalize-step2-dedup.ps1`.
- **`0 unassociated` e `0 ambiguous`** — diferente do Hibernate ORM (que
  teve 6 `unassociated` por causa da falha de parsing isolada em
  `Dialect.java`): como o JavaParser não teve nenhuma falha de parsing no
  Spring Framework (seção Escopo/Inventário), todos os 243 alertas brutos
  (150 SonarQube + 93 PMD) foram resolvidos para um estado definido.
- **`out_of_scope` SonarQube (39):** construtores — SonarQube `java:S107`
  também avalia construtores (parâmetro nativo `constructorMax`, mantido
  no default conforme registrado na seção 3) e `java:S138` também é
  aplicável a construtores; ambos fora da unidade de comparação (seção 7
  do protocolo). Nenhum alerta resolvido para tipo local/anônimo nesta
  base.
- **`out_of_scope` PMD (12):** 11 construtores (`NcssCount` e
  `ExcessiveParameterList` também disparam para construtores, confirmado
  desde o piloto) + 1 nível de classe/tipo (`NcssCount`
  `classReportLevel`) — mesmas categorias já previstas em PROTOCOLO.md
  seção 13 e observadas nos dois projetos anteriores, nenhuma categoria
  nova.
- Deduplicação (`Deduplicator`, chave `tool+project+smell+method_id`):
  192 alertas de entrada (111 SonarQube elegíveis + 81 PMD elegíveis) →
  `192` registros únicos (nenhuma deduplicação necessária — nenhum método
  recebeu mais de um alerta bruto da mesma ferramenta para o mesmo
  smell). `raw_total=192 unique_total=192`.
- Artefatos (todos em
  `runs/spring-framework-6.2.16-2026-10-01/inventories/`):
  `occurrences-sonarqube.csv`, `occurrences-pmd.csv`,
  `association-sonarqube.jsonl`, `association-pmd.jsonl`,
  `dedup-input-sonarqube.jsonl`, `dedup-input-pmd.jsonl`,
  `dedup-input-all.jsonl`, `dedup-results.jsonl` — todos preservando o
  vínculo com o alerta bruto original (`raw_alert_id` = chave do issue do
  SonarQube ou `pmd::<relative_path>::<beginline>::<rule>`). JSON de
  dedup-input construído manualmente (mesma convenção de escape do
  `Associator.java`), nunca com `ConvertTo-Json` — lição já registrada no
  Hibernate ORM/piloto, aplicada preventivamente aqui desde o início
  (nenhuma corrupção de `method_id` genérico encontrada nesta execução).

### Cobertura

- [x] Conjunto de fontes SonarQube validado
- [x] Conjunto de fontes PMD validado
- [x] Diferenças de cobertura explicadas
- [x] Parsing failures reconciliados
- [x] Cobertura considerada comparável

**Status:** CONCLUÍDA
o4
**Evidências:** SonarQube, PMD e `MethodInventoryExtractor` analisaram
exatamente o mesmo conjunto de `5124` arquivos de produção (23 módulos +
sourceSet `java21` do `spring-core`), com **`0` falhas de parsing/processamento
nas três ferramentas** — `5124/5124` (100%) em todas. Diferente do
Hibernate ORM (que teve falhas pontuais de cobertura em 2 ferramentas),
aqui não há nenhuma diferença de cobertura de arquivos a reconciliar entre
SonarQube, PMD e o inventário de métodos elegíveis.

### Métricas

| Smell | \|U\| | \|A\| | \|B\| | Sonar % | PMD % | Interseção | Sonar-only | PMD-only | União | Jaccard |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Long Method | 35236 | 101 | 81 | 0.2866% | 0.2299% | 74 | 27 | 7 | 108 | 0.6852 |
| Long Parameter List | 35236 | 10 | 0 | 0.0284% | 0.0000% | 0 | 10 | 0 | 10 | 0.0000 |

**Evidências:** `U` = `35236` métodos elegíveis (inventário completo, 0
colisões). `A`/`B` = métodos únicos sinalizados por SonarQube/PMD após
associação e deduplicação (excluindo `out_of_scope`/`ambiguous`/
`unassociated`). Fórmulas aplicadas conforme PROTOCOLO.md seção 15 (mesmas
validadas pelo self-test de `Metrics` na seção 4 e usadas nos dois
projetos anteriores): percentuais sobre `|U|`; Jaccard =
`|interseção|/|união|` para Long Method; para Long Parameter List, `B=0`
e `união=10≠0` → caso especial da seção 15 ("apenas um conjunto vazio →
Jaccard = 0"), não `N/A`. Artefato:
`runs/spring-framework-6.2.16-2026-10-01/inventories/metrics-resultado.json`.
Script de cálculo (mesma fórmula validada por `Metrics --self-test`,
conjuntos construídos a partir de `dedup-results.jsonl`):
`runs/spring-framework-6.2.16-2026-10-01/logs/compute-metrics.ps1`.

### Validação final

- [x] Versões/configurações confirmadas (SonarQube `26.9.0.129388`,
      PMD `7.27.0`, mesmo Quality Profile/ruleset validados na seção 4).
- [x] Cobertura reconciliada (100% nas três ferramentas, ver subseção
      Cobertura acima).
- [x] Falhas de parsing/processamento registradas (`0` em todas as
      ferramentas — nenhum arquivo registrado em
      falhas-parsing/falhas-processamento).
- [x] Ocorrências potencialmente elegíveis resolvidas (`0` `ambiguous`,
      `0` `unassociated`).
- [x] Invariantes mínimas (PROTOCOLO.md seção 18) validadas:
      `A ⊆ U` e `B ⊆ U` → `0` violações (script
      `runs/spring-framework-6.2.16-2026-10-01/logs/check-invariantes.ps1`,
      `A_UNION_B_SUBSET_OF_U_VIOLATIONS=0`); `|A∪B| = |A|+|B|-|A∩B|`
      conferido por construção aritmética dos `HashSet` (101+81-74=108;
      10+0-0=10); nenhum `method_id` duplicado no universo (`35236` IDs
      únicos = `35236` linhas do inventário,
      `NO_DUPLICATE_METHOD_IDS=True`).
- [x] Métricas recalculáveis a partir dos artefatos preservados
      (`inventory-methods.jsonl`, `association-*.jsonl`,
      `dedup-results.jsonl`, `metrics-resultado.json`).
- [x] Reprocessamento determinístico: `Associator`/`Deduplicator`/cálculo
      de métricas reexecutados a partir dos MESMOS relatórios brutos já
      salvos (`raw/sonarqube-issues.jsonl`, `raw/pmd-output.xml`), sem
      reinvocar SonarScanner/PMD — `association-sonarqube.jsonl`,
      `association-pmd.jsonl`, `dedup-input-all.jsonl`,
      `dedup-results.jsonl` e `metrics-resultado.json` **idênticos
      byte-a-byte** (SHA-256) entre `inventories/` e `reprocess-check/`.
      Script: `runs/spring-framework-6.2.16-2026-10-01/logs/reprocess-check.ps1`;
      saída: `runs/spring-framework-6.2.16-2026-10-01/logs/reprocess-check-output.txt`.

**DECISÃO:** Spring Framework 6.2.16 — CONCLUÍDO. Todos os critérios
equivalentes aos do piloto (PROTOCOLO.md seção 17) foram atendidos. O
único caso especial de engenharia desta execução (sourceSet MRJAR
`java21` do `spring-core`, já tratado desde a seção de Escopo) não exigiu
abertura de bloqueio nem alteração de protocolo; nenhuma falha de
parsing/processamento ocorreu em nenhuma das três ferramentas (diferente
dos dois projetos anteriores), e a cobertura entre SonarQube, PMD e o
inventário de métodos foi 100% idêntica, sem necessidade de reconciliação.

---

## 8. Quarkus 3.32.1

**Execução permitida somente após aprovação do piloto.**

- [x] Checkout
- [x] Escopo/inventário
- [x] Build
- [x] SonarQube
- [x] PMD
- [x] Normalização
- [x] Cobertura
- [x] Métricas
- [x] Validação final

**Status:** CONCLUÍDO (2026-10-01) — todas as etapas da seção 8 finalizadas; **último projeto do experimento concluído**.

### Checkout

**URL do repositório:** `https://github.com/quarkusio/quarkus.git`  
**Tag:** `3.32.1`  
**Commit SHA:** `058b0b546fe033547d4d42afb7766a9e00b0329b`  
**Data da coleta:** 2026-10-01

**Evidência:** `git ls-remote --tags` confirmou a tag `3.32.1` apontando para
o commit acima. Clone raso (`--depth 1 --branch 3.32.1`) feito em
`sources/quarkus-3.32.1/` (ignorado pelo Git, re-clonável). Integridade
confirmada via `git rev-parse HEAD` (idêntico ao commit da tag) e
`git status --short` (working tree limpo).

### Escopo

- [x] Módulos inspecionados
- [x] Fontes de produção identificadas
- [x] Exclusões identificadas
- [x] Inventário de arquivos incluídos gerado
- [x] Inventário de arquivos excluídos gerado
- [x] Inventário de métodos elegíveis gerado
- [x] Colisões de `method_id` verificadas

**Métodos elegíveis:** `44165` (0 colisões, 0 falhas de parsing)  
**Diretórios `src/main/java` incluídos:** `574`  
**Diretórios `src/main/java` excluídos:** `56`  
**Arquivos `.java` processados:** `7510`

**Evidências** (artefatos em
`runs/quarkus-3.32.1-2026-10-01/inventories/`):

- **Escala e estrutura:** projeto multi-módulo Maven muito maior que os três
  anteriores (630 diretórios `src/main/java` existentes no repositório, só
  dentro das árvores candidatas `core/`, `extensions/`, `devtools/` e
  `independent-projects/`). Módulos declarados no `pom.xml` raiz:
  `independent-projects/*` (11 projetos "externos" que podem ser
  desmembrados do Quarkus), `bom/*` + `build-parent` (BOMs/POM pai, sem
  código), `core`, `test-framework`, `extensions` (~150 extensões),
  `devtools` (CLI/Maven/Gradle), `integration-tests`, `docs`.
- **Exclusões de alto nível (subárvores inteiras, sem nenhum arquivo de
  produção):** `bom/application`, `bom/test`, `bom/dev-ui`, `build-parent`
  (todos `packaging=pom`, confirmado nos respectivos `pom.xml`, sem
  `src/main/java`); `integration-tests` (testes do próprio projeto);
  `test-framework` (biblioteca de apoio a testes — JUnit5/Arquillian/mocks
  — consumida por autores de aplicações Quarkus para escrever as PRÓPRIAS
  `src/main/java` de produção reais do projeto, não parte da unidade
  TCK, não da aplicação em produção); `docs` (documentação Asciidoc; os 15
  arquivos `.java` existentes em `docs/` são geração/validação de
  documentação (`io.quarkus.docs.generation.*`) ou exemplos embutidos em
  `_examples/`, não código de produção).
- **Exclusões pontuais documentadas (módulos específicos dentro das
  subárvores candidatas, cada uma com justificativa própria verificada por
  inspeção do `pom.xml`/propósito):**
  - `independent-projects/parent` — POM pai, sem `src/main/java`.
  - `independent-projects/ide-config` — `packaging=jar`, mas `src/main/`
    contém somente `eclipse-format.xml`/`eclipse.importorder` (config de
    formatação para contribuidores, não código).
  - `independent-projects/revapi` — o próprio `pom.xml` declara
    explicitamente "This is not deployed into a Maven repository. It is
    merely installed into the local Maven repository during a local
    build." → ferramenta interna de build (checagem de compatibilidade de
    API entre releases), não artefato do produto.
  - `independent-projects/enforcer-rules` — regras customizadas do
    `maven-enforcer-plugin` usadas no build do próprio Quarkus.
  - `independent-projects/junit-virtual-threads`,
    `independent-projects/tools/devtools-testing`,
    `extensions/security/test-utils`, `extensions/arc/test-supplement[-decorator]`,
    `extensions/panache/panache-mock` — bibliotecas de apoio a TESTES
    publicadas (análogas ao `hibernate-testing` do Hibernate ORM): extensões
    JUnit, utilitários de mock/supplement para os testes de quem consome o
    Quarkus, não funcionalidade de produção da aplicação.
  - `independent-projects/arc/tcks/*` — módulos de TCK (Technology
    Compatibility Kit), são testes.
  - `independent-projects/bootstrap/benchmarks` — o próprio `pom.xml` o
    nomeia "Quarkus - Bootstrap - JMH Benchmarks" (benchmarks, exclusão
    explícita do protocolo seção 6).
  - `devtools/config-doc-maven-plugin` — plugin Maven usado somente
    internamente para gerar a documentação de configuração do próprio
    Quarkus (ferramenta de build/doc, não artefato consumido por usuários).
  - Arquétipos Maven (`extensions/*/maven-archetype/src/main/resources/
    archetype-resources/src/main/java`, 4 diretórios) e templates de
    Codestarts (`**/resources/codestarts/**`, ~40 diretórios, em
    `devtools/project-core-extension-codestarts`,
    `independent-projects/tools/base-codestarts` e
    `independent-projects/tools/codestarts/examples`) — são "exemplos"
    (seção 6): código-fonte template que é copiado literalmente para
    projetos recém-criados pelo `quarkus create app`, não código de
    produção do próprio Quarkus. Confirmado que vivem sob `src/main/
    resources/` (recursos empacotados), não sob o `src/main/java` real do
    módulo que os empacota — por isso o motor de geração de codestarts em
    si (`independent-projects/tools/codestarts/src/main/java`) permanece
    incluído, só o conteúdo-template é excluído.
  - Fixtures de teste aninhadas (5 diretórios cujo caminho contém
    `\src\test\`, ex.:
    `devtools/gradle/gradle-application-plugin/src/test/resources/.../main/src/main/java`
    e `independent-projects/bootstrap/app-model/src/test/resources/.../src/main/java`)
    — árvores sintéticas usadas pelos testes do próprio plugin/bootstrap,
    não módulos de produção.
- **Inclusões confirmadas (não excluídas apesar do nome sugerir dúvida):**
  `extensions/grpc/stubs` ("Stubs for health and reflection" — código de
  produção hand-written para health-check/reflection do gRPC, não stub
  gerado nem teste); módulos `deployment` de cada extensão (parte real do
  framework de build-time augmentation do Quarkus, publicados como
  `quarkus-x-deployment`, não teste); extensões com deployment escrito em
  Java para dar suporte a Kotlin/Scala (`extensions/kotlin`,
  `extensions/scala`, variantes `*-kotlin` do Panache/RESTEasy Reactive) —
  o código-fonte dessas extensões é Java (`src/main/java`), mesmo que a
  extensão sirva para interoperar com código de usuário em Kotlin/Scala;
  `devtools/{cli,cli-common,gradle,maven}` e
  `independent-projects/extension-maven-plugin` — ferramentas publicadas e
  efetivamente usadas por todo consumidor do Quarkus (scaffolding/build/CLI),
  diferente de ferramentas internas do próprio build do Quarkus.
- **Staging:** mesmo padrão de *junctions* do Windows usado no Hibernate
  ORM/Spring Framework, mas para 574 diretórios (em vez de 17/23) — script
  `runs/quarkus-3.32.1-2026-10-01/logs/build-scope-staging.ps1`, lendo a
  lista de diretórios incluídos de
  `runs/quarkus-3.32.1-2026-10-01/inventories/scope-src-main-java-included.txt`
  (lista completa antes do filtro em `scope-src-main-java-all.txt`, lista de
  excluídos com cada um dos 56 diretórios em
  `scope-src-main-java-excluded.txt`). Link nomeado pelo caminho do módulo
  (sem o sufixo `\src\main\java`), preservando esse caminho no
  `relative_path` calculado pelo `MethodInventoryExtractor`.
- **Resultado da extração:** `arquivos_java_encontrados=7510`,
  `falhas_de_parsing=0`, `metodos_elegiveis=44165`,
  `colisoes_de_identificador=0`. Artefato em
  `runs/quarkus-3.32.1-2026-10-01/inventories/inventory-methods.jsonl`; log
  em `runs/quarkus-3.32.1-2026-10-01/logs/inventory-extractor-output.txt`.

### Build

**Status:** CONCLUÍDO

**Evidências:**

- **JDK efetivo:** JDK 21 (`$env:JAVA_HOME`), satisfazendo o mínimo exigido
  pelo próprio projeto (`independent-projects/parent/pom.xml`:
  `maven.compiler.release=17`, regra `requireJavaVersion` do
  `maven-enforcer-plugin` exige `jdk.min.version=17` "ou maior"; CI oficial
  do Quarkus testa JDK 17 e 21 — `CONTRIBUTING.md` linha 703). `.sdkmanrc`
  recomenda Temurin 17, mas não é uma exigência rígida de versão exata.
- **Ferramenta de build:** wrapper Maven do próprio projeto (`./mvnw.cmd`,
  Maven 3.9.12 autoprovisionado pelo wrapper) — diferente do Hibernate/
  Spring (Gradle), o Quarkus é um projeto Maven multi-módulo.
- **Comando:** `./mvnw.cmd -Dquickly -B` (fluxo oficial documentado em
  `CONTRIBUTING.md`: `-Dquickly` ativa o profile `quick-build`, goals
  `clean install` com testes/docs/enforcer/jbang/forbiddenapis desabilitados
  — mesmo espírito de "evitar execução de testes" da seção 10 do protocolo,
  usando a documentação oficial do próprio projeto).
- **Resultado:** `BUILD SUCCESS`, 1310 módulos no reactor completo (inclui
  módulos fora do escopo de análise, como `integration-tests/*`/`tcks/*`,
  que o Maven ainda precisa construir por fazerem parte da árvore de
  módulos declarada), tempo total `53:32 min`. Log completo em
  `runs/quarkus-3.32.1-2026-10-01/logs/mvnw-quickly-build.txt` (`EXITCODE=0`
  confirmado na última linha).
- **Bytecode disponível para SonarQube:** `target/classes` gerado em cada
  um dos 574 módulos de produção; achado pontual: os 3 módulos sob
  `devtools/gradle/` (`gradle-application-plugin`, `gradle-extension-plugin`,
  `gradle-model`) são, na verdade, um projeto **Gradle aninhado** dentro do
  reactor Maven (`gradlew`/`build.gradle.kts` próprios) — saída em
  `build/classes/java/main` (convenção Gradle), não `target/classes`
  (convenção Maven). Os 571 módulos restantes usam `target/classes` padrão.
  Confirmado: 574/574 diretórios de bytecode existentes após o build.

### SonarQube

- [x] Quality Profile associado (mesmo `exp-mestrado-long-smells`)
- [x] Análise executada
- [x] Tarefa concluída no servidor
- [x] `taskId` registrado
- [x] `analysisId` registrado
- [x] Issues exportados
- [x] Paginação validada
- [x] Total API × total exportado reconciliado
- [x] Logs preservados

**Issues S138:** `374`  
**Issues S107:** `391`  
**Falhas:** nenhuma registrada (2 avisos esperados, ver abaixo)

**Evidências:**

- Projeto `quarkus-3-32-1` criado via API, mesmo Quality Profile
  (`exp-mestrado-long-smells`, somente `java:S138` max=75 e `java:S107`
  max=7) associado e confirmado.
- **Decisão de engenharia por escala (574 módulos):** diferente do
  Hibernate/Spring (lista explícita de diretórios reais em
  `sonar.sources`), o Quarkus usa `sonar.projectBaseDir` apontando para o
  MESMO diretório de staging (junctions) já usado pelo
  `MethodInventoryExtractor` e pelo PMD, com `sonar.sources=.` — garante
  que as três ferramentas analisem exatamente o mesmo conjunto de 7510
  arquivos, sem risco de divergência de transcrição em uma lista de 574
  caminhos. `sonar.java.binaries` lista os 574 diretórios de bytecode reais
  (não pode usar o staging, pois o build não espelha `target/classes` nele).
  Script: `runs/quarkus-3.32.1-2026-10-01/logs/build-sonar-properties.ps1`.
- Análise executada com `sonar-scanner 8.1.0.6389` a partir do diretório de
  staging. `ANALYSIS SUCCESSFUL`/`EXECUTION SUCCESS`;
  `taskId=263a7ceb-7b9d-472e-b39f-261d34a44074`,
  `analysisId=e75c048c-61c6-4c1d-82cb-25155fa4d602`, `status=SUCCESS`
  confirmado via `GET /api/ce/task` (polling com deadline, script
  `check-sonar-status.ps1`). Tempo total do scanner: `27:08 min`.
- 2 avisos nativos do scanner, ambos já esperados/documentados nos projetos
  anteriores: detecção de SCM falhou (staging não é um repositório git —
  não afeta detecção de S138/S107) e `sonar.java.libraries` não configurado
  (mesma decisão dos 3 projetos anteriores — não foi setado em nenhum
  deles; resolução de tipos degradada não afeta contagem de linhas/
  parâmetros, que são estruturais).
- Issues exportados com `scripts/sonarqube/export-issues-paginated.ps1`:
  `REPORTED_TOTAL=765`, `EXPORTED_TOTAL=765`, `UNIQUE_KEYS=765`,
  `PAGES_FETCHED=8`, `VALIDACAO_TOTAL_EXPORTADO=PASS`.
- Log do scanner em
  `runs/quarkus-3.32.1-2026-10-01/logs/sonar-scanner-output.txt`; issues
  brutos em `runs/quarkus-3.32.1-2026-10-01/raw/sonarqube-issues.jsonl`.

### PMD

- [x] Ruleset reutilizado (mesmo dos 3 projetos anteriores)
- [x] Execução concluída
- [x] Relatório estruturado preservado
- [x] Arquivos processados reconciliados
- [x] Erros de processamento registrados

**NcssCount:** `181`  
**ExcessiveParameterList:** `240`  
**Falhas:** nenhuma registrada

**Evidências:**

- Mesmo ruleset dos 3 projetos anteriores
  (`configs/pmd-ruleset-exp-mestrado-long-smells.xml`).
- **Decisão de engenharia por escala:** em vez de passar 574 caminhos reais
  separados por vírgula em `-d` (estouraria o limite de tamanho de linha de
  comando do Windows), o PMD foi executado com um único `-d` apontando para
  o MESMO diretório de staging usado pelo SonarQube e pelo
  `MethodInventoryExtractor` — garante que as 3 ferramentas processem
  exatamente o mesmo conjunto de arquivos.
- Comando: `pmd check -d <staging> -R configs/pmd-ruleset-exp-mestrado-long-smells.xml -f xml -r pmd-output.xml --no-cache`.
  `[INFO] Found 421 violations.`, `7510/7510` arquivos processados (100%,
  idêntico ao `arquivos_java_encontrados` do inventário), `0` erros de
  processamento (diferente do Hibernate — 4 erros — e igual ao Spring — 0
  erros). `EXITCODE=4` (esperado quando há violações, mesmo padrão dos
  projetos anteriores).
- **Achado de ferramenta (documentado na memória do repositório):** o
  script `run-pmd.ps1` NÃO deve setar `$ErrorActionPreference = "Stop"` —
  o PMD escreve seu resumo (`[INFO] Found N violations.`) em stderr, e com
  `*>&1`+`Tee-Object`+`Stop` o PowerShell aborta o script antes de gravar a
  linha `EXITCODE=` final, mesmo com o relatório XML já completo e correto.
- Relatório bruto preservado em
  `runs/quarkus-3.32.1-2026-10-01/raw/pmd-output.xml`; log em
  `runs/quarkus-3.32.1-2026-10-01/logs/pmd-output.txt`.

### Normalização

- Ferramentas `Associator`/`Deduplicator` reutilizadas sem alteração.
  **Decisão de engenharia:** como SonarQube e PMD analisaram o MESMO
  diretório de staging usado pelo inventário (não os caminhos reais do
  repositório, diferente do Hibernate/Spring), o `component` do SonarQube e
  o `name` de arquivo do PMD (após remover o prefixo do staging) já vêm
  exatamente no formato `relative_path` do inventário — sem necessidade de
  nenhum mapeamento de caminho especial (diferente do caso MRJAR do Spring
  Framework).
- SonarQube: `640/765` `eligible_method`; `125` `out_of_scope` (100
  construtores, 18 métodos de tipo local/anônimo, 7 métodos sem corpo).
- PMD: `339/421` `eligible_method`; `82` `out_of_scope` (70 construtores, 6
  métodos de tipo local/anônimo, 5 métodos sem corpo, 1 nível de
  classe/tipo).
- **0 `ambiguous`/`unassociated` em ambas as ferramentas** — mesmo
  resultado do Spring Framework (0 falhas de parsing/processamento em
  nenhuma das 3 ferramentas), apesar da escala muito maior do Quarkus.
  Todas as categorias `out_of_scope` encontradas já eram antecipadas pelo
  protocolo/seção 13 — nenhuma categoria nova.
- Deduplicação: `979` alertas elegíveis (`640+339`), `979` únicos após
  dedup — **sem nenhuma fusão** (mesmo padrão do Spring Framework).
  Artefatos em `runs/quarkus-3.32.1-2026-10-01/inventories/`
  (`association-sonarqube.jsonl`, `association-pmd.jsonl`,
  `dedup-results.jsonl`).

### Cobertura

**Status:** 100% idêntica nas 3 ferramentas — sem reconciliação necessária.

- SonarQube: `7510` arquivos fonte analisados (log do scanner).
- PMD: `7510/7510` arquivos processados (100%).
- JavaParser (`MethodInventoryExtractor`): `7510` arquivos `.java`
  encontrados, `0` falhas de parsing.
- As três ferramentas processaram exatamente o mesmo conjunto de arquivos
  porque analisaram o mesmo diretório de staging — resultado esperado,
  consistente com a decisão de engenharia documentada acima.

### Métricas finais

| Smell | U | A (Sonar) | B (PMD) | %Sonar | %PMD | Interseção | Só Sonar | Só PMD | União | Jaccard |
|---|---|---|---|---|---|---|---|---|---|---|
| Long Method | 44165 | 348 | 169 | 0.7880% | 0.3827% | 161 | 187 | 8 | 356 | 0.4522 |
| Long Parameter List | 44165 | 292 | 170 | 0.6612% | 0.3849% | 156 | 136 | 14 | 306 | 0.5098 |

Artefatos: `runs/quarkus-3.32.1-2026-10-01/inventories/metrics-resultado.json`,
`runs/quarkus-3.32.1-2026-10-01/logs/metrics-summary.txt`.

### Validação final

- Invariantes mínimas (seção 18) validadas: `0` `method_id` duplicados no
  universo (`44165` únicos = `44165` linhas do inventário); `0` violações
  de `A∪B ⊆ U`. Script `check-invariantes.ps1`.
- Reprocessamento determinístico (seção 20) confirmado: `Associator`/
  `Deduplicator`/métricas reexecutados a partir dos mesmos relatórios
  brutos (`raw/sonarqube-issues.jsonl`, `raw/pmd-output.xml`), sem
  reinvocar sonar-scanner/PMD — todos os 5 artefatos comparados
  (`association-sonarqube.jsonl`, `association-pmd.jsonl`,
  `dedup-input-all.jsonl`, `dedup-results.jsonl`, `metrics-resultado.json`)
  idênticos byte-a-byte (SHA-256). `REPROCESSAMENTO_DETERMINISTICO=True`.
  Script/artefatos em `runs/quarkus-3.32.1-2026-10-01/reprocess-check/`.
- Nenhuma decisão metodológica alterada; nenhum bloqueio necessário.
- **Quarkus 3.32.1 CONCLUÍDO. Os 4 projetos do experimento (Apache Commons
  Lang, Hibernate ORM, Spring Framework, Quarkus) têm métricas finais
  validadas.** Próximo passo: consolidação dos resultados finais (seção 24
  do protocolo).

---

## 9. Bloqueios

Nenhum bloqueio registrado.

Use o formato:

```text
### BLOCK-001
Data:
Etapa:
Problema:
Evidência:
Impacto:
Tentativas realizadas:
Mudança metodológica necessária? SIM/NÃO
Decisão necessária:
```

---

## 10. Artefatos importantes

| Artefato | Caminho | Status |
|---|---|---|
| Protocolo | `PROTOCOLO.md` | criado |
| Status | `STATUS.md` | criado |
| README | `README.md` | criado |
| Fontes | `docs/fontes.md` | populado com as fontes oficiais efetivamente consultadas (Docker Hub, API do SonarQube, GitHub Releases/documentação do PMD, Maven Central, documentação do SonarScanner CLI, GitHub do Apache Commons Lang e do Hibernate ORM) |
| Config SonarQube | `configs/sonarqube-quality-profile-exp-mestrado-long-smells.xml` | criado — backup XML do Quality Profile com S138 (max=75) e S107 (max=7) |
| Ruleset PMD | `configs/pmd-ruleset-exp-mestrado-long-smells.xml` | criado — contém somente NcssCount (methodReportLevel=60) e ExcessiveParameterList (minimum=10) |
| Binário PMD | `sources/pmd-bin-7.27.0/` | baixado, extraído e versionado localmente (`7.27.0` confirmado via `pmd.bat --version`); ignorado pelo Git |
| SonarScanner CLI | `sources/sonar-scanner-8.1.0.6389-windows-x64/` | baixado e extraído (`8.1.0.6389` confirmado); ignorado pelo Git |
| SonarQube (runtime) | container Docker `sonarqube-pilot` | em execução, `127.0.0.1:9000`, versão `26.9.0.129388` confirmada |
| Ferramenta de inventário de métodos | `scripts/method-inventory/` | criada (JavaParser 3.28.2); `src/MethodInventoryExtractor.java` + `README.md`; `lib/`/`out/` ignorados pelo Git |
| Ferramenta de associação por localização | `scripts/method-inventory/src/Associator.java` | criada (JavaParser, resolução por AST); valida os 4 estados da seção 13 (`eligible_method`/`out_of_scope`/`ambiguous`/`unassociated`) |
| Ferramenta de deduplicação | `scripts/method-inventory/src/Deduplicator.java` | criada; agrupa por `tool+project+smell+method_id` (seção 14) |
| Ferramenta de métricas | `scripts/method-inventory/src/Metrics.java` | criada; fórmulas da seção 15, incluindo casos de conjuntos vazios |
| Script de exportação paginada do SonarQube | `scripts/sonarqube/export-issues-paginated.ps1` | criado e validado (150 issues em 2 páginas, total exportado = total reportado, sem duplicatas) |
| Fixtures sintéticos | `scripts/fixtures/` | criados (`inventory/OverloadsAndInnerTypes.java`, `boundary/{LongMethodBoundary,NcssBoundary,ParamListBoundary}.java`, `association/{occorrencias-sinteticas.csv,occorrencias-ambiguas.csv,AmbiguousLocation.java,alertas-duplicados-exemplo.jsonl}`, `pagination/PaginationFixture.java`) |
| Scripts | `scripts/` | povoado: inventário, associação, dedup, métricas e exportação paginada do SonarQube; aplicado de ponta a ponta nos dois projetos reais (piloto Commons Lang e Hibernate ORM) |
| Runs | `runs/synthetic-2026-10-01/` | atualizado — artefatos brutos da validação sintética completa (inventories/raw/logs), incluindo resultados de associação, dedup e paginação |
| Runs (piloto) | `runs/commons-lang-3.20.0-2026-10-01/` | piloto Apache Commons Lang 3.20.0 CONCLUÍDO — inventários de arquivos/métodos, issues brutos SonarQube/PMD (incluindo relatório PMD estruturado em XML), resultados de associação/dedup, métricas finais, verificação de reprocessamento determinístico de ponta a ponta (`reprocess-check/`) e logs (scanner, build, scripts de cálculo) |
| Checkout Hibernate ORM | `sources/hibernate-orm-7.2.6.Final/` | clonado (tag `7.2.6`, commit `c549a5c5a0bdd05cbda5105c4fa899b466be365c`); ignorado pelo Git |
| Runs (Hibernate ORM) | `runs/hibernate-orm-7.2.6.Final-2026-10-01/` | CONCLUÍDO — checkout, escopo/inventário (48102 métodos, 0 colisões), build, issues SonarQube (456, raw JSONL), relatório PMD (298 violações + 4 erros de processamento, XML estruturado), associação/dedup/métricas finais, verificação de reprocessamento determinístico (`reprocess-check/`) e logs/scripts completos |
| Checkout Spring Framework | `sources/spring-framework-6.2.16/` | clonado (tag `v6.2.16`, commit `053d8e25f424bae9c5a597c4b248af137dce264f`); ignorado pelo Git |
| Runs (Spring Framework) | `runs/spring-framework-6.2.16-2026-10-01/` | CONCLUÍDO — checkout, escopo/inventário (35236 métodos, 0 colisões, 0 falhas de parsing), build (7256 `.class`), issues SonarQube (150, raw JSONL), relatório PMD (93 violações, 0 erros de processamento, XML estruturado), associação/dedup/métricas finais, verificação de reprocessamento determinístico (`reprocess-check/`) e logs/scripts completos |
| Checkout Quarkus | `sources/quarkus-3.32.1/` | clonado (tag `3.32.1`, commit `058b0b546fe033547d4d42afb7766a9e00b0329b`); ignorado pelo Git |
| Runs (Quarkus) | `runs/quarkus-3.32.1-2026-10-01/` | CONCLUÍDO — checkout, escopo/inventário (574/630 diretórios `src/main/java` de produção, 44165 métodos elegíveis, 0 colisões, 0 falhas de parsing, 7510 arquivos), build (`./mvnw -Dquickly`, BUILD SUCCESS, 1310 módulos), issues SonarQube (765, raw JSONL), relatório PMD (421 violações, 0 erros de processamento, XML estruturado), associação/dedup/métricas finais, verificação de reprocessamento determinístico (`reprocess-check/`) e logs/scripts completos (incluindo listas de escopo incluído/excluído em `inventories/scope-src-main-java-*.txt`) |
| Resultados | `results/consolidado-2026-10-01/` | CONCLUÍDO — `RESULTADOS-FINAIS.md` (seção 24 do protocolo: resumo executado, tabela de métricas dos 4 projetos × 2 smells, configuração efetiva, cobertura, exclusões, erros/limitações, ocorrências pendentes, caminhos de artefatos, comandos de reprodução), `metricas-finais.csv`, pacote exportável `exp-mestrado-pacote-exportavel-2026-10-01.zip` (268 arquivos, sem credenciais/sources/binários baixados) |
| Repositório git | `.git/` | inicializado, commit inicial `5a44e2b` |
| `.gitignore` | `.gitignore` | criado |
| `.env.example` | `.env.example` | criado |

---

## 11. Próxima ação

1. ~~Inspecionar o ambiente local.~~ CONCLUÍDO
2. ~~Criar a estrutura mínima do experimento.~~ CONCLUÍDO
3. ~~Validar a baseline das ferramentas e regras (seção 3).~~ CONCLUÍDO
4. ~~Validação sintética (seção 4 / seção 16 do protocolo).~~ CONCLUÍDO (13/13):
   inventário de métodos, associação por localização, alertas duplicados,
   boundary de Long Method/Long Parameter List, conjuntos vazios, fórmulas
   das métricas, paginação do SonarQube, validação do total exportado e
   reprocessamento determinístico — todos confirmados por execução real
   contra fixtures sintéticos.
5. ~~Piloto Apache Commons Lang 3.20.0 (seção 5).~~ CONCLUÍDO E APROVADO:
   checkout, escopo/inventário (3829 métodos elegíveis, 0 colisões), build
   (`javac --release 8`, sem dependências de compilação), SonarQube (14
   issues S138/S107), PMD (14 violações NcssCount, 0 ExcessiveParameterList),
   normalização (26 alertas associados, 2 out_of_scope de nível de classe),
   cobertura reconciliada e métricas finais (Long Method: Jaccard=0.7857;
   Long Parameter List: Sonar=1/PMD=0). Corrigido bug real de colisão de
   `method_id` por erasure de bounds genéricos (decisão de engenharia,
   documentada na seção 5/Escopo).
6. ~~Auditoria de conformidade entre PROTOCOLO.md e STATUS.md.~~ CONCLUÍDA
   (2026-10-01): relatório PMD estruturado (XML) gerado e preservado;
   reprocessamento determinístico revalidado de ponta a ponta (métricas
   finais idênticas); `docs/fontes.md` completado; status do Hibernate ORM
   corrigido para LIBERADO. Nenhuma inconsistência metodológica encontrada.
7. ~~Checkout do Hibernate ORM 7.2.6.Final (seção 6).~~ CONCLUÍDO: tag
   `7.2.6`, commit `c549a5c5a0bdd05cbda5105c4fa899b466be365c`, árvore de
   trabalho limpa.
8. ~~Escopo/inventário do Hibernate ORM (seção 6).~~ CONCLUÍDO: 17 módulos
   de produção identificados (vs. tooling interno de build e módulos de
   suporte a teste, distinguidos por plugin de publicação e sourceSets);
   inventário de arquivos (6605 incluídos / 11068 excluídos de 17673
   versionados); inventário de métodos elegíveis (48102 métodos, 0
   colisões) via `MethodInventoryExtractor`, com staging por *junctions*
   para `relative_path` globalmente único entre módulos. 1 falha de
   parsing isolada registrada (`Dialect.java` — enum local, limitação do
   JavaParser 3.28.2), sem exigir bloqueio.
9. ~~Build do Hibernate ORM (seção 6).~~ CONCLUÍDO: `./gradlew compileJava`
   (wrapper do próprio projeto, Gradle 9.1.0) com override
   `-Dmain.jdk.version=21 -Dtest.jdk.version=21` (bytecode de saída
   `release 17`, igual ao caminho padrão) porque nenhum JDK 25 estava
   disponível (exigido por `gradle.properties` sem override). Corrigida
   exclusão condicional do módulo `hibernate-jfr` (só incluído quando o
   JDK do Gradle é um OpenJDK) com rebuild usando Microsoft Build of
   OpenJDK 21.0.8. `BUILD SUCCESSFUL`, 17/17 módulos de produção com
   bytecode (9156 arquivos `.class`), sem erros.
10. ~~SonarQube no Hibernate ORM (seção 6).~~ CONCLUÍDO: projeto
    `hibernate-orm-7-2-6-final` analisado com o Quality Profile
    `exp-mestrado-long-smells` (somente `java:S138`/`java:S107`, mesmo do
    piloto); `status=SUCCESS` confirmado via API
    (`analysisId=80dd5e3b-66b8-4201-be40-40fa89addbac`); `456` issues
    exportados e paginação validada (`java:S138=290`, `java:S107=166`).
11. ~~PMD no Hibernate ORM (seção 6).~~ CONCLUÍDO: mesmo ruleset do piloto,
    executado contra os 17 módulos de produção em uma única chamada
    (`-d` com 17 diretórios separados por vírgula); `298` violações
    (`NcssCount=150`, `ExcessiveParameterList=148`); 4 erros de
    processamento isolados (arquivos com interface `Cloneable<T>` própria
    sombreando `java.lang.Cloneable` — limitação de resolução de símbolos
    do PMD 7.27.0, reproduzida isoladamente), documentados em
    `runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/falhas-processamento-pmd.txt`,
    sem exigir bloqueio.
12. ~~Normalização/Cobertura/Métricas do Hibernate ORM (seção 6).~~
    CONCLUÍDO: `Associator`/`Deduplicator` reutilizados sem alteração;
    386/456 issues SonarQube e 190/298 alertas PMD `eligible_method`;
    2 (SonarQube) + 4 (PMD) `unassociated`, todos em `Dialect.java` (mesma
    falha de parsing do JavaParser já registrada na seção de Escopo);
    demais não-elegíveis classificados `out_of_scope` em categorias já
    previstas (construtores, nível de classe, métodos sem corpo); `576`
    alertas deduplicados sem fusões. Cobertura reconciliada (SonarQube
    6605/6605, PMD 6601/6605, JavaParser 6604/6605 — diferenças pontuais
    com causa raiz identificada e reproduzida isoladamente, `0,076%` do
    total). Métricas finais: Long Method Jaccard=0.4789 (U=48102, A=260,
    B=126, interseção=125); Long Parameter List Jaccard=0.3287 (A=126,
    B=64, interseção=47).
13. ~~Validação final do Hibernate ORM (seção 6).~~ CONCLUÍDO: invariantes
    mínimas validadas (`A⊆U`, `B⊆U`, aritmética de união/interseção, 0
    `method_id` duplicados); reprocessamento determinístico confirmado
    (`Associator`/`Deduplicator`/métricas reexecutados a partir dos
    mesmos relatórios brutos, sem reinvocar SonarScanner/PMD — artefatos
    idênticos byte-a-byte). Durante a validação do invariante `A∪B⊆U` foi
    encontrado e corrigido um bug real de engenharia (não metodológico):
    os scripts de normalização usavam `ConvertTo-Json` (PowerShell), que
    escapa `<`/`>` como `\u003c`/`\u003e`, corrompendo `method_id` de
    métodos genéricos (216/576 alertas no Hibernate, 1/26 retroativamente
    no piloto); corrigido construindo o JSON manualmente — métricas
    recalculadas numericamente idênticas nos dois projetos. **Hibernate
    ORM 7.2.6.Final CONCLUÍDO.**
14. ~~Spring Framework 6.2.16 (seção 7).~~ CONCLUÍDO: checkout (tag
    `v6.2.16`, commit `053d8e25f424bae9c5a597c4b248af137dce264f`);
    escopo/inventário (23 módulos `spring-*` de produção por critério
    objetivo de publicação, incluindo caso especial MRJAR
    `spring-core/src/main/java21`; 5124/10975 arquivos incluídos; 35236
    métodos elegíveis, 0 colisões, 0 falhas de parsing); build
    (`./gradlew compileJava`, toolchain BellSoft Liberica 17
    autoprovisionada pelo Gradle; `compileJava21Java` dedicado para o
    sourceSet MRJAR; AspectJ `ajc` para `spring-aspects`; 7256 `.class`
    totais); SonarQube (150 issues: S138=102, S107=48); PMD (93
    violações: NcssCount=83, ExcessiveParameterList=10; 0 erros de
    processamento); normalização (111/150 SonarQube e 81/93 PMD
    `eligible_method`; 0 `ambiguous`/`unassociated` — cobertura 100%
    idêntica nas três ferramentas, diferente dos dois projetos
    anteriores); métricas finais (Long Method Jaccard=0.6852, U=35236,
    A=101, B=81, interseção=74; Long Parameter List Jaccard=0.0000, A=10,
    B=0, união=10 — caso especial "um conjunto vazio"); reprocessamento
    determinístico confirmado byte-a-byte. **Spring Framework 6.2.16
    CONCLUÍDO.**
15. ~~Quarkus 3.32.1 (seção 8).~~ CONCLUÍDO: checkout (tag `3.32.1`,
    commit `058b0b546fe033547d4d42afb7766a9e00b0329b`); escopo/inventário
    (574/630 diretórios `src/main/java` de produção — 56 excluídos com
    justificativa individual: arquétipos Maven, templates de Codestarts,
    TCKs, benchmarks JMH, bibliotecas de apoio a teste publicadas,
    ferramentas internas de build; 44165 métodos elegíveis, 0 colisões, 0
    falhas de parsing, 7510 arquivos `.java`); build (`./mvnw -Dquickly`,
    fluxo oficial documentado, BUILD SUCCESS, 1310 módulos no reactor,
    53:32 min; achado MRJAR-análogo: 3 módulos `devtools/gradle/*` são um
    projeto Gradle aninhado, bytecode em `build/classes/java/main` em vez
    de `target/classes`); SonarQube (765 issues: S138=374, S107=391 —
    `sonar.sources` apontando para o mesmo diretório de staging usado pelo
    inventário, por escala); PMD (421 violações: NcssCount=181,
    ExcessiveParameterList=240; 0 erros de processamento; mesmo diretório
    de staging via um único `-d`, evitando limite de linha de comando);
    normalização (640/765 SonarQube e 339/421 PMD `eligible_method`; 0
    `ambiguous`/`unassociated` — cobertura 100% idêntica nas três
    ferramentas, 7510/7510, igual ao Spring Framework); métricas finais
    (Long Method Jaccard=0.4522, U=44165, A=348, B=169, interseção=161;
    Long Parameter List Jaccard=0.5098, A=292, B=170, interseção=156);
    reprocessamento determinístico confirmado byte-a-byte. **Quarkus
    3.32.1 CONCLUÍDO.**
16. ~~Consolidação dos resultados finais (seção 24).~~ CONCLUÍDO:
    `results/consolidado-2026-10-01/RESULTADOS-FINAIS.md` (resumo
    executado, tabela de métricas dos 4 projetos × 2 smells, configuração
    efetiva de cada ferramenta, cobertura alcançada, arquivos/entidades
    excluídos por projeto, erros/limitações, confirmação de que não há
    ocorrências pendentes, caminhos dos artefatos e comandos completos de
    reprodução); `metricas-finais.csv` (tabela tabular); pacote exportável
    `exp-mestrado-pacote-exportavel-2026-10-01.zip` gerado por
    `scripts/export-package.ps1` (268 arquivos; validação automática no
    próprio script confirma ausência de `.env`/credenciais/`sources/`/
    binários baixados). **EXPERIMENTO COMPLETO — nenhuma ação pendente.**

---

## Análises complementares pós-protocolo (2026-10-01)

Após a conclusão do experimento (seção 11, item 16), foram executadas 4
atividades de análise complementar/sensibilidade, sem reexecutar
SonarQube/PMD nos 4 projetos reais, sem alterar projetos/versões/regras/
thresholds/definição de método elegível/métricas originais, e sem
sobrescrever nenhum artefato existente. Nenhum bloqueio foi necessário.
Resumo completo, achados e limitações em
`results/analises-complementares/RESUMO.md`; detalhe por atividade nos
demais arquivos do mesmo diretório.

1. **Sensibilidade do escopo do Spring** (exclusão de `spring-test`/
   `spring-core-test`): não altera o padrão descritivo (Jaccard Long
   Method `0,6852→0,6792`; Long Parameter List permanece `0,0000`).
2. **Sensibilidade de cobertura do Hibernate** (`U_common`, 6600/6605
   arquivos): zero impacto em qualquer métrica de convergência (Jaccard
   idêntico em ambos os smells).
3. **Validação de `java:S107` com anotações** (fixture sintética nova, 21
   casos, mesmo ambiente do experimento, sem `sonar.java.libraries`):
   confirma empiricamente que `@RequestMapping`/atalhos Spring, JAX-RS,
   `@Inject`, `@Autowired`, `@JsonCreator`, `lombok.Builder` e verbos
   Micronaut suprimem `S107` — **corrige/confirma com evidência direta**
   (não apenas documentação) a observação da seção 3 deste arquivo.
   Revela 2 mecanismos adicionais da regra, não documentados antes:
   qualquer anotação com símbolo não resolvido, e qualquer método que
   seja/pareça ser override, também isentam `S107` — risco estrutural de
   falso-negativo em todo o experimento (rodado sem
   `sonar.java.libraries`). Ver
   `results/analises-complementares/s107-annotation-validation.md`.
4. **Assimetria e divergências**: sobreposição direcional sistematicamente
   assimétrica (PMD→SQ sempre maior que SQ→PMD nos 6 casos com `B>0`);
   exclusivos de Long Parameter List seguem exatamente os thresholds por
   construção (só-Sonar sempre 8–9 parâmetros, só-PMD sempre `>=10`);
   nenhum dos 31 métodos só-PMD com `>=10` parâmetros carrega anotação da
   lista oficial de exceções do `S107` (48% têm `@Override`, compatível
   com o mecanismo de override do item 3); Long Method confirma
   empiricamente `NcssCount` disparando em `>=60` com dados reais. Ver
   `results/analises-complementares/assimetria-e-divergencias.md`.
