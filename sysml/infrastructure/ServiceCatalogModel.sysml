// ServiceCatalogModel.sysml
package ServiceCatalogModel {

  part def Service;
  part def IAM;
  part def PKI;
  part def Logging;
  part def Monitoring;

  part Catalog : Service {
    part IdM : IAM;
    part Certs : PKI;
    part Logs : Logging;
    part Mon  : Monitoring;
  }

  // Example dependencies between services
  Certs -> IdM  : depends;
  Logs  -> Mon  : feeds;
}

