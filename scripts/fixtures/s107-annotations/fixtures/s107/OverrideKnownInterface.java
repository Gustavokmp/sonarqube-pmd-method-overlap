package fixtures.s107;

/**
 * Caso adicional (mecanismo descoberto na leitura do codigo-fonte real da
 * regra, nao fazia parte da lista original do prompt): TooManyParametersCheck
 * pula TODO metodo cujo MethodTree.isOverriding() nao retorne
 * explicitamente FALSE -- ou seja, qualquer override/implementacao real de
 * um tipo conhecido (interface ou classe) fica isento da regra,
 * independentemente de anotacoes e da quantidade de parametros. Esperado:
 * NAO SINALIZA, mesmo sem nenhuma anotacao da lista oficial de excecoes.
 */
public class OverrideKnownInterface implements KnownInterface8 {

    @Override
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
