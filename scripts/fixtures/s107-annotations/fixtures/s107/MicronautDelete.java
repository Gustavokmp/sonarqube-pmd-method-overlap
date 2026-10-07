package fixtures.s107;

import io.micronaut.http.annotation.Delete;

/**
 * Metodo com 8 parametros anotado com @Delete (Micronaut). Consta em
 * METHOD_ANNOTATION_EXCEPTIONS ("io.micronaut.http.annotation.Delete").
 * Esperado: NAO SINALIZA.
 */
public class MicronautDelete {

    @Delete
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
