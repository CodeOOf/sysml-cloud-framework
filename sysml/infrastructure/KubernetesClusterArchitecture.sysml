/**
 * Kubernetes Cluster Architecture Model
 * 
 * OMG SysML v2 textual specification for cloud infrastructure clusters
 * Based on https://www.omg.org/sysml/sysmlv2/
 * 
 * This model defines the architectural structure for two deployment profiles:
 * - Cluster A: Lab-scale cluster with minimal resources
 * - Cluster B: Production-scale EKS-like cluster with HA and scaling
 */

package KubernetesClusterArchitecture {
    import Base::*;

    /**
     * Abstract base definition for Kubernetes cluster configurations
     */
    abstract class KubernetesCluster {
        doc /* Base abstraction for all K8s clusters */
        
        attribute name : String;
        attribute namespace : String;
        
        /* Core cluster properties */
        attribute kubernetesVersion : String;
        attribute containerRuntime : String;
        attribute networkPlugin : String;
    }

    /**
     * Cluster A: Lab-scale development and testing
     * Purpose: Minimal viable cluster for development, testing, and prototyping
     */
    class ClusterA :> KubernetesCluster {
        doc /* Lab-scale Kubernetes cluster for development and testing
                
             Characteristics:
             - Single master node (development only)
             - 2-3 worker nodes
             - Local storage (not production HA)
             - Single datacenter deployment
             - Minimal resource consumption
             - Container registry: Local or Harbor (minimal)
         */
        
        attribute clusterSize : Integer = 3;
        attribute isSingleMaster : Boolean = true;
        attribute hasLocalStorage : Boolean = true;
        
        structure {
            part masterNode : MasterNode {
                doc /* Single master node for dev/test (not HA) */
            }
            part workerNodes : WorkerNode[2..3] {
                doc /* 2-3 worker nodes for workload scheduling */
            }
            part localStorage : StorageNode {
                doc /* Local storage backend (NFS or similar) */
            }
        }
    }

    /**
     * Cluster B: Production-scale EKS-like cluster
     * Purpose: Highly available, scalable production infrastructure
     */
    class ClusterB :> KubernetesCluster {
        doc /* Production EKS-like Kubernetes cluster
                
             Characteristics:
             - Multi-master HA (3 masters for quorum)
             - Auto-scaling worker nodes (5-100+)
             - Distributed storage (Ceph, Longhorn, or managed)
             - Multi-datacenter capable
             - Full observability (metrics, logs, traces)
             - Container registry: Harbor or AWS ECR
             - Network policies enforced
             - RBAC and security hardening
         */
        
        attribute clusterSize : Integer = 5; /* minimum, scales up */
        attribute isSingleMaster : Boolean = false;
        attribute hasHighAvailability : Boolean = true;
        attribute hasLoadBalancing : Boolean = true;
        attribute hasAutoScaling : Boolean = true;
        
        structure {
            part masterNodes : MasterNode[3] {
                doc /* 3 master nodes for HA and etcd quorum */
            }
            part workerNodes : WorkerNode[5..100] {
                doc /* 5-100+ worker nodes with auto-scaling */
            }
            part distributedStorage : DistributedStorageCluster {
                doc /* Distributed storage for persistent volumes */
            }
            part loadBalancer : LoadBalancerService {
                doc /* External load balancer (hardware or software) */
            }
            part ingressController : IngressController {
                doc /* Ingress controller for HTTP(S) routing */
            }
            part serviceRegistry : ServiceRegistry {
                doc /* Service mesh or registry (Consul, Istio) */
            }
        }
    }

    /**
     * MasterNode definition
     * Hosts Kubernetes control plane components
     */
    class MasterNode {
        doc /* Kubernetes master/control plane node
                
             Components:
             - API Server
             - Scheduler
             - Controller Manager
             - etcd (distributed state store)
         */
        
        attribute nodeHostname : String;
        attribute cpuCores : Integer;
        attribute memoryGiB : Integer;
        
        structure {
            part apiServer : APIServer;
            part scheduler : Scheduler;
            part controllerManager : ControllerManager;
            part etcd : EtcdStore;
        }
    }

    /**
     * WorkerNode definition
     * Hosts containerized workloads
     */
    class WorkerNode {
        doc /* Kubernetes worker node for pod scheduling
                
             Responsibilities:
             - Run kubelet agent
             - Execute container workloads
             - Report health and metrics
         */
        
        attribute nodeHostname : String;
        attribute cpuCores : Integer;
        attribute memoryGiB : Integer;
        attribute isGPUEnabled : Boolean = false;
        
        structure {
            part kubelet : Kubelet;
            part containerRuntime : ContainerRuntime;
            part kubeProxy : KubeProxy;
        }
    }

    /**
     * Control plane components
     */
    class APIServer {
        doc /* Kubernetes API Server - primary control plane interface */
        attribute port : Integer = 6443;
        attribute protocol : String = "HTTPS";
    }

    class Scheduler {
        doc /* Pod scheduler - assigns pods to nodes */
    }

    class ControllerManager {
        doc /* Controllers for deployments, statefulsets, daemonsets, etc. */
    }

    class EtcdStore {
        doc /* Distributed key-value store for cluster state */
        attribute replicationFactor : Integer = 3;
    }

    /**
     * Worker node components
     */
    class Kubelet {
        doc /* Kubelet agent running on each worker node */
        attribute port : Integer = 10250;
    }

    class ContainerRuntime {
        doc /* Container runtime (containerd, CRI-O, Docker) */
        attribute runtimeName : String;
    }

    class KubeProxy {
        doc /* Network proxy for service load balancing */
    }

    /**
     * Storage abstractions
     */
    class StorageNode {
        doc /* Storage backend for local cluster storage */
        attribute storageType : String; /* NFS, iSCSI, local */
        attribute capacityTiB : Integer;
    }

    class DistributedStorageCluster {
        doc /* Distributed storage cluster for PVs and backups */
        attribute replicationFactor : Integer = 3;
        attribute capacityTiB : Integer;
        attribute storageEngine : String; /* Ceph, Longhorn, GlusterFS */
    }

    /**
     * Networking and ingress
     */
    class LoadBalancerService {
        doc /* External load balancer for cluster ingress */
        attribute haBackends : Integer = 2;
        attribute protocolSupport : String; /* TCP, UDP, HTTP, HTTPS */
    }

    class IngressController {
        doc /* Kubernetes ingress controller for L7 routing */
        attribute controllerType : String; /* nginx, istio, traefik */
    }

    class ServiceRegistry {
        doc /* Service registry for discovery and routing */
        attribute registryType : String; /* Consul, Istio, Kubernetes DNS */
    }

}
