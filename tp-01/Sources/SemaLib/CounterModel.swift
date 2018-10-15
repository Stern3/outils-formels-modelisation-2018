// Create places
let p0 = Place("p0")
let p1 = Place("p1")
let p2 = Place("p2")
let b0 = Place("b0")
let b1 = Place("b1")
let b2 = Place("b2")

// Create transitions
let t0 = Transition("t0")
let t1 = Transition("t1")
let t2 = Transition("t2")
let t3 = Transition("t3")

// Define the preconditions of a simple Petri net.
func pre(p: Place, t: Transition) -> Nat {
    switch (p, t) {
      case (p0, t0): return 1
      case (b0, t1): return 1
      case (p1, t1): return 1
      case (b0, t2): return 1
      case (b1, t2): return 1
      case (p2, t2): return 1
      case (b0, t3): return 1
      case (b1, t3): return 1
      case (b2, t3): return 1
      default: return 0
    }
}

// Define the postconditions of a simple Petri net.
func post(p: Place, t: Transition) -> Nat {
    switch (p, t) {
      case (b0, t0): return 1
      case (p0, t1): return 1
      case (b1, t1): return 1
      case (b2, t2): return 1
      case (p0, t2): return 1
      case (p1, t2): return 1
      case (p0, t3): return 1
      case (p1, t3): return 1
      case (p2, t3): return 1
      default: return 0
    }
}

// Define the initial marking of a simple Petri net.
func initialMarking(_ place: Place) -> Nat {
    switch place {
      case p0: return 1
      case p1: return 1
      case p2: return 1
      default: return 0
    }
}

/// This function creates the model of a binary counter on 3 bits.
public func createCounterModel() -> PetriNet {
    return PetriNet(places: [p0,p1,p2,b0,b1,b2], transitions: [t0,t1,t2,t3], pre: pre, post: post)
}

/// This function returns the initial marking corresponding to the model of your binary counter.
public func createCounterInitialMarking() -> Marking {
    return initialMarking
}
