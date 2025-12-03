// RackModel.sysml
package RackModel {

  part def Rack;
  part def Equipment;

  // Usage showing equipment as parts of the rack
  part RackA1 : Rack {
    part Server01 : Equipment;
    part Server02 : Equipment;
    part Switch01 : Equipment;
  }

  // Multiplicity example (conceptual)
  part RackA2 : Rack {
    part Servers[4] : Equipment;
  }
}

