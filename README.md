# exp-mestrado

Experimento de comparação entre **SonarQube** e **PMD** na detecção dos code smells **Long Method** e **Long Parameter List**, em nível de método, em quatro projetos Java de código aberto.

Os valores abaixo são os do baseline congelado (protocolo aprovado após o piloto). Detalhes, definições das métricas e limitações estão em [RESULTADOS-FINAIS.md](results/consolidado-2026-10-01/RESULTADOS-FINAIS.md).

## Resultados (índice de Jaccard)

| Projeto | Versão | Métodos elegíveis | Long Method | Long Parameter List |
|---|---|---:|---:|---:|
| Apache Commons Lang | 3.20.0 (piloto) | 3.829 | 0,7857 | 0,0000 |
| Hibernate ORM | 7.2.6.Final | 48.102 | 0,4789 | 0,3287 |
| Spring Framework | 6.2.16 | 35.236 | 0,6852 | 0,0000 |
| Quarkus | 3.32.1 | 44.165 | 0,4522 | 0,5098 |

Jaccard igual a 0,0000 em Long Parameter List (Commons Lang e Spring) significa que o PMD não sinalizou nenhum método elegível; não indica discordância sobre todo o código. Tabela completa (interseção, exclusividades, incidências): [metricas-finais.csv](results/consolidado-2026-10-01/metricas-finais.csv).

## Onde encontrar cada informação

| Para encontrar... | Consulte |
|---|---|
| Metodologia, regras, limiares e fórmulas | [PROTOCOLO.md](PROTOCOLO.md) |
| Estado atual do experimento | [STATUS.md](STATUS.md) |
| Resultados consolidados, cobertura, limitações e comandos de reprodução | [RESULTADOS-FINAIS.md](results/consolidado-2026-10-01/RESULTADOS-FINAIS.md) |
| Registro detalhado da execução (por etapa e por projeto) | [docs/DIARIO-EXECUCAO.md](docs/DIARIO-EXECUCAO.md) |
| Versões do SonarQube, da imagem Docker e do analisador Java | [docs/ambiente-sonarqube.md](docs/ambiente-sonarqube.md) |
| Fontes consultadas (URLs, commits, datas) | [docs/fontes.md](docs/fontes.md) |
| Análises complementares pós-protocolo | [results/analises-complementares/RESUMO.md](results/analises-complementares/RESUMO.md) |
| Ferramentas próprias (inventário, associação, deduplicação, métricas) | [scripts/method-inventory/](scripts/method-inventory/README.md) |
| Hashes SHA-256 dos arquivos versionados | [SHA256SUMS.txt](SHA256SUMS.txt) |

Os comentários em `runs/`, `scripts/` e `results/` que citam "STATUS.md seção N" referem-se às seções do [diário de execução](docs/DIARIO-EXECUCAO.md), que na data da execução era o próprio `STATUS.md`.

## Configuração utilizada

- **SonarQube** Community Build `26.9.0.129388` (Docker, `sonar-java-plugin` `8.41.0.47177`), Quality Profile [exp-mestrado-long-smells](configs/sonarqube-quality-profile-exp-mestrado-long-smells.xml): `java:S138` com `max=75` e `java:S107` com `max=7`.
- **PMD** `7.27.0`, [ruleset](configs/pmd-ruleset-exp-mestrado-long-smells.xml): `NcssCount` com `methodReportLevel=60` e `ExcessiveParameterList` com `minimum=10`.
- Não foi usada referência-ouro: as métricas descrevem a relação entre os conjuntos produzidos pelas ferramentas, não precisão ou revocação.

## Artefatos por execução

Cada execução está em `runs/<projeto>-<versão>-2026-10-01/` (mais `runs/synthetic-2026-10-01/`, com as validações sintéticas), com os subdiretórios `config/` (quando existe), `inventories/` (inventário de métodos, associações, deduplicação e métricas), `logs/` (scripts e saídas de cada etapa), `raw/` (relatórios brutos do SonarQube e do PMD) e `reprocess-check/` (verificação do reprocessamento). As diferenças reais de conteúdo entre as execuções estão na seção 8 de [RESULTADOS-FINAIS.md](results/consolidado-2026-10-01/RESULTADOS-FINAIS.md).

## Reexecutar

1. Pré-requisitos (JDK 21, Docker, SonarQube, SonarScanner, PMD, JavaParser) e comandos por projeto: seção 9 de [RESULTADOS-FINAIS.md](results/consolidado-2026-10-01/RESULTADOS-FINAIS.md). Copie `.env.example` para `.env` e preencha as credenciais locais.
2. Clone o projeto na tag e no commit indicados em [STATUS.md](STATUS.md) para `sources/` (diretório não versionado).
3. Compile e execute as ferramentas de [scripts/method-inventory/](scripts/method-inventory/README.md).
4. Compare os resultados com `inventories/` e `raw/` da execução correspondente.

Os scripts em `runs/*/logs/` preservam caminhos absolutos da máquina original e precisam ser adaptados. O reprocessamento (associação, deduplicação e métricas) parte dos relatórios brutos preservados, mas exige o código-fonte clonado no mesmo commit.

## Limitações a considerar

- No Hibernate ORM a cobertura efetiva diferiu entre os componentes (PMD 6.601 e JavaParser 6.604 de 6.605 arquivos).
- Sem `sonar.java.libraries`, a `java:S107` deixou de sinalizar, na fixture sintética, métodos com certas anotações, anotações não resolvidas e sobrescritas. Trata-se de comportamento observado na configuração utilizada, não de definição geral da regra.
- Resultados válidos para as versões, regras e condições descritas; não são generalizáveis ao ecossistema Java.
