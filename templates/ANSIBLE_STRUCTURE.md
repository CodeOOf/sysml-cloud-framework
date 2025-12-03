/**
 * Ansible Configuration Structure Guide
 * 
 * Template for Ansible playbooks and roles aligned with SysML definitions
 * This file documents how configuration management code maps to SysML models
 */

# Directory Structure for Ansible

```
ansible-roles/
├── shared/                              # Shared roles used by all clusters
│   ├── kubernetes-control-plane/       # Kubeadm + control plane setup
│   │   ├── tasks/
│   │   │   ├── install-deps.yml
│   │   │   ├── configure-kubelet.yml
│   │   │   ├── init-cluster.yml
│   │   │   └── join-cluster.yml
│   │   ├── templates/
│   │   │   └── kubeadm-config.j2
│   │   └── vars/
│   │       └── main.yml
│   │
│   ├── kubernetes-worker/              # Worker node setup
│   │   ├── tasks/
│   │   │   ├── install-deps.yml
│   │   │   ├── configure-kubelet.yml
│   │   │   └── join-node.yml
│   │   └── vars/
│   │       └── main.yml
│   │
│   ├── container-runtime/              # containerd/CRI-O setup
│   │   ├── tasks/
│   │   │   ├── install-containerd.yml
│   │   │   ├── configure-runtime.yml
│   │   │   └── setup-logging.yml
│   │   ├── templates/
│   │   │   └── config.toml.j2
│   │   └── vars/
│   │       ├── main.yml
│   │       └── containerd_version: "1.7.0"
│   │
│   ├── networking/                     # CNI plugin setup
│   │   ├── tasks/
│   │   │   ├── install-cni-plugin.yml
│   │   │   └── configure-network.yml
│   │   └── vars/
│   │       └── main.yml (defines cni_plugin: calico|flannel|cilium)
│   │
│   ├── storage/                        # Storage backend setup
│   │   ├── tasks/
│   │   │   ├── install-ceph.yml
│   │   │   ├── install-longhorn.yml
│   │   │   └── format-volumes.yml
│   │   ├── templates/
│   │   │   ├── ceph.conf.j2
│   │   │   └── longhorn-values.yaml.j2
│   │   └── vars/
│   │       ├── main.yml
│   │       └── storage_engine: "ceph|longhorn"
│   │
│   ├── monitoring/                     # Prometheus/Grafana setup
│   │   ├── tasks/
│   │   │   ├── deploy-prometheus.yml
│   │   │   ├── deploy-grafana.yml
│   │   │   └── configure-dashboards.yml
│   │   └── templates/
│   │       ├── prometheus.yml.j2
│   │       └── grafana-datasource.json.j2
│   │
│   ├── logging/                        # ELK/Loki setup
│   │   ├── tasks/
│   │   │   ├── deploy-elasticsearch.yml
│   │   │   ├── deploy-kibana.yml
│   │   │   └── deploy-logstash.yml
│   │   └── templates/
│   │       └── logstash-config.j2
│   │
│   └── security/                       # RBAC, network policies, PSP
│       ├── tasks/
│       │   ├── configure-rbac.yml
│       │   ├── apply-network-policies.yml
│       │   └── configure-pod-security.yml
│       ├── templates/
│       │   ├── rbac-roles.yaml.j2
│       │   ├── network-policies.yaml.j2
│       │   └── pod-security-policy.yaml.j2
│       └── vars/
│           └── main.yml
│
├── cluster-a/                           # Cluster A playbooks
│   ├── site.yml                        # Main playbook for Cluster A
│   ├── inventory.ini                  # Inventory for Cluster A hosts
│   ├── group_vars/
│   │   ├── masters.yml                # Master node variables
│   │   ├── workers.yml                # Worker node variables (Cluster A 2-3 nodes)
│   │   └── all.yml                    # Common variables
│   ├── host_vars/
│   │   ├── cluster-a-master-1.yml
│   │   ├── cluster-a-worker-1.yml
│   │   └── cluster-a-worker-2.yml
│   └── roles/                         # Cluster A specific roles (if any)
│
├── cluster-b/                           # Cluster B playbooks
│   ├── site.yml                        # Main playbook for Cluster B (HA)
│   ├── inventory.ini                  # Inventory for Cluster B hosts
│   ├── group_vars/
│   │   ├── masters.yml                # Master node variables (3 HA masters)
│   │   ├── workers.yml                # Worker node variables (5+ nodes)
│   │   ├── storage.yml                # Distributed storage config
│   │   └── all.yml
│   ├── host_vars/
│   │   ├── cluster-b-master-{1..3}.yml
│   │   ├── cluster-b-worker-{1..N}.yml
│   │   └── cluster-b-storage-{1..3}.yml
│   └── roles/                         # Cluster B specific roles (HA, scaling)
│       ├── ha-setup/
│       │   ├── tasks/
│       │   │   ├── configure-etcd-cluster.yml
│       │   │   ├── setup-keepalived.yml
│       │   │   └── configure-load-balancer.yml
│       │   └── templates/
│       │       ├── keepalived.conf.j2
│       │       └── haproxy.cfg.j2
│       │
│       └── autoscaling-setup/
│           ├── tasks/
│           │   └── configure-metrics-server.yml
│           └── templates/
│
└── datacenters/                         # Datacenter-specific playbooks
    ├── datacenter-a/
    │   ├── site.yml
    │   ├── inventory.ini
    │   └── group_vars/
    │       └── datacenter_a.yml        # Datacenter A specific vars
    │
    └── datacenter-b/
        ├── site.yml
        ├── inventory.ini
        └── group_vars/
            └── datacenter_b.yml        # Datacenter B specific vars
```

## Playbook Examples

### cluster-a/site.yml (Lab Cluster)
```yaml
---
- name: Deploy Cluster A (Lab/Dev)
  hosts: all
  roles:
    - role: shared/container-runtime
      vars:
        container_runtime: containerd
    
    - role: shared/kubernetes-control-plane
      vars:
        cluster_role: master
      when: inventory_hostname in groups['masters']
    
    - role: shared/kubernetes-worker
      vars:
        cluster_role: worker
      when: inventory_hostname in groups['workers']
    
    - role: shared/networking
      vars:
        cni_plugin: calico
    
    - role: shared/storage
      vars:
        storage_engine: local
        storage_path: /mnt/local-storage
    
    - role: shared/monitoring
    - role: shared/logging
    - role: shared/security
```

### cluster-b/site.yml (Production Cluster)
```yaml
---
- name: Deploy Cluster B (Production/EKS-like)
  hosts: all
  
  pre_tasks:
    - name: Pre-flight checks for HA setup
      include_role:
        name: shared/kubernetes-control-plane
        tasks_from: validate-ha-requirements
  
  roles:
    - role: shared/container-runtime
      vars:
        container_runtime: containerd
    
    # Master nodes with HA
    - role: shared/kubernetes-control-plane
      vars:
        cluster_role: master
        ha_enabled: true
        etcd_cluster_size: 3
      when: inventory_hostname in groups['masters']
    
    # HA-specific setup
    - role: cluster-b/ha-setup
      vars:
        vip_address: "{{ cluster_b_vip }}"
        keepalived_priority: "{{ hostvars[inventory_hostname].keepalived_priority | default(100) }}"
    
    # Worker nodes with auto-scaling capability
    - role: shared/kubernetes-worker
      when: inventory_hostname in groups['workers']
    
    - role: cluster-b/autoscaling-setup
      vars:
        metrics_server_enabled: true
    
    - role: shared/networking
      vars:
        cni_plugin: cilium
        network_policies_enabled: true
    
    - role: shared/storage
      vars:
        storage_engine: ceph
        ceph_cluster_size: 3
        replication_factor: 3
    
    - role: shared/monitoring
      vars:
        prometheus_retention: 30d
        grafana_admin_password: "{{ vault_grafana_password }}"
    
    - role: shared/logging
      vars:
        logging_backend: elasticsearch
        log_retention_days: 30
    
    - role: shared/security
      vars:
        rbac_enabled: true
        network_policies_enabled: true
        pod_security_policy_enabled: true
```

## Mapping SysML to Ansible

### KubernetesClusterArchitecture.sysml → Ansible Roles

1. **MasterNode** → `roles/shared/kubernetes-control-plane/`
   - Installs API Server, Scheduler, ControllerManager, etcd
   - Role variables align with SysML attributes

2. **WorkerNode** → `roles/shared/kubernetes-worker/`
   - Installs Kubelet, ContainerRuntime, KubeProxy
   - Different configurations for Cluster A vs B

3. **DistributedStorageCluster** → `roles/shared/storage/` (ceph variant)
4. **LoadBalancerService** → `roles/cluster-b/ha-setup/`
5. **IngressController** → Part of cluster site.yml deployment

### Template Consistency Across All Deployments

Each cluster/datacenter folder must have:
- `site.yml` - main entry point playbook
- `inventory.ini` - host inventory
- `group_vars/` - group-level variables
- `host_vars/` - host-level overrides (if needed)

This ensures consistency and enables reusability across Cluster A, Cluster B, and both datacenters.
