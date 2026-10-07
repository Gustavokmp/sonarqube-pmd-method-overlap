# Atividade 2 — Sensibilidade de cobertura do Hibernate ORM (`U_common`)

**Tipo:** análise complementar / sensibilidade pós-protocolo. Não altera o
protocolo, os projetos, versões, regras, thresholds, definição de método
elegível ou as métricas originais do Hibernate ORM 7.2.6.Final. Nenhuma
nova execução de SonarQube/PMD foi realizada — esta atividade apenas
filtra os artefatos já gerados (`inventory-methods.jsonl`,
`dedup-results.jsonl`, `falhas-parsing.txt`,
`falhas-processamento-pmd.txt`).

**Data:** 2026-10-01.

## 1. Problema

No Hibernate ORM, as 3 ferramentas usadas no pipeline (SonarQube, PMD,
JavaParser — este último usado apenas para o inventário de métodos
elegíveis, não como "ferramenta comparada") não processaram com sucesso
exatamente o mesmo conjunto de arquivos dentre os 6605 em escopo:

- SonarQube: `6605/6605` (100%).
- PMD: `6601/6605` (4 falhas de processamento).
- JavaParser: `6604/6605` (1 falha de parsing).

Além disso, existem ocorrências `unassociated` (PROTOCOLO.md seção 13) em
`hibernate-core/org/hibernate/dialect/Dialect.java`: 2 do SonarQube e 4 do
PMD, causadas pela mesma falha de parsing do JavaParser nesse arquivo (um
`enum` local dentro de corpo de método, sintaxe válida desde o JDK 16 mas
não suportada pela gramática do JavaParser 3.28.2 usado na ferramenta de
inventário).

Esta atividade define, **apenas para fins de análise complementar**, um
subconjunto `U_common` restrito a arquivos processados com sucesso pelas
3 ferramentas simultaneamente, e recalcula as métricas nesse subconjunto.

## 2. Método

Script:
`scripts/analises-complementares/hibernate-common-coverage-sensitivity.ps1`
(determinístico, reaproveita os artefatos existentes, não reexecuta
SonarQube/PMD):

1. Lista dos arquivos excluídos de `U_common` (os únicos arquivos, dentre
   os 6605 em escopo, que falharam em pelo menos uma das 3 ferramentas):

   | Arquivo | Falhou em | Causa registrada |
   |---|---|---|
   | `hibernate-core/org/hibernate/dialect/Dialect.java` | JavaParser (inventário) | `enum` local em corpo de método (`falhas-parsing.txt`) |
   | `hibernate-envers/org/hibernate/envers/boot/model/Attribute.java` | PMD | `Cloneable<T>` local sombreando `java.lang.Cloneable` (`falhas-processamento-pmd.txt`) |
   | `hibernate-envers/org/hibernate/envers/boot/model/Column.java` | PMD | idem |
   | `hibernate-envers/org/hibernate/envers/boot/model/Key.java` | PMD | idem |
   | `hibernate-envers/org/hibernate/envers/boot/model/TypeSpecification.java` | PMD | idem |

   Os dois conjuntos de falhas (JavaParser × PMD) **não se sobrepõem** —
   5 arquivos distintos no total. SonarQube não contribui exclusões
   (processou os 6605/6605).

2. `U_common` = métodos elegíveis de `inventory-methods.jsonl` cujo
   `relative_path` **não** está nesses 5 arquivos.
3. `A_common`/`B_common` = alertas já normalizados/deduplicados
   (`dedup-results.jsonl`, `eligible_method`) cujo `method_id` pertence a
   `U_common`.
4. Recalcula, para Long Method e Long Parameter List, as mesmas fórmulas
   de PROTOCOLO.md seção 15 (idênticas a `Metrics.java`).

Validação: a variante `original` recalculada pelo script bate, método a
método, com `runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/metrics-resultado.json`
(métricas finais já publicadas em `RESULTADOS-FINAIS.md`).

Artefatos gerados (não sobrescrevem nenhum artefato original):

- `results/analises-complementares/hibernate-common-coverage-sensitivity.json`
- `results/analises-complementares/hibernate-common-coverage-sensitivity.csv`

## 3. Quantidades removidas

- **Arquivos removidos de `U_common`:** 5 (de 6605 → 6600).
- **Métodos elegíveis removidos de `U_common`:** 14 (de 48102 → 48088,
  −0,03%). Quebra por arquivo (contagem automática a partir de
  `inventory-methods.jsonl`):
  - `Dialect.java`: **0** métodos elegíveis — a falha é de *parsing*
    completo do arquivo, então o próprio inventário já não contém nenhum
    método desse arquivo (nada a mais para remover aqui; é a causa das
    ocorrências `unassociated`, não de uma redução adicional de `U`).
  - `Attribute.java`: **0** métodos elegíveis (interface apenas com
    métodos abstratos, sem corpo — já excluídos pela própria definição de
    método elegível, PROTOCOLO.md seção 7).
  - `Column.java`: 6; `Key.java`: 4; `TypeSpecification.java`: 4 (total 14).
- **Impacto por smell nos alertas (`A`, `B`):** **zero** alertas
  removidos em qualquer um dos 4 casos (SonarQube/PMD × Long
  Method/Long Parameter List) — nenhum dos 14 métodos removidos de
  `U_common` estava em `A` ou `B` originalmente.

## 4. Métricas: original vs. `U_common`

| Smell | Variante | \|U\| | \|A\| | \|B\| | %Sonar | %PMD | Interseção | Só Sonar | Só PMD | União | Jaccard |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Long Method | original | 48102 | 260 | 126 | 0,5405 | 0,2619 | 125 | 135 | 1 | 261 | 0,4789 |
| Long Method | **U_common** | 48088 | 260 | 126 | 0,5407 | 0,2620 | 125 | 135 | 1 | 261 | **0,4789** |
| Long Parameter List | original | 48102 | 126 | 64 | 0,2619 | 0,1331 | 47 | 79 | 17 | 143 | 0,3287 |
| Long Parameter List | **U_common** | 48088 | 126 | 64 | 0,2620 | 0,1331 | 47 | 79 | 17 | 143 | **0,3287** |

(Valores com `,` acima apenas para leitura — os artefatos CSV/JSON usam
`.` como separador decimal, formato `F4` em cultura invariante.)

## 5. Os percentuais/interseção/exclusivos/Jaccard mudam? As conclusões permanecem estáveis?

- **Jaccard: não muda** em nenhum dos dois smells (`0,4789` e `0,3287`,
  idênticos à 4ª casa decimal) — porque `A` e `B` (interseção, só-Sonar,
  só-PMD, união) permanecem **exatamente os mesmos**; nenhum dos 14
  métodos removidos de `U_common` estava sinalizado por nenhuma das duas
  ferramentas.
- **Percentuais (`%Sonar`, `%PMD`): variação mínima**, só na 4ª casa
  decimal (ex.: Long Method `0,5405→0,5407`), efeito puramente do
  denominador `U` cair 14 unidades (−0,03%) sem nenhuma mudança no
  numerador.
- **Conclusões descritivas: permanecem estáveis** — a restrição a
  `U_common` não altera nenhuma das métricas de convergência/divergência
  publicadas para o Hibernate ORM.

## 6. Tratamento de `unassociated`

Conforme instrução desta atividade, **as 6 ocorrências `unassociated`
(2 SonarQube + 4 PMD, todas em `Dialect.java`) não são classificadas como
"resolvidas"** apenas por `U_common` excluir o arquivo onde ocorrem — elas
continuam registradas como `unassociated` nos artefatos originais da
normalização (`association-sonarqube.jsonl`,
`association-pmd.jsonl`), exatamente como na coleta real, e PROTOCOLO.md
seção 13 ("ocorrências `ambiguous` ou `unassociated` nunca podem ser
automaticamente classificadas como exclusivas de uma ferramenta") continua
sendo respeitado nas métricas originais publicadas. `U_common` é apenas um
recorte de sensibilidade complementar sobre o universo de métodos — não
reinterpreta nem reclassifica os alertas brutos da coleta original.

## 7. Limitações

- `U_common` é uma análise de sensibilidade; não substitui nem reprocessa
  a cobertura original (100% SonarQube, 6604/6605 JavaParser, 6601/6605
  PMD) já registrada e aceita como válida na consolidação final do
  Hibernate ORM.
- A causa raiz das 5 exclusões já era conhecida e documentada antes desta
  atividade (`falhas-parsing.txt`, `falhas-processamento-pmd.txt`); esta
  atividade apenas quantifica o impacto de removê-las do universo de
  comparação, sem investigar novamente a causa.
