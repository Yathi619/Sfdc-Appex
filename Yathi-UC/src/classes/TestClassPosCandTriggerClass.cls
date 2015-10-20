@isTest
private class TestClassPosCandTriggerClass {

    static testMethod void myUnitTest() {
      
          //Test case for update to Foreign Country(Visa Required true)
      
  /* Position__c pos=new Position__c(Name='TestPosition',Deadline_Date__c=8,Deadline_Month__c=5,Renewal_Date__c=system.today(),Min_Pay__c=5,Max_Pay__c=10,Location__c='Bangalore, India');
      insert pos;  
      Candidate__c can=new Candidate__c(First_Name__c='Yathiraj',Visa_Required__c=false,Zip_Postal_Code__c='574106');
      insert can;
      Job_Application__c job=new Job_Application__c(Position__c=pos.id,Candidate__c=can.Id);
      insert job;
      
    
    
      Position__c posupd=new Position__c(id=pos.Id,Location__c='San Francisco, CA');
      update posupd;
      
      
      
      list <Candidate__c> canlst=new list <Candidate__c>([select id,visa_Required__c from Candidate__c where First_Name__c='Yathiraj']);
      system.assertEquals(true,canlst[0].visa_Required__c);
      
      
      
        //Test case for update to India(Visa Required False)
        
        Position__c pos1=new Position__c(Name='NegativeTestPosition',Deadline_Date__c=8,Deadline_Month__c=5,Renewal_Date__c=system.today(),Min_Pay__c=5,Max_Pay__c=10,Location__c='San Francisco, CA');
        insert pos1;
        System.Debug('Created Position' +pos1);
        Candidate__c can1=new Candidate__c(First_Name__c='RajBrothers',Visa_Required__c=true,Zip_Postal_Code__c='574106');
        insert can1;
        System.Debug('Created Canddidate' +can1);
        Job_Application__c job1=new Job_Application__c(Position__c=pos1.Id,Candidate__c=can1.Id);
        insert job1;
        System.Debug('Created Job_Application' +job1);
        
        
        
        Position__c posupd1=new Position__c(id=pos1.Id,Location__c='Bangalore, India');
        update posupd1;
        System.Debug('Updated Position' +posupd1);
        
        
        
        list <Candidate__c> canlst1=new list <Candidate__c>([select id,Visa_Required__c from Candidate__c where First_Name__c='RajBrothers' ]); 
       	System.Debug('Updated Candidate List' +canlst1);
       	
       	
       	system.assertEquals(false,canlst1[0].Visa_Required__c);
       	System.Debug('required result false' +canlst1[0].Visa_Required__c);
        //List has so many records to get the first record we need canlst1[0]
        
      
         //Bulk Testing -----------------------------------------------------------------------
        
   */
        
        list <Position__c> bulkposlst=new list <Position__c>();
        list <Position__c> UPDbulkposlst=new list <Position__c>();
        
        list <Candidate__c> bulkcanlst=new list<Candidate__c>();
        list <Job_Application__c> bulkjoblst =new list <Job_Application__c>();
        
        
        
        
        for(Integer i=0; i<10;i++)
        {
        	Position__c posbulk=new Position__c(Name='Test Engineer'+i,Deadline_Date__c=8,Deadline_Month__c=5,Renewal_Date__c=system.today(),Min_Pay__c=5,Max_Pay__c=10,Location__c='Bangalore, India');
        	bulkposlst.add(posbulk);
        }
        insert bulkposlst;
        system.debug('Position List'+bulkposlst);
        
        
        
        
        
        
        for(Integer k=0;k<30;k++)
        {
        	Candidate__c canbulk=new Candidate__c(First_Name__c='Test Candidate'+k,Visa_Required__c=false,Zip_Postal_Code__c='574106');
        	bulkcanlst.add(canbulk);
        }
        insert bulkcanlst;
        system.debug('Candidate List'+bulkcanlst);
        
        
        
        
        
        for(Integer p=0;p<10;p++)
        {
        	for(Integer q=p*3;q<(p*3)+3;q++)
       		{
        		Job_Application__c Jobbulk=new Job_Application__c(Candidate__c=bulkcanlst[q].id,Position__c=bulkposlst[p].id);
            	bulkjoblst.add(Jobbulk);
            }	
        }
        insert bulkjoblst;
            system.debug('JobApplication List'+bulkjoblst);
            
            
            
            
        
  	 //	Update the Position
  	 
  	 for(Position__c p:bulkposlst)
  	 {
  	 	Position__c posbulk=new Position__c(ID=p.id, Location__c='San Francisco, CA');
  	 	UPDbulkposlst.add(posbulk);
  	 }
  	 update UPDbulkposlst;
  	  system.debug('Updated Position List'+UPDbulkposlst);
  	  
  	  
  	  
  	  
  	 
  	 //Query  the candidate list to check whether the trigger fired
  	 
  	 list <Candidate__c> CanlstQuery=new list<Candidate__c>([select id,First_Name__c,Visa_Required__c from Candidate__c where First_Name__c like 'Test Candidate%']);
  	 System.Debug('CanlstQuery'+CanlstQuery);
  	 for(Candidate__c c :CanlstQuery)
  	 {
  	 	System.assertEquals(true,c.Visa_Required__c);
  	 }
  
  
  // bulk Testing for Negative Case 
  
 	list <Position__c> bulkneglstPos=new list <Position__c>();
  	list <Position__c> UPDbulkneglstPos=new list <Position__c>();
  	list <Candidate__c> bulkneglstCan=new list<Candidate__c>();
	list <Job_Application__c> bulkneglstJob =new list<Job_Application__c>();
	  	
  
  	for(Integer i=0; i<10;i++)
  	{
  		Position__c bulkpos=new Position__c(Name='SystemAdmin'+i,Deadline_Date__c=5,Deadline_Month__c=8,Renewal_Date__c=system.today(),Min_Pay__c=600,Max_Pay__c=1000,Location__c='San Francisco, CA') ;
  		bulkneglstPos.add(bulkpos);
  	}
  	insert bulkneglstPos;
  	System.debug('bulk Position'+bulkneglstPos);
  
  
  		for(Integer i=0;i<30;i++)
  		{
  			Candidate__c bulkcan=new Candidate__c(First_Name__c='yathi'+i,Visa_Required__c=true,Zip_Postal_Code__c='574106');
  			bulkneglstCan.add(bulkcan);
  		//insert bulkneglstCan;
  		//insert failed error cannot specify an id in insert call-- bcoz once the candidate record is inserted it will be there in the list
  		//bulkneglstCan list i added the next record this time again candidate0 and candidate1 will be inserted bcoz cand0 is in the list
  		}
  		insert bulkneglstCan;
  		System.debug('bulk candidate'+bulkneglstCan);
  		
  		
  		
  		for(Integer m=0; m<10; m++) 
  		{
  			for(Integer n=m*3; n<(m*3)+3; n++)
  			{
  				Job_Application__c bulkjob=new Job_Application__c(Candidate__c=bulkneglstCan[n].id,Position__c=bulkneglstPos[m].id);
  				bulkneglstJob.add(bulkjob);
  			} 
  			
  		}
    	insert bulkneglstJob;
    	System.debug('bulk Job_Application'+bulkneglstJob);
    
    	//update the Position
    	
    	for(Position__c p:bulkneglstPos)
    	{
    		Position__c bulkpos=new Position__c(id=p.Id, Location__c='Bangalore, India');
    		UPDbulkneglstPos.add(bulkpos);
    	}
    		update UPDbulkneglstPos;
    		System.Debug('Updated Position Now'+UPDbulkneglstPos);
    		
    		
    		 //Query  the candidate list to check whether the trigger fired
  	 
  	 list <Candidate__c> CanlstQuery2=new list<Candidate__c>([select id,First_Name__c,Visa_Required__c from Candidate__c where First_Name__c like 'yathi%']);
  	 System.Debug('CanlstQuery2'+CanlstQuery2);
  	 for(Candidate__c c :CanlstQuery2)
  	 {
  	 	System.assertEquals(false,c.Visa_Required__c);
  	 }
    	     
    
    }
}