/*
    Type:       Custom Controller
    Purpose:    Used to create multiple units for a Tower in the Employee application.        

    Used By:   RBI_CreateUnits.page
    ---------------------------------------------------------------
    History:

    08-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_CreateUnits {
	
   	public String Floor   {get; set;}             // Used to input searchfields
   	public Id selectedUnitType {get;set;}
   	public integer unitCount       {get; set;} 
   	public List<SelectOption> uTypeOptions {get; set;}
   	public list<Unit__c> UnitList;
   	public list<Unit_Type__c> UnitTypes {get;set;}
   	public Tower__c TowerRec   {get;set;}
   	public Unit__c objunit {get;set;}
   	public string ProjectId;
   	public string TowerName {get;set;}
   	public string towerId;
   	public decimal SuperArea {get;set;}
   	Map<ID,Unit_Type__c> UnitTypeMap;
   	integer towerunitcount; // used to populate unique name on unit
   	   	
   	public RBI_CreateUnits(){
       ProjectId = System.currentPagereference().getParameters().get('ProjId');
       	TowerName = System.currentPagereference().getParameters().get('TowName');
       	towerId = System.currentPagereference().getParameters().get('TowId');
       	towerunitcount = 0;
       	towerunitcount = (System.currentPagereference().getParameters().get('unittotal')!=null)?Integer.valueOf(System.currentPagereference().getParameters().get('unittotal')):0;
       	uTypeOptions = new List<SelectOption>() ;
        list<Unit__c>   UnitList = new list<Unit__c>();
        objunit = new Unit__c();
        unitCount = 0;
      	getunitTypeOptions();
      	
	}
     
    public void getUnitTypeOptions(){
    	UnitTypeMap = new Map<ID, Unit_Type__c>([select name, Unit_Type__c, Project__c, Super_Area_Sq_Ft__c from Unit_Type__c where Project__c = : ProjectId]);
    	if(UnitTypeMap!=null)
    		UnitTypes = UnitTypeMap.values(); 
		//UnitTypes = [select name, Unit_Type__c, Project__c, Super_Area_Sq_Ft__c from Unit_Type__c where Project__c = : ProjectId];
		if (UnitTypes != null && UnitTypes.Size() >0){
			for(Unit_Type__c unitType:UnitTypes){
		     	uTypeOptions.add(new SelectOption(unitType.Id,unitType.Unit_Type__c +' - '+unitType.Super_Area_Sq_Ft__c + ' sqft'));
	   		}
	   		SuperArea = UnitTypes[0].Super_Area_Sq_Ft__c;
		}
		
	}
	
	public pageReference doCreate(){
		list<Unit__c>   UnitList = new list<Unit__c>();
		Integer i=0;
		string unitname = '';
		for (i=0; i<unitCount; i++){
			towerunitcount = towerunitcount+1;
			unitname = 'To be changed-'+ string.valueOf(towerunitcount);
			UnitList.add(new Unit__c(Name = unitname, Tower_Id__c = towerId, Floor__c = objunit.Floor__c, Unit_Type_Id__c = selectedUnitType));
			system.debug('AAAAA'+UnitList[i].Id);
			
		}
		if (UnitList != null){
			try{
				insert UnitList;
			}catch(DMLException e){
				ApexPages.addMessages(e);
				return null;
			}
			PageReference Pg = new PageReference('/' + towerId);
			return Pg;
		}
		return null;
	}
	
	public pageReference doCreateandNew(){
		list<Unit__c>   UnitList = new list<Unit__c>();
		string unitname = '';
		Integer i=0;
		for (i=0; i<unitCount; i++){
			towerunitcount = towerunitcount+1;
			unitname = 'To be changed-'+ string.valueOf(towerunitcount);
			//unitname = 'To be changed-' + towerunitcount;			
			UnitList.add(new Unit__c(Name = unitname, Tower_Id__c = towerId, Floor__c = objunit.Floor__c, Unit_Type_Id__c = selectedUnitType));
			
		}
		if (UnitList != null){
			try{
				insert UnitList;
			}catch(DMLException e){
				ApexPages.addMessages(e);
				return null;
			}	
			objunit = new Unit__c();
			string strcount = (towerunitcount!=null)?String.valueOf(towerunitcount):'';
			PageReference Pg = ApexPages.currentPage();
			pg.getParameters().put('ProjId',ProjectId);
			pg.getParameters().put('TowName',TowerName);
			pg.getParameters().put('TowId',towerId);
			pg.getParameters().put('unittotal',strcount);
			Pg.setRedirect(true);
			return Pg;
		}
		return null;
	}
	
	public PageReference doCancel(){
		PageReference Pg = new PageReference('/' + towerId);
		return Pg;
    }
	//Used for action function call to populate super area on change of unit type
    public void populateSuperArea(){
    	system.debug('selectedUnitTypeXX'+selectedUnitType+'  '+UnitTypeMap);
 		if(selectedUnitType != null){
    		Unit_Type__c ut = UnitTypeMap.get(selectedUnitType);
    		if(ut!=null){
    			SuperArea = ut.Super_Area_Sq_Ft__c;
    		}
		}
		//return null;
    }    
}