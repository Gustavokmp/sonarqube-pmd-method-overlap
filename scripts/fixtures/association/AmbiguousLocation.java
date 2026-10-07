package fixtures.association;

/**
 * Fixture sintetico para validar o estado "ambiguous" da associacao por
 * localizacao (PROTOCOLO.md secao 13): duas unidades irmas (sem relacao de
 * aninhamento entre si) reivindicam a MESMA linha fisica, porque o relato
 * bruto da ferramenta so informa o numero da linha (sem coluna), tornando
 * impossivel decidir qual delas foi de fato sinalizada.
 *
 * Nao faz parte de nenhum projeto estudado (protocolo secao 16).
 */
public class AmbiguousLocation {

    public void sibling1() { int a = 1; } public void sibling2() { int b = 2; }
}
