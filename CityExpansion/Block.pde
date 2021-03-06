import java.util.*;


//extra care is taken not to rely on rectangular blocks
public class Block implements Comparable<Block> {
    LinkedList<Vertex> corners;  //this is necessary to maintain ordering
    //vertices must always be stored in consecutive order, this is a precondition and not gauranteed by any internal workings of the class

    
    public Block() {
	corners = new LinkedList<Vertex>();
    }
    
    public Block(Collection<Vertex> c) {
	this();
	for (Vertex v: c)
	    corners.addLast(v);
	normalize();
    }

    //gaurantees that the same perimeter of locations has the same representation
    public void normalize() {

	//make sure min element is first (fix cycling)
	Vertex v = Collections.min(corners);
	while (corners.getFirst() != v)
	    corners.addLast(corners.removeFirst());

	//make sure second-min element is second (fix mirroring)
	if (corners.get(1).compareTo(corners.getLast()) > 0) {
	    Collections.reverse(corners);
	    corners.addFirst(corners.removeLast());
	}
    }
	

    @Override
    public boolean equals(Object o) {
	if (!(o instanceof Block)) return false;
	Block b = (Block) o;
	return this.hashCode() == b.hashCode();
    }

    @Override
    public int hashCode() {
	int code=0;
	int shift=0;
	for (Vertex v: corners)
	    code += v.hashCode()<<(shift++);
	return code;
    }

    @Override
    public int compareTo(Block other) {
	return hashCode() - other.hashCode();
    }

    //mainly for testing
    public void print(int grey) {
	fill(grey);
	beginShape();
	for (Vertex v: corners)
	    vertex(v.x(), v.y());
	endShape(CLOSE);
    }

    public void print() {
	print(0);
    }

    @Override
    public String toString() {
	String out = "";
	for (Vertex v: corners)
	    out += v + "\n";
	return out;
    }
}


