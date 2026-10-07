package fixtures.s107;

import org.springframework.beans.factory.annotation.Autowired;

/**
 * Construtor com 8 parametros anotado com @Autowired (injecao de
 * construtor, Spring). Consta em METHOD_ANNOTATION_EXCEPTIONS via
 * SpringUtils.AUTOWIRED_ANNOTATION. Esperado: NAO SINALIZA.
 */
public class AutowiredConstructor {

    @Autowired
    public AutowiredConstructor(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
