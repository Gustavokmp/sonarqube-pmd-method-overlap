package fixtures.s107;

import javax.ws.rs.GET;

/**
 * Metodo com 8 parametros anotado com @GET (JAX-RS, pacote javax.ws.rs).
 * Consta em METHOD_ANNOTATION_EXCEPTIONS ("javax.ws.rs.GET"). Esperado:
 * NAO SINALIZA.
 */
public class JaxRsJavaxGet {

    @GET
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
