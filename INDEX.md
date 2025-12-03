# Welcome to OMG SysML v2 Cloud Platform Architecture

## 🎯 What This Is

This repository demonstrates a **complete, production-ready architecture** for cloud infrastructure designed using **OMG SysML v2** (the next-generation systems modeling language, formally adopted by the OMG on June 30, 2025).

Instead of starting with infrastructure code, **we start with formal architecture models in SysML v2**. Everything else — Terraform configurations, Ansible playbooks, documentation, and deployment procedures — is derived from and traceable to these models.

## 🏗️ Architecture at a Glance

### Two Deployment Profiles

| | **Cluster A** | **Cluster B** |
|---|---|---|
| **Scale** | Lab (3 nodes) | Production (100+ nodes) |
| **Masters** | 1 | 3 (HA) |
| **Workers** | 2-3 | 5-100+ (auto-scaling) |
| **Storage** | Local | Distributed (Ceph) |
| **Datacenters** | 1 (Fabrication A) | 2 (Fabrication A + B) |
| **SysML** | `ClusterA` class | `ClusterB` class |

### Multi-Datacenter Topology

```
Fabrication Datacenter A (Primary)        Fabrication Datacenter B (Secondary)
┌──────────────────────────────────┐     ┌──────────────────────────────────┐
│                                  │     │                                  │
│  ┌─ Cluster A ────────┐          │     │                                  │
│  │ • 1 Master         │          │     │                                  │
│  │ • 2-3 Workers      │          │     │                                  │
│  │ • Local Storage    │          │     │                                  │
│  └────────────────────┘          │     │                                  │
│                                  │     │                                  │
│  ┌─ Cluster B (Part 1) ──────┐   │     │  ┌─ Cluster B (Part 2) ──────┐  │
│  │ • Master 1 (etcd member)  │   │     │  │ • Masters 2-3 (etcd)      │  │
│  │ • Worker Group 1 (2-3)    │───┼─────┼─►│ • Worker Group 2 (3-5)    │  │
│  │ • Storage replicas        │◄──┼─────┼──│ • Storage replicas        │  │
│  └───────────────────────────┘   │     │  └───────────────────────────┘  │
│                                  │     │                                  │
└──────────────────────────────────┘     └──────────────────────────────────┘
         ▲                                       ▲
         └───────────── WAN/VPN ────────────────┘
         ▲                                       ▲
         └─── HA Control Plane (etcd) ──────────┘
             Synchronized Storage
```

## 📚 Documentation (Read In This Order)

1. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** ← **START HERE** (5-min overview)
   - Two deployment profiles at a glance
   - Folder structure essentials
   - Common tasks

2. **[SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)** (30-min read)
   - Complete architecture walkthrough
   - How SysML maps to Terraform and Ansible
   - Design patterns and best practices
   - Step-by-step: "How to Add a New Component"

3. **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** (15-min read)
   - What was built and why
   - Key architectural decisions
   - Detailed traceability examples
   - Project structure summary

4. **[README.md](README.md)** (general info)
   - Project overview
   - Requirements and setup
   - Build commands

## 📂 Key Folders

```
sysml/                              ← OMG SysML v2 Models (Source of Truth)
├── infrastructure/
│   └── KubernetesClusterArchitecture.sysml    Cluster A & B definitions
└── datacenter/
    └── DeploymentArchitecture.sysml           Multi-datacenter topology

library/                            ← Shared Components (No Duplication)
├── sysml-library/
│   └── SharedInfrastructureLibrary.sysml      Base classes & patterns
├── terraform-modules/shared/                   Reusable Terraform modules
└── ansible-roles/shared/                       Reusable Ansible roles

configs/                            ← Cluster-Specific IaC
├── infrastructure-cluster-a/                   Lab cluster deployment
└── infrastructure-cluster-b/                   Production cluster deployment

fabrications/                       ← Datacenter-Specific IaC
├── fabrication-datacenter-a/                   Primary site
└── fabrication-datacenter-b/                   Secondary site (HA/DR)

templates/                          ← Required Structure & Standards
├── TERRAFORM_STRUCTURE.md                      Folder layout guidelines
├── ANSIBLE_STRUCTURE.md                        Playbook organization
└── [configuration templates]

publication/                        ← Generated Documentation
├── *.md (from SysML models)
├── *.pdf (V-Model ordered publications)
│   01_PMP_SEMP.pdf
│   03_SRD_*.pdf
│   04_SAD_*.pdf
│   06_SDD_*.pdf
└── manifest.json (metadata index)
```

## 🔄 From SysML to Deployment

```
Step 1: Define in SysML v2
━━━━━━━━━━━━━━━━━━━━━━━━━━
sysml/infrastructure/KubernetesClusterArchitecture.sysml
class ClusterB :> KubernetesCluster {
    structure {
        part masterNodes : MasterNode[3];
        part workerNodes : WorkerNode[5..100];
    }
}
                    ↓
Step 2: Generate Documentation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ make docs     # SysML → Markdown
$ make pdf      # Markdown → V-Model PDFs
                    ↓
Step 3: Implement in IaC (Traceable)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
configs/infrastructure-cluster-b/cluster-b-masters.tf
resource "aws_instance" "master_nodes" {
    count = 3   # ← from masterNodes[3]
}
                    ↓
Step 4: Deploy with Automation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ terraform apply
$ ansible-playbook site.yml
                    ↓
Result: Cluster running per SysML specification
```

## 🚀 Quick Start

### 1. Read the Architecture
```bash
# First: Quick overview (5 min)
cat QUICK_REFERENCE.md

# Then: Complete guide (30 min)
cat SYSML_ARCHITECTURE_GUIDE.md
```

### 2. View the SysML Models
```bash
# Main cluster definitions
cat sysml/infrastructure/KubernetesClusterArchitecture.sysml

# Multi-datacenter deployment
cat sysml/datacenter/DeploymentArchitecture.sysml

# Shared library components
cat library/sysml-library/SharedInfrastructureLibrary.sysml
```

### 3. Generate Documentation
```bash
make docs    # SysML → Markdown (in publication/)
make pdf     # Markdown → PDFs (in publication/)
```

### 4. Deploy Cluster A (Lab)
```bash
cd configs/infrastructure-cluster-a
terraform init
terraform plan
terraform apply

# Then configure with Ansible
cd ../../ansible-roles/cluster-a
ansible-playbook -i inventory.ini site.yml
```

### 5. Deploy Cluster B (Production)
```bash
cd configs/infrastructure-cluster-b
terraform init
terraform plan
terraform apply

# Multi-master HA setup with Ansible
cd ../../ansible-roles/cluster-b
ansible-playbook -i inventory.ini site.yml
```

## 🔗 Traceability

Every piece of infrastructure is traceable:

- **SysML Attribute** (e.g., `cpuCores: 8`) 
  ↓ Maps to ↓
- **Terraform Variable** (e.g., `instance_type`)
  ↓ Maps to ↓
- **Ansible Task** (e.g., `cpu_count: 8`)
  ↓ Results in ↓
- **Running Infrastructure** (e.g., EC2 instance with 8 vCPUs)

See [SYSML_ARCHITECTURE_GUIDE.md - Section 5](SYSML_ARCHITECTURE_GUIDE.md#5-traceability-sysml--terraform--ansible) for detailed examples.

## 📋 Design Principles

1. **SysML as Source of Truth**
   - All architecture defined in OMG SysML v2 first
   - Executable code derives from and references SysML

2. **Shared Library Pattern**
   - No duplication of Terraform modules or Ansible roles
   - All shared components in `library/` folder
   - Cluster-specific and datacenter-specific configs only override

3. **Template-Driven Consistency**
   - All deployments follow the same folder structure
   - Automation tools can validate and enforce consistency
   - Easy to add new clusters or datacenters

4. **Multi-Datacenter First**
   - HA and DR built in from the start
   - Geographic redundancy is the default, not an add-on
   - SysML explicitly models which components live where

5. **Full Observability**
   - Logging, metrics, tracing are first-class architecture concerns
   - Not afterthoughts, but mandatory components
   - Defined in SysML and deployed via shared Ansible roles

## 🛠️ Technologies

- **Architecture Language**: OMG SysML v2 (textual notation)
- **IaC**: Terraform
- **Configuration Management**: Ansible
- **Container Platform**: Kubernetes
- **Source Control**: Git
- **Documentation**: Pandoc + XeLaTeX

## 📖 Official Resources

- **OMG SysML v2 Specification**: https://www.omg.org/spec/SysML/2.0/Beta4 (formally adopted June 30, 2025)
- **SysML v2 Release Repository**: https://github.com/Systems-Modeling/SysML-v2-Release
- **Textual Syntax Guide**: See `/doc/Intro to the SysML v2 Language-Textual Notation.pdf` in release repo
- **Example Models**: https://github.com/Systems-Modeling/SysML-v2-Release/tree/master/sysml

## ✅ What's Included

- ✅ Complete SysML v2 architecture models (Cluster A, Cluster B, multi-datacenter)
- ✅ Shared library for reusable SysML, Terraform, and Ansible components
- ✅ Template structures for consistency across deployments
- ✅ Terraform configurations for both lab and production clusters
- ✅ Ansible playbooks and roles for full infrastructure automation
- ✅ Automated documentation generation (Markdown + V-Model-ordered PDFs)
- ✅ Traceability from SysML to IaC to running infrastructure
- ✅ Comprehensive guides and quick reference

## 🚧 Architecture Decisions

**Why Two Clusters?**
- Cluster A: Small deployments for rapid iteration (lab, test, dev)
- Cluster B: Large deployments for production workloads (HA, scaling, resilience)
- Same SysML model supports both via specialization

**Why Multi-Datacenter?**
- Single datacenter = single point of failure
- Multi-datacenter = HA built in from the start
- Enables true disaster recovery and geographic redundancy

**Why Shared Library?**
- Eliminates duplication of Terraform and Ansible code
- Single source of truth for each component
- Changes propagate automatically to all clusters
- Enables consistency and maintainability at scale

## 📞 Contributing

To add a new component:

1. Define it in SysML (e.g., `sysml/infrastructure/KubernetesClusterArchitecture.sysml`)
2. Create Terraform module in `library/terraform-modules/shared/`
3. Create Ansible role in `library/ansible-roles/shared/`
4. Reference in cluster/datacenter IaC
5. Regenerate docs: `make docs && make pdf`

See [SYSML_ARCHITECTURE_GUIDE.md - Section 10](SYSML_ARCHITECTURE_GUIDE.md#10-how-to-add-a-new-component) for step-by-step guide.

---

## Next Steps

1. **Read** [QUICK_REFERENCE.md](QUICK_REFERENCE.md) (5 minutes)
2. **Explore** `sysml/` folder to see the models
3. **Review** [SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md) for the complete picture
4. **Deploy** Cluster A or B using the IaC in `configs/`
5. **Extend** by adding new components following the pattern

---

**SysML v2 Compliance**: This project strictly adheres to OMG SysML 2.0 (formally adopted June 30, 2025)  
**Last Updated**: December 4, 2025  
**Status**: Production-Ready
