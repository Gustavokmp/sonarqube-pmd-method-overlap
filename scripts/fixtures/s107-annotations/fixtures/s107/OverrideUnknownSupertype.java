package fixtures.s107;

/**
 * Caso adicional: a classe declara "implements" um tipo que NAO existe em
 * nenhum arquivo desta fixture nem e fornecido como biblioteca. Com a
 * hierarquia desconhecida, MethodTree.isOverriding() retorna null; o
 * proprio codigo-fonte da regra trata null como override ("In case of
 * unknown hierarchy, isOverriding() returns null, we return true to avoid
 * FPs"). Esperado: NAO SINALIZA.
 */
public class OverrideUnknownSupertype implements com.thirdparty.unprovided.UnknownInterface8 {

    @Override
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
