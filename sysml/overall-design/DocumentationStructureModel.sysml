// DocumentationStructureModel.sysml
// V-Model documentation structure: shows how editable docs and SysML models generate publications
package DocumentationStructure {
  
  // Markdown file artifact
  part def MarkdownFile {
    attribute filename : String;
    port out publishPort;
  }
  
  // PDF publication artifact
  part def PDFPublication {
    attribute filename : String;
    port in publishPort;
  }
  
  // Editable context document
  part def EditableContextDoc;
  
  // Action that generates a phase's publications
  action def GeneratePhasePublications {
    doc /* Executes build-docs.py and generate-pdfs.py */
  }
  
  // ========== PHASE 01: Project Management ==========
  action def Phase01_ProjectManagement_Generation : GeneratePhasePublications {
    doc /* Generates 01_PMP_SEMP.pdf from SEMP.md */
  }
  
  part def Phase01_ProjectManagement {
    part sempContextDoc : EditableContextDoc;
    
    part sempMD : MarkdownFile {
      attribute filename = "publication/SEMP.md";
    }
    
    part sempPDF : PDFPublication {
      attribute filename = "publication/01_PMP_SEMP.pdf";
    }
    
    connect sempMD.publishPort to sempPDF.publishPort;
  }
  
  // ========== PHASE 02: Stakeholder Needs Analysis ==========
  action def Phase02_StakeholderNeeds_Generation : GeneratePhasePublications {
    doc /* Generates 02_SNR_StakeholderNeeds.pdf from stakeholder analysis markdown files */
  }
  
  part def Phase02_StakeholderNeeds {
    part stakeholderContextDoc : EditableContextDoc;
    
    part stakeholderNeedsAnalysisMD : MarkdownFile {
      attribute filename = "publication/stakeholder-needs-analysis.md";
    }
    
    part businessConcernsMD : MarkdownFile {
      attribute filename = "publication/business-concerns.md";
    }
    
    part productStrategyMD : MarkdownFile {
      attribute filename = "publication/product-strategy.md";
    }
    
    part snrPDF : PDFPublication {
      attribute filename = "publication/02_SNR_StakeholderNeeds.pdf";
    }
    
    connect stakeholderNeedsAnalysisMD.publishPort to snrPDF.publishPort;
    connect businessConcernsMD.publishPort to snrPDF.publishPort;
    connect productStrategyMD.publishPort to snrPDF.publishPort;
  }
  
  // ========== PHASE 03: System Requirements Definition ==========
  action def Phase03_SystemRequirementsDefinition_Generation : GeneratePhasePublications {
    doc /* Generates 03_SRD_SysMLCloudPlatform.pdf from system requirements markdown files */
  }
  
  part def Phase03_SystemRequirementsDefinition {
    part sysmlArchGuideContext : EditableContextDoc;
    
    part systemRequirementsMD : MarkdownFile {
      attribute filename = "publication/system-requirements-definition.md";
    }
    
    part platformRequirementsMD : MarkdownFile {
      attribute filename = "publication/sys-mlcloud-platform-requirements.md";
    }
    
    part srdPDF : PDFPublication {
      attribute filename = "publication/03_SRD_SysMLCloudPlatform.pdf";
    }
    
    connect systemRequirementsMD.publishPort to srdPDF.publishPort;
    connect platformRequirementsMD.publishPort to srdPDF.publishPort;
  }
  
  // ========== PHASE 04: System Architecture & Design ==========
  action def Phase04_SystemArchitectureDesign_Generation : GeneratePhasePublications {
    doc /* Generates 04_SAD_SysMLCloudPlatform.pdf from architecture markdown files */
  }
  
  part def Phase04_SystemArchitectureDesign {
    part sysmlArchGuideContext : EditableContextDoc;
    
    part platformModelMD : MarkdownFile {
      attribute filename = "publication/sys-mlcloud-platform-model.md";
    }
    
    part platformInterfacesMD : MarkdownFile {
      attribute filename = "publication/sys-mlcloud-platform-interfaces.md";
    }
    
    part sadPDF : PDFPublication {
      attribute filename = "publication/04_SAD_SysMLCloudPlatform.pdf";
    }
    
    connect platformModelMD.publishPort to sadPDF.publishPort;
    connect platformInterfacesMD.publishPort to sadPDF.publishPort;
  }
  
  // ========== PHASE 06: Subsystem Detailed Design ==========
  action def Phase06_SubsystemDetailedDesign_Generation : GeneratePhasePublications {
    doc /* Generates 06_SDD_*.pdf from detailed design markdown files */
  }
  
  part def Phase06_SubsystemDetailedDesign {
    part rackModelMD : MarkdownFile {
      attribute filename = "publication/rack-model.md";
    }
    
    part networkModelMD : MarkdownFile {
      attribute filename = "publication/network-model.md";
    }
    
    part virtualizationMD : MarkdownFile {
      attribute filename = "publication/virtualization-model.md";
    }
    
    part deploymentArchMD : MarkdownFile {
      attribute filename = "publication/deployment-architecture.md";
    }
    
    part sddPDF : PDFPublication {
      attribute filename = "publication/06_SDD_FabricationDatacenterA.pdf";
    }
    
    connect rackModelMD.publishPort to sddPDF.publishPort;
    connect networkModelMD.publishPort to sddPDF.publishPort;
    connect virtualizationMD.publishPort to sddPDF.publishPort;
    connect deploymentArchMD.publishPort to sddPDF.publishPort;
  }
  
  // ========== PHASE 11: Deployment & Operations ==========
  action def Phase11_DeploymentOperations_Generation : GeneratePhasePublications {
    doc /* Generates 11_DPL_DeploymentAndOM.pdf from deployment markdown files */
  }
  
  part def Phase11_DeploymentOperations {
    part testingStrategyContextDoc : EditableContextDoc;
    
    part testingDeploymentPlanMD : MarkdownFile {
      attribute filename = "publication/testing-and-deployment-planning.md";
    }
    
    part deploymentArchitectureGuideMD : MarkdownFile {
      attribute filename = "publication/deployment-architecture.md";
    }
    
    part dplPDF : PDFPublication {
      attribute filename = "publication/11_DPL_DeploymentAndOM.pdf";
    }
    
    connect testingDeploymentPlanMD.publishPort to dplPDF.publishPort;
    connect deploymentArchitectureGuideMD.publishPort to dplPDF.publishPort;
  }
  
  // ========== Navigation & Entry Points ==========
  part def NavigationDocuments {
    part readmeDoc : EditableContextDoc;
    part docsGuideDoc : EditableContextDoc;
    part quickReferenceDoc : EditableContextDoc;
    part vModelGuideDoc : EditableContextDoc;
    part contributingDoc : EditableContextDoc;
  }
  
  // ========== Complete Documentation System ==========
  part documentationSystem {
    part navigation : NavigationDocuments;
    
    part phase01 : Phase01_ProjectManagement;
    action phase01Generation : Phase01_ProjectManagement_Generation;
    
    part phase02 : Phase02_StakeholderNeeds;
    action phase02Generation : Phase02_StakeholderNeeds_Generation;
    
    part phase03 : Phase03_SystemRequirementsDefinition;
    action phase03Generation : Phase03_SystemRequirementsDefinition_Generation;
    
    part phase04 : Phase04_SystemArchitectureDesign;
    action phase04Generation : Phase04_SystemArchitectureDesign_Generation;
    
    part phase06 : Phase06_SubsystemDetailedDesign;
    action phase06Generation : Phase06_SubsystemDetailedDesign_Generation;
    
    part phase11 : Phase11_DeploymentOperations;
    action phase11Generation : Phase11_DeploymentOperations_Generation;
  }
}


