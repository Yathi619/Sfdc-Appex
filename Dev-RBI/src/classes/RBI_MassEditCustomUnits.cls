/*
    Type:       Custom Controller
    Purpose:    Used to Approve the Projects created by the Customer from Customer Portal.

    Used By:   RBI_MassEditCustomUnits.page
    ----------------------------------------------------------------------------------
    History:

    01-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_MassEditCustomUnits {
	// Variable Declaration
	public list<Unit__c> WrapperUnitList {get; set;}

 	transient String  QryString;
 	public Unit__c 	  uni12;
	public string     TowId = '';

	public boolean    ErrorFlag {get; set;}
	public boolean    flag {get; set;}

	public list<Unit__c> Showunit{set;get;}
	public integer sizee{get;set;}
	public string TowName{get;set;}

	//Pagination
	public RBI_PageManager objPageManager {get;set;}
	public Integer pageSize;
	public List<Unit__c> Wrapper1untlist{get;set;}
	public List<Unit__c> unitList = new List<Unit__c>();
	public List<Unit__c> unitDetails;

	/* Constructor */
    public RBI_MassEditCustomUnits(){
        WrapperUnitList = new list<Unit__c>();
        Wrapper1untlist = new List<Unit__c>();
       	ErrorFlag       = false;
        unitList 		= new list<Unit__c>();
        TowId			= System.currentPagereference().getParameters().get('TowerId');
        TowName			= System.currentPagereference().getParameters().get('TowerName');
      	//paging variables
		pageSize = 16;
        objPageManager = new RBI_PageManager(pageSize);
        objPageManager.page = 0;
        objPageManager.numberOfRows =0;

}

    /* Action funtion called on initial load */
	public PageReference InitialLoad(){
		unitList 		= new list<Unit__c>();
		unitList = [Select Name,Unit_Type__c, Unit_Type_Id__c, Super_Area_Sq_Ft__c, Id, Floor__c,Floor_Number__c, Carpet_Area_Sq_Ft__c, 
					Built_up_area_Sq_Ft__c,Tower_Id__r.Name From Unit__c where Tower_Id__c=:TowId order by Floor_Number__c ];
        WrapperUnitList = new list<Unit__c>();
        Showunit = new list<Unit__c>();
  		WrapperUnitList.addAll(unitList);
		Showunit.addAll(unitList);
		if(WrapperUnitList!= null){
			sizee=WrapperUnitList.size();
			objPageManager.numberOfRows = WrapperUnitList.size();
		}


		return null;
	}
    /* Action funtion called on Save button */
	public PageReference saveunits(){
		if(unitList!=null && unitList.size()>0){
			update unitList;
        	PageReference Pg = Page.RBI_MassEditCustomUnits;
    		pg.getParameters().put('TowerId',TowId);
    		Pg.setRedirect(true);
    		return Pg;			
		}

		return null;
	}
    /* Action funtion called on cancel button */
	public PageReference cancelunits(){
	 		PageReference pageRef = new PageReference('/'+TowId);
	 		return pageRef;		
	}			
    // Getter-setter for unitDetails used for pagination
  	public List<Unit__c> getunitDetails(){
  	if((WrapperUnitList !=null) && (WrapperUnitList.size() >0)){
      	 if(Wrapper1untlist !=null)
       		Wrapper1untlist.clear();
        	for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<WrapperUnitList.size();i++){
            	Wrapper1untlist.add(WrapperUnitList.get(i));

         }

      }
       return Wrapper1untlist;
    }

	public void  setunitDetails (List<Unit__c> unitDetails) {
		this.unitDetails = unitDetails;
	}

}