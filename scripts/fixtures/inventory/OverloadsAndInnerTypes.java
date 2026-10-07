package fixtures.inventory;

/**
 * Fixture sintetico para validar: overloads, tipos internos (membro, local,
 * anonimo), distincao metodo x construtor, distincao metodo x classe.
 *
 * Nao faz parte de nenhum projeto estudado (protocolo secao 16).
 */
public class OverloadsAndInnerTypes {

    // --- Overloads: mesmo nome, parametros diferentes -> ids distintos. ---
    public void process(int a) {
        System.out.println(a);
    }

    public void process(int a, int b) {
        System.out.println(a + b);
    }

    public void process(String s) {
        System.out.println(s);
    }

    public void process(String s, int... extra) {
        System.out.println(s + extra.length);
    }

    // --- Construtor: deve ser excluido do inventario. ---
    public OverloadsAndInnerTypes() {
        System.out.println("construtor, nao e metodo elegivel");
    }

    public OverloadsAndInnerTypes(int seed) {
        System.out.println(seed);
    }

    // --- Metodo sem corpo nao existe em classe concreta; ver interface abaixo. ---

    // --- Tipo membro (nested/inner, nomeado): DEVE entrar no inventario. ---
    public static class MemberType {
        public void memberMethod() {
            System.out.println("metodo de tipo membro");
        }

        // tipo membro aninhado dentro de outro tipo membro -> tambem deve entrar.
        public class DeeplyNestedMember {
            public void deepMethod() {
                System.out.println("metodo de tipo membro aninhado");
            }
        }
    }

    // --- Metodo cujo corpo declara um tipo local: o tipo local e seus
    //     metodos NAO devem aparecer no inventario; apenas localMethodHost
    //     (o metodo que o contem) deve aparecer. ---
    public void localMethodHost() {
        class LocalType {
            public void localMethod() {
                System.out.println("metodo de tipo local - deve ser excluido");
            }
        }
        new LocalType().localMethod();
    }

    // --- Metodo que cria uma classe anonima: a classe anonima e seus
    //     metodos NAO devem aparecer no inventario; apenas
    //     anonymousMethodHost deve aparecer. ---
    public void anonymousMethodHost() {
        Runnable r = new Runnable() {
            @Override
            public void run() {
                System.out.println("metodo de classe anonima - deve ser excluido");
            }
        };
        r.run();
    }
}

/**
 * Tipo top-level adicional no mesmo arquivo, incluindo uma interface para
 * validar metodo sem corpo (abstrato) e metodo default/static com corpo.
 */
interface SampleInterface {
    // metodo sem corpo -> excluido do inventario.
    void abstractMethod(int x);

    // metodo default com corpo -> incluido no inventario.
    default void defaultMethod() {
        System.out.println("default method com corpo");
    }

    // metodo static com corpo -> incluido no inventario.
    static void staticInterfaceMethod() {
        System.out.println("static method com corpo");
    }
}
