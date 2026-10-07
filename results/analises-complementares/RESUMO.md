# RESUMO — Análises complementares pós-protocolo

**Data:** 2026-10-01 (correções documentais em 2026-10-07). As 4 atividades
complementares foram executadas.
Nenhuma delas alterou projetos, versões, regras, thresholds, definição de
método elegível, métricas originais ou o baseline congelado em
`PROTOCOLO.md`. Nenhum artefato original foi sobrescrito.

## O que foi executado

1. **Sensibilidade do escopo do Spring** — recalculo das métricas
   excluindo `spring-test`/`spring-core-test` (sem reexecutar
   SonarQube/PMD). → `spring-scope-sensitivity.md`
2. **Sensibilidade de cobertura do Hibernate** — recalculo restrito a
   `U_common` (arquivos processados com sucesso pelas 3 ferramentas), sem
   reexecutar SonarQube/PMD. → `hibernate-common-coverage-sensitivity.md`
3. **Validação de `java:S107` com anotações** — fixture sintética nova
   (21 casos), execução real do mesmo SonarQube/SonarScanner/Quality
   Profile do experimento, sem `sonar.java.libraries`. →
   `s107-annotation-validation.md`
4. **Assimetria e divergências** — sobreposição direcional (8 casos),
   decomposição de exclusivos de Long Parameter List por nº de parâmetros
   + verificação de anotações via AST, e decomposição de divergências de
   Long Method por linhas físicas/NCSS. → `assimetria-e-divergencias.md`

## Principais achados

1. **Spring — exclusão de `spring-test`/`spring-core-test` não muda o
   padrão descritivo.** 331 arquivos / 3241 métodos elegíveis removidos
   (−9,2% de `U`). Long Method: Jaccard `0,6852 → 0,6792` (variação
   ~0,9% relativa); Long Parameter List: Jaccard permanece `0,0000` nas
   duas variantes.
2. **Hibernate — `U_common` (6600/6605 arquivos) não muda nenhuma
   métrica de convergência.** 14 métodos elegíveis removidos de `U`,
   **zero** alertas removidos de `A`/`B` em qualquer smell — Jaccard
   idêntico em Long Method (`0,4789`) e Long Parameter List (`0,3287`).
3. **Na fixture de `java:S107`, métodos com várias anotações deixaram de ser
   sinalizados, inclusive `@RequestMapping`/`@GetMapping`.** Comportamento
   observado empiricamente na configuração utilizada (SonarQube
   `26.9.0.129388`, `sonar-java-plugin` `8.41.0.47177`, sem
   `sonar.java.libraries`): Jackson `@JsonCreator`, JAX-RS
   `@GET/@POST/@PUT/@PATCH` (`javax`/`jakarta`), `@Inject`
   (`javax`/`jakarta`), `@Autowired` (Spring), `lombok.Builder`, verbos HTTP
   do Micronaut e Spring `@RequestMapping`/atalhos. O código-fonte de
   `sonar-java` (tag `8.41.0.47177` e branch `master`) não lista
   `@RequestMapping`/`@GetMapping`; a divergência permanece sem explicação
   (ver `docs/ambiente-sonarqube.md`).
4. **Dois outros comportamentos da fixture, relevantes para um experimento
   rodado sem `sonar.java.libraries`:** (a) método com anotação de símbolo
   não resolvido não foi sinalizado, mesmo fora da lista do item 3; (b)
   método que é ou parece ser *override* (inclusive de hierarquia
   desconhecida) não foi sinalizado, independentemente de anotações.
5. **Sobreposição direcional é assimétrica nos casos analisados:** em todos
   os 6 casos com `B > 0`, `PMD→SQ` (fração do PMD também coberta pelo
   Sonar) é maior que `SQ→PMD` — ex.: Hibernate Long Method `0,9921` vs.
   `0,4808`. Quase tudo que o PMD sinaliza, o SonarQube também sinaliza; o
   inverso não ocorre.
6. **Exclusivos de Long Parameter List são compatíveis com os limiares
   configurados:** 100% dos métodos só-Sonar têm 8–9 parâmetros (nenhum
   `<8` ou `>=10`); 100% dos métodos só-PMD têm `>=10` parâmetros (`S107
   max=7`, `ExcessiveParameterList minimum=10`).
7. **Nenhum dos 31 métodos só-PMD (Long Parameter List, `>=10`
   parâmetros, Hibernate+Quarkus) carrega anotação da lista do item 3.**
   15/31 (48%) têm `@Override` — compatível com o comportamento do item 4b;
   os demais 16 (anotações internas de framework como
   `@BuildStep`/`@Substitute` no Quarkus, ou nenhuma anotação no
   Hibernate) não são explicados pelos comportamentos observados na
   fixture.
8. **Long Method:** NCSS mínimo observado é exatamente `60` em várias
   categorias, isto é, `NcssCount methodReportLevel=60` sinalizou com `>=`
   nos dados reais. Dos 17 métodos só-PMD, 7 têm menos de 75 linhas físicas
   (compatível com a diferença de medida entre NCSS e linhas) e **10 têm 75
   ou mais** (Spring: 78, 81, 83 e 96; Quarkus: 76, 77, 80, 83, 83 e 98),
   caso em que a diferença de limiar não explica a ausência no SonarQube.
   Lista por método em `long-method-pmd-only-physical-lines.csv`.

## Limitações

- As explicações por "compatibilidade" (seção 4) são padrões estatísticos
  agregados, não prova de causalidade por método individual.
- O mecanismo que faz `@RequestMapping`/`@GetMapping` não serem sinalizadas
  pela `S107` nesta instalação não foi localizado no código-fonte
  disponível (achado 3) — observado só empiricamente.
- As anotações de bibliotecas de terceiros na fixture da Atividade 3 são
  stubs locais (mesmo FQN), não os jars reais.
- A definição exata da métrica "lines" do `java:S138` (se exclui linhas
  em branco/comentários) não foi confirmada experimentalmente — hipótese
  não verificada para os 10 casos só-PMD com 75 ou mais linhas físicas
  (achado 8).
- Nenhuma destas análises usa inspeção manual para decidir se um método
  possui ou não um smell; todas usam os conjuntos já normalizados
  (`eligible_method`) ou medidas automatizadas via AST/mensagens das
  próprias ferramentas.
## Bloqueios

Nenhuma das 4 atividades exigiu bloqueio ou mudança metodológica. Todas foram concluídas integralmente.

## Caminhos dos artefatos

```
results/analises-complementares/
├── spring-scope-sensitivity.md / .json / .csv
├── hibernate-common-coverage-sensitivity.md / .json / .csv
├── s107-annotation-validation.md
├── assimetria-e-divergencias.md
├── directional-overlap.json / .csv
├── lpl-exclusives-breakdown.json
├── lpl-exclusives-pmd-annotation-lookup-input.tsv / -output.tsv
├── long-method-divergence-breakdown.json (agregados)
├── long-method-pmd-only-physical-lines.csv (lista por método dos 17 só-PMD)
└── RESUMO.md (este arquivo)

scripts/analises-complementares/
├── spring-scope-sensitivity.ps1
├── hibernate-common-coverage-sensitivity.ps1
├── directional-overlap.ps1
├── lpl-exclusives-breakdown.ps1
├── long-method-divergence-breakdown.ps1
├── long-method-pmd-only-physical-lines.ps1
├── src/AnnotationLookup.java
└── out/ (compilado, gitignored)

scripts/fixtures/s107-annotations/   (fixture da Atividade 3, 34 arquivos: 21 casos, 2 anotações de controle e 11 *stubs*)

runs/synthetic-2026-10-01/
├── logs/run-s107-annotation-validation.ps1, run-export-s107-issues.ps1,
│   delete-s107-fixture-project.ps1, s107-annotation-validation-output.txt,
│   export-issues-s107-annotation-validation-output.txt
└── raw/s107-annotation-validation-scanner-output.txt,
    sonarqube-issues-s107-annotation-validation.jsonl
```
