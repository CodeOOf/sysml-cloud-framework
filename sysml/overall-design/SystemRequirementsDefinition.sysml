/**
 * System Requirements Definition
 * 
 * OMG SysML v2 Requirement specification for the Cloud Platform
 * Based on https://www.omg.org/sysml/sysmlv2/
 * 
 * This model defines the system-level requirements that cascade down to:
 * - Infrastructure sub-system (clusters, networking)
 * - Fabrication sub-system (datacenters, physical topology)
 * - Testing and deployment sub-systems
 * 
 * Source: Requirements derived from external documents in input/ folder
 * External Reference: input/system-requirements/ (original requirement documents)
 */

package SystemRequirementsDefinition {
    import Base::*;

    /**
     * Requirement: Abstract base for all system requirements
     * Links to external requirement documents and Jira tracking
     */
    abstract class SystemRequirement {
        doc /* Base requirement abstraction
                 - Traceable to external documents
                 - Links to Jira/GitLab issues
                 - Mapped to V-Model phases
             */
        
        attribute requirementId : String;
        attribute title : String;
        attribute description : String;
        attribute priority : String; /* "CRITICAL", "HIGH", "MEDIUM", "LOW" */
        attribute status : String; /* "DRAFT", "APPROVED", "IMPLEMENTED", "VERIFIED" */
        
        /* Traceability */
        attribute externalSourceId : String; /* Jira key, GitLab issue #, etc. */
        attribute externalDocumentRef : String; /* input/system-requirements/filename */
        attribute version : String;
    }

    /**
     * SYSTEM_REQ_001: Cluster Architecture
     * The system must support multiple Kubernetes cluster profiles
     */
    class ClusterArchitectureRequirement :> SystemRequirement {
        doc /* Cluster architecture must be flexible and scalable
                 
             References:
             - Jira: PLAT-001
             - External: input/system-requirements/cluster-design.md
             - Specification: OMG SysML v2 Container Model
             
             Acceptance Criteria:
             - Support lab-scale (Cluster A) with minimal HA
             - Support production-scale (Cluster B) with full HA
             - Both clusters must coexist in single organization
             - Multi-datacenter deployment supported for Cluster B
         */
        
        attribute minClusters : Integer = 2;
        attribute maxClusters : Integer = 999;
        attribute multiDatacenterSupported : Boolean = true;
    }

    /**
     * SYSTEM_REQ_002: Multi-Datacenter Deployment
     * The system must support deployment across multiple datacenters
     */
    class MultiDatacenterRequirement :> SystemRequirement {
        doc /* Multi-datacenter support enables disaster recovery
                 
             References:
             - Jira: PLAT-002
             - External: input/system-requirements/disaster-recovery.md
             
             Acceptance Criteria:
             - Primary datacenter (FabricationDatacenterA) fully functional
             - Secondary datacenter (FabricationDatacenterB) for Cluster B HA
             - Automatic failover capability for stateless services
             - Cross-datacenter network latency < 5ms (if co-located)
         */
        
        attribute minDatacenters : Integer = 1;
        attribute maxDatacenters : Integer = 10;
        attribute autoFailoverSupported : Boolean = true;
        attribute maxNetworkLatencyMs : Integer = 5;
    }

    /**
     * SYSTEM_REQ_003: Shared Library Reusability
     * The system must enforce reusable SysML, Terraform, and Ansible components
     */
    class SharedLibraryRequirement :> SystemRequirement {
        doc /* Shared library reduces duplication and improves maintainability
                 
             References:
             - Jira: PLAT-003
             - External: input/system-requirements/code-reuse.md
             
             Acceptance Criteria:
             - Generic SysML models in library/sysml-library/
             - Generic Terraform modules in library/terraform-modules/
             - Generic Ansible roles in library/ansible-roles/
             - No duplication between Cluster A and Cluster B implementations
         */
        
        attribute codeReuseTarget : Double = 0.80; /* 80% code reuse target */
        attribute libraryMaintainedCentrally : Boolean = true;
    }

    /**
     * SYSTEM_REQ_004: Requirements Traceability
     * The system must maintain bidirectional traceability from requirements to code
     */
    class RequirementsTraceabilityRequirement :> SystemRequirement {
        doc /* Full traceability enables impact analysis and change management
                 
             References:
             - Jira: PLAT-004
             - External: input/system-requirements/traceability.md
             - Standard: IEEE 830 (Requirements Specification)
             
             Acceptance Criteria:
             - Each requirement has unique ID (SYSTEM_REQ_NNN)
             - Links to Jira issues maintained
             - Links to external documents in input/ folder
             - SysML models reference requirement IDs in doc blocks
             - Test cases linked to requirements
             - Deployment checklists reference requirements
         */
        
        attribute bidirectionalTracing : Boolean = true;
        attribute externalSystemsSupported : String[] = {"Jira", "GitLab", "Azure DevOps"};
    }

    /**
     * SYSTEM_REQ_005: Infrastructure as Code (IaC) Implementation
     * The system must define all infrastructure through code (Terraform + Ansible)
     */
    class IaCImplementationRequirement :> SystemRequirement {
        doc /* Infrastructure as Code enables reproducibility and version control
                 
             References:
             - Jira: PLAT-005
             - External: input/system-requirements/iac-practices.md
             
             Acceptance Criteria:
             - All Kubernetes infrastructure defined in Terraform
             - All configuration management done through Ansible
             - No manual infrastructure changes
             - Complete environment reproducibility
             - Terraform plan reviewed before apply
             - Ansible playbooks tested in staging
         */
        
        attribute allInfrastructureCoded : Boolean = true;
        attribute terraformModulesRequired : Boolean = true;
        attribute ansibleRolesRequired : Boolean = true;
    }

    /**
     * SYSTEM_REQ_006: Testing and Validation
     * The system must define comprehensive testing and validation procedures
     */
    class TestingAndValidationRequirement :> SystemRequirement {
        doc /* Comprehensive testing ensures reliability and correctness
                 
             References:
             - Jira: PLAT-006
             - External: input/system-requirements/testing-strategy.md
             
             Acceptance Criteria:
             - Unit tests for all SysML model transformations
             - Integration tests for Terraform + Ansible combinations
             - End-to-end cluster deployment tests
             - Network connectivity tests between datacenters
             - Failover scenario tests
             - Documentation tests (PDF generation validation)
         */
        
        attribute unitTestsRequired : Boolean = true;
        attribute integrationTestsRequired : Boolean = true;
        attribute e2eTestsRequired : Boolean = true;
        attribute minTestCoverage : Double = 0.80; /* 80% coverage target */
    }

    /**
     * SYSTEM_REQ_007: Documentation Generation
     * The system must auto-generate documentation from SysML models
     */
    class DocumentationGenerationRequirement :> SystemRequirement {
        doc /* Auto-generated documentation keeps models and docs in sync
                 
             References:
             - Jira: PLAT-007
             - External: input/system-requirements/documentation-strategy.md
             
             Acceptance Criteria:
             - SysML → Markdown conversion automated
             - Markdown → PDF generation with V-Model phases
             - PDF naming follows V-Model abbreviations (01_PMP_, 03_SRD_, etc.)
             - Architecture diagrams included in PDFs
             - Vendor documentation linked and referenced
             - Navigation structure clear for developers
         */
        
        attribute autoGenerationSupported : Boolean = true;
        attribute pdfGenerationSupported : Boolean = true;
        attribute vModelPhaseOrdering : Boolean = true;
    }

    /**
     * SYSTEM_REQ_008: Project Management Integration
     * The system must integrate with project management and issue tracking systems
     */
    class ProjectManagementIntegrationRequirement :> SystemRequirement {
        doc /* Project integration enables work tracking and progress visibility
                 
             References:
             - Jira: PLAT-008
             - External: input/system-requirements/project-integration.md
             
             Acceptance Criteria:
             - Jira API integration for issue creation/updates
             - GitLab API integration for MR/issue creation
             - Project plans traceable to requirements
             - Deployment checklists connected to Jira tasks
             - Automated status updates from CI/CD pipelines
         */
        
        attribute jiraIntegrationSupported : Boolean = true;
        attribute gitlabIntegrationSupported : Boolean = true;
        attribute automatedStatusUpdates : Boolean = true;
    }

    /**
     * SYSTEM_REQ_009: Deployment Automation
     * The system must automate deployment with safety checks and rollback capability
     */
    class DeploymentAutomationRequirement :> SystemRequirement {
        doc /* Automated deployments reduce errors and enable continuous delivery
                 
             References:
             - Jira: PLAT-009
             - External: input/system-requirements/deployment-strategy.md
             
             Acceptance Criteria:
             - Deployment plans generated from SysML models
             - Pre-deployment validation checks
             - Automatic rollback on critical failures
             - Deployment audit logs
             - Zero-downtime deployment for Cluster B
             - Staged rollout capability (canary, blue-green)
         */
        
        attribute automatedDeployment : Boolean = true;
        attribute rollbackCapability : Boolean = true;
        attribute zeroDowntimeSupported : Boolean = true;
    }

    /**
     * SYSTEM_REQ_010: Vendor Documentation Integration
     * The system must reference and integrate vendor documentation
     */
    class VendorDocumentationRequirement :> SystemRequirement {
        doc /* Vendor docs provide context for infrastructure decisions
                 
             References:
             - Jira: PLAT-010
             - External: input/system-requirements/vendor-integration.md
             
             Acceptance Criteria:
             - Vendor documentation folder: vendor-docs/
             - Links to vendor docs in architecture guides
             - References in Terraform/Ansible configurations
             - License terms tracked and documented
             - Version tracking for vendor products (K8s, containerd, etcd, etc.)
         */
        
        attribute vendorDocIntegrated : Boolean = true;
        attribute supportedVendors : String[] = {
            "Kubernetes", "Containerd", "etcd", "Flannel", 
            "Terraform", "Ansible", "Helm", "Prometheus", "ELK"
        };
    }

    /**
     * Container: All system requirements
     */
    part systemRequirements : SystemRequirement[*] {
        part clusterArch : ClusterArchitectureRequirement;
        part multiDC : MultiDatacenterRequirement;
        part sharedLib : SharedLibraryRequirement;
        part traceability : RequirementsTraceabilityRequirement;
        part iac : IaCImplementationRequirement;
        part testing : TestingAndValidationRequirement;
        part docs : DocumentationGenerationRequirement;
        part pmInt : ProjectManagementIntegrationRequirement;
        part deployment : DeploymentAutomationRequirement;
        part vendor : VendorDocumentationRequirement;
    }
}
