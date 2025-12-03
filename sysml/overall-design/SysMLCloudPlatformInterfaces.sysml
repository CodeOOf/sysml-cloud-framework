// SysMLCloudPlatformInterfaces.sysml
package SysMLCloudPlatformInterfaces {

  interface def PowerInterface;
  interface def CoolingInterface;
  interface def NetworkInterface;

  // Top-level interfaces exposed by Datacenter and consumed by Infrastructure
  connect PowerInterface   -> Datacenter;
  connect CoolingInterface -> Datacenter;
  connect NetworkInterface -> Datacenter;

  connect NetworkInterface -> Infrastructure; // logical consumption
}

