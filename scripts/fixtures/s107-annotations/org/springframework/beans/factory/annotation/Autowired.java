package org.springframework.beans.factory.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/** Stub local (nao e a biblioteca Spring real). FQN presente em
 * METHOD_ANNOTATION_EXCEPTIONS via SpringUtils.AUTOWIRED_ANNOTATION =
 * "org.springframework.beans.factory.annotation.Autowired" (codigo-fonte
 * verificado em org.sonar.java.utils.SpringUtils). */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.CONSTRUCTOR, ElementType.FIELD})
public @interface Autowired {
}
