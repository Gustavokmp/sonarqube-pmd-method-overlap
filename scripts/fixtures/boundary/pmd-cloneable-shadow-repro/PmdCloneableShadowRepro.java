package repro;

// Reproduces a PMD 7.27.0 symbol-resolution limitation: PMD resolves the
// unqualified "Cloneable<T>" reference to java.lang.Cloneable (0 type
// parameters) instead of the package-local repro.Cloneable<T> (1 type
// parameter), causing "Cannot parameterize java/lang/Cloneable with [...],
// expecting 0 type arguments" and aborting the file's analysis.
public interface PmdCloneableShadowRepro extends Cloneable<PmdCloneableShadowRepro> {
	void doSomething();
}
