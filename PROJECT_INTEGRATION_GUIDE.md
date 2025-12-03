# Project Integration: Jira, GitLab, and Issue Tracking

This document explains how this project integrates with external project management and issue tracking systems.

## Overview

The cloud platform project integrates with:
- **Jira** (atlassian.com) - For requirement and deployment tracking
- **GitLab** - For code/IaC changes and merge request workflows
- **GitHub** (optional) - Alternative to GitLab

## Requirement Traceability

### Requirement Naming Convention

All requirements follow this pattern:

```
<SUBSYSTEM>_REQ_<NNN>

Where:
  SUBSYSTEM = SYSTEM | INFRA | FAB | TEST | DEPLOY
  NNN       = Sequential number (001, 002, ..., 999)

Examples:
  SYSTEM_REQ_001 = Cluster Architecture
  INFRA_REQ_002  = Cluster B Multi-Master HA
  FAB_REQ_003    = Physical Rack Design
  TEST_001       = SysML Syntax Validation
  DEPLOY_001     = Deployment Plan Definition
```

### Jira Project Keys

Each sub-system has a Jira project:

| Sub-System | Jira Key | Purpose | URL Format |
|---|---|---|---|
| System | PLAT | Platform overall (PLAT-001, PLAT-002, ...) | https://your-jira.atlassian.net/browse/PLAT-001 |
| Infrastructure | INFRA | Kubernetes clusters (INFRA-001, INFRA-002, ...) | https://your-jira.atlassian.net/browse/INFRA-001 |
| Fabrication | FAB | Datacenters (FAB-001, FAB-002, ...) | https://your-jira.atlassian.net/browse/FAB-001 |
| Testing | TEST | Test plans (TEST-001, TEST-002, ...) | https://your-jira.atlassian.net/browse/TEST-001 |
| Deployment | DEPLOY | Deployment procedures (DEPLOY-001, DEPLOY-002, ...) | https://your-jira.atlassian.net/browse/DEPLOY-001 |

## SysML Model Integration

### Linking Requirements to Jira

Each SysML requirement model includes Jira traceability:

```sysml
class ClusterArchitectureRequirement :> SystemRequirement {
    doc /* Cluster architecture must be flexible and scalable
             References:
             - Jira: PLAT-001
             - External: input/system-requirements/cluster-design.md
         */
    
    attribute externalSourceId : String; /* Value: "PLAT-001" */
}
```

### Linking to External Documents

External requirement documents (in `input/` folder) are referenced:

```sysml
attribute externalDocumentRef : String; /* Value: "input/system-requirements/cluster-design.md" */
```

## GitLab Integration

### Repository Structure

```
Private Cloud Platform Repository (Git)
├── sysml/                    # SysML models (source of truth)
├── library/                  # Shared Terraform, Ansible, SysML
├── configs/                  # Cluster-specific Terraform/Ansible
├── fabrications/             # Datacenter-specific configurations
├── scripts/                  # Build and validation scripts
├── publication/              # Generated documentation
├── input/                    # External requirement documents
├── vendor-docs/              # Vendor documentation references
└── .gitlab-ci.yml            # CI/CD pipeline (see below)
```

### Branching Strategy

```
main (production)
  ↑
  ← release/v1.0.0 (prepare release)
  ← develop (integration branch)
    ← feature/PLAT-001-cluster-architecture (feature branch)
    ← feature/INFRA-002-cluster-b-ha
    ← feature/FAB-003-rack-design
    ← hotfix/DEPLOY-fix-deployment-issue
```

**Branch Naming Convention**:
```
<type>/<JIRA-KEY>-<short-description>

Types: feature, hotfix, release, bugfix
Examples:
  feature/PLAT-001-cluster-architecture
  feature/INFRA-002-cluster-b-ha
  hotfix/DEPLOY-123-fix-rollback
```

### Merge Request Workflow

Every change goes through:

```
1. Developer: Create feature branch from develop
   git checkout -b feature/PLAT-001-cluster-architecture

2. Developer: Make changes (SysML, Terraform, Ansible, docs)
   git add sysml/ library/ configs/
   git commit -m "PLAT-001: Define cluster architecture"

3. Developer: Push to GitLab
   git push origin feature/PLAT-001-cluster-architecture

4. GitLab: Create Merge Request
   - Title: "[PLAT-001] Cluster Architecture Definition"
   - Description: Reference Jira issue, link to requirement doc
   - Assignee: Architecture lead
   - Reviewers: At least 2 approvals required

5. CI/CD Pipeline Runs (see below)
   - Syntax validation (SysML, Terraform, Ansible)
   - Unit tests
   - Security scanning
   - Documentation generation

6. Code Review
   - Minimum 2 approvals required
   - Security review (if applicable)
   - Architecture review

7. Merge to develop
   - GitLab: Automatically transitions Jira issue

8. Merge to main
   - Tag version (v1.0.0, v1.0.1, etc.)
   - Create release notes
   - Deploy to production (manual approval)
```

### Jira Integration with GitLab

GitLab automatically updates Jira when:

1. **Mention in commit message**: `PLAT-001` → Jira sees the reference
2. **Mention in MR description**: `Resolves PLAT-001` → Jira transitions on merge
3. **Close on merge**: `Closes PLAT-001` → Jira issue auto-closes

**MR Description Template**:
```markdown
## Description
Brief description of the changes.

## Related Jira Issue
- Resolves PLAT-001
- Related to INFRA-002
- Blocks FAB-003

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation
- [ ] Infrastructure change

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Backwards compatible

## Deployment Notes
How to deploy this change, any migrations needed, etc.
```

## CI/CD Pipeline

### .gitlab-ci.yml Configuration

```yaml
stages:
  - validate
  - test
  - build
  - deploy

# Stage 1: Validate syntax and structure
validate:sysml:
  stage: validate
  script:
    - python scripts/validate-sysml.sh
  only:
    changes:
      - sysml/**
      - scripts/validate-sysml.sh

validate:terraform:
  stage: validate
  script:
    - python scripts/validate-terraform.sh
  only:
    changes:
      - library/terraform-modules/**
      - configs/**
      - scripts/validate-terraform.sh

validate:ansible:
  stage: validate
  script:
    - python scripts/validate-ansible.sh
  only:
    changes:
      - library/ansible-roles/**
      - fabrications/**
      - scripts/validate-ansible.sh

# Stage 2: Run tests
test:unit:
  stage: test
  script:
    - pytest scripts/ --cov=scripts --cov-report=xml
  coverage: '/TOTAL.*\s+(\d+%)$/'

test:integration-cluster-a:
  stage: test
  script:
    - python scripts/test-cluster-a-integration.sh
  only:
    - develop
    - main

test:integration-cluster-b:
  stage: test
  script:
    - python scripts/test-cluster-b-integration.sh
  only:
    - develop
    - main

# Stage 3: Build documentation and artifacts
build:docs:
  stage: build
  script:
    - make docs
    - make pdf
  artifacts:
    paths:
      - publication/
    expire_in: 30 days

# Stage 4: Deploy (manual for production)
deploy:staging:
  stage: deploy
  script:
    - python scripts/deploy-cluster-a.sh --env staging
  environment:
    name: staging
  only:
    - develop
  when: manual

deploy:production:
  stage: deploy
  script:
    - python scripts/deploy-cluster-b.sh --env production
  environment:
    name: production
  only:
    - main
  when: manual
```

## Deployment Procedures

### Deployment Workflow

```
1. Feature Complete
   - All code merged to develop
   - All tests passing
   - Documentation updated
   - Jira issue marked "READY_FOR_DEPLOYMENT"

2. Create Release
   - Create branch: release/v1.0.0
   - Update version numbers
   - Create release notes
   - Create GitLab release tag

3. Request Approvals in Jira
   - Create DEPLOY-001 issue
   - Link to related requirements (PLAT-001, etc.)
   - Request approvals:
     - [ ] CISO approval (security)
     - [ ] Release Manager approval
     - [ ] Ops Lead approval

4. Deploy to Staging (if applicable)
   - GitLab: Trigger manual "deploy:staging" job
   - Jira: DEPLOY-001 transitions to "IN_PROGRESS"
   - Run smoke tests
   - Validate monitoring

5. Deploy to Production
   - GitLab: Trigger manual "deploy:production" job
   - Jira: DEPLOY-001 transitions to "IN_PROGRESS"
   - Monitor for issues
   - Run health checks
   - Confirm success → Jira transitions to "DONE"

6. Rollback (if needed)
   - Trigger rollback procedure
   - Jira: Create DEPLOY-ROLLBACK issue
   - Document issue in post-mortem
```

### Jira Deployment Issue Template

```
Project: DEPLOY
Issue Type: Deployment
Summary: Deploy [Feature Name] to [Environment]

Description:
- Release Version: v1.0.0
- Target Environment: Production
- Deployment Date: YYYY-MM-DD
- Estimated Downtime: 0 minutes (zero-downtime deployment)

Related Requirements:
- PLAT-001: Cluster Architecture
- INFRA-002: Cluster B HA
- (add others)

Deployment Checklist:
- [ ] All tests passing in CI/CD
- [ ] Documentation updated
- [ ] Rollback procedure tested
- [ ] Monitoring in place
- [ ] Team notified
- [ ] Approval from CISO
- [ ] Approval from Release Manager
- [ ] Approval from Ops Lead

Pre-Deployment:
- [ ] terraform plan reviewed and approved
- [ ] ansible playbooks dry-run executed
- [ ] Backup of current state taken

Deployment Steps:
1. (See deployment procedure in publication/)
2. (Detailed steps from DEPLOY_001 plan)
3. (Verification steps)

Rollback Procedure:
(Reference rollback procedure from deployment plan)

Post-Deployment:
- [ ] Health checks passed
- [ ] Monitoring showing normal operation
- [ ] No error rate increase
- [ ] Performance within baseline
- [ ] Post-deployment validation completed
```

## Requirement Status Workflow

### Jira Status Transitions

```
DRAFT
  ↓ (review and approve)
APPROVED
  ↓ (begin implementation)
IN_PROGRESS
  ↓ (code complete)
READY_FOR_TESTING
  ↓ (tests pass)
READY_FOR_DEPLOYMENT
  ↓ (deploy to production)
DEPLOYED
  ↓ (verify in production)
VERIFIED
  ↓ (close)
DONE

Alternative path:
  ... → REJECTED (if requirement not feasible)
  ... → ON_HOLD (if blocked or deferred)
```

### Updating Jira from Git Commits

#### Transition Issue

```bash
git commit -m "PLAT-001 Implement cluster architecture

- Update SysML models
- Add Terraform configuration
- Add Ansible playbooks

Fixes PLAT-001"
```

When merged to develop, Jira issue PLAT-001 transitions to "IN_PROGRESS"
When merged to main, Jira issue PLAT-001 transitions to "READY_FOR_DEPLOYMENT"

#### Close Issue

```bash
git commit -m "PLAT-001 Final testing and documentation

- Complete unit tests
- Complete integration tests
- Update documentation

Closes PLAT-001"
```

When merged, Jira issue PLAT-001 closes automatically.

## Automated Status Updates

### CI/CD Pipeline to Jira

The CI/CD pipeline automatically updates Jira issues:

**Script**: `scripts/update-jira-status.py`

```python
# When tests pass:
jira.issue('PLAT-001').update(status='READY_FOR_TESTING')

# When documentation generated:
jira.issue('PLAT-001').add_comment(
    'Documentation generated: publication/04_SAD_SysMLCloudPlatform.pdf'
)

# When deployment starts:
jira.issue('DEPLOY-001').update(status='IN_PROGRESS')
jira.issue('DEPLOY-001').add_comment(f'Deployment started at {timestamp}')

# When deployment succeeds:
jira.issue('DEPLOY-001').update(status='DONE')
jira.issue('DEPLOY-001').add_comment(f'Deployment completed at {timestamp}')

# When deployment fails/rolls back:
jira.issue('DEPLOY-001').update(status='ROLLED_BACK')
jira.issue('DEPLOY-001').add_comment(f'Rollback executed: {reason}')
```

### Configuration

Edit `.gitlab-ci.yml` to add Jira webhook:

```yaml
variables:
  JIRA_URL: "https://your-jira.atlassian.net"
  JIRA_USER: "ci-bot@company.com"
  JIRA_TOKEN: $JIRA_API_TOKEN  # Store in GitLab secrets

after_script:
  - python scripts/update-jira-status.py
```

## Documentation Integration

### Embedding External Documents

When generating PDFs, include references to:

1. **Jira Issues** (in document metadata)
2. **External Documents** (from `input/` folder)
3. **Vendor Documentation** (from `vendor-docs/` folder)

**Generated PDF Footer Example**:
```
Related Jira Issues: SYSTEM_REQ_001 (PLAT-001)
External Document: input/system-requirements/cluster-design.md
Vendor References: vendor-docs/kubernetes/, vendor-docs/terraform/
```

### Generating Requirement Traceability Report

```bash
python scripts/generate-traceability-report.py
```

Output: `publication/TRACEABILITY_REPORT.md`

Contents:
```markdown
# Requirement Traceability Report

## System Requirements (SYSTEM_REQ_*)
| Req ID | Title | Jira | Status | Implemented | Tested |
|---|---|---|---|---|---|
| SYSTEM_REQ_001 | Cluster Architecture | PLAT-001 | VERIFIED | ✓ | ✓ |
| SYSTEM_REQ_002 | Multi-Datacenter | PLAT-002 | DEPLOYED | ✓ | ✓ |
| ... | | | | | |

## Infrastructure Requirements (INFRA_REQ_*)
| Req ID | Title | Jira | Status | Implemented | Tested |
| INFRA_REQ_001 | Cluster A | INFRA-001 | VERIFIED | ✓ | ✓ |
| ... | | | | | |

## Test Coverage
- Unit Tests: 92 tests, 85% code coverage
- Integration Tests: 8 scenarios, all passing
- E2E Tests: 3 scenarios, all passing
```

## Best Practices

### For Developers

1. **Always reference Jira issue**:
   ```bash
   git commit -m "PLAT-001: Add cluster architecture support"
   ```

2. **Link external documents in commit messages**:
   ```bash
   git commit -m "PLAT-001: Implement per input/system-requirements/cluster-design.md"
   ```

3. **Keep Jira updated**:
   - Transition status as work progresses
   - Add comments with technical decisions
   - Link related issues

4. **Use merge requests for all changes**:
   - Never commit directly to develop/main
   - Always require code review
   - Wait for CI/CD to pass

### For Project Managers

1. **Create Jira issues for all requirements**
2. **Link Jira issues to external documents**
3. **Track requirement status from DRAFT → DONE**
4. **Monitor deployment progress via Jira**
5. **Generate traceability reports for audits**

### For Operations

1. **Create DEPLOY-* issues for deployments**
2. **Verify all approvals before deploying**
3. **Monitor Jira transitions during deployment**
4. **Document rollback reasons in Jira**
5. **Update issue with post-mortem findings**

## Troubleshooting

### Jira Issue Not Updating

**Problem**: GitLab commit doesn't update Jira

**Solution**:
1. Verify Jira API token is valid (stored in GitLab secrets)
2. Check issue key format (PLAT-001, not plat-001)
3. Use keyword "Closes" or "Fixes" correctly
4. Ensure branch is set to track develop/main

### CI/CD Pipeline Failing

**Problem**: GitLab CI fails even though all changes look correct

**Solution**:
1. Check CI/CD logs: https://gitlab.com/project/-/pipelines
2. Validate SysML syntax: `python scripts/validate-sysml.sh`
3. Validate Terraform: `terraform validate`
4. Validate Ansible: `ansible-lint library/ansible-roles/`

### Missing External Documents

**Problem**: SysML model references `input/system-requirements/foo.md` but file doesn't exist

**Solution**:
1. Create the file: `touch input/system-requirements/foo.md`
2. Add content following template (see `input/README.md`)
3. Update SysML to correct path
4. Rebuild documentation

---

**Last Updated**: December 4, 2025
**Maintained By**: DevOps and Release Engineering Team
