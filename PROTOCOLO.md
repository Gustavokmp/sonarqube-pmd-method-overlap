# PROTOCOLO.md

## 1. Objetivo do experimento

Comparar a **convergência e divergência** entre SonarQube e PMD na detecção de dois code smells em projetos Java:

- Long Method
- Long Parameter List

O experimento **não busca determinar qual ferramenta é melhor, mais correta ou mais precisa**, pois não será utilizado ground truth manual. A análise será baseada no comportamento das ferramentas sob configuração fixa e reprodutível.

---

## 2. Projetos e versões

Executar exatamente as seguintes versões:

| Projeto | Versão |
|---|---|
| Apache Commons Lang | `3.20.0` |
| Hibernate ORM | `7.2.6.Final` |
| Spring Framework | `6.2.16` |
| Quarkus | `3.32.1` |

Para cada projeto registrar obrigatoriamente:

- tag utilizada;
- commit SHA correspondente;
- URL do repositório;
- data da coleta.

### Ordem de execução

1. Apache Commons Lang como piloto.
2. Somente após aprovação do piloto:
   - Hibernate ORM;
   - Spring Framework;
   - Quarkus.

O protocolo deve permanecer congelado após a aprovação do piloto.

---

## 3. Baseline das ferramentas

### SonarQube

Baseline pretendida:

- SonarQube Community Build `26.9.0.129388`

Regras:

| Smell | Regra | Parâmetro pretendido |
|---|---|---|
| Long Method | `java:S138` | máximo `75` |
| Long Parameter List | `java:S107` | máximo `7`, considerando métodos |

### PMD

Baseline pretendida:

- PMD `7.27.0`

Regras:

| Smell | Regra | Parâmetro pretendido |
|---|---|---|
| Long Method | `NcssCount` | `methodReportLevel=60` |
| Long Parameter List | `ExcessiveParameterList` | `minimum=10` |

### Validação obrigatória antes da execução

Antes de qualquer análise real, confirmar e registrar:

- existência das versões;
- disponibilidade das regras;
- nomes exatos das propriedades;
- valores efetivamente aplicados;
- semântica dos limites (`>` ou `>=`);
- compatibilidade das regras com a versão usada.

Nenhuma versão, regra, propriedade ou threshold pode ser substituído silenciosamente.

Se a baseline não puder ser reproduzida, registrar o problema em `STATUS.md` e interromper antes de mudar o protocolo.

### Observação metodológica

`java:S138` e `NcssCount` não medem necessariamente tamanho de método da mesma forma. Os thresholds também não devem ser tratados como semanticamente equivalentes.

O objetivo é observar o comportamento das ferramentas com configurações fixas, e não inferir precisão a partir da diferença entre resultados.

---

## 4. Ambiente de execução

Antes de iniciar, registrar:

- sistema operacional;
- versão do Docker;
- versão do Git;
- JDKs disponíveis;
- CPU e memória disponíveis;
- containers existentes relevantes;
- portas relevantes em uso.

Preferir execução isolada com Docker sempre que possível.

### Segurança

Não:

- remover containers existentes;
- remover volumes existentes;
- alterar configurações globais;
- apagar imagens Docker sem autorização;
- armazenar tokens ou senhas no repositório.

SonarQube deve ficar acessível apenas localmente.

Credenciais devem ficar em `.env`, ignorado pelo Git.

Criar `.env.example` sem valores sensíveis.

---

## 5. Integridade dos projetos

O código-fonte estudado não deve ser modificado para facilitar a análise.

Se o build exigir mudança no código ou configuração versionada do projeto:

1. não alterar imediatamente;
2. registrar o problema;
3. documentar a necessidade;
4. aguardar decisão antes de prosseguir.

Dependências, JDKs e ferramentas externas podem ser preparados fora do código estudado.

---

## 6. Escopo de código

Analisar somente código Java de produção versionado.

Excluir:

- testes;
- exemplos;
- benchmarks;
- código gerado;
- código vendorizado ou de terceiros;
- artefatos de build.

Não assumir que todo código de produção está em `src/main/java`.

Antes da análise de cada projeto:

1. inspecionar módulos;
2. identificar diretórios Java de produção;
3. gerar inventário de arquivos incluídos;
4. gerar inventário de arquivos excluídos;
5. registrar justificativa das exclusões.

SonarQube e PMD devem receber o mesmo conjunto elegível de arquivos.

Nenhum projeto deve ser reduzido arbitrariamente. Caso o escopo completo seja tecnicamente inviável, registrar bloqueio antes de selecionar subconjunto.

---

## 7. Unidade de comparação

A unidade de análise é o **método Java elegível**.

### Incluir

Métodos com corpo pertencentes a tipos nomeados top-level ou member, incluindo:

- `static`;
- `private`;
- overloads;
- overrides;
- default methods.

### Excluir

- construtores;
- métodos sem corpo;
- initializers;
- métodos pertencentes a tipos locais;
- métodos pertencentes a tipos anônimos.

Lambdas não são tratadas como unidades independentes.

---

## 8. Identificação dos métodos

Usar parser/AST compatível com os projetos.

Regex não pode ser o mecanismo principal para identificação ou associação de métodos.

Cada método deve possuir identificador estável:

`project + commit + relative_path + qualified_type + method_signature(parameter_types)`

Preservar também:

- caminho relativo;
- tipo qualificado;
- nome do método;
- assinatura;
- tipos dos parâmetros;
- linha inicial;
- linha final.

Executar validação de colisões de identificadores.

---

## 9. Inventários obrigatórios

Antes da comparação, gerar por projeto:

- inventário de arquivos incluídos;
- inventário de arquivos excluídos;
- inventário de métodos elegíveis;
- quantidade de métodos por arquivo/módulo;
- falhas de parsing;
- arquivos não processados;
- justificativas de exclusão.

Um run tecnicamente concluído não implica cobertura completa.

Não liberar métricas finais sem demonstrar cobertura comparável entre as ferramentas.

---

## 10. Build e preparação

Usar a documentação oficial e o wrapper do próprio projeto quando disponível.

Evitar execução de testes se eles não forem necessários para a preparação da análise.

Fornecer ao SonarQube bytecode e dependências sempre que a análise Java exigir.

Registrar:

- comando de build;
- JDK efetivamente usado;
- resultado;
- duração;
- módulos processados;
- erros e warnings relevantes.

---

## 11. SonarQube

Criar Quality Profile específico contendo somente:

- `java:S138`;
- `java:S107`.

Para cada análise:

- usar chave de projeto exclusiva;
- registrar versão do projeto;
- aguardar conclusão da tarefa no servidor;
- preservar logs;
- preservar `taskId`;
- preservar `analysisId`, quando disponível;
- registrar configuração efetiva.

Exportar **todos** os issues das duas regras.

Não restringir a análise a New Code.

A exportação deve:

- suportar paginação;
- respeitar limites da API;
- registrar o total informado pela API;
- verificar se o total exportado corresponde ao total informado.

---

## 12. PMD

Criar ruleset específico contendo somente:

- `NcssCount`;
- `ExcessiveParameterList`.

Registrar:

- versão;
- ruleset;
- parâmetros;
- arquivos processados;
- relatório estruturado;
- logs;
- erros de parsing/processamento.

Distinguir:

- execução tecnicamente bem-sucedida com violações;
- falha técnica do PMD.

---

## 13. Normalização dos alertas

Preservar os relatórios brutos de ambas as ferramentas sem alteração.

Criar uma camada normalizada separada.

Cada ocorrência deve ser associada a um método usando:

- AST;
- caminho do arquivo;
- localização do alerta;
- intervalo de linhas;
- informações estruturadas disponíveis no relatório.

Não associar alertas apenas por nome ou número de linha isolado.

### Estados de associação

Cada alerta deve ser classificado como:

1. `eligible_method`
2. `out_of_scope`
3. `ambiguous`
4. `unassociated`

`NcssCount` pode gerar ocorrências para entidades que não sejam métodos elegíveis. Essas ocorrências devem ser classificadas e excluídas da comparação com justificativa.

Ocorrências `ambiguous` ou `unassociated` nunca podem ser automaticamente classificadas como exclusivas de uma ferramenta.

Não liberar métricas finais enquanto houver ocorrências potencialmente elegíveis sem resolução.

---

## 14. Deduplicação

Deduplicar utilizando:

`tool + project + smell + method_id`

Preservar sempre o vínculo entre o registro normalizado e o alerta bruto original.

Quantidade de alertas não equivale necessariamente à quantidade de métodos.

---

## 15. Métricas

Para cada combinação `projeto × smell`:

- `U` = conjunto de métodos elegíveis;
- `A` = métodos sinalizados pelo SonarQube;
- `B` = métodos sinalizados pelo PMD.

Calcular:

- `|U|`
- `|A|`
- `|B|`
- `%Sonar = 100 × |A| / |U|`
- `%PMD = 100 × |B| / |U|`
- `|A ∩ B|`
- `|A - B|`
- `|B - A|`
- `|A ∪ B|`
- `Jaccard = |A ∩ B| / |A ∪ B|`

### Casos especiais

- Se `|A ∪ B| = 0`: Jaccard = `N/A`.
- Se apenas um conjunto estiver vazio: Jaccard = `0`.
- Se `|U| = 0`: percentuais = `N/A` e registrar problema.

Não usar contagem bruta de alertas como quantidade de métodos.

Não interpretar Jaccard ou interseção como medida de correção.

---

## 16. Validação sintética

Antes do piloto real, criar fixtures/testes sintéticos separados dos projetos estudados.

Validar:

- overloads;
- tipos internos;
- diferenciação entre métodos e construtores;
- diferenciação entre métodos e classes;
- associação por localização;
- alertas duplicados;
- thresholds nas fronteiras;
- fórmulas;
- conjuntos vazios;
- paginação;
- completude da exportação.

Esses testes validam a implementação do pipeline, não a precisão das ferramentas.

---

## 17. Critérios de aprovação do piloto

O Apache Commons Lang só é considerado aprovado se:

- versões e configurações forem confirmadas;
- regras e parâmetros efetivos forem registrados;
- inventário de métodos estiver válido;
- cobertura SonarQube/PMD estiver reconciliada;
- falhas de parsing estiverem registradas;
- ocorrências potencialmente elegíveis estiverem resolvidas;
- invariantes dos conjuntos passarem;
- métricas puderem ser recalculadas a partir dos artefatos preservados;
- reprocessar os mesmos relatórios produzir resultado idêntico.

Se algum critério falhar:

- corrigir a implementação quando não alterar o protocolo; ou
- registrar bloqueio se a solução exigir decisão metodológica.

Não executar os demais projetos enquanto o piloto não for aprovado.

---

## 18. Invariantes mínimas

Validar automaticamente:

- `A ⊆ U`
- `B ⊆ U`
- `|A ∪ B| = |A| + |B| - |A ∩ B|`
- `|A| = |A ∩ B| + |A - B|`
- `|B| = |A ∩ B| + |B - A|`
- nenhum `method_id` duplicado no universo;
- nenhum método fora de `U` presente nas métricas.

---

## 19. Estrutura do repositório

```text
.
├── README.md
├── PROTOCOLO.md
├── STATUS.md
├── .env.example
├── configs/
├── scripts/
├── sources/
├── runs/
│   └── <run_id>/
│       ├── logs/
│       ├── raw/
│       ├── inventories/
│       └── config/
├── results/
│   └── <run_id>/
└── docs/
    └── fontes.md
```

---

## 20. Reprodutibilidade

Cada execução deve possuir `run_id` próprio.

Nunca sobrescrever execução anterior.

Preservar:

- comandos;
- versões;
- configurações;
- relatórios brutos;
- inventários;
- logs;
- resultados normalizados;
- checksums dos artefatos relevantes.

O pipeline deve permitir reprocessar relatórios já coletados sem executar novamente as ferramentas.

---

## 21. Fontes

Em `docs/fontes.md`, registrar para cada fonte:

- título;
- URL;
- organização/autoria;
- data de consulta;
- finalidade no experimento.

Priorizar documentação oficial para decisões técnicas sobre SonarQube, PMD, projetos, builds e APIs.

Não registrar referência não consultada.

---

## 22. Política de mudanças

Correções permitidas:

- bugs de scripts;
- problemas de parsing;
- erros de automação;
- erros de exportação;
- problemas de containerização;
- inconsistências que não alterem a metodologia.

Alterações que requerem bloqueio e registro em `STATUS.md`:

- projeto;
- versão;
- regra;
- threshold;
- escopo;
- unidade de comparação;
- definição de método elegível;
- ferramenta;
- critério de cálculo das métricas.

---

## 23. Organização da documentação

- `PROTOCOLO.md` é a fonte permanente das decisões metodológicas;
- `STATUS.md` registra somente o estado operacional atual;
- decisões já documentadas não são repetidas em outros arquivos;
- logs detalhados são mantidos em arquivos dentro de `runs/<run_id>/logs/`.

---
## 24. Resultado final esperado

Ao concluir o experimento, disponibilizar:

- resumo do que realmente foi executado;
- tabela de métricas por projeto e smell;
- configuração efetiva de cada ferramenta;
- cobertura alcançada;
- arquivos e entidades excluídos;
- erros e limitações;
- ocorrências pendentes, se houver;
- caminhos dos artefatos;
- comandos completos para reprodução;
- pacote exportável sem credenciais, caches, volumes Docker ou dependências baixadas.

---

## Erratum (2026-10-07)

Registro de ajustes posteriores ao congelamento do protocolo. Nenhum deles
altera projeto, versão, regra, limiar, escopo, unidade de comparação,
definição de método elegível, ferramenta ou critério de cálculo das métricas.

1. **Seção 22:** redação neutralizada (os títulos das duas listas deixaram de
   se dirigir ao executor). O conteúdo das listas é o mesmo.
2. **Seção 23:** reescrita como "Organização da documentação", removendo
   orientações sobre consumo de contexto e comunicação por chat. Sem efeito
   metodológico.
3. **Seção 10 ("bytecode e dependências"):** nas quatro análises (piloto incluído) foi
   fornecido apenas o bytecode do próprio projeto (`sonar.java.binaries`);
   `sonar.java.libraries` não foi configurada. Isso é uma limitação de
   interpretação da `java:S107` (ver `results/analises-complementares/s107-annotation-validation.md`
   e `results/consolidado-2026-10-01/RESULTADOS-FINAIS.md`, seção 3).
4. **Seção 6 ("mesmo conjunto elegível de arquivos"):** SonarQube, PMD e
   inventário receberam o mesmo escopo lógico de arquivos. A cobertura
   efetiva diferiu no Hibernate ORM (PMD 6.601/6.605; JavaParser
   6.604/6.605), conforme `RESULTADOS-FINAIS.md`, seção 4.
5. **Seção 19 (estrutura do repositório):** a estrutura efetiva usa
   `runs/<run_id>/{config,inventories,logs,raw,reprocess-check}`,
   `results/consolidado-<data>/`, `results/analises-complementares/`,
   `docs/DIARIO-EXECUCAO.md` (registro detalhado que, na execução, era o
   `STATUS.md`), `docs/ambiente-sonarqube.md` e `SHA256SUMS.txt`. O `STATUS.md`
   atual é um resumo.
6. **Seção 20 (checksums):** os checksums dos artefatos não foram gerados em
   2026-10-01; o `SHA256SUMS.txt` foi gerado em 2026-10-07 sobre os arquivos
   versionados.
7. **Seção 21 (fontes):** foram acrescentadas a `docs/fontes.md` as consultas
   ao código-fonte do `sonar-java` e às páginas SonarSource citadas na
   dissertação.