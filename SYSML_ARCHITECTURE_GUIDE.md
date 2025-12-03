# SysML v2-Based Cloud Infrastructure Architecture

**Source of Truth**: [OMG SysML v2 Specification](https://www.omg.org/sysml/sysmlv2/) and [SysML v2 Release Repository](https://github.com/Systems-Modeling/SysML-v2-Release)

This document describes how this project uses OMG SysML v2 as the authoritative source for cloud infrastructure architecture, with executable code (Terraform/Ansible) derived from and traceable to SysML models.

## 1. Architecture Overview

### Two Deployment Profiles

#### Cluster A: Lab-Scale Development Cluster
- **Purpose**: Development, testing, and prototyping
- **Deployment**: Single datacenter (Fabrication Datacenter A)
- **Scale**: 
  - 1 master node
  - 2-3 worker nodes
  - Local storage backend
- **SysML Definition**: `sysml/infrastructure/KubernetesClusterArchitecture.sysml` → `ClusterA` class

#### Cluster B: Production-Scale EKS-Like Cluster
- **Purpose**: Production workloads with HA and scaling
- **Deployment**: Multi-datacenter (Fabrication A + B)
- **Scale**:
  - 3 master nodes (HA with etcd quorum)
  - 5-100+ auto-scaling worker nodes
  - Distributed storage with geographic redundancy
  - Load balancing and ingress
- **SysML Definition**: `sysml/infrastructure/KubernetesClusterArchitecture.sysml` → `ClusterB` class

### Datacenter Distribution

**Fabrication Datacenter A** (`fabrications/fabrication-datacenter-a/`)
- Hosts complete Cluster A
- Hosts Cluster B Master 1 + etcd member
- Hosts Cluster B Worker Group 1
- Primary storage node

**Fabrication Datacenter B** (`fabrications/fabrication-datacenter-b/`)
- Hosts Cluster B Masters 2 & 3 + etcd members
- Hosts Cluster B Worker Group 2
- Secondary/replica storage nodes

**SysML Definition**: `sysml/datacenter/DeploymentArchitecture.sysml`

## 2. SysML Model Organization

### Core Architecture Models

```
sysml/
├── overall-design/
│   ├── SysMLCloudPlatformModel.sysml
│   ├── SysMLCloudPlatformInterfaces.sysml
│   └── SysMLCloudPlatformRequirements.sysml
│
├── infrastructure/
│   ├── KubernetesClusterArchitecture.sysml        ← Main cluster definitions
│   ├── InfrastructureRequirements.sysml
│   ├── NetworkModel.sysml
│   ├── ServiceCatalogModel.sysml
│   └── VirtualizationModel.sysml
│
└── datacenter/
    ├── DeploymentArchitecture.sysml               ← Multi-datacenter topology
    ├── DatacenterArchitectureModel.sysml
    ├── DatacenterRequirements.sysml
    ├── PowerCoolingInterfaces.sysml
    ├── RackModel.sysml
    └── RoomModel.sysml
```

### Key SysML v2 Concepts Used

1. **Packages** (`package`): Organize models by domain (infrastructure, datacenter, overall-design)
2. **Classes** (`class`): Define infrastructure components (ClusterA, ClusterB, MasterNode, WorkerNode)
3. **Abstract Classes** (`abstract class`): Base definitions (KubernetesCluster, ComputeNode)
4. **Attributes** (`attribute`): Properties of components (cpuCores, memoryGiB, kubernetesVersion)
5. **Structures** (`structure`): Composition relationships (ClusterA contains MasterNode + WorkerNodes)
6. **Specialization** (`:>`): Inheritance (ClusterA :> KubernetesCluster)
7. **Documentation** (`doc`): Formal requirements and design rationale

## 3. Shared Library Structure

**Purpose**: Reusable components and patterns used across all clusters and datacenters

### SysML Library
```
library/sysml-library/
└── SharedInfrastructureLibrary.sysml
    ├── ComputeNode (abstract base)
    ├── NetworkInterface
    ├── StorageVolume
    ├── Service (abstract)
    │   ├── LoggingService
    │   ├── MetricsService
    │   └── TracingService
    ├── SecurityBoundary
    │   ├── NetworkSecurityBoundary
    │   └── ApplicationSecurityBoundary
    ├── ClusterConfigTemplate (abstract)
    │   └── NodePoolConfig
    ├── RBACPolicy
    ├── NetworkPolicy
    │   ├── IngressRule
    │   └── EgressRule
    └── BackupPolicy
```

### Terraform Modules Library
```
library/terraform-modules/
└── shared/
    ├── compute/
    │   ├── node.tf
    │   └── instance_group.tf
    ├── storage/
    │   ├── volume.tf
    │   └── distributed_storage.tf
    ├── networking/
    │   ├── vpc.tf
    │   ├── security_group.tf
    │   └── load_balancer.tf
    └── kubernetes/
        ├── cluster.tf
        ├── node_pool.tf
        └── addons.tf
```

### Ansible Roles Library
```
library/ansible-roles/
└── shared/
    ├── kubernetes-control-plane/
    ├── kubernetes-worker/
    ├── container-runtime/
    ├── networking/
    ├── storage/
    ├── monitoring/
    ├── logging/
    └── security/
```

All shared modules/roles are **imported and extended** by cluster-specific configurations, not duplicated.

## 4. Infrastructure-as-Code (IaC) Organization

### Cluster A (Lab)
```
configs/infrastructure-cluster-a/
├── README.md
├── variables.tf                    # Cluster A overrides (1 master, 2-3 workers)
├── terraform.tfvars
├── main.tf                         # Imports shared modules
├── cluster-a-nodes.tf             # Node sizing specific to lab
└── specs/
    └── cluster.json               # Generated from build-docs.py
```

### Cluster B (Production)
```
configs/infrastructure-cluster-b/
├── README.md
├── variables.tf                    # Cluster B overrides (3 masters, 5-100 workers, HA)
├── terraform.tfvars
├── main.tf
├── cluster-b-masters.tf           # HA master configuration
├── cluster-b-workers.tf           # Auto-scaling configuration
├── cluster-b-networking.tf        # Load balancing and ingress
└── specs/
    └── cluster.json
```

### Datacenter A (Primary)
```
fabrications/fabrication-datacenter-a/
├── README.md
├── variables.tf
├── terraform.tfvars
├── main.tf
├── network.tf                     # Datacenter-specific networking
├── storage.tf                     # Primary storage nodes
├── models/
│   ├── fabrication-datacenter-a.sysml
│   ├── cluster-a-deployment.sysml
│   └── fabrication-layout.sysml
└── specs/
    └── datacenter.json
```

### Datacenter B (Secondary)
```
fabrications/fabrication-datacenter-b/
├── README.md
├── variables.tf
├── terraform.tfvars
├── main.tf
├── network.tf                     # Cross-datacenter networking
├── storage.tf                     # Replica storage nodes
├── models/
│   ├── fabrication-datacenter-b.sysml
│   ├── cluster-b-deployment.sysml
│   └── disaster-recovery.sysml
└── specs/
    └── datacenter.json
```

## 5. Traceability: SysML → Terraform → Ansible

### Example: MasterNode (3 nodes in Cluster B)

**SysML Definition** (`sysml/infrastructure/KubernetesClusterArchitecture.sysml`):
```sysml
class MasterNode {
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

class ClusterB :> KubernetesCluster {
    structure {
        part masterNodes : MasterNode[3];  // ← Three masters required
        // ...
    }
}
```

**Terraform Configuration** (`configs/infrastructure-cluster-b/cluster-b-masters.tf`):
```hcl
# Implement SysML ClusterB.masterNodes[3]
resource "aws_instance" "master_nodes" {
  count             = 3
  instance_type     = var.master_instance_type      # ← Maps to cpuCores, memoryGiB
  availability_zone = "us-east-1${["a", "b", "c"][count.index]}"
  
  tags = {
    Name = "cluster-b-master-${count.index + 1}"  # ← Maps to nodeHostname
  }
}
```

**Ansible Playbook** (`ansible-roles/cluster-b/site.yml`):
```yaml
- role: shared/kubernetes-control-plane
  vars:
    cluster_role: master
    ha_enabled: true                              # ← ClusterB.hasHighAvailability
    etcd_cluster_size: 3                          # ← ClusterB.masterNodes[3]
  when: inventory_hostname in groups['masters']
```

### Example: Storage (Local in Cluster A vs Distributed in Cluster B)

**SysML Definition**:
```sysml
class ClusterA :> KubernetesCluster {
    structure {
        part localStorage : StorageNode;  // ← Local storage
    }
}

class ClusterB :> KubernetesCluster {
    structure {
        part distributedStorage : DistributedStorageCluster;  // ← Distributed
    }
}
```

**Terraform**:
- Cluster A: `configs/infrastructure-cluster-a/cluster-a-storage.tf` → local NFS
- Cluster B: `configs/infrastructure-cluster-b/cluster-b-storage.tf` → Ceph with replication

**Ansible**:
- Cluster A: `ansible-roles/cluster-a/group_vars/workers.yml` → storage_engine: local
- Cluster B: `ansible-roles/cluster-b/group_vars/storage.yml` → storage_engine: ceph

## 6. Template Folder Usage

The `templates/` folder contains **required structure and configuration files** that all subfolders in `configs/` and `fabrications/` must follow:

### Template Files

**`templates/common_variables.tf`**
```hcl
# All clusters must declare these variables
variable "cluster_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "region" {
  type = string
}
# ... additional standard variables
```

**`templates/TERRAFORM_STRUCTURE.md`**
- Defines expected folder layout for all Terraform projects
- Specifies how shared modules are imported
- Documents SysML → Terraform mapping

**`templates/ANSIBLE_STRUCTURE.md`**
- Defines expected playbook and role organization
- Specifies inventory and variable precedence
- Documents SysML → Ansible mapping

### Compliance

Any new cluster or datacenter deployment must:
1. Use the folder structure defined in `templates/`
2. Import shared modules/roles, not duplicate them
3. Align IaC structure with corresponding SysML definitions
4. Document how SysML attributes map to IaC variables

## 7. Build and Publication Pipeline

### Documentation Generation

```bash
make docs
```

**Input**: SysML files in `sysml/*/`
**Process**: `scripts/build-docs.py` converts SysML to Markdown
**Output**: `publication/*.md` + `publication/manifest.json`

### PDF Publication

```bash
make pdf
```

**Input**: Markdown files + manifest
**Process**: `scripts/generate-pdfs.py` groups by V-Model phase
**Output**: Prefixed PDFs (01_PMP_*, 03_SRD_*, 04_SAD_*, 06_SDD_*)

**Example publications**:
- `03_SRD_SystemRequirements.pdf` — System requirements from SysML
- `04_SAD_SysMLCloudPlatform.pdf` — System architecture from `sysml/overall-design/`
- `06_SDD_FabricationDatacenterA.pdf` — Detailed designs from `sysml/datacenter/`

## 8. OMG SysML v2 Resources

- **Official Specification**: https://www.omg.org/spec/SysML/2.0/Beta4
- **Reference Implementation**: https://github.com/Systems-Modeling/SysML-v2-Release
- **Textual Syntax Guide**: See `/doc/Intro to the SysML v2 Language-Textual Notation.pdf` in release repo
- **Example Models**: https://github.com/Systems-Modeling/SysML-v2-Release/tree/master/sysml

## 9. Design Patterns

### Pattern 1: Inheritance with Specialization
```sysml
abstract class KubernetesCluster { /* base */ }
class ClusterA :> KubernetesCluster { /* specialized for lab */ }
class ClusterB :> KubernetesCluster { /* specialized for production */ }
```

### Pattern 2: Composition (Part-Whole)
```sysml
class ClusterB {
    structure {
        part masterNodes : MasterNode[3];    // 3 masters
        part workerNodes : WorkerNode[5..100]; // 5-100 workers
    }
}
```

### Pattern 3: Abstract Interfaces
```sysml
abstract class Service { /* interface for network services */ }
class LoggingService :> Service { /* implementation */ }
class MetricsService :> Service { /* implementation */ }
```

## 10. How to Add a New Component

### Step 1: Define in SysML
Add a new class to the appropriate `sysml/*/` model file:
```sysml
class MyNewComponent {
    attribute property1 : String;
    attribute property2 : Integer;
}
```

### Step 2: Create Terraform Module
In `library/terraform-modules/shared/`, create module:
```
shared/my-component/
├── main.tf
├── variables.tf
└── outputs.tf
```

### Step 3: Create Ansible Role
In `library/ansible-roles/shared/`, create role:
```
shared/my-component-setup/
├── tasks/
│   └── main.yml
├── templates/
│   └── (if needed)
└── vars/
    └── main.yml
```

### Step 4: Use in Cluster
Reference in cluster-specific IaC:
```hcl
# configs/infrastructure-cluster-b/main.tf
module "my_component" {
  source = "../../library/terraform-modules/shared/my-component"
  // ...
}
```

### Step 5: Regenerate Documentation
```bash
make docs
make pdf
```

---

**Last Updated**: 2025-12-04  
**SysML v2 Compliance**: Aligns with OMG SysML 2.0 Beta 4 (formally adopted June 30, 2025)
