// VirtualizationModel.sysml
package VirtualizationModel {

  part def OperatingSystem;
  part def Virtualization;
  part def VM;
  part def Container;

  part OS_Ubuntu : OperatingSystem {
    part KVM : Virtualization {
      part VM_DB     : VM;
      part VM_App    : VM;
      part VM_Admin  : VM;
    }
  }

  part K8s : Virtualization {
    part PodAPI : Container;
    part PodWeb : Container;
  }

  // Trace link example
  OS_Ubuntu -> KVM : provides;
}

