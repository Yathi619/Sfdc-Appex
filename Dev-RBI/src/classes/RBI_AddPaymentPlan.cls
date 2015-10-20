/*
    Type:       Custom Controller
    Purpose:    Used to add Payment Plan for a Project in Employee Portal.         

    Used By:   RBI_AddPaymentPlan.page
    ---------------------------------------------------------------
    History:

    03-May-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_AddPaymentPlan {
	public list<servicewrapper> WrapperListofval {get; set;} 
    public Payment_Plan__c recPayPlan;
    public List_of_Values__c reclistofval;
    public list<Payment_Plan__c> PayPlanlist;
    public string ProjectId;
    public string ProjectName {get;set;}
    
    public RBI_AddPaymentPlan(){
    	ProjectId = System.currentPagereference().getParameters().get('ProjId');
    	ProjectName = System.currentPagereference().getParameters().get('ProjName');
    	WrapperListofval = new list<servicewrapper>();
    	
    }
    
    public list<servicewrapper> getListofValues(){
    	WrapperListofval = new list<servicewrapper>();
        	for(List_of_Values__c reclistofval:[Select Id, Name, Entity_Name__c, Entity_Type__c, Key__c, Value__c From List_of_Values__c where Entity_Name__c = 'Payment Plan']){
            	WrapperListofval.add(new servicewrapper(reclistofval));
      
            }
      
        return WrapperListofval;
    }
    
    public PageReference dosave(){
       
        PayPlanlist = new list<Payment_Plan__c>();	  
        for(servicewrapper servwrapper: WrapperListofval) {
            if(servwrapper.selected == true) {
            
				PayPlanlist.add(new Payment_Plan__c(Project__c=ProjectId, Plan_Type__c=servwrapper.listofval.Id));                      
            }
        }
        try{
	       	if (PayPlanlist !=null){
	        	Database.Insert(PayPlanlist);
	        	PageReference Pg = new PageReference('/' + ProjectId);
	    		return Pg;
	        }
        }catch(DMLException ex){
        	ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Payment Plan already exists!');
        	ApexPages.addMessage(errorMessage);
        	return null;
        }      
        return null;
    }
    
    public PageReference doCancel(){
		PageReference Pg = new PageReference('/' + ProjectId);
		return Pg;
    }
    
    public class servicewrapper{
        public List_of_Values__c listofval {get; set;} 
        public Boolean selected {get; set;}
        
        public servicewrapper(List_of_Values__c lov){
            listofval = lov;
            selected= false;
        }
    }
}