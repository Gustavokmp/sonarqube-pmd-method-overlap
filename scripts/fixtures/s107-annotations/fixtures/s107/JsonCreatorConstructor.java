package fixtures.s107;

import com.fasterxml.jackson.annotation.JsonCreator;

/**
 * Construtor com 8 parametros anotado com @JsonCreator (Jackson). Consta
 * em METHOD_ANNOTATION_EXCEPTIONS ("com.fasterxml.jackson.annotation.JsonCreator").
 * Esperado: NAO SINALIZA.
 */
public class JsonCreatorConstructor {

    @JsonCreator
    public JsonCreatorConstructor(int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8) {
        System.out.println(p1);
    }
}
