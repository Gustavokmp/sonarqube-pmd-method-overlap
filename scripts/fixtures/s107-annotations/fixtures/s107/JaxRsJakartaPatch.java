package fixtures.s107;

import jakarta.ws.rs.PATCH;

/**
 * Metodo com 8 parametros anotado com @PATCH (JAX-RS, pacote jakarta.ws.rs).
 * Consta em METHOD_ANNOTATION_EXCEPTIONS ("jakarta.ws.rs.PATCH"). Esperado:
 * NAO SINALIZA.
 */
public class JaxRsJakartaPatch {

    @PATCH
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
