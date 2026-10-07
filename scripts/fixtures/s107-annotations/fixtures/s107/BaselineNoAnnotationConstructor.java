package fixtures.s107;

/**
 * Caso de controle 2: construtor com 8 parametros, sem nenhuma anotacao.
 * java:S107 usa constructorMax (default tambem 7, nao alterado no
 * experimento). Esperado: SINALIZA.
 */
public class BaselineNoAnnotationConstructor {

    public BaselineNoAnnotationConstructor(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
