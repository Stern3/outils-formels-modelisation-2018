extension PetriNet {

  /// Computes the marking graph of this Petri net, starting from the given marking.
  ///
  /// This method computes the marking graph of the Petri net, assuming it is bounded, and returns
  /// the root of the marking graph. If the model isunbounded, the function returns nil.
  public func computeMarkingGraph(from initialMarking: Marking<Place, Int>) -> MarkingNode<Place>? {

    let root = MarkingNode(marking: initialMarking) //on crée le noeud initial et on lui attribut le marquage initial

        var created = [root] // on crée un vecteur contenant des differents neouds

        var unprocessed : [(MarkingNode<Place>,[MarkingNode<Place>])] = [(root,[])] // on definit une liste contenant des noeuds qui n'ont pas encore été etiquetter

        while let (node, predecessors) = unprocessed.popLast(){

        // on fait une boucle pour voir si  le reseau est bornée

        for transition in transitions { // on parcours toutes les transitions

        guard let newmarking = transition.fire(from: node.marking) //
else { continue }

if let successor = created.first(where: {element in element.marking == newmarking})  {  // on regarde si on a deja le marquage dans la liste
		          node.successors[transition] = successor
		        }
            else if predecessors.contains(where : {element in element.marking < newmarking}) {  // on regarde si le marquage contient deja un marquage
		          return  nil // si la reponse et oui  alors on envoie null et donc le reseau est bornée
		        }
            else
            { //on ajoute les marquage et les successeurs dans la liste
		           let successor = MarkingNode(marking: newmarking)
		           created.append(successor)
		           unprocessed.append((successor, predecessors + [node]))
		           node.successors[transition] = successor //
		        }
		      }
        }

    return root
  }

  /// Computes the coverability graph of this Petri net, starting from the given marking.
  ///
  /// This method computes the coverability graph of the Petri net, and returns its root. Note that
  /// if the model's bound, the coverability graph is actually equivalent to the marking one.
  public func computeCoverabilityGraph(from initialMarking: Marking<Place, Int>)
    -> CoverabilityNode<Place>?
  {
    // TODO: Replace or modify this code with your own implementation.
    let root = CoverabilityNode(marking: extend(initialMarking))
    var vertices: [CoverabilityNode<Place>] = [root]
        var toBeProcessed: [(CoverabilityNode<Place>, [CoverabilityNode<Place>])] = [(root, [])] // root doesn't have predecessors
        while let (currentVertex, preds) = toBeProcessed.popLast() // while we still have smth to process
        {
          for transition in transitions
          {
            if var markingAfterFire = transition.fire(from: currentVertex.marking) // if this transition is fireable from this marking
            {
              if let pred = preds.first(where: {markingAfterFire > $0.marking})
              {
                for place in Place.allCases
                {
                  if (markingAfterFire[place] > pred.marking[place]) // if this marking is contained in another marking, and that one is smaller, then the model is unbounded, and we put omegas
                  {
                    markingAfterFire[place] = .omega
                  }
                }
              }

              if (markingAfterFire > currentVertex.marking)
              {
                for place in Place.allCases
                {
                  if (markingAfterFire[place] > currentVertex.marking[place]) // same thing here, but with the current vertex
                  {
                    markingAfterFire[place] = .omega
                  }
                }
              }

              if let succ = vertices.first(where: {$0.marking == markingAfterFire})
              {
                currentVertex.successors[transition] = succ // same as for marking graph
              }

              else // again, same as for marking graph
              {
                let newVertex = CoverabilityNode(marking: markingAfterFire)
                toBeProcessed.append((newVertex, preds + [currentVertex]))
                vertices.append(newVertex)
                currentVertex.successors[transition] = newVertex
              }

            }
          }

        }

        return root
    }

  /// Converts a regular marking into a marking with extended integers.
  private func extend(_ marking: Marking<Place, Int>) -> Marking<Place, ExtendedInt> {
    return Marking(
      uniquePlacesWithValues: marking.map({
        ($0.place, ExtendedInt.concrete($0.value))
      }))
  }

}
