import com.github.javaparser.ParserConfiguration;
import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.body.CallableDeclaration;
import com.github.javaparser.ast.expr.AnnotationExpr;
import com.github.javaparser.ast.visitor.VoidVisitorAdapter;

import java.io.IOException;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

/**
 * Ferramenta de apoio para a Atividade 4.2 (analise complementar
 * pos-protocolo): dado um metodo/construtor ja identificado (arquivo real +
 * linha inicial, vindos de inventory-methods.jsonl), usa a AST do
 * JavaParser para localizar de novo a mesma declaracao (por linha inicial,
 * mesmo criterio de MethodInventoryExtractor.lineStart = getBegin().line) e
 * lista as anotacoes presentes nela - sem usar regex como mecanismo de
 * identificacao.
 *
 * Entrada (TSV, uma linha por metodo): label \t caminhoArquivoReal \t
 * lineStart \t methodName
 * Saida (TSV): label \t annotations separadas por ';' (vazio se nenhuma)
 */
public class AnnotationLookup {

    public static void main(String[] args) throws IOException {
        StaticJavaParser.getParserConfiguration()
                .setLanguageLevel(ParserConfiguration.LanguageLevel.BLEEDING_EDGE);
        if (args.length < 2 || !args[0].equals("--in")) {
            System.err.println("uso: AnnotationLookup --in <entrada.tsv> --out <saida.tsv>");
            System.exit(2);
            return;
        }
        Path in = Path.of(args[1]);
        Path out = Path.of(args[3]);

        List<String> lines = Files.readAllLines(in, StandardCharsets.UTF_8);
        List<String> results = new ArrayList<>();
        for (String line : lines) {
            if (line.isBlank()) continue;
            String[] parts = line.split("\t", -1);
            String label = parts[0];
            String filePath = parts[1];
            int lineStart = Integer.parseInt(parts[2]);
            String methodName = parts[3];

            String annotations;
            try {
                CompilationUnit cu = StaticJavaParser.parse(Path.of(filePath));
                List<String> found = new ArrayList<>();
                cu.accept(new VoidVisitorAdapter<Void>() {
                    @Override
                    public void visit(com.github.javaparser.ast.body.MethodDeclaration n, Void arg) {
                        super.visit(n, arg);
                        checkNode(n, n.getNameAsString());
                    }

                    @Override
                    public void visit(com.github.javaparser.ast.body.ConstructorDeclaration n, Void arg) {
                        super.visit(n, arg);
                        checkNode(n, n.getNameAsString());
                    }

                    private void checkNode(CallableDeclaration<?> n, String name) {
                        int begin = n.getBegin().map(p -> p.line).orElse(-1);
                        if (begin == lineStart && name.equals(methodName)) {
                            for (AnnotationExpr a : n.getAnnotations()) {
                                found.add(a.getNameAsString());
                            }
                        }
                    }
                }, null);
                annotations = String.join(";", found);
            } catch (Exception e) {
                annotations = "ERROR:" + e.getClass().getSimpleName() + ":" + e.getMessage();
            }
            results.add(label + "\t" + annotations);
        }

        try (PrintStream ps = new PrintStream(Files.newOutputStream(out), true, StandardCharsets.UTF_8)) {
            for (String r : results) {
                ps.println(r);
            }
        }
        System.out.println("PROCESSED=" + results.size());
    }
}
