/**
 * Testing and Deployment Strategy
 * 
 * OMG SysML v2 specification for comprehensive testing and deployment planning
 * Based on https://www.omg.org/sysml/sysmlv2/
 * 
 * This model defines:
 * - Test plan hierarchy (unit, integration, e2e, validation)
 * - Deployment procedures and safety checks
 * - Rollback and recovery procedures
 * - Project integration touchpoints (Jira, GitLab)
 * 
 * External Reference: input/testing-requirements/, input/deployment-procedures/
 * Project Integration: Jira project keys TEST-*, DEPLOY-*
 */

package TestingAndDeploymentPlanning {
    import Base::*;

    /**
     * Test Plan: Abstract base for all test specifications
     */
    abstract class TestPlanSpecification {
        doc /* Test plan specification with traceability
                 - Links to requirements (SYSTEM_REQ_*, INFRA_REQ_*, FAB_REQ_*)
                 - Jira test case management
                 - Execution schedule and results
             */
        
        attribute testId : String; /* TEST_NNN format */
        attribute title : String;
        attribute description : String;
        attribute relatedRequirement : String; /* Links to requirement */
        attribute testType : String; /* "unit", "integration", "e2e", "validation" */
        attribute priority : String; /* "CRITICAL", "HIGH", "MEDIUM", "LOW" */
        attribute status : String; /* "PLANNED", "IN_PROGRESS", "PASSED", "FAILED" */
        attribute jiraIssue : String; /* TEST-NNN */
        attribute externalSourceId : String;
    }

    /**
     * TEST_001: SysML Model Syntax Validation
     * All SysML models must parse without syntax errors
     */
    class SysMLSyntaxValidationTest :> TestPlanSpecification {
        doc /* Validate OMG SysML v2 syntax compliance
                 
             Related Requirements: SYSTEM_REQ_007 (Documentation Generation)
             Jira: TEST-001
             External: input/testing-requirements/sysml-validation.md
             
             Test Procedure:
             1. Run SysML parser on all .sysml files
             2. Check for syntax errors, warnings
             3. Validate package imports and dependencies
             4. Confirm all cross-references resolve
             5. Generate documentation from models
             
             Acceptance Criteria:
             - All .sysml files parse without errors
             - No unresolved package references
             - Documentation generates successfully
             - PDF outputs have correct filenames (V-Model abbreviations)
             
             Automation:
             - CI/CD: scripts/validate-sysml.sh
             - Trigger: Push to sysml/ folder
             - Frequency: On every commit
             
             Test Files:
             - sysml/overall-design/SystemRequirementsDefinition.sysml
             - sysml/infrastructure/KubernetesClusterArchitecture.sysml
             - sysml/infrastructure/InfrastructureSubSystemRequirements.sysml
             - sysml/datacenter/DeploymentArchitecture.sysml
             - sysml/datacenter/FabricationSubSystemRequirements.sysml
         */
        
        attribute modelsToValidate : Integer = 10; /* Number of SysML files */
        attribute allowedWarnings : Integer = 5; /* Acceptable warning count */
    }

    /**
     * TEST_002: Terraform Configuration Validation
     * All Terraform configurations must be valid and plannable
     */
    class TerraformValidationTest :> TestPlanSpecification {
        doc /* Validate Terraform configuration syntax and semantics
                 
             Related Requirements: SYSTEM_REQ_005 (IaC Implementation), INFRA_REQ_010
             Jira: TEST-002
             External: input/testing-requirements/terraform-validation.md
             
             Test Procedure:
             1. Run terraform validate on all configurations
             2. Generate terraform plan (dry-run)
             3. Check for policy violations (tflint)
             4. Validate module dependencies
             5. Ensure no hardcoded credentials
             
             Acceptance Criteria:
             - All configurations valid
             - terraform plan succeeds
             - No policy violations
             - No credential leaks
             
             Automation:
             - CI/CD: scripts/validate-terraform.sh
             - Trigger: Push to configs/ or library/terraform-modules/
             - Frequency: On every commit
             
             Test Directories:
             - library/terraform-modules/
             - configs/infrastructure-cluster-a/
             - configs/infrastructure-cluster-b/
         */
        
        attribute configsToValidate : Integer = 15;
        attribute modulesToValidate : Integer = 8;
    }

    /**
     * TEST_003: Ansible Playbook Linting
     * All Ansible playbooks and roles must pass linting checks
     */
    class AnsibleLintingTest :> TestPlanSpecification {
        doc /* Validate Ansible playbooks and roles
                 
             Related Requirements: SYSTEM_REQ_005 (IaC Implementation)
             Jira: TEST-003
             External: input/testing-requirements/ansible-validation.md
             
             Test Procedure:
             1. Run ansible-lint on all roles
             2. Check syntax with ansible-playbook --syntax-check
             3. Validate variable definitions
             4. Check for hardcoded values
             5. Ensure idempotency compatibility
             
             Acceptance Criteria:
             - All roles pass ansible-lint
             - All playbooks have valid syntax
             - No critical violations
             
             Automation:
             - CI/CD: scripts/validate-ansible.sh
             - Trigger: Push to library/ansible-roles/ or fabrications/*/
             - Frequency: On every commit
             
             Test Directories:
             - library/ansible-roles/
             - fabrications/fabrication-datacenter-a/
             - fabrications/fabrication-datacenter-b/
         */
        
        attribute rolesToValidate : Integer = 20;
    }

    /**
     * TEST_004: Unit Tests for Python Scripts
     * All Python utility scripts must have unit test coverage
     */
    class PythonUnitTestsTest :> TestPlanSpecification {
        doc /* Unit tests for Python build and utility scripts
                 
             Related Requirements: SYSTEM_REQ_006 (Testing and Validation)
             Jira: TEST-004
             External: input/testing-requirements/python-unit-tests.md
             
             Test Procedure:
             1. Run pytest on all test_*.py files
             2. Check code coverage (minimum 80%)
             3. Validate SysML-to-Markdown transformations
             4. Validate PDF generation
             5. Check encoding validation logic
             
             Acceptance Criteria:
             - All tests pass
             - Code coverage >= 80%
             - No regressions from previous version
             
             Automation:
             - CI/CD: pytest scripts/
             - Trigger: Push to scripts/
             - Frequency: On every commit
             
             Test Coverage:
             - scripts/build-docs.py
             - scripts/generate-pdfs.py
             - scripts/check-encoding.py
             - scripts/validate-requirements.py (new)
             - scripts/validate-deployment.py (new)
         */
        
        attribute minCodeCoverage : Double = 0.80;
        attribute testsToRun : Integer = 50; /* Estimated */
    }

    /**
     * TEST_005: Documentation Generation and Consistency
     * Generated documentation must be valid, consistent, and complete
     */
    class DocumentationConsistencyTest :> TestPlanSpecification {
        doc /* Validate generated documentation
                 
             Related Requirements: SYSTEM_REQ_007 (Documentation Generation)
             Jira: TEST-005
             External: input/testing-requirements/documentation-validation.md
             
             Test Procedure:
             1. Generate all markdown files from SysML
             2. Check for broken references
             3. Validate PDF generation
             4. Check PDF metadata and naming
             5. Verify V-Model phase ordering (01_PMP_ → 11_DPL_)
             6. Check image references
             
             Acceptance Criteria:
             - All markdown files generated
             - No broken references
             - All PDFs generate successfully
             - PDF naming follows convention (NN_ABBR_name.pdf)
             - Navigation structure works
             
             Automation:
             - CI/CD: make docs; python scripts/validate-docs.py
             - Trigger: Push to sysml/ or publication/
             - Frequency: On every commit
         */
        
        attribute minMarkdownFiles : Integer = 20;
        attribute minPdfFiles : Integer = 10;
    }

    /**
     * TEST_006: Integration Tests - Cluster A Deployment
     * Test complete deployment of Cluster A in lab environment
     */
    class ClusterAIntegrationTest :> TestPlanSpecification {
        doc /* Integration test for Cluster A (lab-scale) deployment
                 
             Related Requirements: INFRA_REQ_001 (Cluster A), INFRA_REQ_010 (Terraform)
             Jira: TEST-006
             External: input/testing-requirements/cluster-a-integration.md
             
             Test Environment: Lab deployment in FabricationDatacenterA
             
             Test Procedure:
             1. Provision infrastructure with Terraform
             2. Run Ansible configuration playbooks
             3. Verify Kubernetes cluster is healthy
             4. Deploy test application
             5. Test pod networking
             6. Test service discovery
             7. Test persistent volumes (local storage)
             8. Validate logs and metrics are flowing
             9. Tear down and verify cleanup
             
             Acceptance Criteria:
             - Terraform apply succeeds
             - All nodes join cluster
             - kubectl get nodes: all Ready
             - Test pods run and communicate
             - Services DNS resolves correctly
             - Local storage provisioning works
             - Teardown completes without orphaned resources
             
             Estimated Duration: 30-45 minutes
             
             Automation:
             - CI/CD: scripts/test-cluster-a-integration.sh
             - Trigger: On demand (not per-commit)
             - Frequency: Daily/Weekly
             - Environment: Isolated lab network
         */
        
        attribute clusterNodesExpected : Integer = 3; /* 1 master + 2 workers */
        attribute estimatedDurationMinutes : Integer = 45;
    }

    /**
     * TEST_007: Integration Tests - Cluster B Deployment
     * Test complete deployment of Cluster B in staging environment
     */
    class ClusterBIntegrationTest :> TestPlanSpecification {
        doc /* Integration test for Cluster B (production EKS-like) deployment
                 
             Related Requirements: INFRA_REQ_002 (Cluster B), INFRA_REQ_010 (Terraform)
             Jira: TEST-007
             External: input/testing-requirements/cluster-b-integration.md
             
             Test Environment: Staging deployment across FabricationDatacenterA + B
             
             Test Procedure:
             1. Provision etcd cluster across 3 datacenters/zones
             2. Provision 3 master nodes (HA control plane)
             3. Provision initial worker nodes (5+)
             4. Run Ansible configuration playbooks
             5. Verify Kubernetes cluster HA functionality
             6. Test control plane failover scenarios
             7. Deploy distributed storage backend
             8. Test persistent volumes with replication
             9. Test cross-datacenter networking
             10. Test load balancer and ingress
             11. Validate monitoring and logging
             12. Test backup and recovery procedures
             13. Test scaling operations
             14. Tear down and verify cleanup
             
             Acceptance Criteria:
             - Terraform apply succeeds across both datacenters
             - All 3 masters join cluster and form quorum
             - kubectl get nodes: all Ready (3+ masters, 5+ workers)
             - Control plane HA verified
             - Distributed storage operational
             - Cross-datacenter latency acceptable
             - Load balancer distributes traffic
             - Monitoring collects metrics
             - Logging centralized successfully
             - Backup restore tested successfully
             - Scaling operations work
             - Teardown completes without orphaned resources
             
             Estimated Duration: 90-120 minutes
             
             Automation:
             - CI/CD: scripts/test-cluster-b-integration.sh
             - Trigger: On demand (not per-commit)
             - Frequency: Weekly/Monthly
             - Environment: Multi-datacenter staging network
         */
        
        attribute clusterNodesExpected : Integer = 8; /* 3 masters + 5 workers minimum */
        attribute datacentersInvolved : Integer = 2;
        attribute estimatedDurationMinutes : Integer = 120;
    }

    /**
     * TEST_008: Failover and Disaster Recovery Tests
     * Test failover scenarios and disaster recovery procedures
     */
    class FailoverAndDRTest :> TestPlanSpecification {
        doc /* Failover and disaster recovery testing
                 
             Related Requirements: SYSTEM_REQ_002 (Multi-Datacenter), INFRA_REQ_008 (Backup)
             Jira: TEST-008
             External: input/testing-requirements/failover-dr.md
             
             Test Scenarios:
             1. Single node failure
                - Verify pod rescheduling
                - Verify traffic rerouting
             2. Master node failure (Cluster B)
                - Verify cluster remains operational
                - Verify control plane recovers
             3. Datacenter network partition
                - Verify split-brain protection
                - Verify recovery on reconnect
             4. Complete datacenter failure
                - Verify failover to DR site
                - Verify service continuity
             5. etcd data corruption
                - Verify cluster recovery from backup
                - Verify data integrity post-recovery
             
             Acceptance Criteria:
             - Single node failure: pods rescheduled in < 5 minutes
             - Master failure: cluster operational with remaining masters
             - Network partition: split-brain prevented
             - Datacenter failover: services migrate in < 15 minutes
             - etcd recovery: cluster operational, no data loss
             
             Estimated Duration: 60-90 minutes per test scenario
             
             Automation:
             - CI/CD: scripts/test-failover-scenarios.sh
             - Trigger: On demand, monthly
             - Frequency: Monthly
             - Environment: Production-like staging
         */
        
        attribute failoverScenarios : Integer = 5;
        attribute maxAcceptableFailoverTimeSeconds : Integer = 900; /* 15 minutes */
    }

    /**
     * DEPLOY_001: Deployment Plan - Definition and Validation
     */
    class DeploymentPlanDefinition {
        doc /* Deployment plan structure and validation
                 
             Related Requirements: SYSTEM_REQ_009 (Deployment Automation)
             Jira: DEPLOY-001
             External: input/deployment-procedures/deployment-plan.md
             
             Deployment Process:
             1. Pre-deployment checks
                - Review deployment checklist
                - Obtain approvals from CISO, release manager, infrastructure lead
                - Verify all tests passed
             2. Pre-flight validation
                - Terraform plan review
                - Ansible dry-run
                - Security scanning
             3. Execution
                - Apply Terraform changes
                - Execute Ansible playbooks
                - Monitor deployment progress
             4. Post-deployment validation
                - Smoke tests
                - Health checks
                - Monitoring and alerting verification
             5. Rollback (if needed)
                - Identify rollback trigger
                - Execute rollback procedure
                - Verify pre-deployment state
             
             Approval Gates:
             - Security approval (CISO)
             - Release approval (Release Manager)
             - Infrastructure approval (Ops Lead)
             
             Rollback Criteria:
             - Critical service unavailable > 5 minutes
             - Data corruption detected
             - Security incident
             - Manual decision by Ops Lead
             
             Deployment Safety:
             - All changes reviewed (Terraform)
             - Dry-run executed before apply
             - Rollback procedure tested
             - Monitoring in place
             - Communication plan ready
         */
        
        attribute requiresApproval : Boolean = true;
        attribute approversRequired : String[] = {"CISO", "ReleaseManager", "OpsLead"};
        attribute rollbackCapabilityRequired : Boolean = true;
        attribute preFlightValidationRequired : Boolean = true;
    }

    /**
     * DEPLOY_002: Staged Rollout - Canary Deployment
     */
    class CanaryDeploymentStrategy {
        doc /* Canary deployment reduces risk of defective releases
                 
             Related Requirements: SYSTEM_REQ_009 (Deployment Automation)
             Jira: DEPLOY-002
             External: input/deployment-procedures/canary-strategy.md
             
             Canary Procedure:
             1. Deploy to 10% of infrastructure (e.g., 1 worker node)
             2. Monitor metrics and logs for 30 minutes
             3. If healthy, deploy to 50% of infrastructure
             4. Monitor for another 30 minutes
             5. If healthy, deploy to 100%
             6. Final validation and monitoring
             
             Metrics Monitored:
             - Application error rates
             - API latency (p50, p95, p99)
             - Resource utilization (CPU, memory)
             - Pod restart rates
             - Network errors
             
             Rollback Triggers:
             - Error rate > 0.1%
             - Latency p99 > 2x baseline
             - Pod restart rate > 5%
             - Custom metric threshold breaches
             
             Estimated Duration: 2+ hours
         */
        
        attribute stage1PercentageNodes : Integer = 10;
        attribute stage2PercentageNodes : Integer = 50;
        attribute stage3PercentageNodes : Integer = 100;
        attribute monitoringIntervalMinutes : Integer = 30;
        attribute canaryErrorRateThreshold : Double = 0.001; /* 0.1% */
    }

    /**
     * DEPLOY_003: Project Integration - Jira and GitLab
     */
    class ProjectIntegrationForDeployment {
        doc /* Project management system integration for deployments
                 
             Related Requirements: SYSTEM_REQ_008 (Project Management Integration)
             Jira: DEPLOY-003
             External: input/deployment-procedures/project-integration.md
             
             Integration Points:
             1. Jira Issue Creation
                - Deployment ticket: type "Deployment"
                - Links to related requirements (SYSTEM_REQ_*, INFRA_REQ_*)
                - Links to related test cases (TEST_*)
                - Deployment checklist as acceptance criteria
                - Status workflow: TODO → IN_PROGRESS → DONE
             
             2. GitLab Merge Request
                - All changes committed to feature branch
                - MR links to Jira deployment ticket
                - Code review required (minimum 2 approvals)
                - CI/CD pipeline passes
                - Security scanning passes
                - MR description includes deployment plan
             
             3. Automated Status Updates
                - CI/CD pipeline updates Jira status
                - When tests pass: Jira transitions to "READY_FOR_DEPLOYMENT"
                - When deployment starts: Jira transitions to "IN_PROGRESS"
                - When deployment succeeds: Jira transitions to "DONE"
                - When rollback occurs: Jira transitions to "ROLLED_BACK"
             
             4. Deployment Checklist
                - Pre-deployment: All items checked
                - Approvals documented as Jira comments
                - Deployment start time recorded
                - Deployment end time recorded
                - Rollback executed or not (documented)
         */
        
        attribute jiraIntegrationEnabled : Boolean = true;
        attribute gitlabMRRequiredForDeployment : Boolean = true;
        attribute codeReviewApprovalsRequired : Integer = 2;
        attribute automaticStatusUpdateEnabled : Boolean = true;
        attribute deploymentChecklistRequired : Boolean = true;
    }

    /**
     * Container: All test and deployment plans
     */
    part testPlans : TestPlanSpecification[*] {
        part sysmlValidation : SysMLSyntaxValidationTest;
        part terraformValidation : TerraformValidationTest;
        part ansibleLinting : AnsibleLintingTest;
        part pythonTests : PythonUnitTestsTest;
        part docConsistency : DocumentationConsistencyTest;
        part clusterAInteg : ClusterAIntegrationTest;
        part clusterBInteg : ClusterBIntegrationTest;
        part failoverTests : FailoverAndDRTest;
    }

    part deploymentPlans : DeploymentPlanDefinition;
    part canaryStrategy : CanaryDeploymentStrategy;
    part projectIntegration : ProjectIntegrationForDeployment;
}
