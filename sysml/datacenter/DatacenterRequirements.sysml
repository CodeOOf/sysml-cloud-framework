// DatacenterRequirements.sysml
package DatacenterRequirements {

  requirement R_RackRedundancy {
    Id = "DC-REQ-010";
    Text = "Each rack shall have redundant power feeds (A/B).";
    refines = Rack;
  }

  requirement R_CoolingAmbient {
    Id = "DC-REQ-011";
    Text = "Rooms shall maintain < 25�C ambient temperature.";
    refines = Room;
  }

  requirement R_NetworkSegregation {
    Id = "DC-REQ-012";
    Text = "Datacenter network shall provide separate DMZ and OOB segments.";
    refines = Datacenter;
  }
}

