# method-inventory

Ferramenta que extrai o inventário de métodos elegíveis (PROTOCOLO.md seções
7 e 8) de um conjunto de arquivos `.java`, usando a AST do JavaParser (não usa
regex como mecanismo de identificação).

## Dependência

`javaparser-core` 3.28.2, baixado diretamente do Maven Central (sem
Maven/Gradle instalados no ambiente):

```powershell
New-Item -ItemType Directory -Force -Path lib
Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/com/github/javaparser/javaparser-core/3.28.2/javaparser-core-3.28.2.jar" -OutFile "lib/javaparser-core-3.28.2.jar"
```

O jar fica em `lib/` (ignorado pelo Git — ver `.gitignore`). `out/` (classes
compiladas) também é ignorado.

Integridade do jar utilizado no experimento (conferida com o `.jar.sha1` publicado no Maven
Central):

- SHA-1: `0f585a590072b20c6b4be3c35291b6e66a88b995`
- SHA-256: `b5499a3b1c40b16c0671fabe478c9aafeab38160c6fde74a6c13f42d86716ecd`

## Compilar

```powershell
javac -cp lib/javaparser-core-3.28.2.jar -d out src/MethodInventoryExtractor.java src/Associator.java src/Deduplicator.java src/Metrics.java
```

## Executar

```powershell
java -cp "out;lib/javaparser-core-3.28.2.jar" MethodInventoryExtractor `
  --project <nome-do-projeto> --commit <sha> `
  --root <diretorio-raiz-do-codigo> --out <arquivo-de-saida.jsonl>
```

Autoteste da lógica de detecção de colisão de identificadores (seção 8 do
protocolo):

```powershell
java -cp "out;lib/javaparser-core-3.28.2.jar" MethodInventoryExtractor --self-test
```

## Regras de elegibilidade implementadas (PROTOCOLO.md seção 7)

- Inclui: métodos com corpo em tipos top-level ou membros (nested/inner),
  incluindo `static`, `private`, overloads, overrides, default methods.
- Exclui: construtores, métodos sem corpo, initializers, métodos de tipos
  locais e de tipos anônimos — excluídos naturalmente porque a travessia só
  desce pela lista de membros de cada tipo, nunca pelo corpo de
  métodos/construtores/initializers.

## Saída

Um arquivo JSONL (um objeto por linha) com: `method_id`, `project`, `commit`,
`relative_path`, `qualified_type`, `method_name`, `signature`,
`parameter_types`, `line_start`, `line_end`.

Ao final da execução, o stderr reporta `arquivos_java_encontrados`,
`falhas_de_parsing`, `metodos_elegiveis` e `colisoes_de_identificador`. Código
de saída `2` indica colisão de identificador; `3` indica falha de parsing em
pelo menos um arquivo.

## Autotestes das demais ferramentas

```powershell
java -cp "out;lib/javaparser-core-3.28.2.jar" Associator --self-test
java -cp out Deduplicator --self-test
java -cp out Metrics --self-test
```

Os quatro autotestes (incluindo o do MethodInventoryExtractor) foram reexecutados em
2026-10-07 sobre o código versionado e terminaram com `SELF_TEST_RESULT=PASS`.
