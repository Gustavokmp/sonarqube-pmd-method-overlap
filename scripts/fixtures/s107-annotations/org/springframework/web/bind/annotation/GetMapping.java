package org.springframework.web.bind.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/** Stub local (nao e a biblioteca Spring MVC real). Atalho de
 * @RequestMapping -- tambem NAO consta em METHOD_ANNOTATION_EXCEPTIONS no
 * codigo-fonte real da regra. */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface GetMapping {
    String value() default "";
}
