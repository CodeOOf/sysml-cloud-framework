// NetworkModel.sysml
package NetworkModel {

  interface def DMZInterface;
  interface def OOBInterface;
  interface def InternalInterface;

  part def Network;
  part def Firewall;
  part def Switch;
  part def Router;

  part NetA : Network {
    part FW_DMZ : Firewall;
    part FW_OOB : Firewall;
    part SW_Core : Switch;
    part RT_Edge : Router;
  }

  connect DMZInterface     -> FW_DMZ;
  connect OOBInterface     -> FW_OOB;
  connect InternalInterface -> SW_Core;
}

