package repro;

// Minimal repro: a package-local interface that shadows java.lang.Cloneable.
public interface Cloneable<T> {
	T cloneIt();
}
