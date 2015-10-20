public with sharing class PositionCandidateTriggerHandler 
{

	public void onAfterInsert(list <Job_Application__c> joblist)
	{
		Candidate__c can;
		list <Candidate__c> canupdLst;
		
		for(Job_Application__c job : joblist)
		{
			if(job.Position__r.Location__c != 'Bangalore, India' || job.Position__r.Location__c != 'Mumbai, India')
			{
				if(job.Candidate__c !=null)// candidate is not mandatory in job application 
				// so need to check for null condition otherwise exception will occur
				{
					can=new Candidate__c(id=job.Candidate__c); //here creating a new object and storing the candidate 
					//record selected in job application look up field and changing its visa req field 
					can.Visa_Required__c=true;
					
					//(updating the candidate record)next step is to update the candidate list as the candidate record is already exists
					canupdLst=new list <Candidate__c>();
					canupdLst.add(can);
				}
			}
		}
		if(canupdLst!=null && canupdLst.size()>0)
		update canupdLst;
		
	}

}