public with sharing class AddJobApp {

public list<Candidate__c> canlist{get;set;}
public list<wraperclass> wraplist{get;set;}
public list<candidate__c> newcanlist{get;set;} 
public string pid;
	
	 public AddJobApp()
	 {
	//  		pid=system.currentPageReference().getParameters().get('posid');
		canlist = new list<Candidate__c>();
		wraplist  =new list<wraperclass>();
	//		newcanlist=new list<Candidate__c>();
	 }
	  public void ProcessSelected()
	  {	
	  	canlist=[select id,name,Full_Name__c,City__c,Country__c,Current_Employer__c,Education__c,Email__c from Candidate__c];
		for(Candidate__c cwr : canlist)
		{
			wraplist.add(new wraperclass(cwr));
		}
		
	//	for(Candidate__c nc:wraplist)
	//	{
		//if(nc.selected){
		//	newcanlist.add(nc.can);
	//	}
	//	}
	  }
	
 
 	  public class wraperclass
 	  {
 	  	public boolean selected{get;set;}
 	  	public Candidate__c can{get;set;}
 	  	
 	  	public wraperclass(Candidate__c c)
 	  	{
 	  		selected=false;
 	  		can=c;
 	  	}
 	  	
 	  }
 
 
 
 
}