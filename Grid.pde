import java.util.*;

public class Grid {
    //list of 4 vertex queues, corresponding to the four directions (see Vertex)
    List<Queue<Vertex>> directions;
    
    //locations already included in this grid, maps locations to the vertex associated with them
    Map<Location, Vertex> places;
    
    //actual Vertex instances
    //Set<Vertex> vertices; replace by vertices() method

    List<Vertex> fresh; //each grow cycle, stores new tips
    
    Vertex root;
    
    static final int step = 30;  //growth of brances each step
    static final float chance = 0.5;  //chance of sprouting new branch each step

    //null constructor for testing only, never use
    public Grid() {}
    
    public Grid(Vertex root) {
	this.root = root;
	directions = new ArrayList<Queue<Vertex>>();
        places = new HashMap<Location, Vertex>();
	places.put(root.location(), root);
	for (int i=0; i<4; i++) {
	    Queue<Vertex> direction = new ArrayDeque<Vertex>();
	    directions.add(direction);
	    Vertex v = new Vertex(root);
	    direction.add(v);
	} //creates direction queues, each with one linked copy of the root

	println("grid constructed");
    }

    public Collection<Vertex> vertices() {
	return places.values();
    }

    public Set<Vertex> movingTips() {
	Set<Vertex> set = new HashSet<Vertex>();
	for (Queue<Vertex> direction: directions)
	    for (Vertex v: direction)
		set.add(v);
	return set;
    }

    //checks if the position of a vertex is unoccupied and within the viewing space
    private boolean valid(Vertex v) {
	return !places.containsKey(v.loc) &&
	    v.x() < width &&
	    v.x() > 0 &&
	    v.y() < height &&
	    v.y() > 0;
    }

    //tests if grid is clear in a given direction for a given distance from v
    private boolean clearInDirection(int direction, int dist, Vertex v) {
	Location w = v.location();
	while (dist-->0) {
	    w.push(direction, 1);
	    if (places.containsKey(w))
		return false;
	}
	return true;
    }

    //non-deterministic, determines conditions to procedd tip in directiton without sprouting
    boolean proceed(int direction, Vertex tip) {
	return (random(1)>chance || //probably occurs
		tip.age++ < 2 || //or if too young to have a kid
		(tip.age > 100) && (tip.age<105) || //or if just had a kid
		!clearInDirection(direction, step*2, tip)); //or if too close
    }

    boolean stationary(Vertex v) {
	return !movingTips().contains(v);
    }
	
    private void interupt(Vertex tip) {
	//bar-<----tip-<----bar.parent (par)
	Vertex bar = places.get(tip.loc);
	if (bar.loc.equals(tip.loc) && stationary(bar)) {//hit a stationary vertex
	    Vertex parent = tip.neighbors.getFirst();
	    parent.add(bar); //attach prior node to hit one
	    parent.remove(tip); //destroy tip
	} else {
	    Vertex par = bar.neighbors.getFirst(); //note that because neighbors are a list, the first one will be the parent (possibly 2 too)
	    if (par.distance(tip) + tip.distance(bar) == par.distance(bar)) { //check to make sure tip is between bar and par
		
		bar.neighbors.addFirst(tip); //just switch around all the various parenthoods
		
	    } else { //this means bar has a second parent
		
		par = bar.neighbors.get(1); //try second possible parent
		
		bar.neighbors.add(1, tip); //this is the only diff from before
		
	    }
	    tip.neighbors.add(bar); //finish switching neighbors and parents
	    bar.remove(par);
	    tip.neighbors.add(1, par);
	    par.neighbors.add(tip);		

	}
    }
    
    List<Vertex> grow() { //returns moved/new Vertices
	fresh = new ArrayList<Vertex>();
	
	directions: for (int i=0; i<4; i++) {
	    Queue<Vertex> direction = directions.get(i);
	    tips: for (int j = direction.size(); j>0; j--) {
		Vertex tip = direction.remove(); //pull a tip
		
		if (proceed(i, tip)) {
			
		    //don't sprout new tip
		    tip.push(i, step);
		    fresh.add(tip);
		    
		    if (valid(tip))// if tip in a valid position
			direction.add(tip);// cycle back to end of queue
		    if (places.containsKey(tip.loc))//if hit a line
			interupt(tip);
		    
		} else {
		    //sprout new tips (3)
		    for (int k=0; k<4; k++)  { //directions
			if (i-k!=2 && k-i!=2) { //don't sprout in opposite of current direction
			    Queue<Vertex> direction2 = directions.get(k);
			    
			    Vertex tip2 = new Vertex(tip);
			    
			    if (i==k)
				tip2.age = 100; //the sprout that continues in the same direction skips a generation
			    
			    fresh.add(tip2);
			    direction2.add(tip2);
			} //add a linked copy to each OTHER direction (old tip stops growing)
		    }
		}
	    }
	}
	
	for (Vertex tip: fresh)
	    //mark new tips as occupied
	    places.put(tip.location(), tip);
	
	return fresh;
    }
    
    public void print() {
	root.printNet();
    }
    
    public int size() {
	int size = 0;
	for (Queue<Vertex> q: directions)
	    size += q.size();
	return size;
    }

}

