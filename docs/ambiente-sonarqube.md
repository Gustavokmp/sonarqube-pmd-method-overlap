# Ambiente do SonarQube e versão do analisador Java

Evidências coletadas em **2026-10-07** (após a execução de 2026-10-01) a partir da
imagem Docker e do container que executaram o experimento. Nenhum parâmetro do
experimento foi alterado; o objetivo é registrar versões que não constavam nos
artefatos originais.

## Container e imagem

| Item | Valor |
|---|---|
| Container | `sonarqube-pilot` (criado em 2026-10-01T16:25Z) |
| Imagem | `sonarqube:26.9.0.129388-community` |
| ID/digest da imagem | `sha256:4905574ab8584dcac1a06c01cdc43a4ce9e369723ac4a7ab1d029c1bf71e6fe9` |
| `SONAR_VERSION` (ambiente do container) | `26.9.0.129388` |
| JVM do servidor (`JAVA_VERSION`) | `jdk-25.0.4.1+1` |
| Volumes | `sonarqube_data`, `sonarqube_extensions`, `sonarqube_logs` |
| Plugins instalados pelo usuário | nenhum (`/opt/sonarqube/extensions/plugins` contém apenas `README.txt`) |

Comandos utilizados:

```powershell
docker inspect sonarqube-pilot --format 'image={{.Image}} created={{.Created}}'
docker images --digests sonarqube
docker run --rm --entrypoint sh sonarqube:26.9.0.129388-community -c "ls /opt/sonarqube/lib/extensions"
```

## Plugins incluídos na imagem (Java)

| Plugin | Versão |
|---|---|
| `sonar-java-plugin` (SonarJava) | **8.41.0.47177** |
| `sonar-java-symbolic-execution-plugin` | 8.16.4.1912 |

Como não há plugins no volume de extensões, o analisador Java executado nas
quatro coletas e nas validações sintéticas é o incluído na imagem acima.

## Código-fonte da regra S107 nessa versão

Consultado em 2026-10-07, na tag `8.41.0.47177` de `SonarSource/sonar-java`
(`java-checks/.../checks/TooManyParametersCheck.java` e
`java-checks/.../checks/helpers/AnnotationsHelper.java`):

- a lista `METHOD_ANNOTATION_EXCEPTIONS` é a mesma já registrada em
  `results/analises-complementares/s107-annotation-validation.md` (Jackson
  `JsonCreator`, JAX-RS `GET/POST/PUT/PATCH`, `Inject`, `lombok.Builder`,
  verbos HTTP do Micronaut e `Autowired`);
- `@RequestMapping` e `@GetMapping` **não** constam nessa lista;
- o método é isento quando `isOverriding()` não retorna `false` e quando possui
  qualquer anotação com símbolo desconhecido (`hasUnknownAnnotation`).

Portanto, a divergência já registrada permanece: a não sinalização observada
para `@RequestMapping`/`@GetMapping` na fixture sintética não é explicada pelo
código-fonte dessa versão e segue documentada apenas como comportamento
empírico da configuração utilizada.

## Observação sobre os JDKs

O SonarScanner CLI 8.1.0.6389 executou com o JRE embutido
`Java 21.0.11 Eclipse Adoptium` (linha de log `INFO Java 21.0.11 Eclipse Adoptium`
em `runs/*/logs/sonar-scanner-output.txt`). O JDK 21.0.9+7 (Oracle) registrado em
`docs/DIARIO-EXECUCAO.md` é o JDK principal do host (`JAVA_HOME`); o build do
módulo `hibernate-jfr` usou o Microsoft OpenJDK 21.0.8 (ver
`runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/comandos.md`).
