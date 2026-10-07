import java.io.IOException;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Deduplica alertas normalizados por tool+project+smell+method_id
 * (PROTOCOLO.md secao 14), preservando o vinculo com cada alerta bruto
 * original absorvido.
 *
 * Entrada: JSONL simples, uma ocorrencia por linha, campos obrigatorios:
 *   tool, project, smell, method_id, raw_alert_id
 * (apenas os campos acima sao lidos; qualquer JSON com esses pares
 * "chave":"valor" e aceito, sem necessidade de uma biblioteca JSON completa
 * porque o formato de entrada e controlado por nos mesmos nesta validacao).
 *
 * Saida: JSONL com um registro por combinacao unica de
 * tool+project+smell+method_id, contendo a lista de raw_alert_id absorvidos.
 */
public class Deduplicator {

    public static void main(String[] args) throws IOException {
        if (args.length > 0 && args[0].equals("--self-test")) {
            runSelfTest();
            return;
        }

        Path in = null;
        Path out = null;
        for (int i = 0; i < args.length - 1; i += 2) {
            String key = args[i].replaceFirst("^--", "");
            if (key.equals("in")) in = Path.of(args[i + 1]);
            if (key.equals("out")) out = Path.of(args[i + 1]);
        }
        if (in == null || out == null) {
            System.err.println("uso: Deduplicator --in <entrada.jsonl> --out <saida.jsonl>");
            System.exit(2);
        }

        List<Map<String, String>> raw = readJsonl(Files.readAllLines(in, StandardCharsets.UTF_8));
        DedupResult result = dedupe(raw);

        Files.createDirectories(out.toAbsolutePath().getParent());
        try (PrintStream ps = new PrintStream(Files.newOutputStream(out), true, StandardCharsets.UTF_8)) {
            for (Map.Entry<String, List<String>> e : result.groups.entrySet()) {
                ps.println(toJson(e.getKey(), e.getValue()));
            }
        }
        System.out.println("raw_total=" + result.rawTotal);
        System.out.println("unique_total=" + result.groups.size());
    }

    private static final class DedupResult {
        int rawTotal;
        // chave composta "tool::project::smell::method_id" -> lista de raw_alert_id absorvidos
        Map<String, List<String>> groups = new LinkedHashMap<>();
    }

    private static DedupResult dedupe(List<Map<String, String>> raw) {
        DedupResult r = new DedupResult();
        r.rawTotal = raw.size();
        for (Map<String, String> occ : raw) {
            String key = String.join("::",
                    occ.getOrDefault("tool", ""),
                    occ.getOrDefault("project", ""),
                    occ.getOrDefault("smell", ""),
                    occ.getOrDefault("method_id", ""));
            r.groups.computeIfAbsent(key, k -> new ArrayList<>())
                    .add(occ.getOrDefault("raw_alert_id", ""));
        }
        return r;
    }

    private static String toJson(String key, List<String> rawAlertIds) {
        String[] parts = key.split("::", 4);
        StringBuilder ids = new StringBuilder();
        for (int i = 0; i < rawAlertIds.size(); i++) {
            if (i > 0) ids.append(",");
            ids.append("\"").append(rawAlertIds.get(i)).append("\"");
        }
        return "{\"tool\":\"" + parts[0] + "\",\"project\":\"" + parts[1] + "\",\"smell\":\"" + parts[2]
                + "\",\"method_id\":\"" + parts[3] + "\",\"raw_alert_count\":" + rawAlertIds.size()
                + ",\"raw_alert_ids\":[" + ids + "]}";
    }

    /** Parser minimo para o formato JSONL controlado descrito acima (sem dependencias externas). */
    private static List<Map<String, String>> readJsonl(List<String> lines) {
        List<Map<String, String>> result = new ArrayList<>();
        for (String line : lines) {
            String trimmed = line.replace("\uFEFF", "").trim();
            if (trimmed.isEmpty()) continue;
            result.add(parseFlatJsonObject(trimmed));
        }
        return result;
    }

    private static Map<String, String> parseFlatJsonObject(String json) {
        Map<String, String> map = new LinkedHashMap<>();
        String body = json.trim();
        if (body.startsWith("{")) body = body.substring(1);
        if (body.endsWith("}")) body = body.substring(0, body.length() - 1);
        int i = 0;
        int n = body.length();
        while (i < n) {
            while (i < n && (body.charAt(i) == ',' || Character.isWhitespace(body.charAt(i)))) i++;
            if (i >= n) break;
            if (body.charAt(i) != '"') break;
            int keyStart = ++i;
            while (i < n && body.charAt(i) != '"') i++;
            String key = body.substring(keyStart, i);
            i++; // fecha aspas da chave
            while (i < n && (body.charAt(i) == ':' || Character.isWhitespace(body.charAt(i)))) i++;
            String value;
            if (i < n && body.charAt(i) == '"') {
                int valStart = ++i;
                StringBuilder sb = new StringBuilder();
                while (i < n && body.charAt(i) != '"') {
                    if (body.charAt(i) == '\\' && i + 1 < n) {
                        sb.append(body.charAt(i + 1));
                        i += 2;
                    } else {
                        sb.append(body.charAt(i));
                        i++;
                    }
                }
                value = sb.toString();
                i++; // fecha aspas do valor
            } else {
                int valStart = i;
                while (i < n && body.charAt(i) != ',') i++;
                value = body.substring(valStart, i).trim();
            }
            map.put(key, value);
        }
        return map;
    }

    private static void runSelfTest() {
        List<Map<String, String>> raw = new ArrayList<>();
        raw.add(mapOf("tool", "sonarqube", "project", "p1", "smell", "long_method",
                "method_id", "m::A::foo()", "raw_alert_id", "sq-issue-1"));
        // mesma combinacao tool+project+smell+method_id, raw_alert_id diferente (re-execucao) -> deve colapsar.
        raw.add(mapOf("tool", "sonarqube", "project", "p1", "smell", "long_method",
                "method_id", "m::A::foo()", "raw_alert_id", "sq-issue-2"));
        // tool diferente, mesmo metodo/smell -> NAO deve colapsar com os de cima (chave inclui tool).
        raw.add(mapOf("tool", "pmd", "project", "p1", "smell", "long_method",
                "method_id", "m::A::foo()", "raw_alert_id", "pmd-violation-1"));
        // metodo diferente -> grupo proprio.
        raw.add(mapOf("tool", "sonarqube", "project", "p1", "smell", "long_method",
                "method_id", "m::A::bar()", "raw_alert_id", "sq-issue-3"));
        // smell diferente no mesmo metodo/tool -> grupo proprio (nao e o mesmo tipo de alerta).
        raw.add(mapOf("tool", "sonarqube", "project", "p1", "smell", "long_parameter_list",
                "method_id", "m::A::foo()", "raw_alert_id", "sq-issue-4"));

        DedupResult result = dedupe(raw);

        boolean rawTotalOk = result.rawTotal == 5;
        boolean uniqueTotalOk = result.groups.size() == 4;
        String sonarFooKey = "sonarqube::p1::long_method::m::A::foo()";
        boolean sonarFooAbsorbedTwo = result.groups.containsKey(sonarFooKey)
                && result.groups.get(sonarFooKey).size() == 2
                && result.groups.get(sonarFooKey).contains("sq-issue-1")
                && result.groups.get(sonarFooKey).contains("sq-issue-2");
        boolean pmdFooSeparate = result.groups.containsKey("pmd::p1::long_method::m::A::foo()")
                && result.groups.get("pmd::p1::long_method::m::A::foo()").size() == 1;

        System.out.println("self_test_raw_total_5=" + rawTotalOk);
        System.out.println("self_test_unique_total_4=" + uniqueTotalOk);
        System.out.println("self_test_sonar_foo_absorve_dois_raw_alerts=" + sonarFooAbsorbedTwo);
        System.out.println("self_test_pmd_foo_nao_colapsa_com_sonar=" + pmdFooSeparate);

        boolean pass = rawTotalOk && uniqueTotalOk && sonarFooAbsorbedTwo && pmdFooSeparate;
        System.out.println(pass ? "SELF_TEST_RESULT=PASS" : "SELF_TEST_RESULT=FAIL");
        if (!pass) System.exit(1);
    }

    private static Map<String, String> mapOf(String... kv) {
        Map<String, String> m = new LinkedHashMap<>();
        for (int i = 0; i < kv.length; i += 2) m.put(kv[i], kv[i + 1]);
        return m;
    }
}
