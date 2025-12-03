// PowerCoolingInterfaces.sysml
package PowerCoolingInterfaces {

  interface def PowerIP;
  interface def CoolingFlow;
  interface def FacilityNetworkIngress;

  // Connect interfaces to datacenter elements
  connect PowerIP              -> RackA1;
  connect CoolingFlow          -> Room1;
  connect FacilityNetworkIngress -> DatacenterA;
}

