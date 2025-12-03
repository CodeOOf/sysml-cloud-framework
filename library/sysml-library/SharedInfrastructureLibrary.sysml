/**
 * Shared Infrastructure Library
 * 
 * OMG SysML v2 reusable definitions for cloud infrastructure
 * Provides base classes and common patterns used across all projects
 */

package SharedInfrastructureLibrary {
    import Base::*;

    /**
     * Standard compute node abstraction
     * Used as base for master nodes, worker nodes, and other compute resources
     */
    abstract class ComputeNode {
        doc /* Abstract compute node with standard properties */
        
        attribute hostname : String;
        attribute fqdn : String;
        attribute ipAddress : String;
        attribute cpuCores : Integer;
        attribute memoryGiB : Integer;
        attribute diskStorageGiB : Integer;
        attribute operatingSystem : String;
    }

    /**
     * Standard network interface definition
     */
    abstract class NetworkInterface {
        doc /* Network interface with standard properties */
        
        attribute interfaceName : String;
        attribute macAddress : String;
        attribute ipAddress : String;
        attribute subnetMask : String;
        attribute mtuBytes : Integer = 1500;
        attribute bandwidth : String; /* e.g., "1Gbps", "10Gbps" */
    }

    /**
     * Storage volume abstraction
     */
    abstract class StorageVolume {
        doc /* Storage volume with performance characteristics */
        
        attribute volumeName : String;
        attribute capacityGiB : Integer;
        attribute volumeType : String; /* SSD, HDD, NVMe */
        attribute iopsBenchmark : Integer;
        attribute throughputMBps : Integer;
    }

    /**
     * Service definition (for API, database, etc.)
     */
    abstract class Service {
        doc /* Network-accessible service abstraction */
        
        attribute serviceName : String;
        attribute servicePort : Integer;
        attribute protocol : String;
        attribute endpoint : String;
        attribute healthCheckPath : String;
        attribute healthCheckIntervalSec : Integer = 30;
    }

    /**
     * Logging and monitoring infrastructure
     */
    class LoggingService :> Service {
        doc /* Centralized logging service (ELK, Loki, etc.) */
        
        attribute retentionDays : Integer;
        attribute logFormat : String;
    }

    class MetricsService :> Service {
        doc /* Metrics collection service (Prometheus, etc.) */
        
        attribute scrapeIntervalSec : Integer = 30;
        attribute retentionDays : Integer = 15;
    }

    class TracingService :> Service {
        doc /* Distributed tracing service (Jaeger, etc.) */
        
        attribute samplingRate : Real; /* 0.0 to 1.0 */
    }

    /**
     * Security boundary definitions
     */
    abstract class SecurityBoundary {
        doc /* Define security domains and access boundaries */
        
        attribute boundaryName : String;
        attribute trustLevel : String; /* public, internal, restricted */
    }

    class NetworkSecurityBoundary :> SecurityBoundary {
        doc /* Network-level security boundary (VPC, zone, etc.) */
    }

    class ApplicationSecurityBoundary :> SecurityBoundary {
        doc /* Application-level security boundary (namespace, etc.) */
    }

    /**
     * Configuration template for clusters
     */
    abstract class ClusterConfigTemplate {
        doc /* Template for cluster configuration consistency */
        
        attribute templateVersion : String;
        attribute kubernetesVersion : String;
        attribute containerRuntime : String;
        attribute networkPlugin : String;
        attribute ingressController : String;
    }

    /**
     * Node pool configuration
     */
    class NodePoolConfig :> ClusterConfigTemplate {
        doc /* Configuration for a group of similar nodes */
        
        attribute poolName : String;
        attribute nodeCount : Integer;
        attribute machineType : String;
        attribute cpuCores : Integer;
        attribute memoryGiB : Integer;
        attribute diskGiB : Integer;
        attribute autoScaling : Boolean = false;
        attribute minNodes : Integer = 1;
        attribute maxNodes : Integer = 10;
    }

    /**
     * RBAC policy definition
     */
    class RBACPolicy {
        doc /* Role-Based Access Control policy */
        
        attribute policyName : String;
        attribute roleNames : String[0..*];
        attribute subjects : String[0..*];
        attribute resources : String[0..*];
        attribute verbs : String[0..*]; /* get, list, create, update, delete, etc. */
        attribute apiGroups : String[0..*];
        attribute namespaces : String[0..*];
    }

    /**
     * Network policy definition
     */
    class NetworkPolicy {
        doc /* Kubernetes network policy for traffic control */
        
        attribute policyName : String;
        attribute namespace : String;
        attribute policyType : String; /* Ingress, Egress, or both */
        attribute ingressRules : IngressRule[0..*];
        attribute egressRules : EgressRule[0..*];
    }

    /**
     * Ingress rule for network policy
     */
    abstract class NetworkPolicyRule {
        doc /* Base definition for network policy rules */
        
        attribute ruleName : String;
    }

    class IngressRule :> NetworkPolicyRule {
        doc /* Ingress traffic rule */
        
        attribute fromPorts : Integer[0..*];
        attribute fromNamespaces : String[0..*];
        attribute fromIPBlocks : String[0..*];
        attribute protocol : String; /* TCP, UDP */
    }

    class EgressRule :> NetworkPolicyRule {
        doc /* Egress traffic rule */
        
        attribute toPorts : Integer[0..*];
        attribute toNamespaces : String[0..*];
        attribute toIPBlocks : String[0..*];
        attribute protocol : String; /* TCP, UDP */
    }

    /**
     * Backup and disaster recovery policy
     */
    class BackupPolicy {
        doc /* Backup and recovery strategy */
        
        attribute policyName : String;
        attribute backupFrequency : String; /* hourly, daily, weekly */
        attribute retentionDays : Integer;
        attribute rto : Integer; /* Recovery Time Objective (seconds) */
        attribute rpo : Integer; /* Recovery Point Objective (seconds) */
        attribute backupDestination : String;
        attribute encryption : Boolean = true;
    }

}
