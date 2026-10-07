import com.github.javaparser.ParserConfiguration;
import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.Node;
import com.github.javaparser.ast.body.BodyDeclaration;
import com.github.javaparser.ast.body.ConstructorDeclaration;
import com.github.javaparser.ast.body.InitializerDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.body.Parameter;
import com.github.javaparser.ast.body.TypeDeclaration;
import com.github.javaparser.ast.type.ArrayType;
import com.github.javaparser.ast.type.ClassOrInterfaceType;
import com.github.javaparser.ast.type.Type;
import com.github.javaparser.ast.type.TypeParameter;

import java.io.IOException;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Extrai o inventario de metodos elegiveis de um conjunto de arquivos .java,
 * conforme a definicao da secao 7/8 do PROTOCOLO.md:
 *
 * - inclui: metodos com corpo em tipos top-level ou membros (static, private,
 *   overloads, overrides, default methods);
 * - exclui: construtores, metodos sem corpo, initializers, tipos locais e
 *   tipos anonimos.
 *
 * Nao usa regex para identificacao/associacao. Usa exclusivamente a AST do
 * JavaParser. Tipos locais e anonimos sao excluidos naturalmente porque a
 * travessia so desce pela lista de "membros" de cada TypeDeclaration, nunca
 * pelo corpo de metodos/construtores/initializers.
 *
 * Saida: um arquivo JSONL (uma ocorrencia por linha) com os campos exigidos
 * pelo protocolo, mais validacao de colisao de identificadores.
 */
public class MethodInventoryExtractor {

    private static final class Args {
        String project;
        String commit;
        Path root;
        Path out;
    }

    private static final class MethodRecord {
        String methodId;
        String project;
        String commit;
        String relativePath;
        String qualifiedType;
        String methodName;
        String signature;
        List<String> parameterTypes;
        int lineStart;
        int lineEnd;
    }

    public static void main(String[] rawArgs) throws IOException {
        if (rawArgs.length > 0 && rawArgs[0].equals("--self-test")) {
            runSelfTest();
            return;
        }

        Args args = parseArgs(rawArgs);

        StaticJavaParser.getParserConfiguration()
                .setLanguageLevel(ParserConfiguration.LanguageLevel.BLEEDING_EDGE);

        List<Path> javaFiles;
        try (Stream<Path> walk = Files.walk(args.root)) {
            javaFiles = walk.filter(p -> p.toString().endsWith(".java"))
                    .filter(Files::isRegularFile)
                    .sorted()
                    .collect(Collectors.toList());
        }

        List<MethodRecord> records = new ArrayList<>();
        List<String> parseFailures = new ArrayList<>();

        for (Path file : javaFiles) {
            String relative = args.root.relativize(file).toString().replace('\\', '/');
            try {
                CompilationUnit cu = StaticJavaParser.parse(file);
                String packageName = cu.getPackageDeclaration()
                        .map(pd -> pd.getNameAsString())
                        .orElse("");
                for (TypeDeclaration<?> type : cu.getTypes()) {
                    walkType(type, packageName, relative, args, records);
                }
            } catch (Exception e) {
                parseFailures.add(relative + " :: " + e.getClass().getSimpleName() + ": " + e.getMessage());
            }
        }

        List<String> collisions = detectCollisions(records);

        Files.createDirectories(args.out.toAbsolutePath().getParent());
        try (PrintStream ps = new PrintStream(Files.newOutputStream(args.out), true, StandardCharsets.UTF_8)) {
            for (MethodRecord r : records) {
                ps.println(toJson(r));
            }
        }

        System.err.println("arquivos_java_encontrados=" + javaFiles.size());
        System.err.println("falhas_de_parsing=" + parseFailures.size());
        for (String f : parseFailures) {
            System.err.println("PARSE_FAIL: " + f);
        }
        System.err.println("metodos_elegiveis=" + records.size());
        System.err.println("colisoes_de_identificador=" + collisions.size());
        for (String c : collisions) {
            System.err.println("COLLISION: " + c);
        }

        if (!collisions.isEmpty()) {
            System.exit(2);
        }
        if (!parseFailures.isEmpty()) {
            System.exit(3);
        }
    }

    private static List<String> detectCollisions(List<MethodRecord> records) {
        Map<String, Integer> idCount = new HashMap<>();
        for (MethodRecord r : records) {
            idCount.merge(r.methodId, 1, Integer::sum);
        }
        return idCount.entrySet().stream()
                .filter(e -> e.getValue() > 1)
                .map(Map.Entry::getKey)
                .sorted()
                .collect(Collectors.toList());
    }

    /**
     * Exercita a logica de deteccao de colisao de identificadores de forma
     * isolada da travessia de arquivos, conforme exigido pela secao 8 do
     * protocolo ("Executar validacao de colisoes de identificadores").
     */
    private static void runSelfTest() {
        MethodRecord a = new MethodRecord();
        a.methodId = "proj::commit::Foo.java::pkg.Foo::bar()";
        MethodRecord b = new MethodRecord();
        b.methodId = "proj::commit::Foo.java::pkg.Foo::bar()"; // id identico de proposito
        MethodRecord c = new MethodRecord();
        c.methodId = "proj::commit::Foo.java::pkg.Foo::baz()";

        List<String> collisionsFound = detectCollisions(List.of(a, b, c));
        boolean collisionCaseOk = collisionsFound.size() == 1
                && collisionsFound.get(0).equals(a.methodId);

        List<String> noCollisions = detectCollisions(List.of(a, c));
        boolean noCollisionCaseOk = noCollisions.isEmpty();

        System.out.println("self_test_colisao_detectada=" + collisionCaseOk);
        System.out.println("self_test_sem_colisao=" + noCollisionCaseOk);

        // Caso real encontrado no Apache Commons Lang 3.20.0 (Validate.notEmpty):
        // overloads com mesmo nome/numero de parametros mas bounds de tipo
        // genericos diferentes sao metodos distintos na JVM (erasure
        // diferente); a assinatura precisa refletir o bound, nao o texto "T".
        CompilationUnit eraseCu = StaticJavaParser.parse(String.join("\n",
                "class V {",
                "    static <T extends java.util.Collection<?>> T notEmpty(T collection) { return collection; }",
                "    static <T extends java.util.Map<?, ?>> T notEmpty(T map) { return map; }",
                "    static <T> T unbounded(T value) { return value; }",
                "}"
        ));
        List<MethodDeclaration> methods = eraseCu.findAll(MethodDeclaration.class);
        MethodDeclaration collectionOverload = methods.get(0);
        MethodDeclaration mapOverload = methods.get(1);
        MethodDeclaration unboundedOverload = methods.get(2);
        String collectionSig = substituteErasure(collectionOverload.getParameter(0).getType(),
                collectTypeVariableBounds(collectionOverload));
        String mapSig = substituteErasure(mapOverload.getParameter(0).getType(),
                collectTypeVariableBounds(mapOverload));
        String unboundedSig = substituteErasure(unboundedOverload.getParameter(0).getType(),
                collectTypeVariableBounds(unboundedOverload));
        boolean erasureCaseOk = collectionSig.equals("java.util.Collection<?>")
                && mapSig.equals("java.util.Map<?,?>")
                && unboundedSig.equals("Object")
                && !collectionSig.equals(mapSig);
        System.out.println("self_test_erasure_bounds_genericos_distintos=" + erasureCaseOk);

        if (!collisionCaseOk || !noCollisionCaseOk || !erasureCaseOk) {
            System.out.println("SELF_TEST_RESULT=FAIL");
            System.exit(1);
        }
        System.out.println("SELF_TEST_RESULT=PASS");
    }

    private static void walkType(TypeDeclaration<?> type, String packageName, String relativePath,
                                  Args args, List<MethodRecord> out) {
        String qualifiedType = qualifiedTypeName(type, packageName);

        for (BodyDeclaration<?> member : type.getMembers()) {
            if (member instanceof TypeDeclaration) {
                // tipo membro (nested/inner) -> desce recursivamente.
                walkType((TypeDeclaration<?>) member, packageName, relativePath, args, out);
            } else if (member instanceof MethodDeclaration) {
                MethodDeclaration md = (MethodDeclaration) member;
                if (!md.getBody().isPresent()) {
                    // metodo sem corpo (abstrato ou de interface sem default/static) -> excluido.
                    continue;
                }
                out.add(buildRecord(md, qualifiedType, relativePath, args));
            } else if (member instanceof ConstructorDeclaration) {
                // construtores sao excluidos da unidade de comparacao (secao 7).
            } else if (member instanceof InitializerDeclaration) {
                // initializers estaticos/de instancia sao excluidos (secao 7).
            }
            // outros membros (campos, anotacoes) nao sao unidades de comparacao.
        }
    }

    /**
     * Coleta o limite (primeiro bound, ou Object se nao declarado) de cada
     * variavel de tipo visivel no metodo: as do proprio metodo e as de cada
     * tipo envolvente (classe/interface). Necessario porque a assinatura do
     * metodo precisa refletir o apagamento de tipo (erasure) da JVM, nao o
     * texto literal da variavel de tipo: dois metodos com o mesmo nome e
     * parametro "T" mas bounds diferentes (ex.: "T extends Collection" e
     * "T extends Map") sao metodos DISTINTOS na JVM, e o identificador
     * estavel da secao 8 precisa distingui-los (colisao real encontrada em
     * Validate.notEmpty/validIndex e ExceptionUtils.throwUnchecked no
     * Apache Commons Lang 3.20.0, documentada em STATUS.md secao 5).
     */
    private static Map<String, String> collectTypeVariableBounds(MethodDeclaration md) {
        Map<String, String> bounds = new HashMap<>();
        for (TypeParameter tp : md.getTypeParameters()) {
            bounds.put(tp.getNameAsString(), boundText(tp));
        }
        Node parent = md.getParentNode().orElse(null);
        while (parent instanceof TypeDeclaration) {
            TypeDeclaration<?> enclosing = (TypeDeclaration<?>) parent;
            if (enclosing instanceof com.github.javaparser.ast.body.ClassOrInterfaceDeclaration) {
                for (TypeParameter tp : ((com.github.javaparser.ast.body.ClassOrInterfaceDeclaration) enclosing).getTypeParameters()) {
                    bounds.putIfAbsent(tp.getNameAsString(), boundText(tp));
                }
            }
            parent = enclosing.getParentNode().orElse(null);
        }
        return bounds;
    }

    private static String boundText(TypeParameter tp) {
        return tp.getTypeBound().isNonEmpty() ? tp.getTypeBound().get(0).asString() : "Object";
    }

    /** Substitui recursivamente uma variavel de tipo pelo seu bound (erasure); demais tipos permanecem como estao. */
    private static String substituteErasure(Type type, Map<String, String> typeVarBounds) {
        if (type instanceof ArrayType) {
            ArrayType arrayType = (ArrayType) type;
            return substituteErasure(arrayType.getComponentType(), typeVarBounds) + "[]";
        }
        if (type instanceof ClassOrInterfaceType) {
            ClassOrInterfaceType cit = (ClassOrInterfaceType) type;
            if (!cit.getTypeArguments().isPresent() && !cit.getScope().isPresent()) {
                String bound = typeVarBounds.get(cit.getNameAsString());
                if (bound != null) {
                    return bound;
                }
            }
        }
        return type.asString();
    }

    private static String qualifiedTypeName(TypeDeclaration<?> type, String packageName) {
        List<String> chain = new ArrayList<>();
        chain.add(type.getNameAsString());
        Node parent = type.getParentNode().orElse(null);
        while (parent instanceof TypeDeclaration) {
            chain.add(0, ((TypeDeclaration<?>) parent).getNameAsString());
            parent = parent.getParentNode().orElse(null);
        }
        String nested = String.join(".", chain);
        return packageName.isEmpty() ? nested : packageName + "." + nested;
    }

    private static MethodRecord buildRecord(MethodDeclaration md, String qualifiedType,
                                             String relativePath, Args args) {
        Map<String, String> typeVarBounds = collectTypeVariableBounds(md);
        List<String> paramTypes = new ArrayList<>();
        for (Parameter p : md.getParameters()) {
            String t = substituteErasure(p.getType(), typeVarBounds);
            if (p.isVarArgs()) {
                t = t + "...";
            }
            paramTypes.add(t);
        }
        String signature = md.getNameAsString() + "(" + String.join(",", paramTypes) + ")";

        MethodRecord r = new MethodRecord();
        r.project = args.project;
        r.commit = args.commit;
        r.relativePath = relativePath;
        r.qualifiedType = qualifiedType;
        r.methodName = md.getNameAsString();
        r.signature = signature;
        r.parameterTypes = paramTypes;
        r.lineStart = md.getBegin().map(p -> p.line).orElse(-1);
        r.lineEnd = md.getEnd().map(p -> p.line).orElse(-1);
        r.methodId = String.join("::", args.project, args.commit, relativePath, qualifiedType, signature);
        return r;
    }

    private static String toJson(MethodRecord r) {
        List<String> fields = new ArrayList<>();
        fields.add(jsonField("method_id", r.methodId));
        fields.add(jsonField("project", r.project));
        fields.add(jsonField("commit", r.commit));
        fields.add(jsonField("relative_path", r.relativePath));
        fields.add(jsonField("qualified_type", r.qualifiedType));
        fields.add(jsonField("method_name", r.methodName));
        fields.add(jsonField("signature", r.signature));

        StringBuilder paramsArray = new StringBuilder("[");
        for (int i = 0; i < r.parameterTypes.size(); i++) {
            if (i > 0) paramsArray.append(",");
            paramsArray.append("\"").append(escape(r.parameterTypes.get(i))).append("\"");
        }
        paramsArray.append("]");
        fields.add("\"parameter_types\":" + paramsArray);
        fields.add("\"line_start\":" + r.lineStart);
        fields.add("\"line_end\":" + r.lineEnd);

        return "{" + String.join(",", fields) + "}";
    }

    private static String jsonField(String name, String value) {
        return "\"" + name + "\":\"" + escape(value) + "\"";
    }

    private static String escape(String s) {
        StringBuilder sb = new StringBuilder();
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default: sb.append(c);
            }
        }
        return sb.toString();
    }

    private static Args parseArgs(String[] rawArgs) {
        Map<String, String> map = new HashMap<>();
        for (int i = 0; i < rawArgs.length - 1; i += 2) {
            map.put(rawArgs[i].replaceFirst("^--", ""), rawArgs[i + 1]);
        }
        Args args = new Args();
        args.project = map.getOrDefault("project", "unknown");
        args.commit = map.getOrDefault("commit", "unknown");
        args.root = Path.of(map.get("root")).toAbsolutePath().normalize();
        args.out = Path.of(map.get("out")).toAbsolutePath().normalize();
        return args;
    }
}
