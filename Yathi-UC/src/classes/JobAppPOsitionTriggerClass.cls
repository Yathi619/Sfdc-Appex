public with sharing class JobAppPOsitionTriggerClass {

	Position__c pos;
	list <Position__c>  posupdlist = new list <Position__c>(); 
	
	public void onAfterinsert(list <Job_Application__c> joblst)
	{
		for(Job_Application__c jb : joblst)
		{
			if(jb.do_u_want_to_change_Position_Field__c==true)
			{
				pos=new Position__c(id=jb.Position__c);
				pos.Pending_reminder__c=true;
				posupdlist.add(pos);
			}
		}
		if(posupdlist!=null && posupdlist.size() > 0)
		{
			update posupdlist;
		}	
	}
}