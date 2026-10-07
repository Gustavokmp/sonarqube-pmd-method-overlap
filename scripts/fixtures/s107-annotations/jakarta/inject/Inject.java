package jakarta.inject;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/** Stub local (nao e a biblioteca jakarta.inject real). FQN presente em
 * METHOD_ANNOTATION_EXCEPTIONS ("jakarta.inject.Inject"). */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.CONSTRUCTOR, ElementType.FIELD})
public @interface Inject {
}
