package fixtures.s107;

/**
 * Caso de controle 1: metodo com 8 parametros, sem nenhuma anotacao, sem
 * override. Esperado por java:S107 (max=7): SINALIZA.
 */
public class BaselineNoAnnotationMethod {

    public int sum(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        return p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8;
    }
}
