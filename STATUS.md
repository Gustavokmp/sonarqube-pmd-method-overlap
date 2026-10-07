# STATUS.md

## Estado Geral

**Status:** ✅ EXPERIMENTO COMPLETO (2026-10-01)

| Aspecto | Status |
|---|---|
| Piloto (Apache Commons Lang 3.20.0) | ✅ APROVADO |
| Hibernate ORM 7.2.6.Final | ✅ CONCLUÍDO |
| Spring Framework 6.2.16 | ✅ CONCLUÍDO |
| Quarkus 3.32.1 | ✅ CONCLUÍDO |
| Protocolo | 🔒 CONGELADO (após piloto) |
| Consolidação final | ✅ CONCLUÍDA |

**Resultado:** Todos os 4 projetos analisados, métricas finais consolidadas em `results/consolidado-2026-10-01/`

---

## Projetos Executados

### 1. Apache Commons Lang 3.20.0 (Piloto)

- **Versão:** 3.20.0
- **Tag:** rel/commons-lang-3.20.0
- **Commit:** 598dfc163b8b410fb3bb8794521206ec8dcec82a
- **Métodos elegíveis:** 3.829
- **Artefatos:** `runs/commons-lang-3.20.0-2026-10-01/`
- **Resultado:** Long Method Jaccard=0.7857 | Long Parameter List Jaccard=0.0000
- **Status:** ✅ APROVADO (piloto validado)

### 2. Hibernate ORM 7.2.6.Final

- **Versão:** 7.2.6.Final
- **Tag:** 7.2.6
- **Commit:** c549a5c5a0bdd05cbda5105c4fa899b466be365c
- **Métodos elegíveis:** 48.102
- **Artefatos:** `runs/hibernate-orm-7.2.6.Final-2026-10-01/`
- **Resultado:** Long Method Jaccard=0.4789 | Long Parameter List Jaccard=0.3287
- **Status:** ✅ CONCLUÍDO

### 3. Spring Framework 6.2.16

- **Versão:** 6.2.16
- **Tag:** v6.2.16
- **Commit:** 053d8e25f424bae9c5a597c4b248af137dce264f
- **Métodos elegíveis:** 35.236
- **Artefatos:** `runs/spring-framework-6.2.16-2026-10-01/`
- **Resultado:** Long Method Jaccard=0.6852 | Long Parameter List Jaccard=0.0000
- **Status:** ✅ CONCLUÍDO

### 4. Quarkus 3.32.1

- **Versão:** 3.32.1
- **Tag:** 3.32.1
- **Commit:** 058b0b546fe033547d4d42afb7766a9e00b0329b
- **Métodos elegíveis:** 44.165
- **Artefatos:** `runs/quarkus-3.32.1-2026-10-01/`
- **Resultado:** Long Method Jaccard=0.4522 | Long Parameter List Jaccard=0.5098
- **Status:** ✅ CONCLUÍDO

---

## Ferramentas e Configuração

### SonarQube
- **Versão:** 26.9.0.129388 (Community Build), imagem `sonarqube:26.9.0.129388-community` (digest em `docs/ambiente-sonarqube.md`)
- **Analisador Java:** `sonar-java-plugin` 8.41.0.47177 (incluído na imagem)
- **Regras:** java:S138 (max=75) + java:S107 (max=7)
- **Profile:** exp-mestrado-long-smells (backup em `configs/sonarqube-quality-profile-exp-mestrado-long-smells.xml`)
- **Bibliotecas:** `sonar.java.libraries` não configurada nos 4 projetos

### PMD
- **Versão:** 7.27.0
- **Regras:** NcssCount (methodReportLevel=60) + ExcessiveParameterList (minimum=10)
- **Ruleset:** `configs/pmd-ruleset-exp-mestrado-long-smells.xml`

---

## Ambiente

- **Sistema:** Microsoft Windows 11 Pro (10.0.26200, 64 bits)
- **CPU:** 13th Gen Intel Core i7-13620H (10 cores, 16 logical processors)
- **Memória:** 31,74 GB
- **Docker:** 28.3.3
- **Git:** 2.45.1.windows.1
- **JDK principal do host:** 21.0.9+7 (Oracle); o SonarScanner executou com o JRE embutido 21.0.11 (Eclipse Adoptium). Detalhes em `docs/ambiente-sonarqube.md`

---

## Artefatos e Documentação

| Documento | Propósito |
|---|---|
| [PROTOCOLO.md](PROTOCOLO.md) | Definição metodológica (congelada; erratum de 2026-10-07 ao final) |
| [docs/DIARIO-EXECUCAO.md](docs/DIARIO-EXECUCAO.md) | Registro detalhado da execução, por etapa e por projeto |
| [docs/ambiente-sonarqube.md](docs/ambiente-sonarqube.md) | Imagem Docker, versão do analisador Java e JDKs |
| [docs/fontes.md](docs/fontes.md) | URLs e commits de todas as fontes consultadas |
| [results/consolidado-2026-10-01/RESULTADOS-FINAIS.md](results/consolidado-2026-10-01/RESULTADOS-FINAIS.md) | Tabela de métricas, configuração, cobertura, limitações e comandos de reprodução |
| [results/consolidado-2026-10-01/metricas-finais.csv](results/consolidado-2026-10-01/metricas-finais.csv) | Métricas em formato tabular |
| [SHA256SUMS.txt](SHA256SUMS.txt) | Hashes SHA-256 dos arquivos versionados |

### Estrutura por Projeto

Cada execução em `runs/<projeto>-<versão>-<data>/` contém `inventories/`, `logs/`, `raw/` e `reprocess-check/`; Hibernate, Spring e Quarkus têm também `config/`. As diferenças de conteúdo entre as execuções (por exemplo, `logs/comandos.md` só existe no piloto, no Hibernate e na validação sintética) estão na seção 8 de `RESULTADOS-FINAIS.md`.

---

## Análises Complementares (Pós-Protocolo)

Após a conclusão do protocolo, 4 análises adicionais foram executadas:
- Ver `results/analises-complementares/RESUMO.md`

---

## Notas Importantes

1. **Protocolo congelado:** metodologia não alterada após a aprovação do piloto (PROTOCOLO.md seção 2). Ajustes de redação e esclarecimentos posteriores constam no erratum ao final do PROTOCOLO.md
2. **Sem ground truth manual:** o objetivo é documentar o comportamento das ferramentas, não validar
3. **Reprocessamento:** os 5 artefatos principais regenerados a partir dos relatórios brutos (associação, deduplicação e métricas) resultaram idênticos nos 4 projetos; exige o código-fonte clonado no mesmo commit
4. **Cobertura:** SonarQube, PMD e inventário receberam o mesmo escopo lógico de arquivos; a cobertura efetiva foi integral em Commons Lang, Spring e Quarkus e diferiu no Hibernate (PMD 6.601 e JavaParser 6.604 de 6.605)
5. **S107:** na fixture sintética, métodos com certas anotações, anotações não resolvidas e sobrescritas não foram sinalizados (comportamento observado na configuração utilizada, sem `sonar.java.libraries`); relevante para a interpretação de Long Parameter List
6. **Long Method:** 10 dos 17 métodos só-PMD têm 75 ou mais linhas físicas; a diferença de limiar não explica esses casos

---

**Última atualização:** 2026-10-07 (revisão documental; resultados de 2026-10-01 inalterados)