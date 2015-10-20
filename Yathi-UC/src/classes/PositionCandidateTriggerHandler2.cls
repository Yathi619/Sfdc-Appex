public with sharing class PositionCandidateTriggerHandler2 {

	public void onAfterUpdate(list <Position__c> poslst)
	{
		Candidate__c candobj=new Candidate__c();
		list <Candidate__c> canlst=new list<Candidate__c>();
		list <Candidate__c> canlst2=new list<Candidate__c>();
		
		list <Job_Application__c> Joblst=new list<Job_Application__c>();
		
		set <string> PosIds=new set <string>();
		set <string> PosIds2=new set<string>();
		
		set <string> CanIds=new set<string>();
		set <string> CanIds2=new set<string>();
		
		for(Position__c p:poslst)
		{
			if(!p.Location__c.contains('India')){
				PosIds.add(p.id);
			}
			else
			{
				PosIds2.add(p.id);
			}
		}
		
		//System.Debug('Position_IDs'+ PosIds);
		Joblst=[select id, Position__c,Candidate__c from Job_Application__c where Position__c =:PosIds];
		//job list contains all Job Applications and all the applied candidates  ids  for a single position 
		System.Debug('Job Lists'+ Joblst);
		
		for(Job_Application__c j : Joblst)
		{
			CanIds.add(j.Candidate__c);
			//candobj=new Candidate__c(id=j.Candidate__c, Visa_Required__c=true);
			//canlst.add(candobj);
			 //Go To Position 'Developer' for all the job application of Developer, 
			 //candidate applied for that position when the location changes in developer
		    //trigger has to be fired
			//id=j.Candidate__c getting candidate__c id from Job Application
			
		}
		System.Debug('Candidate Id' + CanIds);
		canlst=[select id,visa_Required__c from Candidate__c where id=:CanIds];
		System.Debug('Candidate Lists' + canlst);
		for(Candidate__c cc : canlst)
		{
			cc.Visa_Required__c=true;
			cc.city__c='bangalore';
		}
		if(canlst!=null && canlst.size()>0)
		{
			update canlst;
		}
		
		
		Joblst=[select id,Position__c,Candidate__c from Job_Application__c where Position__c=:PosIds2];
		
		for(Job_Application__c j :Joblst)
		{
			CanIds2.add(j.Candidate__c);	
		}
		canlst2=[select id,Visa_Required__c from Candidate__c where id=:CanIds2];
		
		for(Candidate__c cc : canlst2)
		{
			cc.Visa_Required__c=false;
		}		
		
		
		if(canlst2!=null && canlst2.size()>0)
		{
			update canlst2;
		}
		
		
	} 

}