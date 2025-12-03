/**
 * Deployment Architecture Model
 * 
 * OMG SysML v2 specification for cloud infrastructure deployment across datacenters
 * Aligns Cluster A and Cluster B deployments to Fabrication Datacenters A and B
 */

package DeploymentArchitecture {
    import Base::*;
    import KubernetesClusterArchitecture::*;

    /**
     * Datacenter abstraction
     * Represents physical or logical datacenter boundaries
     */
    abstract class Datacenter {
        doc /* Physical datacenter hosting compute, storage, and networking */
        
        attribute name : String;
        attribute location : String;
        attribute region : String;
        attribute availabilityZone : String;
    }

    /**
     * Fabrication Datacenter A
     * Hosts Cluster A (development) and part of Cluster B (HA replica)
     */
    class FabricationDatacenterA :> Datacenter {
        doc /* Lab datacenter in primary site
                
             Contains:
             - Cluster A (complete): Development and testing
             - Cluster B Master 1 & etcd member: Part of HA control plane
             - Cluster B Worker nodes subset: HA-enabled
         */
        
        structure {
            part clusterA : ClusterA {
                doc /* Complete Cluster A deployment */
            }
            part clusterBMaster1 : MasterNode {
                doc /* First master for Cluster B HA */
            }
            part clusterBWorkerGroup1 : WorkerNode[2..3] {
                doc /* Worker group 1 of Cluster B */
            }
        }
    }

    /**
     * Fabrication Datacenter B
     * Hosts remaining Cluster B infrastructure for geographic redundancy
     */
    class FabricationDatacenterB :> Datacenter {
        doc /* Secondary datacenter for HA and DR
                
             Contains:
             - Cluster B Master 2 & 3: Control plane replication
             - Cluster B Worker nodes subset: Load distribution
             - Distributed storage replicas
         */
        
        structure {
            part clusterBMaster2 : MasterNode {
                doc /* Second master for Cluster B HA */
            }
            part clusterBMaster3 : MasterNode {
                doc /* Third master for Cluster B HA */
            }
            part clusterBWorkerGroup2 : WorkerNode[3..5] {
                doc /* Worker group 2 of Cluster B */
            }
            part distributedStorageReplicas : DistributedStorageCluster {
                doc /* Storage layer with geographic redundancy */
            }
        }
    }

    /**
     * Overall deployment architecture
     * Captures how both clusters span across datacenters
     */
    class CloudPlatformDeployment {
        doc /* Complete cloud platform deployment architecture
                
             Multi-datacenter topology:
             - Cluster A: Single datacenter (Fabrication A)
             - Cluster B: Multi-datacenter HA (Fabrication A + B)
             - Storage: Replicated across both sites
             - Networking: Cross-datacenter connectivity (WAN)
         */
        
        structure {
            part fabricationDatacenterA : FabricationDatacenterA;
            part fabricationDatacenterB : FabricationDatacenterB;
            
            part networkingLayer : NetworkingLayer {
                doc /* Cross-datacenter networking */
            }
            part storageLayer : StorageLayer {
                doc /* Distributed storage spanning datacenters */
            }
        }
    }

    /**
     * Networking layer definition
     */
    class NetworkingLayer {
        doc /* Network infrastructure connecting datacenters */
        
        attribute vpnBackhaul : Boolean = true;
        attribute directConnect : Boolean = false;
        attribute latencyMs : Integer; /* Expected cross-datacenter latency */
    }

    /**
     * Storage layer definition
     */
    class StorageLayer {
        doc /* Distributed storage subsystem */
        
        attribute replicationStrategy : String; /* sync, async, stretched */
        attribute recoveryTimeObjective : Integer; /* RTO in seconds */
        attribute recoveryPointObjective : Integer; /* RPO in seconds */
    }

}
