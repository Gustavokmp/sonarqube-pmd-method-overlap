package fixtures.s107;

import io.micronaut.http.annotation.Get;

/**
 * Metodo com 8 parametros anotado com @Get (Micronaut). Consta em
 * METHOD_ANNOTATION_EXCEPTIONS ("io.micronaut.http.annotation.Get").
 * Esperado: NAO SINALIZA.
 */
public class MicronautGet {

    @Get
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
