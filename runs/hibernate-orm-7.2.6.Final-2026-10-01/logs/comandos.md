# Comandos — Hibernate ORM 7.2.6.Final — Escopo/Inventário

## Inspeção de módulos (decisão de escopo)

Inspecionados `settings.gradle` (lista de `include`) e os arquivos `.gradle`
de cada módulo (presença de `maven-publish`/`com.gradle.plugin-publish` para
distinguir artefatos publicados de tooling interno de build; sourceSets
customizados `test`/`demo`/`test_legacy`/`intTest`/`it`/`jakartaData`/
`quarkusHrPanache`/`quarkusOrmPanache` para distinguir produção de teste).

Módulos de produção (src/main/java) — 17 ao todo:
hibernate-core, hibernate-envers, hibernate-spatial,
hibernate-community-dialects, hibernate-vector, hibernate-c3p0,
hibernate-hikaricp, hibernate-agroal, hibernate-jcache, hibernate-micrometer,
hibernate-graalvm, hibernate-jfr, hibernate-scan-jandex,
tooling/metamodel-generator, tooling/hibernate-gradle-plugin,
tooling/hibernate-maven-plugin, tooling/hibernate-ant.

Excluídos: hibernate-testing (biblioteca de suporte a testes),
hibernate-integrationtest-java-modules (só `src/test`), hibernate-platform
(BOM, sem `.java`), local-build-plugins / local-build-asciidoctor-extensions
(tooling interno de build do próprio Hibernate, não publicado),
documentation/release/design/rules/ci/checkerstubs/drivers/edb/javadoc/shared
(sem `.java` de produção), além de `src/test`, `src/demo`, `src/test_legacy`,
`src/intTest`, `src/it`, `src/jakartaData`, `src/quarkusHrPanache`,
`src/quarkusOrmPanache` dentro dos próprios módulos de produção.

## Inventário de arquivos

```powershell
./runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/build-file-inventory.ps1
# TOTAL_VERSIONADO=17673 ARQUIVOS_INCLUIDOS=6605 ARQUIVOS_EXCLUIDOS=11068 SOMA_OK=True
```

## Inventário de métodos elegíveis

Staging via junctions (Windows), para que `relative_path` calculado pelo
`MethodInventoryExtractor` fique globalmente único entre módulos (mesmo
esquema de identificador de método, sem alterar a ferramenta já validada):

```powershell
./runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/build-scope-staging.ps1
cd scripts/method-inventory
java -cp "out;lib/javaparser-core-3.28.2.jar" MethodInventoryExtractor `
  --project hibernate-orm --commit c549a5c5a0bdd05cbda5105c4fa899b466be365c `
  --root "$env:TEMP\hibernate-orm-scope-stage" `
  --out ../../runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/inventory-methods.jsonl
# arquivos_java_encontrados=6605 falhas_de_parsing=1 metodos_elegiveis=48102 colisoes_de_identificador=0
```

Falha de parsing isolada (1 arquivo, `hibernate-core/org/hibernate/dialect/Dialect.java`,
enum local dentro de método — limitação confirmada do JavaParser 3.28.2):
ver `runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/falhas-parsing.txt`
e fixture de reprodução isolada `scripts/fixtures/boundary/LocalEnumRepro.java`.

## Resumo por módulo

```powershell
./runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/compute-methods-by-module-detail.ps1
```

## Build

Decisão de JDK: `gradle.properties` do projeto define
`orm.jdk.base=17` (bytecode produzido), `orm.jdk.min=25` e `orm.jdk.max=25`
(faixa exigida para o JDK que executa o próprio Gradle, quando nenhuma
versão explícita é configurada). Nenhum JDK 25 estava disponível no
ambiente (máximo instalado: JDK 24.0.2). Em vez de instalar um novo JDK,
usou-se o mecanismo de override já documentado no próprio código de build
do projeto (`JdkVersionConfig`/`JdkVersionSettingsPlugin`, mensagem de
aviso que sugere exatamente essa combinação de propriedades): propriedades
de sistema `-Dmain.jdk.version=21 -Dtest.jdk.version=21`, que fazem o
build usar JDK 21 como compilador/launcher mantendo o bytecode de saída em
`release 17` — idêntico ao que o caminho padrão (com JDK 25) produziria.
Não é mudança metodológica: nenhum parâmetro de linguagem/bytecode do
projeto foi alterado, apenas contornada a exigência de que o próprio
processo do Gradle rode sob um JDK específico. Nota: `README.adoc` do
projeto (linha 21) afirma "requires at least JDK 21", inconsistente com
`orm.jdk.min=25` do `gradle.properties` desta tag — inconsistência da
própria documentação do projeto, não resolvida (não é necessário resolver
para fins deste experimento), apenas registrada.

Execução 1 (JDK 21 Oracle — `C:\Program Files\Java\jdk-21`):

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"
.\gradlew.bat compileJava "-Dmain.jdk.version=21" "-Dtest.jdk.version=21" --console=plain
# BUILD SUCCESSFUL in 2m 49s — 76 actionable tasks: 65 executed, 11 up-to-date
# EXITCODE=0 DURATION_SECONDS=169.6715156
```

Log completo: `build-run1-oraclejdk21.log`.

Achado: o módulo `hibernate-jfr` (um dos 17 de produção) **não apareceu no
grafo de tarefas** dessa execução. Causa: `settings.gradle` só inclui
`hibernate-jfr` quando `System.getProperty("java.runtime.name")` é
`"OpenJDK Runtime Environment"` — o JDK Oracle usado reporta
`"Java(TM) SE Runtime Environment"`. Confirmado via
`java -XshowSettings:properties` do próprio JDK Oracle 21.

Execução 2 (JDK 21 Microsoft Build of OpenJDK —
`C:\Users\gusta\.jdks\ms-21.0.8`, confirmado `java.runtime.name=OpenJDK
Runtime Environment` via `-XshowSettings:properties`), para incluir
`hibernate-jfr`:

```powershell
$env:JAVA_HOME = "C:\Users\gusta\.jdks\ms-21.0.8"
.\gradlew.bat compileJava "-Dmain.jdk.version=21" "-Dtest.jdk.version=21" --console=plain
# BUILD SUCCESSFUL in 1m 3s — 79 actionable tasks: 5 executed, 74 up-to-date
# EXITCODE=0 DURATION_SECONDS=63.9751579
```

Log completo: `build-run2-openjdk21-jfr.log` (demais módulos ficaram
`UP-TO-DATE`, incrementais; apenas `hibernate-jfr` foi de fato compilado
nesta execução).

**Resultado final:** `.class` gerados para os 17 módulos de produção
(contagem por módulo, via `Get-ChildItem -Recurse -Filter *.class`):
hibernate-core=8010, hibernate-envers=397, hibernate-community-dialects=329,
hibernate-spatial=113, hibernate-vector=91, hibernate-jfr=22,
hibernate-scan-jandex=14, hibernate-processor=107
(`tooling/metamodel-generator`), hibernate-ant=38 (`tooling/hibernate-ant`),
hibernate-gradle-plugin=11 (`tooling/hibernate-gradle-plugin`),
hibernate-jcache=8, hibernate-hikaricp=3, hibernate-micrometer=3,
hibernate-c3p0=4, hibernate-agroal=2, hibernate-graalvm=2,
hibernate-maven-plugin=2 (`tooling/hibernate-maven-plugin`) — total
`9156` arquivos `.class`. Nenhum erro de compilação; apenas avisos
padrão do `javac` (`deprecation`/`removal`/`unchecked`, informativos) e um
aviso do próprio Gradle sobre features incompatíveis com Gradle 10
(nível da ferramenta de build, não do código analisado).


Resultado em `runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/metodos-por-modulo-detalhado.txt`.
