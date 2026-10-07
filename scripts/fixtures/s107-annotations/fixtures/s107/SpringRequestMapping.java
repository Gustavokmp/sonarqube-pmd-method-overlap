package fixtures.s107;

import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Metodo com 8 parametros anotado com @RequestMapping (Spring MVC).
 * Hipotese anterior (STATUS.md, baseada em documentacao geral, nao no
 * codigo-fonte da regra): esta anotacao seria tratada como excecao nativa
 * do java:S107. Verificacao no codigo-fonte real de
 * org.sonar.java.checks.TooManyParametersCheck (METHOD_ANNOTATION_EXCEPTIONS)
 * mostra que ela NAO consta na lista. Esperado: SINALIZA.
 */
public class SpringRequestMapping {

    @RequestMapping("/x")
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
