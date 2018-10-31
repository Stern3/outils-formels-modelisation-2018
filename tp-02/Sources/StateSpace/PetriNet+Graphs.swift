extension PetriNet {

  /// Computes the marking graph of this Petri net, starting from the given marking.
  ///
  /// This method computes the marking graph of the Petri net, assuming it is bounded, and returns
  /// the root of the marking graph. If the model isunbounded, the function returns nil.
  public func computeMarkingGraph(from initialMarking: Marking<Place, Int>) -> MarkingNode<Place>? {

     // root est déclarée en tant que marquage initial
     let root = MarkingNode(marking: initialMarking)
     var created = [root]  // va stocker tous les noeuds qui vont être crées en tirant les différentes transitions
     //  unprocessed va stocker tous les noeuds et leur prédecesseurs attention: la racine n'a pas de prédecesseur
     var unprocessed: [(MarkingNode<Place>, [MarkingNode<Place>])] = [(root, [])]

      // Fait une boucle qui agit tant que l'on trouve un marquage dans la dernière valeur de la liste unprocessed
     while let (node, predecessors) = unprocessed.popLast() {


       for transition in transitions {

           //  guard teste si chaque transition est tirable depuis chaque marquage que l'on trouve grâce à l'étape précédente (boucle while)
          // Un nouveau marquage "newMarking" est alors obtenu après avoir tiré une transition
         guard let newMarking = transition.fire(from: node.marking)
           else { continue } // continue de travailler même si la création du nouveau marquage n'est pas possible (transition non tirable)

          // On recherche si "newMarking" a déjà été créé au préalable
         if let successor = created.first(where : { other in other.marking == newMarking }) {  // la fonction first(where:) retourne le premier élément qui satisfait une certaine condition
           //  On ajoute "newMarking" à la liste des successeurs du marquage
           node.successors[transition] = successor

           // On teste si "newMarking" représente la borne supérieure de tous les marquages explorés jusque là (nbr de jetons dans chaque place du marquage)
         } else if predecessors.contains(where : { other in newMarking > other.marking }) {
              return nil // Dans le cas où le réseau est non borné

         } else { // Réseau borné

           // On crée "successor" utilisant la valeur de newMarking en tant que successeur du marquage
           let successor = MarkingNode(marking: newMarking)
           // On ajoute "successor" à la liste de noeuds crées
           created.append(successor)
           // On ajoute "successor" ainsi que ses predecesseurs à la liste de noeuds(unprocessed)
           unprocessed.append((successor, predecessors + [node]))
           // On ajoute "successor" à la liste de successeurs du marquage
           node.successors[transition] = successor
         }
       }
     }

     return root // Marquage initial avec racine et successeurs
   }



  /// Computes the coverability graph of this Petri net, starting from the given marking.
  ///
  /// This method computes the coverability graph of the Petri net, and returns its root. Note that
  /// if the model's bound, the coverability graph is actually equivalent to the marking one.
  public func computeCoverabilityGraph(from initialMarking: Marking<Place, Int>)
  -> CoverabilityNode<Place>?{

    // root est déclarée en tant que marquage initial etendu(extended)
  let root = CoverabilityNode(marking: extend(initialMarking))
  var created = [root] // va stocker tous les noeuds crées
  //  unprocessed va stocker tous les noeuds et leur prédecesseurs attention: la racine n'a pas de prédecesseur
  var unprocessed: [(CoverabilityNode<Place>, [CoverabilityNode<Place>])] = [(root, [])]

    // Fait une boucle qui agit tant que l'on trouve un marquage dans la dernière valeur de la liste unprocessed
  while let (node, predecessors) = unprocessed.popLast() {

    for transition in transitions {

      //  guard teste si chaque transition est tirable depuis chaque marquage que l'on trouve grâce à l'étape précédente (boucle while)
      // Un nouveau marquage "newMarking" est alors obtenu après avoir tiré la transition
      guard var newMarking = transition.fire(from: node.marking)
        else { continue } // continue de travailler même si la création du nouveau marquage n'est pas possible (transition non tirable)
        /*
           # --------------------------------------------------------------------------
           # TEST ALL PREVIOUS MARKINGS == PREDECESSORS
           # --------------------------------------------------------------------------
           */
       // On teste si "newMarking" représente la borne supérieure de tous les marquages explorés jusque là (nbr de jetons dans chaque place du marquage
      if let predecessor = predecessors.first(where: {other in other.marking < newMarking})  {

        for place in Place.allCases {
          // On vérifie pour chaque place du "newMarking" si il y a un nombre de jetons plus élevé que dans le marquage précédent(predecesseur)
          if predecessor.marking[place] < newMarking[place] {
            newMarking[place] = .omega // On attribue la valeur omega à la place qui contenait le plus de jetons(borne)
          }
        }
      }
      /*
      # --------------------------------------------------------------------------
      # TEST UNPROCESSED CURRENT NODE
      # --------------------------------------------------------------------------
      */
        // On teste si "newMarking" représente la borne supérieure du marquage
      if node.marking < newMarking {

        for place in Place.allCases {
          // On vérifie s'il y a un nbr supérieur de jetons dans chaque place place du "newMarking" par rapport à notre marquage
          if node.marking[place] < newMarking[place] {
            newMarking[place] = .omega // On attribue la valeur omega à la place qui contenait le plus de jetons(borne)
          }
        }
      }

      // Recherche si "newMarking" a déjà été créé au préalable
      if let successor = created.first(where : { other in other.marking == newMarking }) {
        //  On ajoute "newMarking" à la liste des successeurs du marquage
        node.successors[transition] = successor
      } else {
        // On crée "successor" utilisant la valeur de newMarking en tant que successeur du marquage
        let successor = CoverabilityNode(marking: newMarking)
        // On ajoute "successor" à la liste de noeuds crées
        created.append(successor)
         // On ajoute "successor" ainsi que ses predecesseurs à la liste de noeuds(unprocessed)
        unprocessed.append((successor, predecessors + [node]))
         // On ajoute "successor" à la liste de successeurs du marquage
        node.successors[transition] = successor
      }
    }
  }

  return root // Marquage initial avec racine et successeurs
}

  /// Converts a regular marking into a marking with extended integers.
  private func extend(_ marking: Marking<Place, Int>) -> Marking<Place, ExtendedInt> {
    return Marking(
      uniquePlacesWithValues: marking.map({
        ($0.place, ExtendedInt.concrete($0.value))
      }))
  }




}
