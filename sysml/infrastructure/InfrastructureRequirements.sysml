// InfrastructureRequirements.sysml
package InfrastructureRequirements {

  requirement R_IAM {
    Id = "INF-REQ-100";
    Text = "The system shall provide centralized IAM.";
    refines = Service;
  }

  requirement R_PKI {
    Id = "INF-REQ-101";
    Text = "The system shall implement PKI for service authentication.";
    refines = Service;
  }

  requirement R_AZ_Config {
    Id = "INF-REQ-102";
    Text = "Cluster deployment shall support at least 2 availability zones.";
    refines = Cluster;
  }

  requirement R_DMZ_Services {
    Id = "INF-REQ-103";
    Text = "Public-facing services shall be placed in the DMZ network zone.";
    refines = Network;
  }
}

