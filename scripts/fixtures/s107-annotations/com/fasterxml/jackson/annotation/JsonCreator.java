package com.fasterxml.jackson.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Stub local (NAO e a biblioteca Jackson real - sonar.java.libraries fica
 * ausente, como nas execucoes reais do experimento). Mesmo nome totalmente
 * qualificado usado em METHOD_ANNOTATION_EXCEPTIONS de
 * org.sonar.java.checks.TooManyParametersCheck (codigo-fonte verificado em
 * 2026-10-01 via raw.githubusercontent/jsdelivr do repositorio
 * SonarSource/sonar-java).
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.CONSTRUCTOR})
public @interface JsonCreator {
}
