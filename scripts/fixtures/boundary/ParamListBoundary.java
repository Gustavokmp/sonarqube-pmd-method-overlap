package fixtures.boundary;

/**
 * Fixture sintetico para validar as fronteiras exatas de:
 * - java:S107 (max=7 parametros em metodos)
 * - PMD ExcessiveParameterList (minimum=10 parametros)
 *
 * Nomes indicam a quantidade exata de parametros do metodo.
 */
public class ParamListBoundary {

    public void params5(int p1, int p2, int p3, int p4, int p5) {
        System.out.println(p1);
    }

    public void params6(int p1, int p2, int p3, int p4, int p5, int p6) {
        System.out.println(p1);
    }

    public void params7(int p1, int p2, int p3, int p4, int p5, int p6, int p7) {
        System.out.println(p1);
    }

    public void params8(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }

    public void params9(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9) {
        System.out.println(p1);
    }

    public void params10(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9, int p10) {
        System.out.println(p1);
    }

    public void params11(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9, int p10, int p11) {
        System.out.println(p1);
    }

    public void params12(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9, int p10, int p11, int p12) {
        System.out.println(p1);
    }
}
