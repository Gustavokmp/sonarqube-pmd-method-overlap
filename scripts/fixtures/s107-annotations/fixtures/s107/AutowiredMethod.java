package fixtures.s107;

import org.springframework.beans.factory.annotation.Autowired;

/**
 * Metodo (nao construtor) com 8 parametros anotado com @Autowired. A
 * excecao da regra se aplica igualmente a metodos e construtores
 * (usesAuthorizedAnnotation nao distingue). Esperado: NAO SINALIZA.
 */
public class AutowiredMethod {

    @Autowired
    public void setDependencies(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
