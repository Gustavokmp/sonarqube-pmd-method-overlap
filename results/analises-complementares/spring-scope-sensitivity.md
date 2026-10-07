# Atividade 1 — Sensibilidade do escopo do Spring Framework (exclusão de `spring-test`/`spring-core-test`)

**Tipo:** análise complementar / sensibilidade pós-protocolo. Não altera o
protocolo, os projetos, versões, regras, thresholds, definição de método
elegível ou as métricas originais do Spring Framework 6.2.16. Nenhuma nova
execução de SonarQube/PMD foi realizada — esta atividade apenas filtra os
artefatos já gerados (`inventory-methods.jsonl`, `dedup-results.jsonl`).

**Data:** 2026-10-01.

## 1. Problema

No escopo original do Spring Framework (PROTOCOLO.md seção 6, decisão
registrada em `docs/DIARIO-EXECUCAO.md` seção 7), os 23 módulos `spring-*` de produção
foram incluídos integralmente, o que inclui `spring-test` e
`spring-core-test` — dois módulos cuja função é prover **infraestrutura de
apoio a teste** para quem consome o Spring (mocks, `TestContext`
framework, utilitários de teste), análogos a bibliotecas como
`hibernate-testing` (Hibernate ORM) ou `quarkus-security-test-utils`/
`test-framework` (Quarkus), que foram **excluídas** do escopo nesses
outros dois projetos pelo mesmo critério ("bibliotecas de apoio a teste,
mesmo quando publicadas como artefato de produção").

Esta atividade mede o quanto essa assimetria de critério afeta as métricas
finais do Spring, sem alterar o escopo já congelado (PROTOCOLO.md seção
22: mudança metodológica exigiria bloqueio, não é o caso aqui — é uma
análise de sensibilidade declarada como complementar).

## 2. Método

Script: `scripts/analises-complementares/spring-scope-sensitivity.ps1`
(determinístico, reaproveita os artefatos existentes, não reexecuta
SonarQube/PMD):

1. Carrega `runs/spring-framework-6.2.16-2026-10-01/inventories/inventory-methods.jsonl`
   (universo `U` original, 35236 métodos elegíveis).
2. Filtra por `relative_path`, excluindo tudo que comece com
   `spring-test/` ou `spring-core-test/` → `U'` (variante de
   sensibilidade).
3. Carrega `dedup-results.jsonl` (alertas `eligible_method` já
   normalizados e deduplicados — `tool + project + smell + method_id`,
   PROTOCOLO.md seção 14) e recalcula `A'` (SonarQube) e `B'` (PMD) como a
   interseção dos alertas originais com `U'`.
4. Recalcula, para Long Method e Long Parameter List, exatamente as
   fórmulas de PROTOCOLO.md seção 15 (idênticas a `Metrics.java`):
   `|U|`, `|A|`, `|B|`, `%Sonar`, `%PMD`, interseção, só-Sonar, só-PMD,
   união, Jaccard — com os mesmos casos especiais de conjunto vazio.

Validação: a variante `original` recalculada pelo script bate, método a
método, com `runs/spring-framework-6.2.16-2026-10-01/inventories/metrics-resultado.json`
(métricas finais já publicadas em `RESULTADOS-FINAIS.md`), confirmando que
o script reproduz corretamente o pipeline antes de aplicar o filtro.

Artefatos gerados (não sobrescrevem nenhum artefato original):

- `results/analises-complementares/spring-scope-sensitivity.json`
- `results/analises-complementares/spring-scope-sensitivity.csv`

## 3. Resultado

**Arquivos excluídos do universo:** 331 (todos sob `spring-test/` ou
`spring-core-test/`).
**Métodos elegíveis excluídos de `U`:** 3241 (de 35236 → 31995, −9,2%).

| Smell | Variante | \|U\| | \|A\| | \|B\| | %Sonar | %PMD | Interseção | Só Sonar | Só PMD | União | Jaccard |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Long Method | original | 35236 | 101 | 81 | 0,2866 | 0,2299 | 74 | 27 | 7 | 108 | 0,6852 |
| Long Method | **sem spring-test/spring-core-test** | 31995 | 99 | 79 | 0,3094 | 0,2469 | 72 | 27 | 7 | 106 | **0,6792** |
| Long Parameter List | original | 35236 | 10 | 0 | 0,0284 | 0,0000 | 0 | 10 | 0 | 10 | 0,0000 |
| Long Parameter List | **sem spring-test/spring-core-test** | 31995 | 9 | 0 | 0,0281 | 0,0000 | 0 | 9 | 0 | 9 | **0,0000** |

(Valores com `,` acima apenas para leitura — os artefatos CSV/JSON usam
`.` como separador decimal, formato `F4` em cultura invariante.)

## 4. Comparação com os resultados originais

- **Long Method:** todos os 2 métodos removidos de `A` e os 2 removidos de
  `B` vieram exatamente da interseção (`sonarOnly`=27 e `pmdOnly`=7
  permanecem **idênticos** nas duas variantes) — ou seja, os únicos
  métodos longos dentro de `spring-test`/`spring-core-test` detectados
  pelas ferramentas foram sinalizados por **ambas** simultaneamente.
  Jaccard cai de `0,6852` para `0,6792` (variação de −0,0060, ~0,9%
  relativo). `%Sonar` e `%PMD` sobem levemente (denominador `U` menor),
  como esperado.
- **Long Parameter List:** `B` (PMD) permanece `0` nas duas variantes.
  `A` (SonarQube) cai de 10 para 9 (1 dos 10 alertas estava em
  `spring-test`/`spring-core-test`). Jaccard permanece `0,0000` nas duas
  variantes (caso "apenas um conjunto vazio" da seção 15 — não é alterado
  pela exclusão).

## 5. A exclusão altera o padrão/conclusão descritiva?

**Não.** Em nenhum dos dois smells a exclusão de `spring-test`/
`spring-core-test` muda a categoria descritiva do resultado:

- Long Method permanece com convergência moderada-alta (~0,68–0,69 de
  Jaccard em ambas as variantes), com SonarQube sinalizando
  proporcionalmente mais métodos que PMD em ambas.
- Long Parameter List permanece com Jaccard `0,0000` nas duas variantes
  (PMD não sinalizou nenhum método em nenhum cenário; SonarQube sinalizou
  uma quantidade pequena e praticamente igual, 10 vs. 9).

A magnitude do impacto é pequena (variação de Jaccard de 0,9% relativo em
Long Method; nenhuma mudança qualitativa em Long Parameter List),
proporcional ao tamanho do subconjunto excluído (9,2% dos métodos
elegíveis do projeto). A assimetria de critério de escopo identificada no
problema não compromete a validade descritiva das métricas finais
publicadas para o Spring Framework.

## 6. Limitações

- Esta é uma análise de sensibilidade; não substitui nem reinterpreta o
  escopo original congelado do Spring Framework (PROTOCOLO.md seção 22).
- A exclusão foi feita por prefixo de caminho relativo (`spring-test/`,
  `spring-core-test/`), auditável diretamente nos arquivos listados em
  `inventory-methods.jsonl` — nenhuma inspeção manual de código foi usada
  para decidir inclusão/exclusão de métodos individuais.
