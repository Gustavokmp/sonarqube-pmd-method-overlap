package org.springframework.web.bind.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/** Stub local (nao e a biblioteca Spring MVC real). Usada para testar a
 * hipotese (documentada em STATUS.md antes desta validacao) de que esta
 * anotacao seria uma excecao nativa do java:S107 -- NAO consta em
 * METHOD_ANNOTATION_EXCEPTIONS no codigo-fonte real da regra. */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.TYPE})
public @interface RequestMapping {
    String value() default "";
}
