# configs/ — Dynamic Infrastructure Repositories

Purpose
-------
This folder contains infrastructure sub-repositories. Each sub-folder under `configs/` is an independent, authoritative owner for its artifacts (Terraform, Ansible, templates, docs) and defines its own name. Folder names are dynamic: they can be `cluster-a`, `cluster-01`, `prod-west`, `c`, `d`, or any other identifier chosen by the owning team.

Key Principles
--------------
- Dynamic names: Do NOT hard-code expectations about a fixed set of names (A, B, etc.) in SysML models or documentation. Wherever an example name is used (e.g., `cluster-a` or `A`), it is just that — an example.
- Ownership: Each sub-folder is the owner of everything inside it. Modify files in that folder to update that infrastructure instance.
- Machine-readable manifest: Each sub-folder SHOULD include a small manifest (see `manifest.schema.json`) describing metadata: `id`, `displayName`, `type`, `owner`, `contact`, and `purpose`.

Example sub-folder layout
-------------------------
```
configs/
  ├─ cluster-a/              # example name — could be 'c' or 'east-1'
  │  ├─ main.tf
  │  ├─ variables.tf
  │  ├─ modules/
  │  └─ manifest.json        # required for tooling
  └─ production-west/        # another example
     ├─ main.tf
     └─ manifest.json
```

Manifest (recommended)
----------------------
Each sub-folder SHOULD contain `manifest.json` conforming to `configs/manifest.schema.json` at repository root. Example `manifest.json`:

```json
{
  "id": "cluster-a",
  "displayName": "Lab Cluster A (example)",
  "type": "kubernetes-cluster",
  "owner": "team-infra",
  "contact": "infra@example.com",
  "purpose": "lab/testing",
  "relatedSysMLRequirements": ["INFRA_REQ_001"]
}
```

Examples vs. Instances
----------------------
- The documentation contains examples named `A` and `B` to demonstrate different architectures. Those are not prescriptive names. Replace them with your real instance IDs and update `manifest.json` accordingly.

Tooling
-------
- Build and traceability tooling will resolve actual instance names by reading each sub-folder's `manifest.json`.
- If no `manifest.json` exists, tools should treat the folder as an unmanaged example and warn but not fail.

Ownership and Governance
------------------------
- Teams owning a `configs/*` folder are responsible for its CI/CD, security, and lifecycle.
- Cross-references in SysML should reference requirement IDs, not literal folder names.

For more details see `PROJECT_INTEGRATION_GUIDE.md` and `publication/NAVIGATION_GUIDE.md`.
