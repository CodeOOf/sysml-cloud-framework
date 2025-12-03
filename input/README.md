# External Requirements Documents

This folder contains the authoritative source documents for requirements that feed into the SysML models.

## Structure

```
input/
├── system-requirements/          # System-level requirements documents
│   ├── cluster-design.md         # (SYSTEM_REQ_001) Cluster architecture requirements
│   ├── disaster-recovery.md      # (SYSTEM_REQ_002) Multi-datacenter and DR strategy
│   ├── code-reuse.md             # (SYSTEM_REQ_003) Shared library requirements
│   ├── traceability.md           # (SYSTEM_REQ_004) Requirements traceability strategy
│   ├── iac-practices.md          # (SYSTEM_REQ_005) Infrastructure as Code standards
│   ├── testing-strategy.md       # (SYSTEM_REQ_006) Testing and validation requirements
│   ├── documentation-strategy.md # (SYSTEM_REQ_007) Documentation generation requirements
│   ├── project-integration.md    # (SYSTEM_REQ_008) Project management integration
│   ├── deployment-strategy.md    # (SYSTEM_REQ_009) Deployment automation requirements
│   └── vendor-integration.md     # (SYSTEM_REQ_010) Vendor documentation integration
│
├── infrastructure-requirements/  # Infrastructure sub-system requirements
│   ├── cluster-a-design.md       # (INFRA_REQ_001) Cluster A architecture
│   ├── cluster-b-design.md       # (INFRA_REQ_002) Cluster B HA architecture
│   ├── container-runtime.md      # (INFRA_REQ_003) Containerd specifications
│   ├── network-plugin.md         # (INFRA_REQ_004) Flannel network configuration
│   ├── storage-design.md         # (INFRA_REQ_005) Storage backend design
│   ├── security-policies.md      # (INFRA_REQ_006) RBAC and security policies
│   ├── observability.md          # (INFRA_REQ_007) Monitoring and logging requirements
│   ├── backup-dr.md              # (INFRA_REQ_008) Backup and disaster recovery procedures
│   ├── load-balancing.md         # (INFRA_REQ_009) Load balancer and ingress configuration
│   └── terraform-standards.md    # (INFRA_REQ_010) Terraform module organization standards
│
├── fabrication-requirements/     # Fabrication sub-system requirements
│   ├── datacenter-a-design.md    # (FAB_REQ_001) Fabrication Datacenter A specifications
│   ├── datacenter-b-design.md    # (FAB_REQ_002) Fabrication Datacenter B specifications
│   ├── rack-design.md            # (FAB_REQ_003) Physical rack design and layout
│   ├── network-connectivity.md   # (FAB_REQ_004) Inter-datacenter network connectivity
│   ├── power-cooling.md          # (FAB_REQ_005) Power and cooling infrastructure
│   ├── physical-security.md      # (FAB_REQ_006) Physical security and access control
│   ├── environmental-monitoring.md # (FAB_REQ_007) Environmental monitoring and alerts
│   ├── floorplan.md              # (FAB_REQ_008) Floorplan and facility layout
│   ├── room-infrastructure.md    # (FAB_REQ_009) Room infrastructure and facilities
│   └── virtualization.md         # (FAB_REQ_010) Virtualization and hypervisor support
│
└── testing-deployment/          # Testing and deployment procedure documents
    ├── sysml-validation.md       # (TEST_001) SysML model syntax validation procedure
    ├── terraform-validation.md   # (TEST_002) Terraform configuration validation procedure
    ├── ansible-validation.md     # (TEST_003) Ansible playbook linting procedure
    ├── python-unit-tests.md      # (TEST_004) Python script unit test procedures
    ├── documentation-validation.md # (TEST_005) Documentation generation validation
    ├── cluster-a-integration.md  # (TEST_006) Cluster A integration test procedure
    ├── cluster-b-integration.md  # (TEST_007) Cluster B integration test procedure
    ├── failover-dr.md            # (TEST_008) Failover and DR test procedures
    ├── deployment-plan.md        # (DEPLOY_001) Deployment plan and approval gates
    ├── canary-strategy.md        # (DEPLOY_002) Canary deployment strategy
    └── project-integration.md    # (DEPLOY_003) Jira and GitLab integration for deployments
```

## Document Format

Each requirement document should follow this format:

```markdown
# [REQUIREMENT_ID]: [Title]

**Status**: DRAFT | APPROVED | IMPLEMENTED | VERIFIED
**Owner**: [Team/Person]
**Last Updated**: [Date]
**Parent Requirement**: [Link to parent SYSTEM_REQ_* or related requirement]

## Overview
Brief description of the requirement.

## Acceptance Criteria
- Criterion 1
- Criterion 2
- Criterion 3

## Related System Requirement
Links to SYSTEM_REQ_*, INFRA_REQ_*, FAB_REQ_* that this document feeds.

## SysML Traceability
References to SysML model elements (classes, attributes) that implement this requirement.

## Implementation Guidance
How this requirement is typically implemented in the project.

## Vendor Documentation
Links to external vendor documentation (see vendor-docs/ folder).

## Approval Sign-Off
- [ ] Stakeholder approval
- [ ] Technical review
- [ ] Security review (if applicable)
```

## Integration with SysML Models

Each document in `input/` folder has a corresponding SysML model element with:

1. **Document Reference**: `externalDocumentRef` attribute points to this file
2. **Requirement ID**: Unique ID (SYSTEM_REQ_001, INFRA_REQ_001, etc.)
3. **Jira Link**: Issue tracking reference in `externalSourceId`
4. **Version Tracking**: Document version in `version` attribute

### Example: Linking a Document to SysML

**File**: `input/system-requirements/cluster-design.md`

**SysML Model Reference** (in `sysml/overall-design/SystemRequirementsDefinition.sysml`):
```sysml
class ClusterArchitectureRequirement :> SystemRequirement {
    doc /* Cluster architecture must be flexible and scalable
             References:
             - Jira: PLAT-001
             - External: input/system-requirements/cluster-design.md
         */
    // ... requirement details ...
}
```

## Creating New Requirement Documents

1. Create document in appropriate `input/` subfolder
2. Reference Jira issue (create if doesn't exist)
3. Update SysML model with `externalDocumentRef` pointing to new document
4. Ensure SysML doc block references the document
5. Update this README with new document link

## Document Status Workflow

```
DRAFT → APPROVED → IMPLEMENTED → VERIFIED
  ↓       ↓           ↓            ↓
Authored Under Review Coded      Tested
```

### Status Definitions

- **DRAFT**: Initial document, not yet reviewed
- **APPROVED**: Reviewed and approved by stakeholders
- **IMPLEMENTED**: Code/configuration implemented per document
- **VERIFIED**: Implementation tested and validated

## Approval Requirements

| Document Type | Reviewers | Approvers |
|---|---|---|
| System Requirements | Tech Lead, Arch | CTO, Product Owner |
| Infrastructure Req | SRE Lead, Security | Ops Lead, CISO |
| Fabrication Req | Facilities, Network | Facilities Manager |
| Testing/Deployment | QA Lead, DevOps | Release Manager |

## Maintenance

- Review and update documents quarterly
- Archive outdated documents to `archive/` subfolder
- Maintain change history in document

## Integration with Build Pipeline

When running `make docs`, the build pipeline:

1. Reads all `.sysml` files
2. Extracts `externalDocumentRef` attributes
3. Validates referenced documents exist
4. Generates traceability report
5. Embeds document references in generated markdown/PDF

To see all external document references:
```bash
grep -r "externalDocumentRef" sysml/ | sort | uniq
```
