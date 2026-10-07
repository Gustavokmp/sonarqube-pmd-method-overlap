package fixtures.s107;

import lombok.Builder;

/**
 * Construtor com 8 parametros anotado com @Builder (Lombok). Consta em
 * METHOD_ANNOTATION_EXCEPTIONS ("lombok.Builder"). Esperado: NAO SINALIZA.
 */
public class LombokBuilderConstructor {

    @Builder
    public LombokBuilderConstructor(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
