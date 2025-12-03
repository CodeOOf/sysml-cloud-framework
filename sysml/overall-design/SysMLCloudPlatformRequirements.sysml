// SysMLCloudPlatformRequirements.sysml
package SysMLCloudPlatformRequirements {

  requirement R_Uptime {
    Id = "REQ-001";
    Text = "The platform shall provide 99.99% service uptime.";
    refines = Cloud;     // from SysMLCloudPlatformModel
  }

  requirement R_Zones {
    Id = "REQ-002";
    Text = "The platform shall segregate DMZ and Out-of-Band (OOB) management networks.";
    refines = Cloud;
  }

  requirement R_AZ {
    Id = "REQ-003";
    Text = "The platform shall support at least 2 availability zones per region.";
    refines = Cloud;
  }
}

