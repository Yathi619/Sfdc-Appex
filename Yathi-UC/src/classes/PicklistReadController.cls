public with sharing class PicklistReadController {

public boolean read{get;set;}
public boolean read1{get;set;}

public Position__c pick;

public PicklistReadController( Apexpages.Standardcontroller std)
{
	read=false;
	read1=false;
	pick=new Position__c();
	pick=(Position__c)std.getRecord();
}
public void showtextbox()
	{
 		if(pick.Resident__c == 'Yes')
 			read = true;
 	    else
 	        read = false;
 	}
 	public void showtextbox1()
	{
 		if(pick.vegetarian__c == 'Yes')
 			read1 = true;
 	    else
 	        read1 = false;
 	}

}