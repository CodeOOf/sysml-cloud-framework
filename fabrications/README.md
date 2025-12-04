# fabrications/ — Dynamic Datacenter/Fabrication Repositories

Purpose
-------
This folder contains fabrication or datacenter sub-repositories. Each sub-folder under `fabrications/` is an independent owner of its physical design artifacts (SysML models, floorplans, rack definitions, local specs). Folder names are dynamic and decided by the owning team; `fabrication-datacenter-a` is an example only.

Key Principles
--------------
- Dynamic names: Do NOT treat `A`/`B` as canonical. They are examples used in documentation. Production names should reflect organizational conventions (site codes, region, environment).
- Ownership: The sub-folder owns models, specs, views, and any physical deployment documentation within it.
- Manifest: Each sub-folder SHOULD include `manifest.json` conforming to `fabrications/manifest.schema.json`.

Example layout
--------------
```
fabrications/
  ├─ datacenter-east-1/      # example name
  │  ├─ models/
  │  ├─ specs/
  │  └─ manifest.json
  └─ datacenter-lab/         # example name
     ├─ models/
     ├─ specs/
     └─ manifest.json
```

Manifest Example
----------------
```json
{
  "id": "datacenter-east-1",
  "displayName": "Fabrication Datacenter East 1 (example)",
  "type": "datacenter",
  "owner": "team-fabrication",
  "contact": "fabops@example.com",
  "location": "Building 1, Floor 2",
  "relatedSysMLRequirements": ["FAB_REQ_001"]
}
```

Tooling and Integration
-----------------------
- Build tooling reads `manifest.json` to map SysML references to the actual folder IDs.
- When referencing fabrication instances in SysML or docs, reference requirement IDs and manifest `id` values rather than literal example names.

See also `configs/README.md` and `docs/PROJECT_INTEGRATION_GUIDE.md` for CI/CD and ownership best practices.
