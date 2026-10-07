# Atividade 3 — Validação de `java:S107` com anotações, sem `sonar.java.libraries`

**Tipo:** análise complementar / sensibilidade pós-protocolo. Não altera o
protocolo, a baseline, os projetos ou as métricas originais dos 4 projetos
do experimento.

**Data:** 2026-10-01 (mesma execução dia do protocolo congelado).

## 1. Objetivo

Confirmar experimentalmente, no MESMO ambiente usado nas 4 coletas reais
(SonarQube Community Build, SonarScanner 8.1.0.6389, Quality Profile
`exp-mestrado-long-smells` com `java:S138 max=75` / `java:S107 max=7`, SEM
`sonar.java.libraries`), quais anotações realmente suprimem `java:S107`
(`TooManyParametersCheck`) — em vez de assumir isso a partir de
documentação geral.

`docs/DIARIO-EXECUCAO.md` (seção 3, observações da validação da baseline) registrava a
hipótese: *"métodos anotados com `@RequestMapping`/atalhos Spring,
anotações JAX-RS, injeção de construtor `@Autowired`/`@Inject`,
`@JsonCreator` e anotações Micronaut são ignorados pela regra"*. Esta
atividade testa essa hipótese caso a caso — e, ao testar, revela uma
divergência entre o que o código-fonte publicado da regra sugere e o
comportamento realmente observado nesta instalação (seção 4).

## 2. Método

### 2.1 Fonte de verdade consultada (contexto, não prova final)

O código-fonte da regra foi consultado no repositório oficial
`SonarSource/sonar-java`, branch `master` (consultado em 2026-10-01, via
espelho jsDelivr do GitHub):

- `java-checks/.../checks/TooManyParametersCheck.java` (`@Rule(key = "S107")`)
- `java-frontend/.../utils/SpringUtils.java` (`AUTOWIRED_ANNOTATION`)
- `java-checks/.../checks/helpers/AnnotationsHelper.java` (`hasUnknownAnnotation`)

A lista `METHOD_ANNOTATION_EXCEPTIONS` encontrada nesse código é:

```
com.fasterxml.jackson.annotation.JsonCreator
javax.ws.rs.GET / POST / PUT / PATCH
jakarta.ws.rs.GET / POST / PUT / PATCH
javax.inject.Inject
jakarta.inject.Inject
lombok.Builder
io.micronaut.http.annotation.Get / Post / Put / Delete / Options / Patch / Head / Trace
org.springframework.beans.factory.annotation.Autowired   (via SpringUtils.AUTOWIRED_ANNOTATION)
```

`@RequestMapping`/atalhos (`org.springframework.web.bind.annotation.*`) **não
aparecem nessa lista**. A lógica de supressão (`visitMethod`) revelou ainda
dois mecanismos adicionais, não previstos na formulação inicial da atividade, mas
diretamente relevantes à validade do experimento (que roda sem
`sonar.java.libraries`):

1. `usesAuthorizedAnnotation` retorna `true` (suprime o alerta) se o método
   tiver **qualquer** anotação cujo símbolo não seja resolvido
   (`AnnotationsHelper.hasUnknownAnnotation`), independentemente de essa
   anotação estar ou não na lista lida no código-fonte.
2. `isOverriding(tree)` suprime o alerta sempre que
   `MethodTree.isOverriding()` não retornar explicitamente `false` — tanto
   um override real de um supertipo conhecido quanto um "override" de um
   supertipo desconhecido (hierarquia não resolvida) são isentos. Comentário
   original do código: *"In case of unknown hierarchy, isOverriding()
   returns null, we return true to avoid FPs."*

**Importante (ver seção 4.1):** a execução real mostrou que `@RequestMapping`/
`@GetMapping` SÃO tratados como exceção nesta instalação, divergindo do que
esse arquivo único sugeria. Isso pode indicar divergência de versão entre o
branch `master` consultado e o plugin Java efetivamente empacotado na build
Community `26.9.0.129388`, ou um mecanismo de reconhecimento adicional não
contido nesse arquivo. A leitura de código acima deve ser tratada como
**contexto/hipótese de partida**, não como prova do comportamento
efetivamente instalado — por isso esta atividade testa empiricamente, e o
resultado empírico é o que vale para o experimento.

> **Atualização (2026-10-07):** a versão do analisador Java executado foi recuperada a partir da imagem Docker utilizada: `sonar-java-plugin` `8.41.0.47177` (ver `docs/ambiente-sonarqube.md`). O código-fonte da tag `8.41.0.47177` contém a mesma lista de exceções e os mesmos mecanismos (`hasUnknownAnnotation`, `isOverriding`) descritos acima, e também não lista `@RequestMapping`/`@GetMapping`. Assim, a hipótese de divergência de versão entre o `master` e a build executada fica descartada; a não sinalização observada para essas duas anotações continua sem explicação pelo código-fonte e é tratada apenas como comportamento observado.

### 2.2 Fixture sintética

Fixture isolada em `scripts/fixtures/s107-annotations/` (não faz parte dos
4 projetos estudados), com 21 classes de teste (pacote `fixtures.s107` e
subpacote `fixtures.s107.probes`) e 11 anotações/interfaces "stub" locais
(mesmo nome totalmente qualificado das anotações reais, mas declaradas
localmente, sem depender de nenhuma biblioteca externa — coerente com
`sonar.java.libraries` ausente também nas 4 coletas reais). Todos os
métodos/construtores de teste têm exatamente 8 parâmetros `int` (acima do
`max=7`/`constructorMax=7`).

Além dos casos da formulação inicial (sem anotação, `@RequestMapping`/atalho,
JAX-RS, `@Autowired`, `@Inject`, `@JsonCreator`, Micronaut), foram
adicionados 5 casos extras, descobertos como necessários durante a própria
execução desta atividade (ver seção 4.1):

- `ProbeMarkerControl` / `ProbeMappingControl`: anotações customizadas,
  conhecidas (mesma árvore de fontes), que **não** constam em
  `METHOD_ANNOTATION_EXCEPTIONS` — usadas para confirmar que a resolução de
  símbolo funciona normalmente para anotações desconhecidas da regra,
  isolando se a não-sinalização de `@RequestMapping`/`@GetMapping` é um
  efeito geral (qualquer anotação "estranha" suprime) ou específico dessas
  duas anotações.
- `DeprecatedControl`: `@Deprecated` (anotação do próprio JDK, sempre
  resolvível via bootclasspath, independente de `sonar.java.libraries`),
  também fora dessa lista — mesmo propósito de isolamento.
- Casos de override (`KnownInterface8`, `OverrideKnownInterface`,
  `OverrideUnknownSupertype`) e de anotação genuinamente não resolvível
  (`UnknownUnresolvableAnnotation`) — mecanismos adicionais encontrados na
  leitura do código-fonte, relevantes à validade do experimento sem
  `sonar.java.libraries`.

### 2.3 Execução

Mesmo SonarQube (`sonarqube-pilot`), mesmo SonarScanner, mesmo Quality
Profile (`exp-mestrado-long-smells`), **sem `sonar.java.libraries`**:

```
sonar-scanner.bat -Dsonar.projectKey=exp-mestrado-s107-annotation-validation ^
  -Dsonar.sources=. -Dsonar.host.url=<url> -Dsonar.token=<token> ^
  -Dsonar.java.binaries=. -Dsonar.sourceEncoding=UTF-8
```

34 arquivos indexados (29 originais + 5 de isolamento, adicionados após a
primeira rodada revelar a divergência da seção 4.1), `ANALYSIS SUCCESSFUL`
nas duas execuções, 0 erros. Avisos esperados e coerentes com as 4 coletas
reais: `Missing 'sonar.java.libraries' property` e `Unresolved
imports/types have been detected`. Projeto efêmero
(`exp-mestrado-s107-annotation-validation`) removido via
`POST /api/projects/delete` após a exportação final dos issues (não é um
projeto do experimento).

Issues exportados com paginação validada
(`scripts/sonarqube/export-issues-paginated.ps1`, `rules=java:S107`):
execução final `REPORTED_TOTAL=6`, `EXPORTED_TOTAL=6`,
`VALIDACAO_TOTAL_EXPORTADO=PASS`.

Artefatos preservados (sem sobrescrever a validação sintética anterior,
seção 4 do protocolo):

- `scripts/fixtures/s107-annotations/` (fixture completa, 21 casos de
  teste + 11 anotações/interfaces stub)
- `runs/synthetic-2026-10-01/logs/run-s107-annotation-validation.ps1`,
  `run-export-s107-issues.ps1`, `delete-s107-fixture-project.ps1`,
  `s107-annotation-validation-output.txt`,
  `export-issues-s107-annotation-validation-output.txt`
- `runs/synthetic-2026-10-01/raw/s107-annotation-validation-scanner-output.txt`
  (última execução), `sonarqube-issues-s107-annotation-validation.jsonl`
  (6 issues finais)

## 3. Resultado por caso

| # | Classe (arquivo) | Parâmetros | Anotação testada | Esperado (lista lida no código-fonte `master`) | Resultado real (`java:S107`) |
|---|---|---|---|---|---|
| 1 | `BaselineNoAnnotationMethod` | 8 (método) | nenhuma | SINALIZA | **SINALIZOU** |
| 2 | `BaselineNoAnnotationConstructor` | 8 (construtor) | nenhuma | SINALIZA | **SINALIZOU** |
| 3 | `SpringRequestMapping` | 8 (método) | `@RequestMapping` | SINALIZA (não consta na lista lida) | **não sinalizou (diverge do esperado pela leitura do código)** |
| 4 | `SpringGetMappingShortcut` | 8 (método) | `@GetMapping` (atalho) | SINALIZA (não consta na lista lida) | **não sinalizou (diverge do esperado pela leitura do código)** |
| 5 | `JaxRsJavaxGet` | 8 (método) | `@javax.ws.rs.GET` | NÃO sinaliza (consta na lista) | não sinalizou |
| 6 | `JaxRsJakartaPatch` | 8 (método) | `@jakarta.ws.rs.PATCH` | NÃO sinaliza (consta na lista) | não sinalizou |
| 7 | `InjectJavaxMethod` | 8 (método) | `@javax.inject.Inject` | NÃO sinaliza (consta na lista) | não sinalizou |
| 8 | `InjectJakartaConstructor` | 8 (construtor) | `@jakarta.inject.Inject` | NÃO sinaliza (consta na lista) | não sinalizou |
| 9 | `AutowiredConstructor` | 8 (construtor) | `@Autowired` (Spring) | NÃO sinaliza (consta na lista) | não sinalizou |
| 10 | `AutowiredMethod` | 8 (método) | `@Autowired` (Spring) | NÃO sinaliza (consta na lista) | não sinalizou |
| 11 | `JsonCreatorConstructor` | 8 (construtor) | `@JsonCreator` (Jackson) | NÃO sinaliza (consta na lista) | não sinalizou |
| 12 | `LombokBuilderConstructor` | 8 (construtor) | `@lombok.Builder` | NÃO sinaliza (consta na lista) | não sinalizou |
| 13 | `MicronautGet` | 8 (método) | `@io.micronaut...Get` | NÃO sinaliza (consta na lista) | não sinalizou |
| 14 | `MicronautDelete` | 8 (método) | `@io.micronaut...Delete` | NÃO sinaliza (consta na lista) | não sinalizou |
| 15 | `UnknownUnresolvableAnnotation` | 8 (método) | anotação não declarada em lugar nenhum (tipo desconhecido) | fora da lista, mas mecanismo `hasUnknownAnnotation` previsto no código → NÃO sinaliza | não sinalizou |
| 16 | `KnownInterface8` (declaração abstrata na interface) | 8 (método sem corpo) | nenhuma | regra não distingue método abstrato → SINALIZA | **SINALIZOU** |
| 17 | `OverrideKnownInterface` (implementa `KnownInterface8`) | 8 (override real de tipo conhecido) | `@Override` apenas | mecanismo `isOverriding()` previsto no código → NÃO sinaliza | não sinalizou |
| 18 | `OverrideUnknownSupertype` (implementa tipo nunca declarado) | 8 ("override" de tipo desconhecido) | `@Override` apenas | mecanismo `isOverriding()==null→true` previsto no código → NÃO sinaliza | não sinalizou |
| 19 | `ProbeMarkerControl` | 8 (método) | anotação customizada sem elementos, não listada (controle) | SINALIZA | **SINALIZOU** |
| 20 | `ProbeMappingControl` | 8 (método) | anotação customizada com `value()` default, não listada, pacote próprio (controle) | SINALIZA | **SINALIZOU** |
| 21 | `DeprecatedControl` | 8 (método) | `@Deprecated` (JDK, não listada) (controle) | SINALIZA | **SINALIZOU** |

6 issues `java:S107` no total, exatamente os casos 1, 2, 16, 19, 20 e 21.

## 4. Achados

### 4.1 Achado principal: divergência entre o código-fonte lido e o comportamento instalado

`@RequestMapping` e `@GetMapping` (Spring MVC) **suprimiram `java:S107`**
na execução real (casos 3 e 4), embora não constem na lista
`METHOD_ANNOTATION_EXCEPTIONS` do arquivo `TooManyParametersCheck.java`
consultado na branch `master` do repositório `SonarSource/sonar-java`. Ou
seja: a hipótese original de `docs/DIARIO-EXECUCAO.md` (de que `@RequestMapping`/atalhos
suprimem `S107`) **estava correta na prática**, mesmo que a leitura isolada
desse único arquivo de código-fonte sugerisse o contrário.

Os três controles adicionados (casos 19, 20, 21) eliminam explicações
alternativas:

- `ProbeMarkerControl` (anotação própria, sem elementos, pacote de teste) →
  **sinalizou** — anotações desconhecidas da regra, quando resolvíveis,
  não suprimem o alerta por padrão.
- `ProbeMappingControl` (anotação própria com elemento `value()` com
  default, mesma forma de uso de `@RequestMapping("/x")`, mas em pacote
  próprio) → **sinalizou** — descarta a hipótese de que o elemento
  `value()` com valor-padrão, por si só, causasse alguma falha de
  resolução que fosse interpretada como "anotação desconhecida".
- `DeprecatedControl` (`@Deprecated`, anotação do JDK, sempre resolvível) →
  **sinalizou** — confirma que anotações conhecidas e fora da lista
  são normalmente sinalizadas.

Como as três variantes de controle (iguais em forma a `@RequestMapping`,
mas em pacotes diferentes) sinalizaram normalmente, a supressão de
`@RequestMapping`/`@GetMapping` é específica ao nome totalmente
qualificado `org.springframework.web.bind.annotation.*`, não um artefato de
resolução de símbolo. A causa não foi identificada: a versão exata do analisador (`sonar-java-plugin` `8.41.0.47177`) foi recuperada posteriormente (ver `docs/ambiente-sonarqube.md`) e o código-fonte dessa versão também não lista essas anotações. **Este ponto fica registrado como não explicado pela leitura do código-fonte, mas observado de forma consistente no comportamento**, que é o que importa para a validade do experimento (o protocolo não se baseia em documentação da ferramenta, e sim no comportamento efetivo sob configuração fixa).

### 4.2 Demais categorias da lista lida no código-fonte, observadas na fixture

JAX-RS (`@GET`/`@PATCH`, `javax`/`jakarta.ws.rs`), `@Inject`
(`javax`/`jakarta.inject`), `@Autowired` (Spring, construtor e método),
`@JsonCreator` (Jackson), `@lombok.Builder` e os verbos HTTP do Micronaut
(`@Get`/`@Delete`) suprimiram `java:S107` na prática, consistente com a
lista `METHOD_ANNOTATION_EXCEPTIONS` lida no código-fonte.

### 4.3 Mecanismo adicional: anotação com símbolo não resolvido (`hasUnknownAnnotation`)

Um método com 8 parâmetros anotado com um tipo de anotação **nunca
declarado em lugar nenhum** da fixture (caso 15) também não foi
sinalizado — consistente com `AnnotationsHelper.hasUnknownAnnotation`
isentando qualquer método com ao menos uma anotação de símbolo
desconhecido, **independentemente** de essa anotação constar ou não na`r`nlista lida no código-fonte. Nos 4 projetos reais (executados sem
`sonar.java.libraries`), métodos anotados com anotações de bibliotecas
externas não incluídas em `sonar.java.binaries` podem ficar isentos de
`S107` por este motivo, sem relação com a lista de exceções lida no código-fonte —
risco estrutural da configuração usada em todo o experimento, não apenas
desta fixture.

### 4.4 Mecanismo adicional: detecção de override (`isOverriding`)

`S107` isenta qualquer método que seja (caso 17) ou pareça ser (caso 18,
hierarquia não resolvida) um override — não apenas por anotação. Em
projetos com muitas classes que implementam interfaces/estendem classes de
dependências externas não incluídas em `sonar.java.binaries`
(frequentemente o caso em Spring/Hibernate/Quarkus), este mecanismo pode
isentar silenciosamente métodos de `S107`, independentemente de anotações.

### 4.5 Declarações abstratas também são avaliadas

A declaração abstrata do método em `KnownInterface8` (sem corpo) também foi
sinalizada pela regra (caso 16) — SonarQube não distingue método abstrato
de método concreto para `S107`, diferente da unidade de comparação do
protocolo (PROTOCOLO.md seção 7 exclui métodos sem corpo). Esse tipo de
ocorrência já era tratado como `out_of_scope` na normalização das 4
coletas reais (PROTOCOLO.md seção 13) — não afeta as métricas finais, é
apenas registro do comportamento observado da ferramenta.

## 5. Limitações

- As anotações de bibliotecas de terceiros (JAX-RS, Jackson, Lombok,
  Micronaut, `javax`/`jakarta.inject`, Spring) foram testadas com **stubs
  locais** com o mesmo nome totalmente qualificado, não com os jars reais
  — decisão deliberada para preservar a ausência de `sonar.java.libraries`,
  idêntica às 4 coletas reais. O mecanismo de exceção confirmado
  (`metadata::isAnnotatedWith` por nome totalmente qualificado) não deveria
  depender de metadados carregados do jar real, então o comportamento
  observado deve generalizar — mas isso não foi testado com os jars
  originais nesta atividade.
- O mecanismo exato que faz `@RequestMapping`/`@GetMapping` serem exceção
  nesta instalação **não foi localizado no código-fonte consultado**
  (seção 4.1) — o achado é empírico e reprodutível (rodando esta fixture
  novamente deve reproduzir o mesmo resultado), mas sua explicação por
  código-fonte fica como limitação registrada, não investigada mais a
  fundo para não introduzir inferência sobre versão interna do plugin sem
  evidência direta.
- Esta atividade valida o comportamento da regra em um ambiente
  controlado; não altera, reprocessa ou reinterpreta nenhum resultado dos
  4 projetos reais do experimento.

## 6. Relação com `docs/DIARIO-EXECUCAO.md`

Esta atividade **confirma empiricamente** (embora não pela leitura do
código-fonte consultado) a afirmação original de `docs/DIARIO-EXECUCAO.md` (seção 3)
sobre `@RequestMapping`/atalhos Spring não serem sinalizados pela `S107` na configuração utilizada. As
demais anotações citadas (`@Autowired`/`@Inject`, `@JsonCreator`,
Micronaut) também foram confirmadas, agora com evidência experimental
direta (não apenas documentação) e com dois mecanismos adicionais
documentados (`hasUnknownAnnotation`, `isOverriding`). Ver seção "Análises
complementares pós-protocolo" em `docs/DIARIO-EXECUCAO.md` para o apontamento formal.
