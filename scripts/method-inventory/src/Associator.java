import com.github.javaparser.ParserConfiguration;
import com.github.javaparser.Position;
import com.github.javaparser.Range;
import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.Node;
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
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * Associa ocorrencias brutas (arquivo + numero de linha) a metodos elegiveis,
 * usando exclusivamente a AST do JavaParser (PROTOCOLO.md secao 13).
 *
 * Nunca associa por nome ou numero de linha isolado: resolve o no mais
 * especifico da AST que contem a linha informada e sobe na arvore ate a
 * unidade de interesse mais proxima (metodo, construtor, initializer ou o
 * proprio tipo), decidindo o estado de associacao a partir dessa unidade.
 *
 * Estados possiveis (secao 13): eligible_method, out_of_scope, ambiguous,
 * unassociated.
 */
public class Associator {

    private static final class Args {
        String project;
        String commit;
        Path root;
        Path occurrences;
        Path out;
    }

    private static final class Occurrence {
        String relativePath;
        int line;
        String label;
    }

    public static void main(String[] rawArgs) throws IOException {
        if (rawArgs.length > 0 && rawArgs[0].equals("--self-test")) {
            runSelfTest();
            return;
        }

        Args args = parseArgs(rawArgs);
        StaticJavaParser.getParserConfiguration()
                .setLanguageLevel(ParserConfiguration.LanguageLevel.BLEEDING_EDGE);

        List<Occurrence> occurrences = readOccurrences(args.occurrences);
        Map<String, CompilationUnit> parsedByPath = new HashMap<>();

        Files.createDirectories(args.out.toAbsolutePath().getParent());
        try (PrintStream ps = new PrintStream(Files.newOutputStream(args.out), true, StandardCharsets.UTF_8)) {
            for (Occurrence occ : occurrences) {
                Result r = classify(occ, args, parsedByPath);
                ps.println(toJson(occ, r));
            }
        }
    }

    private enum Status { ELIGIBLE_METHOD, OUT_OF_SCOPE, AMBIGUOUS, UNASSOCIATED }

    private static final class Result {
        Status status;
        String methodId;
        String reason;
    }

    private static Result classify(Occurrence occ, Args args, Map<String, CompilationUnit> cache) {
        Path file = args.root.resolve(occ.relativePath);
        if (!Files.isRegularFile(file)) {
            return unassociated("arquivo nao encontrado: " + occ.relativePath);
        }

        CompilationUnit cu = cache.get(occ.relativePath);
        if (cu == null) {
            try {
                cu = StaticJavaParser.parse(file);
                cache.put(occ.relativePath, cu);
            } catch (Exception e) {
                return unassociated("falha de parsing: " + e.getMessage());
            }
        }

        List<Node> candidateUnits = new ArrayList<>();
        collectMinimalUnits(cu, occ.line, candidateUnits);

        if (candidateUnits.isEmpty()) {
            return unassociated("linha nao pertence a nenhum tipo declarado (ex.: package/import)");
        }
        if (candidateUnits.size() > 1) {
            return ambiguous("multiplas unidades (metodo/tipo) reivindicam a mesma linha sem relacao de aninhamento");
        }

        Node unit = candidateUnits.get(0);
        if (unit instanceof MethodDeclaration) {
            MethodDeclaration md = (MethodDeclaration) unit;
            if (!md.getBody().isPresent()) {
                return outOfScope("metodo sem corpo (abstrato/interface sem default)");
            }
            if (!isEligibleMethod(md)) {
                return outOfScope("metodo pertence a tipo local ou anonimo");
            }
            Result r = new Result();
            r.status = Status.ELIGIBLE_METHOD;
            r.methodId = buildMethodId(md, args.project, args.commit, occ.relativePath);
            r.reason = "metodo elegivel";
            return r;
        }
        if (unit instanceof ConstructorDeclaration) {
            return outOfScope("construtor (fora da unidade de comparacao)");
        }
        if (unit instanceof InitializerDeclaration) {
            return outOfScope("initializer estatico/de instancia");
        }
        if (unit instanceof TypeDeclaration) {
            return outOfScope("nivel de classe/tipo (ex.: NcssCount classReportLevel)");
        }
        return unassociated("tipo de unidade nao reconhecido: " + unit.getClass().getSimpleName());
    }

    /**
     * Preenche candidateUnits com as unidades de interesse (MethodDeclaration,
     * ConstructorDeclaration, InitializerDeclaration, TypeDeclaration) cuja
     * faixa de linhas contem a linha informada, mantendo apenas as unidades
     * mais especificas (sem outra unidade candidata aninhada dentro dela).
     */
    private static void collectMinimalUnits(CompilationUnit cu, int line, List<Node> out) {
        List<Node> all = new ArrayList<>();
        cu.findAll(Node.class).forEach(n -> {
            if (!(n instanceof MethodDeclaration || n instanceof ConstructorDeclaration
                    || n instanceof InitializerDeclaration || n instanceof TypeDeclaration)) {
                return;
            }
            n.getRange().ifPresent(range -> {
                if (containsLine(range, line)) {
                    all.add(n);
                }
            });
        });

        for (Node candidate : all) {
            boolean hasNestedCandidate = false;
            for (Node other : all) {
                if (other != candidate && candidate.isAncestorOf(other)) {
                    hasNestedCandidate = true;
                    break;
                }
            }
            if (!hasNestedCandidate) {
                out.add(candidate);
            }
        }
    }

    private static boolean containsLine(Range range, int line) {
        return range.begin.line <= line && line <= range.end.line;
    }

    private static boolean isEligibleMethod(MethodDeclaration md) {
        Node current = md;
        Node parent = current.getParentNode().orElse(null);
        while (parent != null) {
            if (parent instanceof CompilationUnit) {
                return true;
            }
            if (parent instanceof TypeDeclaration) {
                current = parent;
                parent = current.getParentNode().orElse(null);
                continue;
            }
            // qualquer outro ancestral (ObjectCreationExpr anonimo,
            // LocalClassDeclarationStmt, BlockStmt, etc.) indica tipo local
            // ou anonimo -> nao elegivel.
            return false;
        }
        return true;
    }

    private static String buildMethodId(MethodDeclaration md, String project, String commit, String relativePath) {
        String qualifiedType = qualifiedTypeName(md);
        Map<String, String> typeVarBounds = collectTypeVariableBounds(md);
        List<String> paramTypes = new ArrayList<>();
        for (Parameter p : md.getParameters()) {
            String t = substituteErasure(p.getType(), typeVarBounds);
            if (p.isVarArgs()) t = t + "...";
            paramTypes.add(t);
        }
        String signature = md.getNameAsString() + "(" + String.join(",", paramTypes) + ")";
        return String.join("::", project, commit, relativePath, qualifiedType, signature);
    }

    // Mesma logica de MethodInventoryExtractor (resolucao de erasure de
    // variaveis de tipo genericas para o bound), mantida aqui para que
    // Associator calcule exatamente o mesmo method_id (PROTOCOLO.md secao 8).
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

    private static String qualifiedTypeName(MethodDeclaration md) {
        List<String> chain = new ArrayList<>();
        Node parent = md.getParentNode().orElse(null);
        while (parent instanceof TypeDeclaration) {
            chain.add(0, ((TypeDeclaration<?>) parent).getNameAsString());
            parent = parent.getParentNode().orElse(null);
        }
        String packageName = md.findCompilationUnit()
                .flatMap(cu -> cu.getPackageDeclaration())
                .map(pd -> pd.getNameAsString())
                .orElse("");
        String nested = String.join(".", chain);
        return packageName.isEmpty() ? nested : packageName + "." + nested;
    }

    private static Result unassociated(String reason) {
        Result r = new Result();
        r.status = Status.UNASSOCIATED;
        r.reason = reason;
        return r;
    }

    private static Result outOfScope(String reason) {
        Result r = new Result();
        r.status = Status.OUT_OF_SCOPE;
        r.reason = reason;
        return r;
    }

    private static Result ambiguous(String reason) {
        Result r = new Result();
        r.status = Status.AMBIGUOUS;
        r.reason = reason;
        return r;
    }

    private static String toJson(Occurrence occ, Result r) {
        List<String> fields = new ArrayList<>();
        fields.add(field("relative_path", occ.relativePath));
        fields.add("\"line\":" + occ.line);
        fields.add(field("label", occ.label));
        fields.add(field("status", r.status.name().toLowerCase()));
        fields.add(field("method_id", r.methodId == null ? "" : r.methodId));
        fields.add(field("reason", r.reason));
        return "{" + String.join(",", fields) + "}";
    }

    private static String field(String name, String value) {
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

    private static List<Occurrence> readOccurrences(Path csv) throws IOException {
        List<Occurrence> result = new ArrayList<>();
        List<String> lines = Files.readAllLines(csv, StandardCharsets.UTF_8);
        for (String rawLine : lines) {
            // remove possivel BOM (arquivo pode ter sido salvo como UTF-8 com BOM).
            String line = rawLine.replace("\uFEFF", "");
            if (line.isBlank() || line.startsWith("#")) continue;
            String[] parts = line.split(",", 3);
            Occurrence occ = new Occurrence();
            occ.relativePath = parts[0].trim();
            occ.line = Integer.parseInt(parts[1].trim());
            occ.label = parts.length > 2 ? parts[2].trim() : "";
            result.add(occ);
        }
        return result;
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
        args.occurrences = Path.of(map.get("occurrences")).toAbsolutePath().normalize();
        args.out = Path.of(map.get("out")).toAbsolutePath().normalize();
        return args;
    }

    /**
     * Exercita a resolucao de aninhamento (metodo elegivel vs. construtor vs.
     * tipo local/anonimo vs. nivel de classe) usando posicoes sinteticas,
     * sem depender de arquivos em disco.
     */
    private static void runSelfTest() {
        String src = String.join("\n",
                "package t;",
                "public class Outer {",                         // linha 2
                "    public void eligible() {",                 // linha 3
                "        int x = 1;",                            // linha 4
                "    }",                                         // linha 5
                "    public Outer() {",                          // linha 6
                "        int y = 1;",                            // linha 7
                "    }",                                         // linha 8
                "    public void hostsLocal() {",                // linha 9
                "        class Local {",                         // linha 10
                "            void m() { int z = 1; }",           // linha 11
                "        }",                                     // linha 12
                "        new Local().m();",                      // linha 13
                "    }",                                         // linha 14
                "}"                                               // linha 15
        );
        CompilationUnit cu = StaticJavaParser.parse(src);

        List<Node> units4 = new ArrayList<>();
        collectMinimalUnits(cu, 4, units4);
        boolean eligibleOk = units4.size() == 1 && units4.get(0) instanceof MethodDeclaration
                && isEligibleMethod((MethodDeclaration) units4.get(0));

        List<Node> units7 = new ArrayList<>();
        collectMinimalUnits(cu, 7, units7);
        boolean constructorOk = units7.size() == 1 && units7.get(0) instanceof ConstructorDeclaration;

        List<Node> units11 = new ArrayList<>();
        collectMinimalUnits(cu, 11, units11);
        boolean localOk = units11.size() == 1 && units11.get(0) instanceof MethodDeclaration
                && !isEligibleMethod((MethodDeclaration) units11.get(0));

        List<Node> units2 = new ArrayList<>();
        collectMinimalUnits(cu, 2, units2);
        boolean classLevelOk = units2.size() == 1 && units2.get(0) instanceof TypeDeclaration;

        System.out.println("self_test_metodo_elegivel=" + eligibleOk);
        System.out.println("self_test_construtor_out_of_scope=" + constructorOk);
        System.out.println("self_test_tipo_local_out_of_scope=" + localOk);
        System.out.println("self_test_nivel_de_classe_out_of_scope=" + classLevelOk);

        boolean pass = eligibleOk && constructorOk && localOk && classLevelOk;
        System.out.println(pass ? "SELF_TEST_RESULT=PASS" : "SELF_TEST_RESULT=FAIL");
        if (!pass) System.exit(1);
    }
}
