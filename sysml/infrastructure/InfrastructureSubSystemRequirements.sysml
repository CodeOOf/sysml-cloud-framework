/**
 * Infrastructure Sub-System Requirements
 * 
 * OMG SysML v2 requirement specification for the Kubernetes Infrastructure sub-system
 * Based on https://www.omg.org/sysml/sysmlv2/
 * 
 * These requirements cascade from SYSTEM_REQ_* and define specific needs for:
 * - Cluster A (lab-scale) in configs/infrastructure-cluster-a/
 * - Cluster B (production EKS-like) in configs/infrastructure-cluster-b/
 * 
 * External Reference: input/infrastructure-requirements/
 * Project Integration: Jira project key INFRA-*
 */

package InfrastructureSubSystemRequirements {
    import Base::*;

    /**
     * Requirement: Infrastructure subsystem base
     * Inherits traceability from system level
     */
    abstract class InfrastructureRequirement {
        doc /* Infrastructure subsystem requirement
                 - Traces to SYSTEM_REQ_* parent
                 - Specific to Cluster A or Cluster B
                 - Links to Jira INFRA-* issues
                 - References external documents
             */
        
        attribute requirementId : String; /* INFRA_REQ_NNN format */
        attribute relatedSystemReq : String; /* Links to SYSTEM_REQ_* */
        attribute appliesToCluster : String; /* "A", "B", or "A,B" */
        attribute externalSourceId : String;
        attribute priority : String;
        attribute version : String;
    }

    /**
     * INFRA_REQ_001: Cluster A - Single Master Architecture
     * Cluster A must use single-master architecture suitable for development
     */
    class ClusterASingleMasterRequirement :> InfrastructureRequirement {
        doc /* Cluster A: Lab-scale development cluster
                 
             Parent System Requirement: SYSTEM_REQ_001 (Cluster Architecture)
             Jira: INFRA-001
             External: input/infrastructure-requirements/cluster-a-design.md
             
             Acceptance Criteria:
             - 1 master node (no HA needed for dev)
             - 2-3 worker nodes for testing
             - Local storage (no distributed HA)
             - Container runtime: containerd
             - Network plugin: Flannel (simple overlay)
             - Deployed in FabricationDatacenterA only
             
             Terraform Implementation:
             - configs/infrastructure-cluster-a/main.tf
             - configs/infrastructure-cluster-a/master.tf
             - configs/infrastructure-cluster-a/workers.tf
             
             Ansible Implementation:
             - library/ansible-roles/cluster-a-init/
             - library/ansible-roles/master-node/
             - library/ansible-roles/worker-node/
         */
        
        attribute masterNodes : Integer = 1;
        attribute workerNodes : Integer = 3; /* 2-3 range */
        attribute dataCenters : Integer = 1;
    }

    /**
     * INFRA_REQ_002: Cluster B - Multi-Master High Availability
     * Cluster B must use 3-node etcd + 3 master architecture for production HA
     */
    class ClusterBHARequirement :> InfrastructureRequirement {
        doc /* Cluster B: Production EKS-like cluster with full HA
                 
             Parent System Requirement: SYSTEM_REQ_001 (Cluster Architecture)
             Jira: INFRA-002
             External: input/infrastructure-requirements/cluster-b-design.md
             
             Acceptance Criteria:
             - 3 master nodes (etcd co-located)
             - 5+ worker nodes (scalable to 100+)
             - Distributed storage backend (Ceph, etcd, or managed storage)
             - Container runtime: containerd
             - Network plugin: Flannel with CNI
             - Multi-master control plane (kube-apiserver, scheduler, controller-manager behind LB)
             - Deployed across FabricationDatacenterA + FabricationDatacenterB
             
             Master Distribution:
             - Master 1: FabricationDatacenterA
             - Master 2-3: FabricationDatacenterB
             - Worker nodes: Distributed across both datacenters
             
             Terraform Implementation:
             - configs/infrastructure-cluster-b/main.tf
             - configs/infrastructure-cluster-b/master-ha.tf
             - configs/infrastructure-cluster-b/workers.tf
             - configs/infrastructure-cluster-b/etcd-cluster.tf
             
             Ansible Implementation:
             - library/ansible-roles/cluster-b-init/
             - library/ansible-roles/master-ha-node/
             - library/ansible-roles/etcd-cluster/
             - library/ansible-roles/worker-node/
         */
        
        attribute masterNodes : Integer = 3;
        attribute workerNodesMin : Integer = 5;
        attribute workerNodesMax : Integer = 100;
        attribute dataCenters : Integer = 2;
        attribute haEnabled : Boolean = true;
        attribute etcdNodesColocated : Boolean = true;
    }

    /**
     * INFRA_REQ_003: Container Runtime Specification
     * Both clusters must use containerd as container runtime
     */
    class ContainerRuntimeRequirement :> InfrastructureRequirement {
        doc /* Container runtime must be modern and stable
                 
             Parent System Requirement: SYSTEM_REQ_005 (IaC Implementation)
             Jira: INFRA-003
             External: input/infrastructure-requirements/container-runtime.md
             Vendor Doc: vendor-docs/containerd/
             
             Acceptance Criteria:
             - Containerd version >= 1.7.0
             - CRI plugin enabled and configured
             - Image pull/push to registries supported
             - Filesystem snapshots: overlayfs
             - Supported in both Cluster A and B
             
             Terraform Implementation:
             - configs/infrastructure-cluster-a/container-runtime.tf
             - configs/infrastructure-cluster-b/container-runtime.tf
             
             Ansible Implementation:
             - library/ansible-roles/container-runtime/
             - library/ansible-roles/container-registry-config/
         */
        
        attribute containerRuntime : String = "containerd";
        attribute minVersion : String = "1.7.0";
        attribute registriesSupported : Integer = 5; /* Multiple registries can be configured */
    }

    /**
     * INFRA_REQ_004: Network Plugin Configuration
     * Clusters must use Flannel for pod networking
     */
    class NetworkPluginRequirement :> InfrastructureRequirement {
        doc /* Network plugin enables pod-to-pod communication
                 
             Parent System Requirement: SYSTEM_REQ_001 (Cluster Architecture)
             Jira: INFRA-004
             External: input/infrastructure-requirements/network-plugin.md
             Vendor Doc: vendor-docs/flannel/
             
             Acceptance Criteria:
             - Flannel backend: VXLAN for overlay
             - Pod CIDR range: 10.244.0.0/16
             - Service CIDR range: 10.96.0.0/12
             - Network policies enforced (Calico can be added for policies)
             - Cross-cluster networking for Cluster B workers
             
             Terraform Implementation:
             - configs/infrastructure-cluster-a/network-plugin.tf
             - configs/infrastructure-cluster-b/network-plugin.tf
             
             Ansible Implementation:
             - library/ansible-roles/flannel-cni/
         */
        
        attribute networkPlugin : String = "Flannel";
        attribute backend : String = "VXLAN";
        attribute podCIDR : String = "10.244.0.0/16";
        attribute serviceCIDR : String = "10.96.0.0/12";
    }

    /**
     * INFRA_REQ_005: Storage Backend
     * Cluster A uses local storage; Cluster B uses distributed storage
     */
    class StorageBackendRequirement :> InfrastructureRequirement {
        doc /* Storage backend supports persistent volumes
                 
             Parent System Requirement: SYSTEM_REQ_001 (Cluster Architecture)
             Jira: INFRA-005
             External: input/infrastructure-requirements/storage-design.md
             
             Acceptance Criteria:
             
             Cluster A:
             - Local storage on worker nodes
             - hostPath PersistentVolume for development
             - No HA requirement
             
             Cluster B:
             - Distributed storage (option: etcd-backed, Ceph, or managed)
             - StorageClass for dynamic provisioning
             - Replication factor: 3
             - Snapshot capability for backups
             
             Terraform Implementation:
             - configs/infrastructure-cluster-a/storage-local.tf
             - configs/infrastructure-cluster-b/storage-distributed.tf
             
             Ansible Implementation:
             - library/ansible-roles/local-storage-provisioner/
             - library/ansible-roles/distributed-storage-provisioner/
         */
        
        attribute clusterAStorageType : String = "local";
        attribute clusterBStorageType : String = "distributed";
        attribute snapshotSupported : Boolean = true;
    }

    /**
     * INFRA_REQ_006: Security Policies and RBAC
     * Kubernetes RBAC must enforce least-privilege access
     */
    class SecurityPoliciesRequirement :> InfrastructureRequirement {
        doc /* Security ensures least-privilege access control
                 
             Parent System Requirement: SYSTEM_REQ_005 (IaC Implementation)
             Jira: INFRA-006
             External: input/infrastructure-requirements/security-policies.md
             
             Acceptance Criteria:
             - Default deny network policies
             - RBAC roles defined for service accounts
             - Pod security policies (or Pod Security Standards in K8s 1.25+)
             - Secrets management through etcd encryption
             - No privileged containers unless explicitly justified
             
             Terraform Implementation:
             - configs/infrastructure-cluster-a/security-policies.tf
             - configs/infrastructure-cluster-b/security-policies.tf
             
             Ansible Implementation:
             - library/ansible-roles/rbac-setup/
             - library/ansible-roles/network-policies/
         */
        
        attribute defaultDenyEnabled : Boolean = true;
        attribute rbacEnforced : Boolean = true;
        attribute secretsEncrypted : Boolean = true;
    }

    /**
     * INFRA_REQ_007: Monitoring and Logging
     * Infrastructure must emit observability signals (metrics, logs, traces)
     */
    class MonitoringAndLoggingRequirement :> InfrastructureRequirement {
        doc /* Observability enables operational visibility
                 
             Parent System Requirement: SYSTEM_REQ_007 (Documentation Generation)
             Jira: INFRA-007
             External: input/infrastructure-requirements/observability.md
             Vendor Doc: vendor-docs/prometheus/, vendor-docs/grafana/, vendor-docs/elk/
             
             Acceptance Criteria:
             - Prometheus for metrics collection
             - Grafana dashboards for visualization
             - ELK (Elasticsearch, Logstash, Kibana) for centralized logging
             - Traces from key components (kubelet, API server)
             - Alerting on critical thresholds
             
             Terraform Implementation:
             - configs/infrastructure-cluster-a/monitoring-stack.tf
             - configs/infrastructure-cluster-b/monitoring-stack.tf
             
             Ansible Implementation:
             - library/ansible-roles/prometheus-setup/
             - library/ansible-roles/grafana-setup/
             - library/ansible-roles/elk-stack/
         */
        
        attribute prometheusEnabled : Boolean = true;
        attribute grafanaEnabled : Boolean = true;
        attribute elkEnabled : Boolean = true;
        attribute alertingEnabled : Boolean = true;
    }

    /**
     * INFRA_REQ_008: Backup and Disaster Recovery
     * Critical infrastructure components must be backed up and recoverable
     */
    class BackupAndDRRequirement :> InfrastructureRequirement {
        doc /* Backup and recovery ensures business continuity
                 
             Parent System Requirement: SYSTEM_REQ_002 (Multi-Datacenter)
             Jira: INFRA-008
             External: input/infrastructure-requirements/backup-dr.md
             
             Acceptance Criteria:
             - etcd snapshots taken regularly
             - Cluster A: Local backup only
             - Cluster B: Cross-datacenter backup
             - RPO (Recovery Point Objective): 1 hour
             - RTO (Recovery Time Objective): 4 hours
             - Tested quarterly
             
             Terraform Implementation:
             - configs/infrastructure-cluster-a/backup-policy.tf
             - configs/infrastructure-cluster-b/backup-policy.tf
             
             Ansible Implementation:
             - library/ansible-roles/etcd-backup/
             - library/ansible-roles/backup-scheduler/
         */
        
        attribute rpoHours : Integer = 1;
        attribute rtoHours : Integer = 4;
        attribute crossDatacenterBackup : Boolean = true;
        attribute quarterlyTestingRequired : Boolean = true;
    }

    /**
     * INFRA_REQ_009: Load Balancing and Ingress
     * External traffic must be load-balanced to services
     */
    class LoadBalancingRequirement :> InfrastructureRequirement {
        doc /* Load balancing distributes traffic across services
                 
             Parent System Requirement: SYSTEM_REQ_001 (Cluster Architecture)
             Jira: INFRA-009
             External: input/infrastructure-requirements/load-balancing.md
             
             Acceptance Criteria:
             - Cluster A: kube-proxy (iptables mode)
             - Cluster B: kube-proxy + External Load Balancer (cloud provider or MetalLB)
             - Ingress controller for HTTP/HTTPS routing
             - TLS termination at ingress
             
             Terraform Implementation:
             - configs/infrastructure-cluster-a/load-balancer.tf
             - configs/infrastructure-cluster-b/load-balancer-external.tf
             
             Ansible Implementation:
             - library/ansible-roles/ingress-controller/
         */
        
        attribute kubeProxyEnabled : Boolean = true;
        attribute externalLBClusterB : Boolean = true;
        attribute ingressControllerSupported : Boolean = true;
    }

    /**
     * INFRA_REQ_010: Terraform Module Organization
     * All infrastructure code must follow shared module patterns
     */
    class TerraformModuleRequirement :> InfrastructureRequirement {
        doc /* Terraform modules enforce code reuse and consistency
                 
             Parent System Requirement: SYSTEM_REQ_003 (Shared Library)
             Jira: INFRA-010
             External: input/infrastructure-requirements/terraform-standards.md
             Reference: templates/TERRAFORM_STRUCTURE.md
             
             Acceptance Criteria:
             - Shared modules in library/terraform-modules/
             - Cluster-specific overrides in configs/infrastructure-cluster-a/b/
             - All modules have variables.tf, outputs.tf, main.tf, README.md
             - Module versions tracked and tested
             - Terraform plan review process documented
             
             Structure:
             - library/terraform-modules/kubernetes-base/
             - library/terraform-modules/etcd-cluster/
             - library/terraform-modules/container-runtime/
             - configs/infrastructure-cluster-a/: Cluster A specialization
             - configs/infrastructure-cluster-b/: Cluster B specialization
         */
        
        attribute modulesShared : Boolean = true;
        attribute consistencyEnforced : Boolean = true;
        attribute versioningEnabled : Boolean = true;
    }

    /**
     * Container: All infrastructure requirements
     */
    part infraRequirements : InfrastructureRequirement[*] {
        part clusterA : ClusterASingleMasterRequirement;
        part clusterB : ClusterBHARequirement;
        part runtime : ContainerRuntimeRequirement;
        part network : NetworkPluginRequirement;
        part storage : StorageBackendRequirement;
        part security : SecurityPoliciesRequirement;
        part monitoring : MonitoringAndLoggingRequirement;
        part backup : BackupAndDRRequirement;
        part lb : LoadBalancingRequirement;
        part terraform : TerraformModuleRequirement;
    }
}
