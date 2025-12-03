/**
 * Infrastructure as Code Structure Guide
 * 
 * Template for Terraform configurations aligned with SysML definitions
 * This file documents how IaC code maps to SysML architecture models
 */

# Directory Structure for Terraform Modules

```
terraform-modules/
├── shared/                          # Shared modules referenced by all clusters
│   ├── compute/
│   │   ├── node.tf                 # Base compute node module
│   │   ├── instance_group.tf       # Instance group management
│   │   └── variables.tf
│   ├── storage/
│   │   ├── volume.tf               # Storage volume module
│   │   ├── distributed_storage.tf  # Ceph, Longhorn, etc.
│   │   └── variables.tf
│   ├── networking/
│   │   ├── vpc.tf                  # Virtual network
│   │   ├── security_group.tf       # Network security
│   │   └── load_balancer.tf        # Load balancing
│   └── kubernetes/
│       ├── cluster.tf              # K8s cluster provisioning
│       ├── node_pool.tf            # Node pool management
│       └── addons.tf               # CNI, ingress, etc.
│
├── cluster-a/                       # Cluster A specific configuration
│   ├── terraform.tfvars            # Cluster A variables
│   ├── cluster-a-nodes.tf          # Node configuration
│   ├── cluster-a-storage.tf        # Local storage setup
│   └── main.tf                     # Module instantiation
│
├── cluster-b/                       # Cluster B specific configuration
│   ├── terraform.tfvars            # Cluster B variables (HA, scaling)
│   ├── cluster-b-masters.tf        # HA master configuration
│   ├── cluster-b-workers.tf        # Auto-scaling workers
│   ├── cluster-b-storage.tf        # Distributed storage setup
│   ├── cluster-b-networking.tf     # Load balancing and ingress
│   └── main.tf                     # Module instantiation
│
├── datacenters/
│   ├── datacenter-a/               # Fabrication Datacenter A
│   │   ├── datacenter.tfvars
│   │   ├── network.tf
│   │   └── storage.tf
│   └── datacenter-b/               # Fabrication Datacenter B
│       ├── datacenter.tfvars
│       ├── network.tf
│       └── storage.tf
│
└── templates/                       # Configuration templates (see below)
    ├── common_variables.tf         # Common variables for all deployments
    ├── provider_config.tf          # Provider configurations
    └── backend_config.tf           # Remote state configuration
```

## Mapping SysML to Terraform

### KubernetesClusterArchitecture.sysml → Terraform Modules

1. **ClusterA (SysML class)** → `cluster-a/main.tf`
   - SysML MasterNode → `terraform-modules/shared/kubernetes/cluster.tf` + `cluster-a-nodes.tf`
   - SysML WorkerNode[2..3] → `terraform-modules/shared/kubernetes/node_pool.tf` + `cluster-a-workers.tf`
   - SysML StorageNode → `terraform-modules/shared/storage/volume.tf` + `cluster-a-storage.tf`

2. **ClusterB (SysML class)** → `cluster-b/main.tf`
   - SysML MasterNode[3] → `cluster-b-masters.tf` (HA configuration)
   - SysML WorkerNode[5..100] → `cluster-b-workers.tf` (auto-scaling)
   - SysML DistributedStorageCluster → `cluster-b-storage.tf` (Ceph/Longhorn)
   - SysML LoadBalancerService → `cluster-b-networking.tf`

3. **DeploymentArchitecture.sysml** → `datacenters/` folder structure
   - SysML FabricationDatacenterA → `datacenters/datacenter-a/`
   - SysML FabricationDatacenterB → `datacenters/datacenter-b/`
   - SysML NetworkingLayer → `datacenters/*/network.tf`
   - SysML StorageLayer → `datacenters/*/storage.tf`

## Template Structure (Used by all subfolders in configs/ and fabrications/)

```
configs/infrastructure-cluster-b/
├── variables.tf                    # Cluster-specific variables
├── terraform.tfvars               # Variable values
├── main.tf                        # Root module instantiation
├── outputs.tf                     # Exported values
├── backend.tf                     # Remote state configuration
├── specs/
│   ├── cluster.json               # Cluster configuration (output of build-docs.py)
│   ├── nodes.json                 # Node pool definitions
│   ├── storage.json               # Storage configuration
│   └── networking.json            # Network configuration
└── README.md                      # Deployment instructions

fabrications/fabrication-datacenter-a/
├── variables.tf
├── terraform.tfvars
├── main.tf
├── outputs.tf
├── backend.tf
├── models/                        # SysML models for this datacenter
│   ├── datacenter-a.sysml
│   ├── cluster-a-deployment.sysml
│   └── fabrication-layout.sysml
├── specs/
│   ├── datacenter.json
│   ├── racks.json
│   └── network-topology.json
└── README.md
```

## Key Design Principles

1. **Shared Modules**: All compute, storage, and networking logic lives in `terraform-modules/shared/`
   - Imported by `cluster-a/`, `cluster-b/`, and datacenter modules
   - Reduces duplication and enables consistent versioning

2. **Environment Separation**: Cluster-specific and datacenter-specific configs in separate folders
   - `cluster-a/` contains only Cluster A overrides
   - `cluster-b/` contains only Cluster B overrides
   - `datacenters/` contains only datacenter-specific networking and storage

3. **SysML ↔ Terraform Traceability**:
   - Each SysML class maps to a Terraform module or subfolder
   - Each SysML attribute maps to a Terraform variable
   - Terraform outputs align with SysML requirements

4. **Template Consistency**: All subfolders follow this structure
   - Enables automation and reduces onboarding burden
   - Tools can generate or validate consistency
