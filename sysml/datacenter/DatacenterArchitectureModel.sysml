// DatacenterArchitectureModel.sysml
package DatacenterArchitecture {

  block def Datacenter;
  part def Room;
  part def Rack;
  part def Equipment;

  // Example composition
  part DatacenterA : Datacenter {
    part Room1 : Room {
      part RackA1 : Rack;
      part RackA2 : Rack;
    }
    part Room2 : Room {
      part RackB1 : Rack;
    }
  }

  // Example rack content
  part RackA1 : Rack {
    part Server01 : Equipment;
    part Server02 : Equipment;
    part Switch01 : Equipment;
  }

  part RackB1 : Rack {
    // empty to start
  }
}

