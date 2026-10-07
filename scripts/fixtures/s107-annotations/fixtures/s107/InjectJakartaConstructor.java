package fixtures.s107;

import jakarta.inject.Inject;

/**
 * Construtor com 8 parametros anotado com @Inject (pacote jakarta.inject).
 * Consta em METHOD_ANNOTATION_EXCEPTIONS ("jakarta.inject.Inject").
 * Esperado: NAO SINALIZA.
 */
public class InjectJakartaConstructor {

    @Inject
    public InjectJakartaConstructor(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
