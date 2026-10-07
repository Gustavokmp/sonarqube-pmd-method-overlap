package fixtures.s107;

import org.springframework.web.bind.annotation.GetMapping;

/**
 * Metodo com 8 parametros anotado com @GetMapping (atalho Spring MVC de
 * @RequestMapping). Tambem NAO consta em METHOD_ANNOTATION_EXCEPTIONS no
 * codigo-fonte real da regra. Esperado: SINALIZA.
 */
public class SpringGetMappingShortcut {

    @GetMapping("/x")
    public void handle(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
