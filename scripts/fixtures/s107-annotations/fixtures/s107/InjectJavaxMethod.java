package fixtures.s107;

import javax.inject.Inject;

/**
 * Metodo (nao construtor) com 8 parametros anotado com @Inject (pacote
 * javax.inject). Consta em METHOD_ANNOTATION_EXCEPTIONS
 * ("javax.inject.Inject"). Esperado: NAO SINALIZA.
 */
public class InjectJavaxMethod {

    @Inject
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
