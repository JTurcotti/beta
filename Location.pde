import java.util.*;

public class Location {
    int x, y;

    public Location(int x, int y) {
	this.x = x;
	this.y = y;
    }

    /* 0-down
       1-right
       2-up
       3-left
    */
    public void push(int direction, int step) {
	if (direction > 1)
	    step *= -1;
	if (direction%2 == 0)
	    y += step;
	else
	    x += step;
    }

    @Override
    public String toString() {
	return "(" + this.x + ", " + this.y + ")";
    }

    @Override
    public boolean equals(Object o) {
	if (!(o instanceof Location)) return false;
	Location l = (Location) o;
	return (l.x == this.x) && (l.y == this.y);
    }

    @Override
    public int hashCode() {
	return x<<16 + y;
    }
}