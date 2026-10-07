# Fontes consultadas

Registrar aqui, para cada fonte efetivamente consultada: título, URL,
organização/autoria, data de consulta e finalidade no experimento.

Não registrar referência não consultada.

---

### Docker Hub — imagem oficial do SonarQube

- **URL:** https://hub.docker.com/_/sonarqube/tags
- **Organização/autoria:** SonarSource (imagem oficial Docker)
- **Data de consulta:** 2026-10-01
- **Finalidade:** confirmar a existência e o digest exato da tag `26.9.0.129388-community` usada no experimento, antes de baixar e subir o container. O digest efetivamente utilizado (`sha256:4905574ab8584dcac1a06c01cdc43a4ce9e369723ac4a7ab1d029c1bf71e6fe9`) foi registrado a posteriori em `docs/ambiente-sonarqube.md`.

### API REST do SonarQube (instância local do experimento)

- **URL:** `http://localhost:9000/api/rules/show`, `http://localhost:9000/api/server/version`, `http://localhost:9000/api/qualityprofiles/*` (instância local, não pública)
- **Organização/autoria:** SonarSource (fonte primária — a própria ferramenta em execução)
- **Data de consulta:** 2026-10-01
- **Finalidade:** confirmar, na própria versão instalada (`26.9.0.129388`), os parâmetros e valores default das regras `java:S138` (`max=75`) e `java:S107` (`max=7`, `constructorMax=7`); registrar a presença, nessa instalação, de comportamentos de supressão da `java:S107` associados a anotações (investigados empiricamente em `results/analises-complementares/s107-annotation-validation.md`); criar e exportar o Quality Profile dedicado do experimento.

### GitHub Releases — PMD

- **URL:** https://github.com/pmd/pmd/releases/tag/pmd_releases%2F7.27.0
- **Organização/autoria:** projeto PMD (comunidade open source)
- **Data de consulta:** 2026-10-01
- **Finalidade:** confirmar a existência oficial da versão `7.27.0` e obter o link de download direto da distribuição binária (`pmd-dist-7.27.0-bin.zip`).

### Documentação oficial do PMD — regras de design Java

- **URL:** https://docs.pmd-code.org/pmd-doc-7.27.0/pmd_rules_java_design.html
- **Organização/autoria:** projeto PMD
- **Data de consulta:** 2026-10-01
- **Finalidade:** confirmar as propriedades e valores default das regras `NcssCount` (`methodReportLevel=60`, `classReportLevel=1500`) e `ExcessiveParameterList` (`minimum=10`), e confirmar que `NcssCount` se aplica a classes, métodos e construtores.

### Execução local do binário oficial do PMD

- **URL:** não aplicável (execução local de `pmd-bin-7.27.0/bin/pmd.bat`, distribuição baixada do GitHub Releases acima)
- **Organização/autoria:** projeto PMD
- **Data de consulta:** 2026-10-01
- **Finalidade:** confirmar empiricamente a versão exata (`PMD 7.27.0`, commit `360072ec0489c04167501c310e42f0af5d3cfd7b`) e validar, via teste de fumaça com um arquivo Java sintético, o disparo correto de `NcssCount` e `ExcessiveParameterList` (incluindo a descoberta de que `ExcessiveParameterList` também se aplica a construtores).

### Maven Central — javaparser-core

- **URL:** https://repo1.maven.org/maven2/com/github/javaparser/javaparser-core/
- **Organização/autoria:** projeto JavaParser (comunidade open source)
- **Data de consulta:** 2026-10-01
- **Finalidade:** obter a biblioteca de parsing AST usada na ferramenta de inventário de métodos (`scripts/method-inventory/`), necessária para cumprir o requisito do protocolo (seção 8) de usar parser/AST — e não regex — compatível com sintaxe Java moderna (records, sealed types, pattern matching) presente nos projetos do experimento.

### SonarSource — documentação do SonarScanner CLI

- **URL:** https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/scanners/sonarscanner.md
- **Organização/autoria:** SonarSource
- **Data de consulta:** 2026-10-01
- **Finalidade:** obter a versão e a URL de download oficiais do SonarScanner CLI (`8.1.0.6389`, Windows x64) para executar análises reais contra a instância local do SonarQube durante a validação sintética (testes de fronteira de `java:S138`/`java:S107`).

### GitHub — mirror oficial do Apache Commons Lang

- **URL:** https://github.com/apache/commons-lang
- **Organização/autoria:** Apache Software Foundation (mirror oficial do repositório Git do projeto)
- **Data de consulta:** 2026-10-01
- **Finalidade:** localizar a tag exata correspondente à versão `3.20.0` (`rel/commons-lang-3.20.0`, commit `598dfc163b8b410fb3bb8794521206ec8dcec82a`) e clonar o código-fonte do projeto piloto do experimento.

### GitHub — mirror oficial do Hibernate ORM

- **URL:** https://github.com/hibernate/hibernate-orm
- **Organização/autoria:** Hibernate/Red Hat (mirror oficial do repositório Git do projeto)
- **Data de consulta:** 2026-10-01
- **Finalidade:** confirmar, via `git ls-remote --tags`, a convenção de tags do projeto (releases finais usam o número de versão sem sufixo `.Final`, ex.: tag `7.2.6` corresponde à release `7.2.6.Final`; pré-lançamentos usam sufixos como `.CR1`) e clonar o código-fonte do segundo projeto do experimento (commit `c549a5c5a0bdd05cbda5105c4fa899b466be365c`).

### PMD — documentação oficial de formatos de relatório (`-f`/`--format`)

- **URL:** não aplicável (saída de `pmd.bat check --help`, distribuição oficial `pmd-bin-7.27.0`)
- **Organização/autoria:** projeto PMD
- **Data de consulta:** 2026-10-01
- **Finalidade:** confirmar os formatos de relatório estruturado suportados pelo PMD `7.27.0` (`xml`, `json`, `sarif`, `csv`, entre outros) para corrigir uma inconsistência operacional: o relatório do piloto havia sido gerado apenas em formato `text` (não estruturado); regerado em formato `xml` conforme exigido pela seção 12 do protocolo, preservado ao lado do `.txt` original.

### GitHub — mirror oficial do Spring Framework

- **URL:** https://github.com/spring-projects/spring-framework
- **Organização/autoria:** Spring Framework/Pivotal/VMware (mirror oficial do repositório Git do projeto)
- **Data de consulta:** 2026-10-01
- **Finalidade:** localizar a tag exata correspondente à versão `6.2.16` (`v6.2.16`, commit `053d8e25f424bae9c5a597c4b248af137dce264f`) e clonar o código-fonte do terceiro projeto do experimento.

### GitHub — repositório oficial do Quarkus

- **URL:** https://github.com/quarkusio/quarkus
- **Organização/autoria:** Quarkus.io/Red Hat (repositório oficial do projeto)
- **Data de consulta:** 2026-10-01
- **Finalidade:** localizar a tag exata correspondente à versão `3.32.1` (`3.32.1`, commit `058b0b546fe033547d4d42afb7766a9e00b0329b`) e clonar o código-fonte do quarto projeto do experimento.

### GitHub — SonarSource/sonar-java (código-fonte da regra `java:S107`)

- **URL:** https://github.com/SonarSource/sonar-java (branch `master`, consultada em 2026-10-01 via espelho jsDelivr; tag `8.41.0.47177`, consultada em 2026-10-07 em https://raw.githubusercontent.com/SonarSource/sonar-java/8.41.0.47177/java-checks/src/main/java/org/sonar/java/checks/TooManyParametersCheck.java)
- **Organização/autoria:** SonarSource
- **Data de consulta:** 2026-10-01 (`master`) e 2026-10-07 (tag `8.41.0.47177`)
- **Finalidade:** ler `TooManyParametersCheck`, `AnnotationsHelper` e `SpringUtils` para formular hipóteses sobre a supressão de `java:S107`. A tag `8.41.0.47177` corresponde ao `sonar-java-plugin` incluído na imagem Docker utilizada (ver `docs/ambiente-sonarqube.md`). O código-fonte é usado apenas como contexto; o comportamento efetivo foi caracterizado empiricamente.

### SonarSource — catálogo de regras Java

- **URL:** https://rules.sonarsource.com/java/
- **Organização/autoria:** SonarSource
- **Data de consulta:** 2026-10-02 (data de acesso registrada na dissertação)
- **Finalidade:** identificar `java:S138` e `java:S107` como regras associadas ao tamanho de métodos e à quantidade de parâmetros. Não é utilizado para inferir a implementação executada.

### SonarSource — documentação de análise Java

- **URL:** https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/languages/java
- **Organização/autoria:** SonarSource
- **Data de consulta:** 2026-10-02 (data de acesso registrada na dissertação)
- **Finalidade:** distinguir `sonar.java.binaries` (bytecode do projeto) de `sonar.java.libraries` (bibliotecas de terceiros).