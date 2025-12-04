# Publication Structure and Navigation Guide

This folder contains all generated and organized documentation for the cloud platform, organized by **V-Model Phases** and **PDF Output Structure**.

## Quick Navigation

### 📋 For Readers
- **First time?** Start here: [INDEX.md](INDEX.md)
- **Need quick answers?** See: [QUICK_REFERENCE.md](../QUICK_REFERENCE.md)
- **Want complete guide?** Read: [SYSML_ARCHITECTURE_GUIDE.md](../SYSML_ARCHITECTURE_GUIDE.md)
- **Looking for architecture diagrams?** See: [Architecture Components](#architecture-components) below

### 🔍 For Developers
- **Navigation by PDF**: See [PDF Organization](#pdf-organization) below
- **Markdown file mapping**: See [Markdown to PDF Mapping](#markdown-to-pdf-mapping)
- **Finding specific requirements**: See [Requirements Documents](#requirements-documents)
- **Looking for infrastructure code**: See [Architecture Components - Infrastructure](#infrastructure-architecture)

---

## PDF Organization

All PDFs are generated with **V-Model Phase prefixes** (e.g., `03_SRD_*`, `04_SAD_*`). Files in this folder map directly to those PDFs.

### V-Model Phase Mapping

```
Phase Number    Abbreviation    Document Purpose                 Markdown Files
─────────────────────────────────────────────────────────────────────────────────
01              PMP             Project Management Plan          SEMP.md
02              SNS             Stakeholder Needs Statement      (stakeholder-input)
03              SRD             System Requirements Document     *-requirements.md
04              SAD             System Architecture & Design     *-architecture-model.md, *-interfaces.md
05              SSR             SubSystem Requirements           (specific to datacenter/cluster)
06              SDD             Subsystem Detailed Design        (detailed configurations)
07              SCI             Software/Code Implementation     (Terraform/Ansible references)
08              ITP             Integration Test Plan           (test procedures)
09              STP             System Test Plan (Verification) (validation procedures)
10              SV              System Validation               (validation results)
11              DPL             Deployment Plan / O&M           (deployment procedures)
```

---

## PDF Output Files

### 01_PMP_* (Project Management Plan)

**PDF File**: `01_PMP_SEMP.pdf`

**Source Markdown**:
- `SEMP.md` - System Engineering Management Plan

**Contents**:
- Project scope and objectives
- V-Model lifecycle phases
- Document organization and naming conventions
- Traceability and requirements management
- Quality assurance and validation strategy
- Project governance and approval gates

**When to Read**: Start here for understanding project structure and process

---

### 03_SRD_* (System Requirements Documents)

**PDF Files**:
- `03_SRD_SysMLCloudPlatform.pdf` - Overall system requirements
- `03_SRD_SystemRequirements.pdf` - All requirements consolidated
- `03_SRD_Infrastructure.pdf` - Infrastructure requirements (Cluster A/B)
- `03_SRD_Datacenter.pdf` - Fabrication requirements (Datacenters A/B)

**Source Markdown**:
- `sys-mlcloud-platform-requirements.md` - System-level
- `infrastructure-requirements.md` - Infrastructure sub-system
- `datacenter-requirements.md` - Fabrication sub-system

**Contents** (03_SRD_SysMLCloudPlatform.pdf):
```
├── System Requirements Overview
│   ├── SYSTEM_REQ_001: Cluster Architecture
│   ├── SYSTEM_REQ_002: Multi-Datacenter Deployment
│   ├── SYSTEM_REQ_003: Shared Library Reusability
│   ├── SYSTEM_REQ_004: Requirements Traceability
│   ├── SYSTEM_REQ_005: IaC Implementation
│   ├── SYSTEM_REQ_006: Testing and Validation
│   ├── SYSTEM_REQ_007: Documentation Generation
│   ├── SYSTEM_REQ_008: Project Management Integration
│   ├── SYSTEM_REQ_009: Deployment Automation
│   └── SYSTEM_REQ_010: Vendor Documentation Integration
├── Acceptance Criteria for Each Requirement
├── External Document References (input/ folder)
├── Jira Traceability (SYSTEM_REQ_* issue keys)
└── Related SysML Models
```

**Contents** (03_SRD_Infrastructure.pdf):
```
├── Infrastructure Sub-System Requirements
│   ├── INFRA_REQ_001: Cluster A Single Master Architecture
│   ├── INFRA_REQ_002: Cluster B Multi-Master HA
│   ├── INFRA_REQ_003: Container Runtime (containerd)
│   ├── INFRA_REQ_004: Network Plugin (Flannel)
│   ├── INFRA_REQ_005: Storage Backend (local vs distributed)
│   ├── INFRA_REQ_006: Security Policies and RBAC
│   ├── INFRA_REQ_007: Monitoring and Logging
│   ├── INFRA_REQ_008: Backup and Disaster Recovery
│   ├── INFRA_REQ_009: Load Balancing and Ingress
│   └── INFRA_REQ_010: Terraform Module Organization
├── Cluster A vs Cluster B Comparison Table
├── External Source Documents (input/infrastructure-requirements/)
├── Jira Traceability (INFRA_REQ_* issue keys)
├── Related Terraform Implementations (configs/)
├── Related Ansible Implementations (library/ansible-roles/)
└── Cross-References to Fabrication Requirements
```

**Contents** (03_SRD_Datacenter.pdf):
```
├── Fabrication Sub-System Requirements
│   ├── FAB_REQ_001: Fabrication Datacenter A (Primary)
│   ├── FAB_REQ_002: Fabrication Datacenter B (Secondary/DR)
│   ├── FAB_REQ_003: Physical Rack Design
│   ├── FAB_REQ_004: Network Connectivity
│   ├── FAB_REQ_005: Power and Cooling Infrastructure
│   ├── FAB_REQ_006: Security and Physical Access Control
│   ├── FAB_REQ_007: Environmental Monitoring
│   ├── FAB_REQ_008: Floorplan and Layout Design
│   ├── FAB_REQ_009: Room Infrastructure and Facilities
│   └── FAB_REQ_010: Virtualization Support
├── Datacenter A vs Datacenter B Specifications
├── External Source Documents (input/fabrication-requirements/)
├── Jira Traceability (FAB_REQ_* issue keys)
├── Physical Topology Diagrams (SysML models)
└── Deployment Topology (which clusters live where)
```

**When to Read**: After understanding project structure; before reading architecture

---

### 04_SAD_* (System Architecture & Design Documents)

**PDF Files**:
- `04_SAD_SysMLCloudPlatform.pdf` - Overall architecture
- `04_SAD_Infrastructure.pdf` - Infrastructure architecture (Cluster A/B design)
- `04_SAD_Fabrication.pdf` - Fabrication architecture (Datacenter A/B design)

**Source Markdown**:
- `sys-mlcloud-platform-model.md` - System model
- `cluster-architecture-model.md` - Cluster architecture
- `datacenter-architecture-model.md` - Datacenter architecture
- `sys-mlcloud-platform-interfaces.md` - System interfaces and integration points

**Contents** (04_SAD_SysMLCloudPlatform.pdf):
```
├── System-Level Architecture Overview
│   ├── Cluster A (Lab-Scale)
│   ├── Cluster B (Production EKS-like)
│   ├── Fabrication Datacenter A (Primary)
│   └── Fabrication Datacenter B (Secondary/DR)
├── Multi-Datacenter Topology
├── Network Architecture
├── Storage Architecture
├── Security Architecture
├── Monitoring and Observability Stack
├── SysML Model Organization
│   ├── sysml/overall-design/
│   ├── sysml/infrastructure/
│   └── sysml/datacenter/
└── Design Rationale
```

**Contents** (04_SAD_Infrastructure.pdf):
```
├── Cluster A Design
│   ├── Architecture Diagram
│   ├── Component Description (Master, Workers, Storage)
│   ├── Container Runtime Configuration
│   ├── Network Design
│   ├── Storage Backend (Local)
│   ├── Security Policies
│   ├── Related Terraform Files (`configs/{instance-id}/`) — per-instance (replace `{instance-id}`)
│   └── Related Ansible Roles (library/ansible-roles/)
├── Cluster B Design
│   ├── Architecture Diagram
│   ├── Component Description (HA Masters, Workers, Distributed Storage)
│   ├── Container Runtime Configuration
│   ├── Network Design
│   ├── Storage Backend (Distributed)
│   ├── Security Policies
│   ├── Load Balancing
│   ├── Monitoring and Logging
│   ├── Related Terraform Files (`configs/{instance-id}/`) — per-instance (replace `{instance-id}`)
│   └── Related Ansible Roles (library/ansible-roles/)
├── Comparison Table (Cluster A vs B)
├── Design Decisions and Rationale
└── SysML Models
    ├── sysml/infrastructure/KubernetesClusterArchitecture.sysml
    └── sysml/infrastructure/InfrastructureSubSystemRequirements.sysml
```

**Contents** (04_SAD_Fabrication.pdf):
```
├── Fabrication Datacenter A (Primary Site)
│   ├── Physical Layout (Floorplan)
│   ├── Rack Design (RackA1, RackA2)
│   ├── Network Connectivity
│   ├── Power and Cooling
│   ├── Security and Access Control
│   ├── Environmental Monitoring
│   ├── Clusters Hosted (Cluster A + Cluster B Master 1)
│   ├── SysML Models (models/, views/)
│   └── Specifications (specs/datacenter.json)
├── Fabrication Datacenter B (Secondary/DR Site)
│   ├── Physical Layout (Floorplan)
│   ├── Rack Design (RackB1, RackB2+)
│   ├── Network Connectivity to Datacenter A
│   ├── Power and Cooling
│   ├── Security and Access Control
│   ├── Environmental Monitoring
│   ├── Clusters Hosted (Cluster B Masters 2-3 + Workers)
│   ├── SysML Models (models/, views/)
│   └── Specifications (specs/datacenter.json)
├── Inter-Datacenter Connectivity
├── Design Rationale (Why 2 datacenters? Why this distribution?)
└── SysML Models
    ├── sysml/datacenter/DeploymentArchitecture.sysml
    ├── sysml/datacenter/FabricationSubSystemRequirements.sysml
   ├── fabrications/{instance-id}/models/
   └── fabrications/{instance-id}/models/
```

**When to Read**: After reading requirements; before reading detailed design or implementation

---

### 06_SDD_* (Subsystem Detailed Design Documents)

**PDF Files**:
- `06_SDD_FabricationDatacenterA.pdf` - Datacenter A detailed design
- `06_SDD_FabricationDatacenterB.pdf` - Datacenter B detailed design

**Source Markdown**:
- `floorplan.md` - Physical floor layout
- `room-model.md` - Room infrastructure design
- `rack-model.md` - Rack design and equipment
- `rack-a1.md`, `rack-a2.md` - Specific racks in Datacenter A
- `rack-b1.md` - Specific racks in Datacenter B
- `rack-a1-view.md`, `rackb1-view.md` - Rack visual representations
- `power-cooling-interfaces.md` - Power and cooling specifications
- `network-model.md` - Network specifications
- `virtualization-model.md` - Virtualization specifications
- `service-catalog-model.md` - Services offered

**Contents** (06_SDD_FabricationDatacenterA.pdf):
```
├── Datacenter A Detailed Specifications
│   ├── Physical Room Layout and Floorplan
│   ├── Rack A1 Detailed Design
│   │   ├── Equipment Specifications
│   │   ├── Power Distribution
│   │   ├── Network Port Mapping
│   │   └── Thermal Profile
│   ├── Rack A2 Detailed Design
│   │   └── (Similar to Rack A1)
│   ├── Network Connections and Cable Routing
│   ├── Power Distribution and UPS Configuration
│   ├── Cooling System Layout
│   ├── Environmental Monitoring Points
│   ├── Security Access Points and CCTV
│   └── Deployment Procedures (detailed step-by-step)
├── Cluster A Deployment Details
│   ├── Master Node Placement (Rack A1, Unit X)
│   ├── Worker Node Placement (Rack A1-A2, Units Y-Z)
│   ├── Storage Configuration (Local)
│   └── Network Configuration
├── Cluster B Component Placement (Master 1 only)
│   └── Master 1 Node Placement and Networking
└── Implementation Files
   ├── fabrications/{instance-id}/models/
   ├── fabrications/{instance-id}/specs/
   ├── fabrications/{instance-id}/views/
   ├── configs/{instance-id}/
    └── library/ansible-roles/
```

**When to Read**: When physically building or reconfiguring datacenters

---

### Additional Markdown Files (Component Models)

These markdown files provide detailed architectural models and are organized by component:

#### Cluster Architecture
- `cluster-architecture-model.md` → Used in `04_SAD_Infrastructure.pdf`
- `rack-model.md` → Used in `06_SDD_Datacenter*.pdf`

#### Infrastructure Models
- `network-model.md` → System interfaces and networking
- `power-cooling-interfaces.md` → Power and thermal design
- `virtualization-model.md` → Hypervisor and container runtime
- `service-catalog-model.md` → Available services and APIs

#### Component Details
- `rack-a1.md`, `rack-a2.md`, `rack-b1.md` → Specific equipment configurations
- `rack-a1-view.md`, `rack-b1-view.md` → Visual representations

#### System Interfaces
- `sys-mlcloud-platform-model.md` → Overall system design
- `sys-mlcloud-platform-interfaces.md` → External interfaces (→ 04_SAD_SysMLCloudPlatform.pdf)
- `sys-mlcloud-platform-requirements.md` → System-level requirements (→ 03_SRD_SysMLCloudPlatform.pdf)

---

## Markdown to PDF Mapping

### Quick Lookup Table

| Markdown File | Primary PDF | Secondary PDF | Phase | Purpose |
|---|---|---|---|---|
| SEMP.md | 01_PMP_SEMP.pdf | - | PMP | Project management |
| sys-mlcloud-platform-requirements.md | 03_SRD_SysMLCloudPlatform.pdf | 03_SRD_SystemRequirements.pdf | SRD | System requirements |
| infrastructure-requirements.md | 03_SRD_Infrastructure.pdf | 03_SRD_SystemRequirements.pdf | SRD | Infrastructure req |
| datacenter-requirements.md | 03_SRD_Datacenter.pdf | 03_SRD_SystemRequirements.pdf | SRD | Fabrication req |
| sys-mlcloud-platform-model.md | 04_SAD_SysMLCloudPlatform.pdf | - | SAD | System architecture |
| sys-mlcloud-platform-interfaces.md | 04_SAD_SysMLCloudPlatform.pdf | - | SAD | System interfaces |
| cluster-architecture-model.md | 04_SAD_Infrastructure.pdf | - | SAD | Cluster architecture |
| datacenter-architecture-model.md | 04_SAD_Fabrication.pdf | - | SAD | Datacenter architecture |
| network-model.md | 04_SAD_SysMLCloudPlatform.pdf | - | SAD | Network design |
| power-cooling-interfaces.md | 06_SDD_FabricationDatacenterA/B.pdf | 04_SAD_Fabrication.pdf | SDD | Power/cooling |
| virtualization-model.md | 04_SAD_Infrastructure.pdf | 06_SDD_Datacenter*.pdf | SAD/SDD | Virtualization |
| service-catalog-model.md | 04_SAD_SysMLCloudPlatform.pdf | - | SAD | Services |
| floorplan.md | 06_SDD_FabricationDatacenterA/B.pdf | - | SDD | Physical layout |
| room-model.md | 06_SDD_FabricationDatacenterA/B.pdf | - | SDD | Room design |
| rack-model.md | 06_SDD_FabricationDatacenterA/B.pdf | 04_SAD_Fabrication.pdf | SDD | Rack design |
| rack-a1.md, rack-a2.md | 06_SDD_FabricationDatacenterA.pdf | - | SDD | Rack A specifics |
| rack-b1.md | 06_SDD_FabricationDatacenterB.pdf | - | SDD | Rack B specifics |
| rack-a1-view.md | 06_SDD_FabricationDatacenterA.pdf | - | SDD | Visual - Rack A |
| rack-b1-view.md | 06_SDD_FabricationDatacenterB.pdf | - | SDD | Visual - Rack B |
| index.md | (metadata only) | - | - | Entry point |

---

## Architecture Components

### System-Level Architecture

**File**: `sys-mlcloud-platform-model.md`

Contains the high-level system design showing how Cluster A, Cluster B, and Datacenters A/B fit together.

**Related Files**:
- `sys-mlcloud-platform-interfaces.md` - Integration points
- `sys-mlcloud-platform-requirements.md` - Requirements driving the design
- SysML Model: `sysml/overall-design/SysMLCloudPlatformModel.sysml`

---

### Infrastructure Architecture

**Files**:
- `cluster-architecture-model.md` - Both Cluster A and B design
- `network-model.md` - Networking specification
- `virtualization-model.md` - Container runtime and virtualization

**Related SysML Models**:
- `sysml/infrastructure/KubernetesClusterArchitecture.sysml`
- `sysml/infrastructure/InfrastructureSubSystemRequirements.sysml`

**Related Code**:
- `library/terraform-modules/` - Reusable Terraform modules
- `library/ansible-roles/` - Reusable Ansible roles
- `configs/{instance-id}/` - Per-instance Terraform/Ansible (replace `{instance-id}`)
- `configs/{instance-id}/` - Per-instance Terraform/Ansible (replace `{instance-id}`)

---

### Fabrication Architecture

**Files**:
- `datacenter-architecture-model.md` - Multi-datacenter design
- `floorplan.md` - Physical layout
- `room-model.md` - Room infrastructure
- `rack-model.md` - Rack design standards
- `rack-a1.md`, `rack-a2.md`, `rack-b1.md` - Specific rack configurations
- `power-cooling-interfaces.md` - Power and thermal
- `network-model.md` - Datacenter networking

**Related SysML Models**:
- `sysml/datacenter/DeploymentArchitecture.sysml`
- `sysml/datacenter/FabricationSubSystemRequirements.sysml`

**Related Files**:
- `fabrications/{instance-id}/models/` (per-instance; replace `{instance-id}`)
- `fabrications/{instance-id}/models/` (per-instance; replace `{instance-id}`)

---

## Requirements Documents

Location: `input/` folder (external documents referenced by SysML models)

### System-Level Requirements
- `input/system-requirements/` - 10 system-level requirements

### Infrastructure Sub-System Requirements
- `input/infrastructure-requirements/` - 10 infrastructure-specific requirements

### Fabrication Sub-System Requirements
- `input/fabrication-requirements/` - 10 fabrication-specific requirements

### Testing & Deployment Requirements
- `input/testing-deployment/` - Test and deployment procedures

**How to Find a Requirement**:

1. Search for requirement ID in SysML models
   ```bash
   grep -r "SYSTEM_REQ_001" sysml/
   grep -r "INFRA_REQ_001" sysml/
   grep -r "FAB_REQ_001" sysml/
   ```

2. Find external document reference
   ```bash
   grep -r "externalDocumentRef" sysml/ | grep "SYSTEM_REQ_001"
   ```

3. Read the external document
   ```bash
   cat input/system-requirements/cluster-design.md
   ```

---

## Navigation Commands

### Generate complete documentation with all markdown and PDFs

```bash
make clean
make docs
make pdf
```

### Generate specific PDFs

```bash
# System requirements only
python scripts/generate-pdfs.py publication --filter "03_SRD"

# Architecture and design
python scripts/generate-pdfs.py publication --filter "04_SAD"

# Detailed design
python scripts/generate-pdfs.py publication --filter "06_SDD"
```

### View specific markdown file

```bash
# System requirements
cat publication/sys-mlcloud-platform-requirements.md

# Infrastructure architecture
cat publication/cluster-architecture-model.md

# Datacenter detailed design
cat publication/floorplan.md
```

### Search for requirements

```bash
# Find all mentions of specific requirement
grep -r "SYSTEM_REQ_001" .

# Find all external document references
grep -r "externalDocumentRef" sysml/

# Find all Jira issue links
grep -r "jiraIssue\|externalSourceId" sysml/
```

---

## File Organization Best Practices

### For Developers Working on Infrastructure

1. **Read in this order**:
   - `INDEX.md` - Understand project structure
   - `03_SRD_Infrastructure.pdf` - Understand requirements for your cluster
   - `04_SAD_Infrastructure.pdf` - Understand design
   - `configs/{instance-id}/README.md` - Implementation guide (replace `{instance-id}` with your cluster id)

2. **Reference materials**:
   - `QUICK_REFERENCE.md` - Common tasks
   - `vendor-docs/` - Official vendor documentation
   - `input/infrastructure-requirements/` - Detailed requirement documents

### For Facility/Operations Teams

1. **Read in this order**:
   - `03_SRD_Datacenter.pdf` - Understand requirements
   - `04_SAD_Fabrication.pdf` - Understand design
   - `06_SDD_FabricationDatacenter*.pdf` - Detailed specifications and procedures

2. **Reference materials**:
   - `floorplan.md` - Physical layout
   - `fabrications/{instance-id}/` - Detailed specs (replace `{instance-id}` with your datacenter id)
   - `vendor-docs/` - Equipment vendor documentation

### For Project Managers

1. **Read in this order**:
   - `01_PMP_SEMP.pdf` - Project structure and phases
   - `03_SRD_SystemRequirements.pdf` - Requirements overview
   - Status: Open `input/` folder for requirement tracking

2. **Integration points**:
   - Jira project keys: PLAT-*, INFRA-*, FAB-*, TEST-*, DEPLOY-*
   - External documents: `input/` folder
   - Vendor documentation: `vendor-docs/` folder

---

## Maintenance and Updates

When updating documentation:

1. **Edit markdown file** (e.g., `cluster-architecture-model.md`)
2. **Rebuild PDFs**: `make pdf`
3. **Verify PDF content** appears in correct output (e.g., `04_SAD_Infrastructure.pdf`)
4. **Commit changes**: Include related SysML models and markdown files
5. **Update navigation**: If adding new markdown or PDF, update this README

---

**Last Updated**: December 4, 2025
**Maintained By**: Architecture and Documentation Team
