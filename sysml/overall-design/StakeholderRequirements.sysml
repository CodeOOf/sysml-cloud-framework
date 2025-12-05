// StakeholderRequirements.sysml
// Phase 02: Stakeholder Needs and Requirements
// Uses SysML v2 requirements pattern with actors, requirements, and test cases
// 
// Visual conventions:
// - Actors (stakeholders): stick figures
// - Requirements: wheat/tan color boxes
// - Test cases: green color boxes
// - Relationships: «trace», «satisfy», «verify»

package StakeholderRequirements {
  
  // ========== ACTORS (Stakeholders as stick figures) ==========
  
  actor 'Business Unit Manager' {
    doc /* Responsible for business case, ROI, budget approval */
  }
  
  actor 'Enterprise Architect' {
    doc /* Responsible for architecture governance and standards */
  }
  
  actor 'Operations Team' {
    doc /* Responsible for deployment, monitoring, reliability */
  }
  
  actor 'Development Team' {
    doc /* Responsible for application development and CI/CD */
  }
  
  actor 'Security Team' {
    doc /* Responsible for compliance and data protection */
  }
  
  // ========== BUSINESS REQUIREMENTS (Wheat/Tan Color) ==========
  
  requirement CostReduction {
    doc /* 
     * Reduce infrastructure operational costs by 30%
     * Target: $240K annual savings
     * Timeline: Within 24 months
     */
    text = "The private cloud platform shall reduce infrastructure operational costs by 30% compared to current baseline.";
    reqId = "BR-001";
  }
  
  requirement DataSovereignty {
    doc /*
     * Maintain data sovereignty and compliance
     * All data remains within controlled datacenter facilities
     */
    text = "The system shall ensure all customer data remains within on-premises datacenter facilities under organizational control.";
    reqId = "BR-002";
  }
  
  requirement HighAvailability {
    doc /*
     * Ensure 99.9% uptime SLA
     * Maximum 8.76 hours downtime per year
     */
    text = "The system shall provide 99.9% availability, measured monthly, excluding planned maintenance windows.";
    reqId = "BR-003";
  }
  
  requirement RapidDeployment {
    doc /*
     * Improve deployment speed 10x
     * From hours to minutes
     */
    text = "The system shall enable application deployment within 15 minutes from code commit to production readiness.";
    reqId = "BR-004";
  }
  
  requirement SecurityCompliance {
    doc /*
     * Meet SOC2 Type II and ISO 27001 requirements
     * Maintain audit trail and access controls
     */
    text = "The system shall implement security controls compliant with SOC2 Type II and ISO 27001 standards.";
    reqId = "BR-005";
  }
  
  // ========== TECHNICAL REQUIREMENTS (Wheat/Tan Color) ==========
  
  requirement ScalableInfrastructure {
    doc /*
     * Support horizontal and vertical scaling
     * Auto-scaling based on workload
     */
    text = "The infrastructure shall support horizontal scaling across 50+ compute nodes and vertical scaling per workload demands.";
    reqId = "TR-001";
  }
  
  requirement InfrastructureAsCode {
    doc /*
     * All infrastructure defined as code
     * Version controlled and reproducible
     */
    text = "All infrastructure components shall be defined using Infrastructure as Code with version control and automated provisioning.";
    reqId = "TR-002";
  }
  
  requirement ObservabilityMonitoring {
    doc /*
     * Comprehensive monitoring and alerting
     * Real-time visibility into system health
     */
    text = "The system shall provide real-time monitoring, logging, and alerting for all infrastructure components with <5 minute alert latency.";
    reqId = "TR-003";
  }
  
  requirement DisasterRecovery {
    doc /*
     * RPO: 1 hour, RTO: 4 hours
     * Automated backup and recovery
     */
    text = "The system shall support automated disaster recovery with RPO of 1 hour and RTO of 4 hours.";
    reqId = "TR-004";
  }
  
  requirement OpenStandards {
    doc /*
     * Avoid vendor lock-in
     * Use open standards and APIs
     */
    text = "The system shall use open standards (OCI, CNI, CSI) and avoid proprietary vendor lock-in.";
    reqId = "TR-005";
  }
  
  // ========== OPERATIONAL REQUIREMENTS (Wheat/Tan Color) ==========
  
  requirement AutomatedOrchestration {
    doc /*
     * Kubernetes-based orchestration
     * Automated workload management
     */
    text = "The system shall use Kubernetes for container orchestration with automated workload scheduling and management.";
    reqId = "OR-001";
  }
  
  requirement SelfServiceProvisioning {
    doc /*
     * Development teams can self-provision resources
     * Within approved resource quotas
     */
    text = "The system shall provide self-service resource provisioning for development teams within approved quotas and policies.";
    reqId = "OR-002";
  }
  
  requirement ContinuousDeployment {
    doc /*
     * CI/CD pipeline integration
     * Automated testing and deployment
     */
    text = "The system shall integrate with CI/CD pipelines for automated testing and continuous deployment workflows.";
    reqId = "OR-003";
  }
  
  requirement ResourceOptimization {
    doc /*
     * Efficient resource utilization
     * Automated bin packing and scheduling
     */
    text = "The system shall optimize resource utilization achieving >70% average CPU/memory utilization across the cluster.";
    reqId = "OR-004";
  }
  
  // ========== TEST CASES (Green Color) ==========
  
  test case VerifyCostReduction {
    doc /*
     * Verify 30% cost reduction achieved
     * Compare current vs baseline costs
     */
    objective = "Verify that infrastructure operational costs are reduced by 30% compared to baseline";
    verify CostReduction;
  }
  
  test case VerifyDataSovereignty {
    doc /*
     * Verify all data remains on-premises
     * Audit data storage locations
     */
    objective = "Verify that all customer data resides within on-premises datacenter facilities";
    verify DataSovereignty;
  }
  
  test case VerifyHighAvailability {
    doc /*
     * Verify 99.9% uptime SLA
     * Measure actual availability over 30 days
     */
    objective = "Verify system availability meets or exceeds 99.9% over a 30-day measurement period";
    verify HighAvailability;
  }
  
  test case VerifyRapidDeployment {
    doc /*
     * Verify deployment time <15 minutes
     * Measure end-to-end deployment pipeline
     */
    objective = "Verify application deployment completes within 15 minutes from commit to production-ready";
    verify RapidDeployment;
  }
  
  test case VerifySecurityCompliance {
    doc /*
     * Verify SOC2 and ISO 27001 compliance
     * Security audit and penetration testing
     */
    objective = "Verify security controls meet SOC2 Type II and ISO 27001 requirements through audit";
    verify SecurityCompliance;
  }
  
  test case VerifyScalability {
    doc /*
     * Verify horizontal/vertical scaling
     * Load testing with increasing workload
     */
    objective = "Verify infrastructure scales to 50+ nodes and handles 10x workload increase";
    verify ScalableInfrastructure;
  }
  
  test case VerifyInfrastructureAsCode {
    doc /*
     * Verify all infrastructure is code-defined
     * Audit infrastructure definitions
     */
    objective = "Verify 100% of infrastructure is defined in version-controlled IaC templates";
    verify InfrastructureAsCode;
  }
  
  test case VerifyMonitoring {
    doc /*
     * Verify monitoring and alerting works
     * Test alert generation and latency
     */
    objective = "Verify monitoring captures all components and alerts trigger within 5 minutes";
    verify ObservabilityMonitoring;
  }
  
  test case VerifyDisasterRecovery {
    doc /*
     * Verify backup and recovery procedures
     * Simulate disaster scenario
     */
    objective = "Verify disaster recovery achieves RPO of 1 hour and RTO of 4 hours in simulated failure";
    verify DisasterRecovery;
  }
  
  test case VerifyOpenStandards {
    doc /*
     * Verify use of open standards
     * Audit APIs and interfaces
     */
    objective = "Verify system uses open standards (OCI, CNI, CSI) and avoids proprietary vendor APIs";
    verify OpenStandards;
  }
  
  // ========== RELATIONSHIPS ==========
  
  // Actors trace to requirements they care about
  
  // Business Unit Manager cares about cost and business value
  connect 'Business Unit Manager' to CostReduction;
  connect 'Business Unit Manager' to HighAvailability;
  connect 'Business Unit Manager' to RapidDeployment;
  
  // Enterprise Architect cares about architecture and standards
  connect 'Enterprise Architect' to ScalableInfrastructure;
  connect 'Enterprise Architect' to InfrastructureAsCode;
  connect 'Enterprise Architect' to OpenStandards;
  
  // Operations Team cares about operational aspects
  connect 'Operations Team' to AutomatedOrchestration;
  connect 'Operations Team' to ObservabilityMonitoring;
  connect 'Operations Team' to DisasterRecovery;
  connect 'Operations Team' to ResourceOptimization;
  
  // Development Team cares about deployment and tooling
  connect 'Development Team' to RapidDeployment;
  connect 'Development Team' to SelfServiceProvisioning;
  connect 'Development Team' to ContinuousDeployment;
  
  // Security Team cares about compliance and security
  connect 'Security Team' to DataSovereignty;
  connect 'Security Team' to SecurityCompliance;
  
  // Requirements satisfy higher-level requirements
  satisfy CostReduction with ScalableInfrastructure;
  satisfy CostReduction with ResourceOptimization;
  satisfy RapidDeployment with ContinuousDeployment;
  satisfy RapidDeployment with AutomatedOrchestration;
  satisfy HighAvailability with DisasterRecovery;
  satisfy HighAvailability with ObservabilityMonitoring;
  satisfy SecurityCompliance with DataSovereignty;
  
  // Test cases verify requirements (already defined in test case)
  // verify relationships are implicit in "verify <requirement>" syntax
}
