public with sharing class RBI_DeveloperProfile {

	public list<List_of_Values__c> allprojlist{get;set;}
	public list<List_of_Values__c> lvongoinglist{get;set;}
	public list<List_of_Values__c> lvcomplete{get;set;}
	public Account acc {get; set;}
	string accId;
	public ApexPages.StandardController sController;
		
	public RBI_DeveloperProfile(ApexPages.StandardController stdCon)
	{
		sController = stdCon;
		this.acc=(Account)stdCon.getRecord();
		accid=acc.Id;
		showlovproject();
		
	}
	
	public void showlovproject() {
		
		allprojlist = new list<List_of_Values__c>();
		allprojlist = [Select Total_BUA__c, Project_Type__c, Dev_Project_Address__c, Loan_Amount__c, Land_Area_in_Acres__c, Id,Project_Id_Const_Loan__c, Dwelling_Units__c, Dev_Project_Name__c, Completion_Year__c, Bank_Name__c From List_of_Values__c  where Developer__c=:accid];
		system.debug('Project List '+allprojlist + accid);
		if (allprojlist.size() != null) {
			lvongoinglist= new list<List_of_Values__c>();
		 	lvcomplete = new list<List_of_Values__c>();
		 
	    	for(List_of_Values__c lv :allprojlist){
	    		if(lv.Project_Type__c == 'Ongoing') { 
	    			lvongoinglist.add(lv);
	    		
	    		}
	    		else if(lv.Project_Type__c == 'Completed') {
	    			lvcomplete.add(lv);
	    		 
	    		}	
	    	
	   	   	}
		}
		
	}
		
}