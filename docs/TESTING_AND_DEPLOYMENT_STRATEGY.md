# Testing and Deployment Strategy

> **Previous**: [README.md](../README.md) → [DOCS_GUIDE.md](DOCS_GUIDE.md) → [SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)  
> **V-Model Phases**: 08 (ITP) → 09 (STP) → 10 (SV) → 11 (DPL)  
> **Time to read**: 45–60 minutes
>
> **📝 Note**: This is editable documentation in `docs/`. Related deployment and operations documentation may be published in `publication/11_DPL_*.pdf` (auto-generated from `publication/` markdown).

Comprehensive guide for testing and deploying the cloud platform infrastructure.

## Overview

This strategy implements the full V-Model testing phase (08_ITP, 09_STP, 10_SV) along with deployment procedures (11_DPL).

## Testing Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│  V-Model Validation Testing (Full System in Production)         │
│  - System runs as designed in production environment            │
│  - Metrics align with requirements                              │
│  - Long-term stability (weeks)                                  │
│  Related: 10_SV, 11_DPL                                         │
└─────────────────────────────────────────────────────────────────┘
                            ↑
┌─────────────────────────────────────────────────────────────────┐
│  V-Model System Testing (Verification in Staging)               │
│  - End-to-end cluster functionality                             │
│  - Multi-datacenter failover scenarios                          │
│  - Related: 09_STP                                              │
└─────────────────────────────────────────────────────────────────┘
                            ↑
┌─────────────────────────────────────────────────────────────────┐
│  V-Model Integration Testing (Components in Lab)                │
│  - Cluster A in isolated lab environment                        │
│  - Cluster B in multi-zone staging                              │
│  - Related: 08_ITP                                              │
└─────────────────────────────────────────────────────────────────┘
                            ↑
┌─────────────────────────────────────────────────────────────────┐
│  Unit Testing (Individual Components)                           │
│  - SysML syntax validation                                      │
│  - Terraform plan validation                                    │
│  - Ansible playbook linting                                     │
│  - Python script unit tests                                     │
│  - Documentation generation validation                          │
└─────────────────────────────────────────────────────────────────┘
```

## Test Types and Procedures

### 1. Unit Tests (TEST_001-005)

#### TEST_001: SysML Syntax Validation

**Objective**: Ensure all SysML models parse without errors

**Procedure**:
```bash
# Run SysML validator on all models
python scripts/validate-sysml.sh

# Or manually validate specific model
grep -r "package\|class\|attribute" sysml/ | head -20
```

**Acceptance Criteria**:
- ✓ All `.sysml` files parse without syntax errors
- ✓ No unresolved package references
- ✓ All inheritance (`>`) resolves
- ✓ All compositions (`part`) resolve
- ✓ Documentation blocks are valid

**Frequency**: On every commit (automated)
**Duration**: < 1 minute
**Responsible**: CI/CD pipeline

---

#### TEST_002: Terraform Validation

**Objective**: Ensure all Terraform configurations are valid

**Procedure**:
```bash
# Validate shared Terraform modules
cd library/terraform-modules
terraform validate

# Validate Terraform per-instance under configs/
# Recommended: each instance folder should contain a manifest.json and be validated individually.
# Example (Bash): validate every directory under configs/
for d in configs/*/; do
  echo "Validating $d"
  terraform -chdir="$d" validate
done

# Example (PowerShell): validate every directory under configs\
Get-ChildItem -Directory configs | ForEach-Object {
  Write-Host "Validating $($_.FullName)"
  terraform -chdir "$($_.FullName)" validate
}
```

**Acceptance Criteria**:
- ✓ All configurations pass `terraform validate`
- ✓ No syntax errors or missing variables
- ✓ Module dependencies resolve
- ✓ No hardcoded credentials
- ✓ Variable defaults are appropriate
- ✓ Output values are documented

**Frequency**: On every commit (automated)
**Duration**: < 2 minutes
**Responsible**: CI/CD pipeline

---

#### TEST_003: Ansible Linting

**Objective**: Ensure all Ansible playbooks and roles are well-structured

**Procedure**:
```bash
# Install ansible-lint
pip install ansible-lint

# Lint all roles
ansible-lint library/ansible-roles/

# Lint all playbooks
ansible-lint fabrications/
```

**Acceptance Criteria**:
- ✓ All roles pass `ansible-lint`
- ✓ No critical violations
- ✓ No variable naming issues
- ✓ Playbook syntax correct
- ✓ Role structure follows conventions
- ✓ All references valid

**Frequency**: On every commit (automated)
**Duration**: < 1 minute
**Responsible**: CI/CD pipeline

---

#### TEST_004: Python Unit Tests

**Objective**: Ensure Python scripts have good test coverage

**Procedure**:
```bash
# Install pytest and coverage
pip install pytest pytest-cov

# Run all tests with coverage
pytest scripts/ --cov=scripts --cov-report=html

# View coverage report
open htmlcov/index.html
```

**Acceptance Criteria**:
- ✓ All tests pass
- ✓ Code coverage >= 80%
- ✓ No regressions from previous version
- ✓ All critical paths tested

**Test Files**:
- `scripts/test_build_docs.py`
- `scripts/test_generate_pdfs.py`
- `scripts/test_validate_requirements.py`
- `scripts/test_deployment_planning.py`

**Frequency**: On every commit (automated)
**Duration**: < 3 minutes
**Responsible**: CI/CD pipeline

---

#### TEST_005: Documentation Consistency

**Objective**: Ensure generated documentation is valid and consistent

**Procedure**:
```bash
# Clean and rebuild all documentation
make clean
make docs
make pdf

# Validate generated files
python scripts/validate-documentation.py
```

**Acceptance Criteria**:
- ✓ All markdown files generated from SysML
- ✓ No broken references between documents
- ✓ All PDFs generate successfully
- ✓ PDF filenames follow V-Model convention (NN_ABBR_*.pdf)
- ✓ Navigation structure works (links not broken)
- ✓ All images reference valid files
- ✓ Table of contents accurate

**Generated Artifacts**:
- 20+ markdown files in `publication/`
- 10+ PDF files with proper prefixes
- Traceability report

**Frequency**: On every commit (automated)
**Duration**: < 5 minutes
**Responsible**: CI/CD pipeline

---

### 2. Integration Tests (TEST_006-007)

#### TEST_006: Cluster A Integration Test

**Objective**: Verify complete Cluster A deployment in lab environment

**Prerequisites**:
- Lab environment available (isolated network)
- Terraform and Ansible installed
- kubeadm/kubelet available
- Network access to nodes

**Test Environment**:
```
┌─────────────────────────────────────────┐
│  Lab Network (Isolated)                 │
├─────────────────────────────────────────┤
│  Master Node                            │
│    - CPU: 4 cores                       │
│    - RAM: 8 GB                          │
│    - IP: 192.168.1.10                   │
│                                         │
│  Worker Node 1                          │
│    - CPU: 4 cores                       │
│    - RAM: 8 GB                          │
│    - IP: 192.168.1.11                   │
│                                         │
│  Worker Node 2                          │
│    - CPU: 4 cores                       │
│    - RAM: 8 GB                          │
│    - IP: 192.168.1.12                   │
└─────────────────────────────────────────┘
```

**Test Procedure**:

```bash
# 1. Provision infrastructure with Terraform
cd configs/infrastructure-cluster-a
terraform plan -out=tfplan
terraform apply tfplan

# 2. Run configuration playbooks
ansible-playbook -i hosts.ini playbooks/cluster-setup.yml

# 3. Verify cluster health
kubectl get nodes
# Expected: Master and 2 workers all Ready

# 4. Verify system components
kubectl get pods -n kube-system
kubectl get svc -n kube-system

# 5. Deploy test application
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
EOF

# 6. Verify pod networking
kubectl exec -it <pod-name> -- curl http://test-app/

# 7. Test service discovery
kubectl exec -it <pod-name> -- nslookup test-app

# 8. Test persistent volumes
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: test-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/test-data"
EOF

# 9. Monitor metrics and logs
kubectl logs test-app-xxx-yyy
kubectl top nodes
kubectl top pods

# 10. Tear down and verify cleanup
terraform destroy

# 11. Verify no orphaned resources
aws ec2 describe-instances --filters "Name=tag:cluster,Values=cluster-a"
# Expected: Empty list
```

**Acceptance Criteria**:
- ✓ Terraform apply succeeds
- ✓ All nodes join cluster (`kubectl get nodes` shows all Ready)
- ✓ Test pods run and communicate
- ✓ Services DNS resolves correctly
- ✓ Local storage provisioning works
- ✓ Logs flow to centralized location
- ✓ Metrics appear in monitoring system
- ✓ Teardown completes without orphaned resources

**Frequency**: On every commit (automated in CI/CD)
**Duration**: 30-45 minutes
**Responsible**: DevOps team + CI/CD automation
**Environment**: Lab (isolated from production)

---

#### TEST_007: Cluster B Integration Test

**Objective**: Verify complete Cluster B deployment with HA in staging

**Prerequisites**:
- Staging environment with 2 datacenters (or zones)
- Network connectivity between zones (< 5ms latency)
- Terraform and Ansible installed
- etcd cluster tools available

**Test Environment**:
```
┌──────────────────────────────────────────────────────────┐
│  Staging Network (Multi-Zone)                            │
├─────────────────────────────┬───────────────────────────┤
│  Zone 1 (Datacenter A)      │  Zone 2 (Datacenter B)    │
├─────────────────────────────┼───────────────────────────┤
│  Master 1 (etcd-0)          │  Master 2 (etcd-1)        │
│  - IP: 10.0.1.10            │  - IP: 10.0.2.10          │
│  - Etcd member: LEADER      │  - Etcd member: FOLLOWER  │
│                             │                           │
│  Worker Pool 1              │  Master 3 (etcd-2)        │
│  - 3 nodes                  │  - IP: 10.0.2.11          │
│  - IPs: 10.0.1.20-22        │  - Etcd member: FOLLOWER  │
│                             │                           │
│  Distributed Storage        │  Worker Pool 2            │
│  - Replication factor: 3    │  - 2+ nodes               │
│                             │  - IPs: 10.0.2.20+        │
└─────────────────────────────┴───────────────────────────┘
                  Inter-Zone Link (< 5ms)
```

**Test Procedure**:

```bash
# 1. Provision etcd cluster
cd configs/infrastructure-cluster-b/etcd
terraform plan -out=tfplan
terraform apply tfplan

# 2. Verify etcd cluster health
etcdctl member list
etcdctl member health
# Expected: All 3 members healthy

# 3. Provision master nodes
cd ../masters
terraform plan -out=tfplan
terraform apply tfplan

# 4. Verify master node initialization
ansible-playbook -i hosts.ini playbooks/master-init.yml

# 5. Provision worker nodes
cd ../workers
terraform plan -out=tfplan
terraform apply tfplan

# 6. Verify worker node join
ansible-playbook -i hosts.ini playbooks/worker-join.yml
kubectl get nodes
# Expected: 3 masters + 5+ workers all Ready

# 7. Test control plane failover (Master 1)
kubectl drain node/master-1
# Expected: Pods evicted, control plane still responsive
kubectl uncordon node/master-1

# 8. Test control plane failover (Master 2)
kill -9 <process-pid-on-master-2>
kubectl get nodes
# Expected: Master 2 becomes NotReady, cluster still functional
# Wait for recovery...
kubectl get nodes
# Expected: Master 2 recovered

# 9. Deploy distributed storage
kubectl apply -f configs/infrastructure-cluster-b/storage-backend/

# 10. Test distributed storage with replication
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app-distributed
spec:
  replicas: 3
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: app
        image: nginx:latest
        volumeMounts:
        - name: data
          mountPath: /data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: test-pvc
EOF

# 11. Verify cross-zone networking
# From Zone 1 pod:
kubectl exec -it <pod-in-zone-1> -- \
  curl http://<service-in-zone-2>:8080

# 12. Test load balancer
kubectl create service loadbalancer test-lb --tcp=80:80

# 13. Monitor cross-zone latency
kubectl run netcat --image=nicolaka/netcat -- \
  nc -zv -w1 <ip-in-other-zone> 80

# 14. Test etcd backup and recovery
etcdctl snapshot save backup.db
etcdctl snapshot restore --data-dir=restored.etcd backup.db

# 15. Test zone failover
# Simulate Zone 1 network partition (in staging only!)
iptables -A OUTPUT -d 10.0.2.0/24 -j DROP
# Expected: Zone 2 becomes primary, workloads reschedule
# Remove iptables rule to recover
iptables -D OUTPUT -d 10.0.2.0/24 -j DROP

# 16. Tear down and verify cleanup
terraform destroy

# 17. Verify no orphaned resources
aws ec2 describe-instances --filters "Name=tag:cluster,Values=cluster-b"
# Expected: Empty list
```

**Acceptance Criteria**:
- ✓ Terraform apply succeeds across both zones
- ✓ All 3 masters join cluster and form quorum
- ✓ etcd cluster healthy (all members synced)
- ✓ All 5+ workers ready
- ✓ Control plane HA verified (master failures don't kill cluster)
- ✓ Distributed storage operational and replicated
- ✓ Cross-zone latency < 5ms
- ✓ Load balancer distributes traffic
- ✓ Cross-zone pod communication works
- ✓ Zone failover scenarios pass
- ✓ Teardown completes without orphaned resources

**Frequency**: Daily/Weekly (automated in CI/CD)
**Duration**: 90-120 minutes
**Responsible**: DevOps team + CI/CD automation
**Environment**: Staging (multi-zone, production-like)

---

### 3. System Testing (TEST_008: Failover and DR Tests)

**Objective**: Verify system resilience to various failure scenarios

**Test Scenarios**:

#### Scenario 1: Single Node Failure
```bash
# Simulate node crash
ssh <worker-node> "sudo shutdown -h now"

# Expected outcomes:
# - Pods running on crashed node are evicted (within 5 minutes)
# - Pods reschedule on healthy nodes
# - No data loss for stateless apps
```

#### Scenario 2: Master Node Failure (Cluster B only)
```bash
# Stop kubelet on master-2
ssh master-2 "sudo systemctl stop kubelet"

# Expected outcomes:
# - Cluster remains functional with remaining 2 masters
# - etcd quorum maintained
# - Control plane responsive
```

#### Scenario 3: Datacenter Network Partition
```bash
# Simulate network partition (staging only)
on_zone_a: iptables -A OUTPUT -d 10.0.2.0/24 -j DROP
on_zone_b: iptables -A OUTPUT -d 10.0.1.0/24 -j DROP

# Expected outcomes:
# - Split-brain prevented by etcd
# - Minority partition loses quorum
# - Majority partition remains operational
# - Services continue on majority side

# Remove iptables rules to recover
iptables -F
```

#### Scenario 4: Complete Datacenter Failure
```bash
# Simulate Datacenter A complete failure
# In staging: power down all VMs in Zone 1

# Expected outcomes:
# - Zone 2 becomes sole operational zone
# - Pods reschedule to Zone 2 (if resources available)
# - Stateless services migrate within 5-15 minutes
# - Persistent data remains available (replicated to Zone 2)
```

#### Scenario 5: etcd Data Corruption
```bash
# Backup current etcd state
etcdctl snapshot save good_backup.db

# Simulate data corruption
# In staging: manually corrupt etcd member
etcdctl put /corrupted-key corrupted-value

# Test recovery from backup
etcdctl snapshot restore good_backup.db --data-dir=restore.etcd
# Restart etcd with restored data

# Expected outcomes:
# - Cluster recovers from backup
# - No permanent data loss
# - etcd cluster resyncs
```

**Acceptance Criteria**:
- ✓ Single node failure: pods rescheduled in < 5 minutes
- ✓ Master failure: cluster operational with remaining masters
- ✓ Network partition: split-brain prevented
- ✓ Datacenter failover: services migrate in < 15 minutes
- ✓ etcd recovery: cluster operational, no data loss

**Frequency**: Monthly (after major changes)
**Duration**: 60-90 minutes
**Responsible**: DevOps team
**Environment**: Staging (can tolerate disruptions)

---

## Deployment Procedures

### Deployment Approval Gates

```
┌─────────────────────────────────────────────┐
│  PHASE 1: Pre-Deployment Planning           │
│  - Stakeholder sign-off: ✓                  │
│  - Requirements verified: ✓                 │
│  - All tests passing: ✓                     │
│  - Release notes prepared: ✓                │
│  - Rollback procedure tested: ✓             │
│  - Monitoring configured: ✓                 │
│  Jira: Create DEPLOY-* issue (status: TODO) │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  PHASE 2: Approval Request                  │
│  - CISO approval: ☐ (security review)       │
│  - Release Manager: ☐ (change control)      │
│  - Ops Lead: ☐ (operational readiness)      │
│  Jira: DEPLOY-* (status: AWAITING_APPROVAL) │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  PHASE 3: Pre-Flight Validation             │
│  - Final terraform plan review: ✓           │
│  - Ansible playbook dry-run: ✓              │
│  - Security scanning: ✓                     │
│  - Monitoring health check: ✓               │
│  - Backup verification: ✓                   │
│  Jira: DEPLOY-* (status: READY_FOR_DEPLOY)  │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  PHASE 4: Execution (With Monitoring)       │
│  - Apply terraform changes                  │
│  - Run ansible playbooks                    │
│  - Monitor metrics and logs                 │
│  - Verify new services available            │
│  - No error rate increase                   │
│  Jira: DEPLOY-* (status: IN_PROGRESS)       │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  PHASE 5: Post-Deployment Validation        │
│  - Health checks passed: ✓                  │
│  - Smoke tests passed: ✓                    │
│  - Performance baseline: ✓                  │
│  - Monitoring alerts: none                  │
│  - No security violations: ✓                │
│  Jira: DEPLOY-* (status: DONE)              │
└─────────────────────────────────────────────┘
                    ↓
           ┌────────────────┐
           │ SUCCESS        │
           └────────────────┘

ROLLBACK PATH (if needed):
           ┌────────────────┐
           │ ERROR DETECTED │
           └────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  ROLLBACK DECISION                          │
│  - Error severity assessment                │
│  - Impact analysis                          │
│  - Rollback authority approval              │
│  - Estimated recovery time                  │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  ROLLBACK EXECUTION                         │
│  - Execute rollback procedure                │
│  - Verify pre-deployment state               │
│  - Validate system health                    │
│  - Update Jira: DEPLOY-* (status: ROLLED_BACK)
│  - Schedule post-mortem                      │
└─────────────────────────────────────────────┘
```

### Deployment Checklist

Before executing any deployment:

```
PRE-DEPLOYMENT CHECKLIST
☐ Deployment ticket created in Jira (DEPLOY-*)
☐ Related requirements reviewed (SYSTEM_REQ_*, INFRA_REQ_*, etc.)
☐ All unit tests passing (TEST_001-005)
☐ Integration tests passing (TEST_006-007)
☐ Failover scenarios validated (TEST_008)
☐ Documentation updated (publication/ PDFs generated)
☐ External requirement documents reviewed
☐ Vendor documentation consulted for compatibility
☐ Team notified 24 hours in advance
☐ Maintenance window scheduled and communicated
☐ Rollback procedure documented and tested
☐ Monitoring and alerting configured
☐ On-call team available
☐ CISO security approval obtained
☐ Release Manager approval obtained
☐ Ops Lead operational approval obtained

FINAL SIGN-OFF
☐ I, __________________, acknowledge all requirements are met
☐ I understand the rollback procedure
☐ I accept responsibility for this deployment
  
Signature: ________________ Date: _________ Time: _________
```

### Zero-Downtime Deployment

For Cluster B production deployments, use canary/blue-green strategy:

```bash
# Blue-Green Deployment Strategy

# PHASE 1: Prepare Green Environment
# 1. Provision new infrastructure (parallel to current)
# 2. Run ansible playbooks
# 3. Validate new environment health
# 4. Run smoke tests in green environment

# PHASE 2: Cutover Traffic
# 1. Update load balancer to route to green
# 2. Monitor error rates
# 3. Verify services responding on green

# PHASE 3: Decommission Blue
# 1. Wait 30 minutes (rollback window)
# 2. Decommission old infrastructure
# 3. Update DNS if applicable

# PHASE 4: Validate
# 1. Confirm all services on green
# 2. Validate data consistency
# 3. Update Jira status to DONE

# ROLLBACK: Switch back to blue if problems detected
load_balancer.route_to("blue")
```

### Canary Deployment

For reducing risk of defective releases:

```
10% Deployed (Stage 1)
├─ Monitor for 30 minutes
├─ If error rate < 0.1%: continue
└─ If error rate > 0.1%: ROLLBACK

50% Deployed (Stage 2)
├─ Monitor for 30 minutes
├─ If error rate < 0.1%: continue
└─ If error rate > 0.1%: ROLLBACK

100% Deployed (Stage 3)
├─ Final validation
└─ Declare success
```

## Post-Deployment Validation

After deployment, validate:

```bash
# 1. Health Checks
for service in $(kubectl get svc -o jsonpath='{.items[*].metadata.name}'); do
  status=$(kubectl get svc $service -o jsonpath='{.status.phase}')
  if [ "$status" != "Active" ]; then
    echo "ERROR: Service $service unhealthy: $status"
  fi
done

# 2. Metrics Collection
curl http://prometheus:9090/api/v1/query?query=up

# 3. Log Aggregation
curl http://elasticsearch:9200/logs/_stats | grep total

# 4. Monitoring Alerts
# Check that no critical alerts are firing

# 5. Performance Baseline
# Verify latency and throughput match expected values
```

## Disaster Recovery Procedures

See `input/testing-deployment/failover-dr.md` for comprehensive DR procedures.

---

**Last Updated**: December 4, 2025  
**Maintained By**: DevOps and Quality Assurance Team

## Next Steps

### After successful deployment...
→ Review **`publication/11_DPL_DeploymentAndOM.pdf`** (Phase 11: Operations & Maintenance)

### For operational runbooks and post-deployment monitoring...
→ Consult the deployment documentation and O&M procedures in `input/` or `publication/` folders

### To revisit architecture and design before deployment...
→ Read **[SYSML_ARCHITECTURE_GUIDE.md](SYSML_ARCHITECTURE_GUIDE.md)** (Architecture review)  
→ Review **`publication/06_SDD_*.pdf`** (Phase 06: Detailed Design)

### To understand how to modify or extend deployments...
→ Read **[CONTRIBUTING.md](CONTRIBUTING.md)** (Development & modification guidelines)

### Return to the main thread:
→ Back to **[DOCS_GUIDE.md](DOCS_GUIDE.md)**
