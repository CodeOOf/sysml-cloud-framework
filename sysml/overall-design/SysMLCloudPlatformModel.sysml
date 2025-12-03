// SysMLCloudPlatformModel.sysml
package SysMLCloudPlatform {

  part def SysMLCloudPlatform;

  // Subsystems
  part def Datacenter;
  part def Infrastructure;

  // Overall system instance
  part Cloud : SysMLCloudPlatform {
    part DC : Datacenter;
    part INF : Infrastructure;

    // High-level relation to show infra realized by DC hardware
    DC -> INF : realize;
  }
}

