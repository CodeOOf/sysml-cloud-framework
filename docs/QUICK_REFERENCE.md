# Quick Reference: OMG SysML v2 Cloud Architecture

> **Previous**: [README.md](../README.md) → [DOCS_GUIDE.md](DOCS_GUIDE.md)  
> **V-Model Phase**: N/A (Quick Start)  
> **Time to read**: 5–10 minutes  
> **Published as**: N/A (Reference material only)

## Files to Start With

1. **`SYSML_ARCHITECTURE_GUIDE.md`** ← Complete guide (start here)
2. **`IMPLEMENTATION_SUMMARY.md`** ← What was built and why
3. **`README.md`** ← Project overview
4. **`sysml/infrastructure/KubernetesClusterArchitecture.sysml`** ← Main models

## Two Deployment Profiles (examples)

The table below shows two example profiles used in documentation: `Cluster A` (lab) and `Cluster B` (production). These are illustrative — real instance IDs and folders live under `configs/{instance-id}/`.

| Feature | Example: Lab Profile | Example: Production Profile |
|---------|--------|---------|
| **Purpose** | Dev/test/prototype | Production workloads |
| **Masters** | 1 (dev-only) | 3 (HA with etcd quorum) |
| **Workers** | 2-3 | 5-100+ (auto-scaling) |
| **Storage** | Local (NFS) | Distributed (Ceph/Longhorn) |
| **Datacenter** | Single site (example) | Multi-site (example) |
| **Load Balancer** | No | Yes |
| **Ingress** | No | Yes |
| **HA Enabled** | No | Yes |
| **Observability** | Prometheus + ELK | Full stack + alerts |

## Datacenter Distribution

```
Fabrication Datacenter A (Primary)
├── Cluster A: Complete deployment (1 master, 2-3 workers)
├── Cluster B: Master 1 + Worker Group 1
└── Storage: Primary nodes

Fabrication Datacenter B (Secondary)
├── Cluster B: Masters 2-3 + Worker Group 2
└── Storage: Replica nodes
```

## Folder Structure Essentials

Use per-instance directories. Examples below show illustrative instance names; replace `{instance-id}` with your chosen id.

```
configs/
├── {instance-id}/          # Per-instance IaC (example: cluster-a, prod-west)
│   ├── main.tf (imports shared modules)
│   ├── variables.tf (instance overrides)
   └── specs/                         # JSON outputs

fabrications/
├── {instance-id}/          # Per-instance fabrication/datacenter (example: datacenter-east-1)
│   ├── models/                        # SysML models for this site
│   ├── network.tf
│   ├── storage.tf
│   └── specs/

library/
├── sysml-library/                     # Shared SysML definitions
│   └── SharedInfrastructureLibrary.sysml
├── terraform-modules/shared/          # Shared Terraform modules
│   ├── compute/
│   ├── storage/
│   ├── networking/
│   └── kubernetes/
└── ansible-roles/shared/              # Shared Ansible roles
    ├── kubernetes-control-plane/
    ├── kubernetes-worker/
    ├── container-runtime/
    ├── networking/
    ├── storage/
    ├── monitoring/
    ├── logging/
    └── security/
```

## SysML v2 Textual Syntax (Key Concepts)

```sysml
// Packages organize models by domain
package KubernetesClusterArchitecture {
    import Base::*;

    // Abstract base class
    abstract class KubernetesCluster {
        attribute kubernetesVersion : String;
    }

    // Specialized class (inheritance)
    class ClusterA :> KubernetesCluster {
        // Composition: what parts make up this cluster
        structure {
            part masterNode : MasterNode;           // Single master
            part workerNodes : WorkerNode[2..3];    // 2-3 workers
            part localStorage : StorageNode;         // Local storage
        }
    }

    class ClusterB :> KubernetesCluster {
        structure {
            part masterNodes : MasterNode[3];               // 3 HA masters
            part workerNodes : WorkerNode[5..100];         // 5-100 workers
            part distributedStorage : DistributedStorageCluster;
        }
    }

    // Component definition
    class MasterNode {
        doc /* Control plane node */
        attribute nodeHostname : String;
        attribute cpuCores : Integer;
        attribute memoryGiB : Integer;
        
        structure {
            part apiServer : APIServer;
            part scheduler : Scheduler;
            part etcd : EtcdStore;
        }
    }
}
```

## Build and Publish

```bash
# Generate markdown from SysML
make docs

# Generate V-Model-ordered PDFs
make pdf

# View generated files
ls publication/*.pdf

# Example outputs:
# 01_PMP_SEMP.pdf                       - Project Management Plan
# 03_SRD_SysMLCloudPlatform.pdf        - System Requirements
# 04_SAD_SysMLCloudPlatform.pdf        - System Architecture & Design
# 06_SDD_FabricationDatacenterA.pdf    - Detailed Design
```

## Traceability: SysML → IaC → Deployment

```
SysML Definition                       Terraform                           Ansible
────────────────────────────────────────────────────────────────────────────────────
class ClusterB                         resource "aws_instance" "master"    - role: shared/kubernetes-control-plane
  ├─ masterNodes[3]        ────→          count = 3                ────→      vars:
  ├─ cpuCores: 8                          instance_type = "c5.2xlarge"        ha_enabled: true
  └─ memoryGiB: 32                        iam_instance_profile = "master"     etcd_cluster_size: 3
```

## How to Add a New Component

1. **Define in SysML** (`sysml/infrastructure/KubernetesClusterArchitecture.sysml`):
   ```sysml
   class MyNewComponent {
       attribute property1 : String;
   }
   ```

2. **Create Terraform Module** (`library/terraform-modules/shared/my-component/`):
   ```hcl
   resource "aws_resource" "my_component" {
       name = var.property1
   }
   ```

3. **Create Ansible Role** (`library/ansible-roles/shared/my-component-setup/`):
   ```yaml
   - name: Configure my component
     debug:
       msg: "{{ property1 }}"
   ```

4. **Use in Clusters** (`configs/infrastructure-cluster-b/main.tf`):
   ```hcl
   module "my_component" {
       source = "../../library/terraform-modules/shared/my-component"
       property1 = "value"
   }
   ```

5. **Regenerate Docs**:
   ```bash
   make docs && make pdf
   ```

## V-Model PDF Naming Convention

| Prefix | Phase | Example PDF |
|--------|-------|-----|
| 01_PMP | Project Management | Project Management Plan |
| 02_SNS | Stakeholder Needs | Stakeholder Needs Statement |
| 03_SRD | System Requirements | System Requirements Document |
| 04_SAD | System Architecture & Design | System Architecture & Design |
| 05_SSR | Subsystem Requirements | Subsystem Requirements |
| 06_SDD | Subsystem Detailed Design | Detailed Design Document |
| 07_SCI | Implementation | Code Implementation |
| 08_ITP | Integration | Integration Test Plan |
| 09_STP | Verification | System Test Plan |
| 10_SV | Validation | System Validation |
| 11_DPL | Deployment & O&M | Deployment Plan |

## Template Compliance Checklist

For any new cluster or datacenter:

- [ ] Folder structure follows `templates/TERRAFORM_STRUCTURE.md`
- [ ] Folder structure follows `templates/ANSIBLE_STRUCTURE.md`
- [ ] Uses shared modules/roles (no duplication)
- [ ] Defines variables.tf with cluster-specific overrides
- [ ] Includes specs/ with JSON outputs
- [ ] README.md documents the deployment
- [ ] SysML models in models/ describe the architecture

## Official Resources

- **OMG SysML v2 Spec**: https://www.omg.org/spec/SysML/2.0/Beta4
- **SysML Release Repo**: https://github.com/Systems-Modeling/SysML-v2-Release
- **Textual Syntax Guide**: See `/doc/Intro to the SysML v2 Language-Textual Notation.pdf` in repo
- **Example Models**: https://github.com/Systems-Modeling/SysML-v2-Release/tree/master/sysml

## Common Tasks

**Deploy an instance (example)**:
```powershell
# Replace {instance-id} with the instance folder name, e.g. 'cluster-a' or 'prod-west'
cd configs\{instance-id}
terraform init && terraform apply

# Then run Ansible from the appropriate role
cd ..\..\library\ansible-roles\{role-name}
ansible-playbook -i inventory.ini site.yml
```

**Add Master Node to Cluster B**:
1. Update `ClusterB.masterNodes` multiplicity in SysML (e.g., `[3..5]`)
2. Update Terraform count in `cluster-b-masters.tf`
3. Update Ansible inventory in `cluster-b/inventory.ini`
4. Run Ansible playbook to join new master

**Update Container Runtime**:
1. Update SysML `ContainerRuntime.runtimeName` attribute
2. Update Ansible role `shared/container-runtime/` tasks
3. Re-run Ansible playbook: `ansible-playbook -i inventory.ini site.yml`

---

**SysML v2 Compliance**: Aligns with OMG SysML 2.0 (formally adopted June 30, 2025)

## Next Steps

### If you want to understand the full architecture...
→ Read **[SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)** (30 min)

### If you're ready to build and deploy...
→ Read **[TESTING_AND_DEPLOYMENT_STRATEGY.md](TESTING_AND_DEPLOYMENT_STRATEGY.md)** (deployment & testing)

### If you want to understand the project plan...
→ Read **[SEMP.md](SEMP.md)** (Project Management Plan)

### Return to the main thread:
→ Back to **[DOCS_GUIDE.md](DOCS_GUIDE.md)**
