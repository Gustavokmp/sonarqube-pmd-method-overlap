import java.util.LinkedHashSet;
import java.util.Set;
import java.util.TreeSet;

/**
 * Calcula as metricas por combinacao projeto x smell definidas em
 * PROTOCOLO.md secao 15, a partir dos conjuntos:
 *   U = metodos elegiveis (universo)
 *   A = metodos sinalizados pelo SonarQube
 *   B = metodos sinalizados pelo PMD
 *
 * Trata explicitamente os casos especiais de conjuntos vazios descritos na
 * secao 15:
 *   - |A uniao B| == 0            -> Jaccard = N/A
 *   - exatamente um dos conjuntos vazio (uniao != 0) -> Jaccard = 0
 *   - |U| == 0                     -> percentuais = N/A (situacao a registrar)
 */
public class Metrics {

    static final class Result {
        int universeSize;
        int sonarCount;
        int pmdCount;
        String percentSonar; // "N/A" ou valor formatado
        String percentPmd;
        int intersectionCount;
        int onlySonarCount;
        int onlyPmdCount;
        int unionCount;
        String jaccard; // "N/A" ou valor formatado
        boolean emptyUniverseProblem;
    }

    static Result compute(Set<String> universe, Set<String> sonar, Set<String> pmd) {
        Result r = new Result();
        r.universeSize = universe.size();

        Set<String> a = new TreeSet<>(sonar);
        Set<String> b = new TreeSet<>(pmd);

        Set<String> intersection = new LinkedHashSet<>(a);
        intersection.retainAll(b);

        Set<String> onlyA = new LinkedHashSet<>(a);
        onlyA.removeAll(b);

        Set<String> onlyB = new LinkedHashSet<>(b);
        onlyB.removeAll(a);

        Set<String> union = new LinkedHashSet<>(a);
        union.addAll(b);

        r.sonarCount = a.size();
        r.pmdCount = b.size();
        r.intersectionCount = intersection.size();
        r.onlySonarCount = onlyA.size();
        r.onlyPmdCount = onlyB.size();
        r.unionCount = union.size();

        if (r.universeSize == 0) {
            r.percentSonar = "N/A";
            r.percentPmd = "N/A";
            r.emptyUniverseProblem = true;
        } else {
            r.percentSonar = format(100.0 * r.sonarCount / r.universeSize);
            r.percentPmd = format(100.0 * r.pmdCount / r.universeSize);
            r.emptyUniverseProblem = false;
        }

        if (r.unionCount == 0) {
            r.jaccard = "N/A";
        } else if (r.sonarCount == 0 || r.pmdCount == 0) {
            r.jaccard = format(0.0);
        } else {
            r.jaccard = format(1.0 * r.intersectionCount / r.unionCount);
        }

        return r;
    }

    private static String format(double v) {
        return String.format("%.4f", v);
    }

    public static void main(String[] args) {
        if (args.length > 0 && args[0].equals("--self-test")) {
            runSelfTest();
            return;
        }
        System.err.println("uso: Metrics --self-test (ferramenta de validacao de formulas)");
        System.exit(2);
    }

    private static void runSelfTest() {
        boolean allOk = true;

        // Caso 1: cenario normal com sobreposicao parcial, calculavel a mao.
        // U = {m1..m10} (10 metodos). A = {m1,m2,m3,m4} (Sonar). B = {m3,m4,m5} (PMD).
        // Intersecao = {m3,m4} (2). Uniao = {m1,m2,m3,m4,m5} (5). Jaccard = 2/5 = 0.4.
        Set<String> universe1 = setOf("m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10");
        Set<String> a1 = setOf("m1", "m2", "m3", "m4");
        Set<String> b1 = setOf("m3", "m4", "m5");
        Result r1 = compute(universe1, a1, b1);
        boolean case1Ok = r1.universeSize == 10 && r1.sonarCount == 4 && r1.pmdCount == 3
                && r1.intersectionCount == 2 && r1.onlySonarCount == 2 && r1.onlyPmdCount == 1
                && r1.unionCount == 5
                && r1.percentSonar.equals(format(40.0)) && r1.percentPmd.equals(format(30.0))
                && r1.jaccard.equals(format(0.4)) && !r1.emptyUniverseProblem;
        System.out.println("self_test_caso_normal_formulas=" + case1Ok);
        allOk &= case1Ok;

        // Caso 2: A e B ambos vazios -> uniao = 0 -> Jaccard = N/A (nao 0/0 silencioso).
        Set<String> universe2 = setOf("m1", "m2");
        Result r2 = compute(universe2, setOf(), setOf());
        boolean case2Ok = r2.unionCount == 0 && r2.jaccard.equals("N/A")
                && r2.percentSonar.equals(format(0.0)) && r2.percentPmd.equals(format(0.0));
        System.out.println("self_test_ambos_vazios_jaccard_na=" + case2Ok);
        allOk &= case2Ok;

        // Caso 3: apenas A vazio, B nao vazio -> uniao != 0 -> Jaccard = 0 (nao N/A).
        Set<String> universe3 = setOf("m1", "m2", "m3");
        Result r3 = compute(universe3, setOf(), setOf("m1"));
        boolean case3Ok = r3.unionCount == 1 && r3.jaccard.equals(format(0.0))
                && r3.intersectionCount == 0;
        System.out.println("self_test_apenas_um_vazio_jaccard_zero=" + case3Ok);
        allOk &= case3Ok;

        // Caso 3b: simetrico, apenas B vazio.
        Result r3b = compute(universe3, setOf("m1"), setOf());
        boolean case3bOk = r3b.unionCount == 1 && r3b.jaccard.equals(format(0.0));
        System.out.println("self_test_apenas_B_vazio_jaccard_zero=" + case3bOk);
        allOk &= case3bOk;

        // Caso 4: |U| == 0 -> percentuais N/A, problema registrado (mesmo com A/B hipoteticamente vazios tambem).
        Result r4 = compute(setOf(), setOf(), setOf());
        boolean case4Ok = r4.percentSonar.equals("N/A") && r4.percentPmd.equals("N/A")
                && r4.emptyUniverseProblem;
        System.out.println("self_test_universo_vazio_percentuais_na=" + case4Ok);
        allOk &= case4Ok;

        System.out.println(allOk ? "SELF_TEST_RESULT=PASS" : "SELF_TEST_RESULT=FAIL");
        if (!allOk) System.exit(1);
    }

    private static Set<String> setOf(String... items) {
        Set<String> s = new LinkedHashSet<>();
        for (String i : items) s.add(i);
        return s;
    }
}
