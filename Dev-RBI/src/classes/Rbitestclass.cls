public with sharing class Rbitestclass {
	
	
	
	public String agentId{get;set;}
	public Id[] selectedTowers = new Id[]{};
	//public Id selectedTowers{get;set;}
	public Id selectedUnit{get;set;}
	//list<Tower__c> towerList	
	Id projectId = null;
	public boolean EnabledBuilding{get; set;}
	public List<SelectOption> fieldLableAPI {get; set;}
	
	public Rbitestclass(){ 
        projectId = ApexPages.currentPage().getParameters().get('projectId');
        projectName = '';
        gettowerRecords();
        fieldLableAPI = new List<SelectOption>() ;
        system.debug('Construtor');
	}
	
	public string projectName {get; set;}
	
	public List<SelectOption> gettowerRecords(){
 		List<SelectOption> options = new List<SelectOption>();
		list<Tower__c> towerRecords = [select Project_Name__c, Project__c, name from Tower__c where Project__c = : projectId];
		projectName = towerRecords[0].Project_Name__c;
		system.debug('towerRecords[0].Project_Name__c '+towerRecords[0].Project_Name__c+' projectName '+projectName);
		if (towerRecords.Size() >0){
			for(Tower__c tower:towerRecords){ 
		     	options.add(new SelectOption(tower.Id,tower.name));
	   		}
	   }
	   setEnabledBuilding(true);
	   system.debug('gettowerRecords');
	   return options;
	}
	
	public List<SelectOption> getPopUnitPicklst(){
		List<SelectOption> options = new List<SelectOption>();
		system.debug('selectedTowers '+selectedTowers);
		list<Unit__c> PopUnitPicklst = [select name from Unit__c where Tower_Id__c = : selectedTowers]; 
		if (PopUnitPicklst.Size() >0){
			for(Unit__c unit:PopUnitPicklst){
		     	options.add(new SelectOption(unit.Id,unit.name));
	   		}
	   }
	   system.debug('getPopUnitPicklst');
	   setEnabledBuilding(false);
	   return options;
		
	}
	public void setSelectedTowers(Id[] selectedUnit) {
		system.debug('setSelectedTowers');
    	this.selectedTowers = selectedTowers;
	} 
	
	public Id[] getSelectedTowers() {
		system.debug('getSelectedTowers');
    	return selectedTowers;
    	
	}
	public Void setEnabledBuilding(Boolean b) {
    	this.EnabledBuilding=b;
    	system.debug('setEnabledBuilding');
    }
    
    public PageReference populatePicklistValue(){
    	system.debug('populatePicklistValueselectedTowers '+selectedTowers);
    	getPopUnitPicklst();
    	system.debug('____________'+agentId);
    	//selectedTowers.id=selectedUnit.id;
    	return null;
    }
    
	public PageReference generatePDF(){
		system.debug('generatePDF');
		system.debug('generatePDFselectedTowers '+selectedTowers);
		return null;  
	}
}