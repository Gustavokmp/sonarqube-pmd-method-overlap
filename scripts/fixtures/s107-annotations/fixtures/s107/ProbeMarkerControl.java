package fixtures.s107;

import fixtures.s107.probes.ProbeMarker;

/** Controle: anotacao customizada, conhecida (mesma arvore de fontes),
 * sem nenhum elemento, que NAO consta em METHOD_ANNOTATION_EXCEPTIONS.
 * Esperado (se a resolucao de simbolo funcionar normalmente): SINALIZA. */
public class ProbeMarkerControl {

    @ProbeMarker
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
