// ClusterArchitectureModel.sysml
package ClusterArchitecture {

  block def Infrastructure;
  part def Hardware;
  part def OperatingSystem;
  part def Virtualization;
  part def Network;
  part def Service;
  part def Cluster;

  // Hardware realized by Datacenter
  part InfraA : Infrastructure {
    part HW : Hardware;
    part OS : OperatingSystem;
    part Virt : Virtualization;
    part Net : Network;
    part Svc : Service;
    part Clus : Cluster;
  }

  // Logical build-up relationships
  HW   -> OS   : supports;
  OS   -> Virt : hosts;
  Virt -> Net  : provides;
  Net  -> Svc  : enables;
  Svc  -> Clus : composes;
}

