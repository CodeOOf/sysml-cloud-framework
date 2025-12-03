/**
 * Fabrication Sub-System Requirements
 * 
 * OMG SysML v2 requirement specification for the Datacenter Fabrication sub-system
 * Based on https://www.omg.org/sysml/sysmlv2/
 * 
 * These requirements cascade from SYSTEM_REQ_* and define specific needs for:
 * - Fabrication Datacenter A (primary site)
 * - Fabrication Datacenter B (secondary site for Cluster B HA)
 * 
 * External Reference: input/fabrication-requirements/
 * Project Integration: Jira project key FAB-*
 */

package FabricationSubSystemRequirements {
    import Base::*;

    /**
     * Requirement: Fabrication subsystem base
     * Inherits traceability from system level
     */
    abstract class FabricationRequirement {
        doc /* Fabrication subsystem requirement
                 - Traces to SYSTEM_REQ_* parent
                 - Specific to Datacenter A or B
                 - Links to Jira FAB-* issues
                 - References external documents
             */
        
        attribute requirementId : String; /* FAB_REQ_NNN format */
        attribute relatedSystemReq : String; /* Links to SYSTEM_REQ_* */
        attribute appliesToDatacenter : String; /* "A", "B", or "A,B" */
        attribute externalSourceId : String;
        attribute priority : String;
        attribute version : String;
    }

    /**
     * FAB_REQ_001: Fabrication Datacenter A - Primary Site
     * Datacenter A must host Cluster A and Cluster B Master 1
     */
    class DatacenterAPrimaryRequirement :> FabricationRequirement {
        doc /* Fabrication Datacenter A: Primary deployment site
                 
             Parent System Requirement: SYSTEM_REQ_002 (Multi-Datacenter)
             Jira: FAB-001
             External: input/fabrication-requirements/datacenter-a-design.md
             
             Acceptance Criteria:
             - Co-hosts Cluster A (complete, all nodes)
             - Co-hosts Cluster B Master 1 (first etcd member)
             - Physical location: Primary facility
             - Network latency to Datacenter B: < 5ms
             - Power and cooling provisioned for growth
             - Physical racks: A1, A2 (see fabrications/fabrication-datacenter-a/)
             
             Associated SysML Models:
             - sysml/datacenter/DeploymentArchitecture.sysml (FabricationDatacenterA)
             
             Deployment Implementation:
             - fabrications/fabrication-datacenter-a/models/ (SysML design)
             - fabrications/fabrication-datacenter-a/specs/ (datacenter.json)
             - fabrications/fabrication-datacenter-a/views/ (rack views)
             
             Project Structure:
             - fabrications/fabrication-datacenter-a/
               ├── models/ (SysML definitions)
               ├── specs/ (JSON specifications)
               ├── views/ (visual representations)
               ├── projects/ (project management integration)
               └── requirements/ (FAB_REQ_* definitions)
         */
        
        attribute clustersHosted : String[] = {"Cluster A", "Cluster B (Master 1)"};
        attribute physicalRacks : Integer = 2;
        attribute isPrimary : Boolean = true;
    }

    /**
     * FAB_REQ_002: Fabrication Datacenter B - Secondary/DR Site
     * Datacenter B must host Cluster B Masters 2-3 and worker nodes
     */
    class DatacenterBSecondaryRequirement :> FabricationRequirement {
        doc /* Fabrication Datacenter B: Secondary deployment site for HA/DR
                 
             Parent System Requirement: SYSTEM_REQ_002 (Multi-Datacenter)
             Jira: FAB-002
             External: input/fabrication-requirements/datacenter-b-design.md
             
             Acceptance Criteria:
             - Co-hosts Cluster B Masters 2-3 (completing HA quorum)
             - Co-hosts Cluster B worker nodes
             - Physical location: Secondary facility (DR)
             - Network latency to Datacenter A: < 5ms
             - Automatic failover for stateless services
             - Physical racks: B1 (and expandable)
             
             Associated SysML Models:
             - sysml/datacenter/DeploymentArchitecture.sysml (FabricationDatacenterB)
             
             Deployment Implementation:
             - fabrications/fabrication-datacenter-b/models/ (SysML design)
             - fabrications/fabrication-datacenter-b/specs/ (datacenter.json)
             - fabrications/fabrication-datacenter-b/views/ (rack views)
             
             Project Structure:
             - fabrications/fabrication-datacenter-b/
               ├── models/ (SysML definitions)
               ├── specs/ (JSON specifications)
               ├── views/ (visual representations)
               ├── projects/ (project management integration)
               └── requirements/ (FAB_REQ_* definitions)
         */
        
        attribute clustersHosted : String[] = {"Cluster B (Masters 2-3, Workers)"};
        attribute physicalRacks : Integer = 1;
        attribute isPrimary : Boolean = false;
        attribute isDR : Boolean = true;
    }

    /**
     * FAB_REQ_003: Physical Rack Design
     * Racks must follow standard equipment placement and cooling design
     */
    class PhysicalRackDesignRequirement :> FabricationRequirement {
        doc /* Physical racks organize compute, network, storage hardware
                 
             Parent System Requirement: SYSTEM_REQ_001 (Cluster Architecture)
             Jira: FAB-003
             External: input/fabrication-requirements/rack-design.md
             Reference: templates/TERRAFORM_STRUCTURE.md (physical layout)
             
             Acceptance Criteria:
             - Standard 42U racks (or equivalent)
             - Equipment: Compute nodes (2U or 1U), Network switches, Storage
             - Cable management compliance with standards
             - Thermal zoning and hot-aisle/cold-aisle containment
             - UPS provisioning for 15-minute failover window
             - Documented rack layouts (floorplan.sysml)
             
             SysML Models (Racks):
             - fabrications/fabrication-datacenter-a/models/rackA1.sysml
             - fabrications/fabrication-datacenter-a/models/rackA2.sysml
             - fabrications/fabrication-datacenter-b/models/rackB1.sysml
             
             SysML Views:
             - fabrications/fabrication-datacenter-a/views/rackA1-view.sysml
             - fabrications/fabrication-datacenter-b/views/rackB1-view.sysml
         */
        
        attribute standardRackSize : String = "42U";
        attribute hotAisleColdAisleSupported : Boolean = true;
        attribute upsProvisionedMinutes : Integer = 15;
    }

    /**
     * FAB_REQ_004: Network Connectivity
     * Datacenters must be interconnected with low-latency network
     */
    class NetworkConnectivityRequirement :> FabricationRequirement {
        doc /* Network interconnects datacenters for cluster communication
                 
             Parent System Requirement: SYSTEM_REQ_002 (Multi-Datacenter)
             Jira: FAB-004
             External: input/fabrication-requirements/network-connectivity.md
             Vendor Doc: vendor-docs/networking/
             
             Acceptance Criteria:
             - Direct fiber link between datacenters
             - Bandwidth: 10Gbps minimum (redundant paths preferred)
             - Network latency: < 5ms
             - Layer 3 connectivity (IP routing)
             - VPN overlay for security (optional)
             - Dedicated link for cluster traffic
             
             Network Design (SysML):
             - sysml/overall-design/SysMLCloudPlatformInterfaces.sysml (network interfaces)
         */
        
        attribute minBandwidthGbps : Integer = 10;
        attribute maxLatencyMs : Integer = 5;
        attribute redundantPathsRequired : Boolean = true;
    }

    /**
     * FAB_REQ_005: Power and Cooling Infrastructure
     * Datacenters must provide reliable power and thermal management
     */
    class PowerCoolingRequirement :> FabricationRequirement {
        doc /* Power and cooling enable continuous operation
                 
             Parent System Requirement: SYSTEM_REQ_002 (Multi-Datacenter)
             Jira: FAB-005
             External: input/fabrication-requirements/power-cooling.md
             Reference: sysml/datacenter/PowerCoolingInterfaces.sysml
             
             Acceptance Criteria:
             - Redundant power feeds (N+1 minimum)
             - UPS for critical components (15-min failover window)
             - Generator backup for extended outages
             - CRAC/CRAH systems for climate control
             - Temperature monitoring and alerts
             - Hot-aisle containment for efficiency
             
             SysML Specification:
             - sysml/datacenter/PowerCoolingInterfaces.sysml (power/cooling model)
         */
        
        attribute redundancyLevel : String = "N+1";
        attribute upsFailoverMinutes : Integer = 15;
        attribute generatorBackupAvailable : Boolean = true;
        attribute temperatureMonitored : Boolean = true;
    }

    /**
     * FAB_REQ_006: Security and Physical Access Control
     * Datacenters must enforce physical security and access controls
     */
    class PhysicalSecurityRequirement :> FabricationRequirement {
        doc /* Physical security protects infrastructure assets
                 
             Parent System Requirement: SYSTEM_REQ_001 (Cluster Architecture)
             Jira: FAB-006
             External: input/fabrication-requirements/physical-security.md
             
             Acceptance Criteria:
             - Cage/enclosure for all equipment
             - Badge access control with audit logs
             - CCTV monitoring in all areas
             - Intrusion detection
             - Access restricted to authorized personnel
             - Visitor access logged and supervised
             - Disaster recovery procedures documented
         */
        
        attribute badgeAccessRequired : Boolean = true;
        attribute cctvMonitored : Boolean = true;
        attribute accessAuditingEnabled : Boolean = true;
        attribute visitorLogRequired : Boolean = true;
    }

    /**
     * FAB_REQ_007: Environmental Monitoring
     * Datacenters must continuously monitor environmental conditions
     */
    class EnvironmentalMonitoringRequirement :> FabricationRequirement {
        doc /* Environmental monitoring detects and alerts on anomalies
                 
             Parent System Requirement: SYSTEM_REQ_007 (Documentation Generation)
             Jira: FAB-007
             External: input/fabrication-requirements/environmental-monitoring.md
             Vendor Doc: vendor-docs/monitoring/
             
             Acceptance Criteria:
             - Temperature sensors on all racks
             - Humidity sensors in critical areas
             - Water ingress detection (leak detection)
             - Air quality sensors
             - Real-time alerting on threshold violations
             - Historical data retention (1+ years)
             - Integration with infrastructure monitoring stack
         */
        
        attribute temperatureSensored : Boolean = true;
        attribute humiditySensored : Boolean = true;
        attribute leakDetectionEnabled : Boolean = true;
        attribute realTimeAlerting : Boolean = true;
    }

    /**
     * FAB_REQ_008: Floorplan and Layout Design
     * Datacenters must have documented floorplans and equipment layout
     */
    class FloplanLayoutRequirement :> FabricationRequirement {
        doc /* Floorplan documents physical layout and planning
                 
             Parent System Requirement: SYSTEM_REQ_001 (Cluster Architecture)
             Jira: FAB-008
             External: input/fabrication-requirements/floorplan.md
             
             Acceptance Criteria:
             - Floorplan diagram with equipment placement
             - Identification of hot/cold aisles
             - Cable routing documented
             - Emergency exit paths marked
             - Capacity planning information
             - Versioning and change history
             
             SysML Floorplan Models:
             - fabrications/fabrication-datacenter-a/models/floorplan.sysml
             - fabrications/fabrication-datacenter-b/models/floorplan.sysml
             
             Generated Views:
             - fabrications/fabrication-datacenter-a/views/floorplan-view.md
             - fabrications/fabrication-datacenter-b/views/floorplan-view.md
         */
        
        attribute equipmentLocationsDocumented : Boolean = true;
        attribute hotColdAisleMarked : Boolean = true;
        attribute capacityPlanningIncluded : Boolean = true;
        attribute changeHistoryMaintained : Boolean = true;
    }

    /**
     * FAB_REQ_009: Room Infrastructure and Facilities
     * Datacenters must have appropriate supporting facilities
     */
    class RoomInfrastructureRequirement :> FabricationRequirement {
        doc /* Room infrastructure includes non-IT systems
                 
             Parent System Requirement: SYSTEM_REQ_001 (Cluster Architecture)
             Jira: FAB-009
             External: input/fabrication-requirements/room-infrastructure.md
             Reference: sysml/datacenter/RoomModel.sysml
             
             Acceptance Criteria:
             - Sufficient floor loading (compute density)
             - Overhead cable trays and plenums
             - Raised floors (preferred) or cable management
             - Humidity and temperature control
             - Fire suppression system
             - Electrical infrastructure (outlets, PDUs)
             
             SysML Room Model:
             - sysml/datacenter/RoomModel.sysml
         */
        
        attribute floorLoadingSupported : Boolean = true;
        attribute raisedFloorsInstalled : Boolean = false; /* Can be true/false */
        attribute fireSuppressionEnabled : Boolean = true;
    }

    /**
     * FAB_REQ_010: Virtualization and Hypervisor Support
     * Infrastructure must support containerization and virtualization
     */
    class VirtualizationRequirement :> FabricationRequirement {
        doc /* Virtualization enables resource isolation and efficiency
                 
             Parent System Requirement: SYSTEM_REQ_001 (Cluster Architecture)
             Jira: FAB-010
             External: input/fabrication-requirements/virtualization.md
             Reference: sysml/datacenter/VirtualizationModel.sysml
             Vendor Doc: vendor-docs/virtualization/
             
             Acceptance Criteria:
             - Hardware virtualization enabled (VT-x or AMD-V)
             - Kubernetes running on bare metal or VMs
             - Container runtime: containerd
             - Nested virtualization support (if needed for labs)
             
             SysML Virtualization Model:
             - sysml/datacenter/VirtualizationModel.sysml
         */
        
        attribute hardwareVirtualizationSupported : Boolean = true;
        attribute containerRuntimeSupported : Boolean = true;
        attribute nestedVirtualizationSupported : Boolean = false; /* Optional */
    }

    /**
     * Container: All fabrication requirements
     */
    part fabricationRequirements : FabricationRequirement[*] {
        part dcA : DatacenterAPrimaryRequirement;
        part dcB : DatacenterBSecondaryRequirement;
        part racks : PhysicalRackDesignRequirement;
        part network : NetworkConnectivityRequirement;
        part powerCooling : PowerCoolingRequirement;
        part security : PhysicalSecurityRequirement;
        part monitoring : EnvironmentalMonitoringRequirement;
        part floorplan : FloplanLayoutRequirement;
        part room : RoomInfrastructureRequirement;
        part virt : VirtualizationRequirement;
    }
}
