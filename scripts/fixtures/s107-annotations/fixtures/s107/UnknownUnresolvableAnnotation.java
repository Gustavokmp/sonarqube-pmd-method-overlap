package fixtures.s107;

/**
 * Caso adicional (mecanismo descoberto na leitura do codigo-fonte real da
 * regra via AnnotationsHelper.hasUnknownAnnotation, nao fazia parte da
 * lista original do prompt, mas e diretamente relevante porque o
 * experimento real nao usa sonar.java.libraries): metodo com 8 parametros
 * anotado com um tipo de anotacao que NAO e declarado em nenhum arquivo
 * desta fixture nem fornecido como biblioteca. TooManyParametersCheck pula
 * QUALQUER metodo que tenha ao menos uma anotacao cujo simbolo nao seja
 * resolvido -- independentemente de essa anotacao estar ou nao na lista
 * oficial de excecoes. Esperado: NAO SINALIZA (falso negativo estrutural,
 * nao e uma excecao documentada da regra).
 */
public class UnknownUnresolvableAnnotation {

    @com.thirdparty.unprovided.NotProvidedAnnotation
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
