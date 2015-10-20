/*
    Type:       Custom Controller
    Purpose:    Used to calculate the number of Unit Types for each tower in Employee Application.     

    Used By:   RBI_TowerUnitTypeCount.page
    ----------------------------------------------------------------------------------
    History:

    01-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_TowerUnittypeCount {
	
	public list<aggregateResult> UnitList{get; set;}
	public list<floorStrucWrap> floorWrapForPDF {get;set;}
	public string towerId ='';
    
    //Constructor
    public RBI_TowerUnittypeCount(ApexPages.standardController std){
        towerId=Apexpages.currentPage().getParameters().get('id');
        UnitList = new list<aggregateResult>();
        floorWrapForPDF = new list<floorStrucWrap>();
        unitlist = [Select Unit_Type_Id__r.Unit_Type__c unittyp, Tower_Id__r.Name towername, COUNT(Name) cou, MAX(Unit_Type_Id__r.Carpet_Area_Sq_Ft__c) CarpetArea,
							MAX(Unit_Type_Id__r.Built_up_area_Sq_Ft__c) builtuparea From Unit__c 
							WHERE  Tower_Id__c =: towerid
							GROUP BY Tower_Id__r.Name, Unit_Type_Id__r.Unit_Type__c];
			
		if (unitlist.size() != null){
			for(aggregateResult aggRes : unitlist){
				String towname = '';
				String unitType = '';
				Integer noOfUnit;
				Double cpparam;
				Double builtparam;
				
				towname  = (String) aggRes.get('towername');
				unitType = (String) aggRes.get('unittyp');
				noOfUnit = (Integer) aggRes.get('cou');
				cpparam = (Double) aggRes.get('CarpetArea');
				builtparam = (Double) aggRes.get('builtuparea');	
				
				floorWrapForPDF.add(new floorStrucWrap(towname, unitType, noOfUnit, cpparam, builtparam));
					
       		}
		}
    }
	
	public class floorStrucWrap{
    	public String towname        {get;set;}
    	public String unitType     {get;set;} 
    	public Integer noOfUnits   {get;set;}
    	public Double carpetarea  {get;set;}
    	public Double builtuparea {get;set;}    	    	
    	public floorStrucWrap(String tname, String unitTyp, Integer noOfUni, Double cparea,Double btarea){
    		towname = tname;
    		unitType = unitTyp;
    		noOfUnits = noOfUni;
    		carpetarea = cparea;
    		builtuparea = btarea;
    	}
    }
}