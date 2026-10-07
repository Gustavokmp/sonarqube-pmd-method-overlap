package fixtures.boundary;

public class LocalEnumRepro {

	public void method() {
		enum Unit { day, hour, minute }
		Unit u = Unit.day;
		System.out.println(u);
	}
}
