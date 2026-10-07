package io.micronaut.http.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/** Stub local (nao e a biblioteca Micronaut real). FQN presente em
 * METHOD_ANNOTATION_EXCEPTIONS ("io.micronaut.http.annotation.Get"). */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Get {
    String value() default "/";
}
