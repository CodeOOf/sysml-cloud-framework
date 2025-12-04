# Vendor Documentation Repository

This folder contains references, links, and local copies of vendor documentation for technologies used in this cloud platform.

## Structure

```
vendor-docs/
├── kubernetes/
│   ├── README.md
│   ├── api-reference.md
│   ├── high-availability-setup.md
│   ├── network-plugin-integration.md
│   ├── storage-classes.md
│   ├── rbac-authorization.md
│   └── etcd-administration.md
│
├── containerd/
│   ├── README.md
│   ├── installation-guide.md
│   ├── container-runtime-interface.md
│   ├── image-pull-registry-config.md
│   └── troubleshooting.md
│
├── etcd/
│   ├── README.md
│   ├── clustering-guide.md
│   ├── backup-restore.md
│   ├── security-config.md
│   └── admin-operations.md
│
├── flannel/
│   ├── README.md
│   ├── setup-guide.md
│   ├── network-policies.md
│   └── troubleshooting.md
│
├── terraform/
│   ├── README.md
│   ├── language-spec.md
│   ├── standard-library.md
│   ├── cli-reference.md
│   └── best-practices.md
│
├── ansible/
│   ├── README.md
│   ├── getting-started.md
│   ├── module-reference.md
│   ├── playbook-structure.md
│   └── best-practices.md
│
├── prometheus/
│   ├── README.md
│   ├── configuration-guide.md
│   ├── alerting-rules.md
│   └── kubernetes-integration.md
│
├── grafana/
│   ├── README.md
│   ├── installation-guide.md
│   ├── dashboard-examples.md
│   └── datasource-configuration.md
│
├── elasticsearch/
│   ├── README.md
│   ├── installation-guide.md
│   ├── cluster-setup.md
│   ├── index-management.md
│   └── kubernetes-deployment.md
│
├── networking/
│   ├── README.md
│   ├── linux-networking-fundamentals.md
│   ├── vxlan-overlay-networks.md
│   └── service-mesh-overview.md
│
├── storage/
│   ├── README.md
│   ├── persistent-volumes.md
│   ├── ceph-distributed-storage.md
│   ├── etcd-backed-storage.md
│   └── backup-strategies.md
│
└── licenses/
    ├── README.md
    ├── kubernetes-license.txt
    ├── etcd-license.txt
    ├── ansible-license.txt
    ├── terraform-license.txt
    └── open-source-compliance.md
```

## Adding Vendor Documentation

### 1. For External (Online) References

Create a README in the vendor folder with links:

**Example**: `vendor-docs/kubernetes/README.md`

```markdown
# Kubernetes Documentation

## Official Resources
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Kubernetes API Reference](https://kubernetes.io/docs/reference/)
- [etcd Administration Guide](https://etcd.io/docs/)

## Key Topics for This Project
- [High Availability Setup](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability-setup/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

## How This Project Uses Kubernetes
- Example instances: `Cluster A` (single-master development) and `Cluster B` (3-master HA production). These are examples — real instance folders live under `configs/{instance-id}/`.
- Version: 1.28+ (check `sysml/infrastructure/KubernetesClusterArchitecture.sysml`)

## Relevant SysML Models
- `sysml/infrastructure/KubernetesClusterArchitecture.sysml`
- `sysml/infrastructure/InfrastructureSubSystemRequirements.sysml`

## Project-Specific Guides
-- [Cluster Configuration](../../configs/{instance-id}/README.md) — replace `{instance-id}` with your instance folder name
- [Ansible Deployment](../../library/ansible-roles/README.md)
```

### 2. For Local (Downloaded) Documentation

Place documentation files in appropriate vendor folder:

```
vendor-docs/prometheus/
├── README.md              # Links to official docs + local files
├── prometheus-guide.pdf   # Downloaded from prometheus.io
├── alerting-rules.yaml    # Example rules used in project
└── kubernetes-config.yaml # Project-specific configuration
```

### 3. License Tracking

All vendor software must have licenses tracked:

```
vendor-docs/licenses/
├── README.md              # License compliance summary
├── kubernetes-license.txt # Apache 2.0
├── etcd-license.txt       # Apache 2.0
├── ansible-license.txt    # GPL v3.0
└── open-source-compliance.md
```

## Referencing Vendor Documentation in SysML Models

In your SysML requirement documents, reference vendor docs:

```sysml
class ContainerRuntimeRequirement :> InfrastructureRequirement {
    doc /* Container runtime must be modern and stable
             
         Vendor Doc: vendor-docs/containerd/
         References: https://containerd.io/docs/
         
         Acceptance Criteria:
         - Containerd version >= 1.7.0
         ...
     */
}
```

## Referencing Vendor Documentation in Generated Documentation

The build pipeline includes vendor documentation links in generated markdown:

```markdown
# Container Runtime Configuration

**Related SysML Requirement**: INFRA_REQ_003
**Vendor Documentation**: [Containerd Docs](../../vendor-docs/containerd/README.md)
**Official Resource**: https://containerd.io/docs/

## Configuration
...
```

## Integration Points

### Terraform Configurations

Reference vendor docs in Terraform comments:

```hcl
# Install Kubernetes per vendor documentation
# Reference: https://kubernetes.io/docs/setup/production-environment/
# Project-specific: vendor-docs/kubernetes/high-availability-setup.md

resource "kubernetes_namespace" "apps" {
  metadata {
    name = "applications"
  }
}
```

### Ansible Playbooks

Reference vendor docs in Ansible playbook comments:

```yaml
---
# Install etcd cluster for Kubernetes
# Reference: https://etcd.io/docs/v3.5/op-guide/clustering/
# Project-specific: vendor-docs/etcd/clustering-guide.md
# Related SysML: sysml/infrastructure/InfrastructureSubSystemRequirements.sysml (INFRA_REQ_002)

- name: Setup etcd cluster
  hosts: etcd_nodes
  roles:
    - etcd-cluster-setup
```

## Generated Vendor Reference Report

Running the build pipeline generates a report of all vendor references:

```bash
make vendor-report
```

Output: `publication/VENDOR_DOCUMENTATION_REFERENCE.md`

This report includes:
- All vendor documentation used
- Links to local copies (if available)
- Links to official sources
- License information
- Security patch status (where applicable)

## Version Management

Track vendor software versions:

```yaml
# versions.yaml
vendors:
  kubernetes:
    version: "1.28.0"
    docs: "vendor-docs/kubernetes/README.md"
    license: "Apache 2.0"
    security-patches: "up-to-date"
  
  containerd:
    version: "1.7.0"
    docs: "vendor-docs/containerd/README.md"
    license: "Apache 2.0"
    security-patches: "up-to-date"
```

## Compliance and Support

### Open Source Compliance

Maintain compliance with all licenses (see `vendor-docs/licenses/open-source-compliance.md`):
- Apache 2.0 projects can be freely used
- GPL v3.0 projects require derivative works to be open-source
- Check vendor license before adding

### Vendor Support Agreements

Track vendor support relationships:

```
vendor-docs/support-contacts.md:
- Kubernetes: Community support (no commercial agreement)
- Terraform: HashiCorp support (if applicable)
- Ansible: Red Hat support (if applicable)
```

### Security Patches

Monitor vendor security advisories:
- Subscribe to vendor security mailing lists
- Check for CVEs affecting deployed versions
- Document patching procedures in `vendor-docs/security-update-procedure.md`

## Best Practices

1. **Always Link to Official Docs**: Include official vendor documentation links
2. **Version Your References**: Note the version of documentation referenced
3. **Local Copies for Accessibility**: Download important guides for offline access
4. **License Compliance**: Never violate vendor licenses
5. **Attribution**: Always credit vendor sources
6. **Integration**: Link vendor docs from SysML models and code
7. **Keep Current**: Update vendor documentation links quarterly

## Maintenance Schedule

- **Monthly**: Check vendor security advisories
- **Quarterly**: Review and update documentation links
- **Annually**: Major version updates and license compliance audit

---

**Last Updated**: December 4, 2025
**Maintained By**: Infrastructure Team
