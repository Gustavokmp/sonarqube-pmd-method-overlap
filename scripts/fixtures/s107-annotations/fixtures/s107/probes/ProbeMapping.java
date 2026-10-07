package fixtures.s107.probes;

/** Anotacao de controle com um elemento "value()" com default, imitando a
 * forma de @RequestMapping("/x"), mas em pacote proprio (nao
 * org.springframework.*) -- isola o efeito do elemento default do efeito
 * do pacote/nome real do Spring. Nao consta em METHOD_ANNOTATION_EXCEPTIONS. */
public @interface ProbeMapping {
    String value() default "";
}
