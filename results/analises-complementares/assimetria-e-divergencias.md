# Atividade 4 — Assimetria e divergências (análise complementar)

**Tipo:** análise complementar / sensibilidade pós-protocolo. Não altera o
protocolo, os projetos, versões, regras, thresholds ou as métricas
originais dos 4 projetos. Nenhuma nova execução de SonarQube/PMD foi
realizada — toda esta atividade usa exclusivamente `inventory-methods.jsonl`,
`dedup-results.jsonl`, `association-pmd.jsonl` e `pmd-output.xml`/
`metrics-resultado.json` já existentes.

**Data:** 2026-10-01.

---

## 4.1 Sobreposição direcional

Para cada `projeto × smell`, usando apenas `|A|`, `|B|` e `|A ∩ B|` já
publicados (`metrics-resultado.json`/`RESULTADOS-FINAIS.md`):

- `SQ→PMD = |A∩B| / |A|` (se `|A| > 0`, senão `N/A`)
- `PMD→SQ = |A∩B| / |B|` (se `|B| > 0`, senão `N/A`)

Script: `scripts/analises-complementares/directional-overlap.ps1`.
Artefatos: `results/analises-complementares/directional-overlap.json`/`.csv`.

| Projeto | Smell | A | B | A∩B | SQ→PMD (fração de A também em B) | PMD→SQ (fração de B também em A) |
|---|---|---|---|---|---|---|
| commons-lang-3.20.0 | long_method | 13 | 12 | 11 | 0,8462 | 0,9167 |
| commons-lang-3.20.0 | long_parameter_list | 1 | 0 | 0 | 0,0000 | N/A |
| hibernate-orm-7.2.6.Final | long_method | 260 | 126 | 125 | 0,4808 | 0,9921 |
| hibernate-orm-7.2.6.Final | long_parameter_list | 126 | 64 | 47 | 0,3730 | 0,7344 |
| spring-framework-6.2.16 | long_method | 101 | 81 | 74 | 0,7327 | 0,9136 |
| spring-framework-6.2.16 | long_parameter_list | 10 | 0 | 0 | 0,0000 | N/A |
| quarkus-3.32.1 | long_method | 348 | 169 | 161 | 0,4626 | 0,9527 |
| quarkus-3.32.1 | long_parameter_list | 292 | 170 | 156 | 0,5342 | 0,9176 |

**Padrão observado em todos os 6 casos com `B > 0`:** `PMD→SQ` é sempre
**maior** que `SQ→PMD` (ex.: Hibernate Long Method 0,9921 vs. 0,4808;
Quarkus Long Parameter List 0,9176 vs. 0,5342). Ou seja: quase tudo que o
PMD sinaliza, o SonarQube também sinaliza — mas o SonarQube sinaliza um
conjunto bem maior de métodos adicionais que o PMD não sinaliza. Esse
padrão é consistente com `|A|` ser sistematicamente maior que `|B|` em 7
dos 8 casos (exceção: Quarkus Long Parameter List, onde `A=292 > B=170`
ainda assim segue o mesmo padrão). Não se afirma aqui qual ferramenta é
"mais correta" — apenas a direção e magnitude da assimetria de
sobreposição.

---

## 4.2 Long Parameter List — decomposição dos exclusivos

Para cada método exclusivo de uma ferramenta (só-Sonar / só-PMD),
quantidade de parâmetros obtida automaticamente de `parameter_types`
(`inventory-methods.jsonl`), classificada em `<8`, `8-9`, `>=10`.

Script: `scripts/analises-complementares/lpl-exclusives-breakdown.ps1`.
Artefato: `results/analises-complementares/lpl-exclusives-breakdown.json`.

| Projeto | Só-Sonar (total) | `<8` | `8-9` | `>=10` | Só-PMD (total) | `<8` | `8-9` | `>=10` |
|---|---|---|---|---|---|---|---|---|
| commons-lang-3.20.0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| hibernate-orm-7.2.6.Final | 79 | 0 | 79 | 0 | 17 | 0 | 0 | 17 |
| spring-framework-6.2.16 | 10 | 0 | 10 | 0 | 0 | 0 | 0 | 0 |
| quarkus-3.32.1 | 136 | 0 | 136 | 0 | 14 | 0 | 0 | 14 |

**Achado estrutural (decorre dos limiares configurados):** com `max=7`, a
`java:S107` sinaliza métodos com `>=8` parâmetros e, com `minimum=10`, a
`ExcessiveParameterList` sinaliza com `>=10`. Consequência observada: **100%
dos métodos só-Sonar caem no bucket `8-9`** (nenhum tem `<8`; nenhum tem
`>=10`, caso em que o PMD também teria sinalizado) e **100% dos métodos
só-PMD caem no bucket `>=10`** (a `ExcessiveParameterList` não possui, na
configuração utilizada, isenção por anotação). Esse padrão é **compatível
com a diferença de limiar** como explicação para os exclusivos do SonarQube
(métodos de 8–9 parâmetros, abaixo do mínimo de 10 do PMD); não há, porém,
demonstração causal método a método.

### 4.2.1 Exclusivos PMD com `>=10` parâmetros — verificação de anotações (AST)

Para os 31 métodos só-PMD com `>=10` parâmetros (17 Hibernate + 14
Quarkus; Commons Lang e Spring têm `B=0`, não se aplica), as anotações
presentes na declaração foram extraídas automaticamente via AST
(`scripts/analises-complementares/src/AnnotationLookup.java`, JavaParser
com `LanguageLevel.BLEEDING_EDGE`, localizando o nó `MethodDeclaration`/
`ConstructorDeclaration` no arquivo-fonte real pelo mesmo `line_start` do
inventário).

| Anotação encontrada | Hibernate (17) | Quarkus (14) |
|---|---|---|
| `@Override` | 10 | 5 |
| nenhuma anotação | 7 | 0 |
| `@BuildStep` (Quarkus, framework interno) | — | 6 (1 também com `@SuppressWarnings`) |
| `@Substitute` (GraalVM, framework interno) | — | 2 |
| `@SuppressForbidden` (Quarkus, framework interno) | — | 1 |

**Nenhum dos 31 métodos só-PMD com `>=10` parâmetros carrega qualquer uma
das anotações da lista de exceções observada na fixture da Atividade 3**
(`@JsonCreator`, JAX-RS `@GET/@POST/@PUT/@PATCH`, `@Inject`, `@Autowired`,
`lombok.Builder`, verbos HTTP do Micronaut, nem `@RequestMapping`/
`@GetMapping`). Portanto a não-sinalização pelo SonarQube **não é explicada
por essa lista de anotações**.

- **`@Override` (15 dos 31, 48%)**: compatível com a não sinalização de
  métodos sobrescritos observada na Atividade 3 (no código-fonte da versão
  `8.41.0.47177`, `TooManyParametersCheck` isenta métodos cujo
  `MethodTree.isOverriding()` não retorne explicitamente `false`).
- **7 casos sem nenhuma anotação (todos em Hibernate)**: compatível com o
  mesmo mecanismo de override, mas sem a anotação `@Override` explícita no
  código-fonte (Java não exige essa anotação para um override válido) —
  não é possível confirmar isso neste artefato sem reexecutar a análise
  semântica completa do SonarQube; registrado como **não totalmente
  explicado**, apenas compatível com a hipótese de override.
- **`@BuildStep`/`@Substitute`/`@SuppressForbidden` (9 dos 14 casos do
  Quarkus)**: anotações de frameworks internos (Quarkus/GraalVM), que
  **não constam** na lista de exceções lida no código-fonte. Se essas
  anotações forem resolvidas pelo SonarQube como símbolos conhecidos
  (plausível, pois os módulos que as declaram — `core/deployment` —
  fazem parte do próprio `sonar.java.binaries` do Quarkus), a não-
  sinalização desses métodos pelo SonarQube **não é explicada pela lista
  de exceções nem pelo mecanismo de anotação desconhecida** — fica como
  achado **não explicado pelos mecanismos confirmados nesta análise**,
  possível candidato a override silencioso (sem `@Override`) ou outro
  fator não investigado aqui. Não se afirma causalidade.

---

## 4.3 Long Method — decomposição das divergências

Para métodos comuns, só-Sonar e só-PMD de cada projeto: linhas físicas
(`line_end - line_start + 1`, de `inventory-methods.jsonl`, disponível
para todos) e NCSS (extraído da mensagem bruta das violações `NcssCount`
em `pmd-output.xml`, disponível apenas para métodos que o PMD realmente
sinalizou — comuns e só-PMD — associado ao `method_id` via
`association-pmd.jsonl`, o mesmo artefato de associação por AST já
validado na coleta original).

Script: `scripts/analises-complementares/long-method-divergence-breakdown.ps1`.
Artefato: `results/analises-complementares/long-method-divergence-breakdown.json`.

### Linhas físicas (contagem bruta de linhas do método, inclui comentários/brancas)

| Projeto | Categoria | n | mín | máx | média | mediana |
|---|---|---|---|---|---|---|
| commons-lang-3.20.0 | comuns | 11 | 82 | 162 | 115,55 | 112 |
| commons-lang-3.20.0 | só-Sonar | 2 | 91 | 118 | 104,50 | 91 |
| commons-lang-3.20.0 | só-PMD | 1 | 71 | 71 | 71,00 | 71 |
| hibernate-orm-7.2.6.Final | comuns | 125 | 79 | 598 | 162,39 | 135 |
| hibernate-orm-7.2.6.Final | só-Sonar | 135 | 83 | 326 | 119,87 | 111 |
| hibernate-orm-7.2.6.Final | só-PMD | 1 | 54 | 54 | 54,00 | 54 |
| spring-framework-6.2.16 | comuns | 74 | 84 | 1134 | 151,84 | 122 |
| spring-framework-6.2.16 | só-Sonar | 27 | 85 | 137 | 101,67 | 97 |
| spring-framework-6.2.16 | só-PMD | 7 | 67 | 96 | 78,57 | 78 |
| quarkus-3.32.1 | comuns | 161 | 79 | 659 | 181,86 | 151 |
| quarkus-3.32.1 | só-Sonar | 187 | 80 | 304 | 128,52 | 115 |
| quarkus-3.32.1 | só-PMD | 8 | 63 | 98 | 77,88 | 77 |

### NCSS (apenas métodos sinalizados pelo PMD — comuns + só-PMD; não disponível para só-Sonar sem reexecutar PMD)

| Projeto | Categoria | n | mín | máx | média | mediana | faltantes |
|---|---|---|---|---|---|---|---|
| commons-lang-3.20.0 | comuns | 11 | 62 | 128 | 80,55 | 74 | 0 |
| commons-lang-3.20.0 | só-Sonar | 0 | — | — | — | — | 2 |
| commons-lang-3.20.0 | só-PMD | 1 | 67 | 67 | 67,00 | 67 | 0 |
| hibernate-orm-7.2.6.Final | comuns | 125 | 60 | 219 | 88,78 | 77 | 0 |
| hibernate-orm-7.2.6.Final | só-Sonar | 0 | — | — | — | — | 135 |
| hibernate-orm-7.2.6.Final | só-PMD | 1 | 66 | 66 | 66,00 | 66 | 0 |
| spring-framework-6.2.16 | comuns | 74 | 60 | 820 | 95,59 | 72 | 0 |
| spring-framework-6.2.16 | só-Sonar | 0 | — | — | — | — | 27 |
| spring-framework-6.2.16 | só-PMD | 7 | 61 | 73 | 64,00 | 63 | 0 |
| quarkus-3.32.1 | comuns | 161 | 60 | 403 | 94,93 | 79 | 0 |
| quarkus-3.32.1 | só-Sonar | 0 | — | — | — | — | 187 |
| quarkus-3.32.1 | só-PMD | 8 | 60 | 87 | 65,62 | 61 | 0 |

### Observações

1. **NCSS mínimo = 60 em todas as categorias com dados** (Hibernate
   comuns, Quarkus só-PMD) — consistente com `NcssCount
   methodReportLevel=60` usando operador `>=` (valor exato do threshold já
   dispara), confirmado empiricamente aqui pela primeira vez a partir de
   dados reais dos 4 projetos (`docs/DIARIO-EXECUCAO.md` já registrava esse comportamento
   a partir da validação sintética).
2. **Só-PMD: 7 dos 17 métodos têm menos de 75 linhas físicas e 10 têm 75
   ou mais** (lista por método em
   `results/analises-complementares/long-method-pmd-only-physical-lines.csv`,
   gerada por `scripts/analises-complementares/long-method-pmd-only-physical-lines.ps1`):
   - abaixo de 75: Commons Lang 71; Hibernate 54; Spring 67, 71 e 74;
     Quarkus 63 e 63;
   - 75 ou mais: Spring 78, 81, 83 e 96; Quarkus 76, 77, 80, 83, 83 e 98.

   Os 7 casos abaixo de 75 são compatíveis com a diferença de medida: NCSS
   conta instruções, não linhas físicas, e um método pode ter poucas linhas
   físicas e muitas instruções (código denso), disparando `NcssCount` sem
   disparar `S138`.
3. **Os 10 casos só-PMD com 75 ou mais linhas físicas não são explicados
   por diferença de limiar.** A contagem física inclui linhas em branco e
   comentários; a definição interna da medida "lines" da `S138` não foi
   estabelecida (a fixture de fronteira usou métodos sem brancos nem
   comentários, e não discrimina essa questão). É uma hipótese, não
   confirmada, que a `S138` desconsidere linhas em branco/comentários e
   atinja contagem efetiva inferior a 76 nesses métodos. Resolver isso
   exigiria reexecutar o SonarQube com instrumentação adicional; fica
   registrado como limitação, não como conclusão.4. **Só-Sonar sempre com linhas físicas > 75** (mínimo 80–91 conforme o
   projeto) — consistente com o próprio critério de disparo do `S138`
   (operador `>`, portanto `>=76`). NCSS desses métodos não está disponível
   sem reexecutar o PMD (eles não foram sinalizados por `NcssCount`); não
   se afirma se o NCSS real estaria abaixo de 60 — apenas que a ausência de
   sinalização pelo PMD é compatível com essa hipótese.

---

## Limitações gerais da Atividade 4

- Nenhum número desta atividade foi obtido por reexecução de SonarQube ou
  PMD; todos vêm de artefatos já existentes e preservados (metrics
  publicadas, `dedup-results.jsonl`, `association-pmd.jsonl`,
  `pmd-output.xml`, `inventory-methods.jsonl`).
- As explicações por "compatibilidade" (diferença de threshold, exceção
  por anotação, override) não constituem prova de causalidade para cada
  método individual — apenas um padrão estatístico agregado, consistente
  com os mecanismos confirmados na Atividade 3 e com os thresholds do
  PROTOCOLO.md seção 3.
- Não foi investigada a definição exata da métrica "lines" usada
  internamente por `java:S138` (se exclui ou não linhas em branco/
  comentários) além do que já está documentado publicamente pela regra —
  isso poderia explicar os casos da seção 4.3 observação 3, mas não foi
  confirmado experimentalmente nesta atividade.
