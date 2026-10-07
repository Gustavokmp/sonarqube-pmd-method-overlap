package lombok;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/** Stub local (nao e a biblioteca Lombok real). FQN presente em
 * METHOD_ANNOTATION_EXCEPTIONS ("lombok.Builder"). */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.METHOD, ElementType.CONSTRUCTOR})
public @interface Builder {
}
