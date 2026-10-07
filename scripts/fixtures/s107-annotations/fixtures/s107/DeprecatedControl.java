package fixtures.s107;

/** Controle: anotacao do proprio JDK (sempre resolvivel via bootclasspath,
 * independente de sonar.java.libraries), que NAO consta em
 * METHOD_ANNOTATION_EXCEPTIONS. Esperado: SINALIZA. */
public class DeprecatedControl {

    @Deprecated
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
