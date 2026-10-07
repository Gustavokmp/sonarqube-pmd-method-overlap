package fixtures.s107;

import fixtures.s107.probes.ProbeMapping;

/** Controle: anotacao customizada com elemento "value()" com default (mesma
 * forma de uso de @RequestMapping("/x")), que NAO consta em
 * METHOD_ANNOTATION_EXCEPTIONS. Esperado (se a resolucao de simbolo
 * funcionar normalmente, isolando o efeito do pacote real do Spring):
 * SINALIZA. */
public class ProbeMappingControl {

    @ProbeMapping("/x")
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
