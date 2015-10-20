@isTest
private class TestClassPosJobCan 
{
    static testMethod void myUnitTest() 
    {
        list<Candidate__c> canlst=new list<Candidate__c>();
        System.Test.startTest();
        Candidate__c can=new Candidate__c(First_Name__c='Yuvi',Visa_Required__c=false,Education__c='MCA',Zip_Postal_Code__c='574106');
        insert can;
        System.debug('candidateCheck'+ can);
        
        Position__c pos=new Position__c(Name='Journaist',Location__c='San Francisco, CA',Min_Pay__c=5, Max_Pay__c=8,Renewal_Date__c=system.today());
        insert pos;
        System.debug('PositionCheck'+pos);
        
        Job_Application__c job=new Job_Application__c(Candidate__c=can.Id,Position__c=pos.Id);
        insert job;
        System.debug('Job_ApplicationCheck'+job);
        
        //---------------------------------------------------------------------------------------
        
        //query always gives the result in list so need to define the list 
        canlst=[select First_Name__c,Visa_Required__c,id from Candidate__c where First_Name__c='Yuvi'];
        System.debug('check' +canlst);
        
        for(Candidate__c c : canlst)
        {
            system.assertEquals(true,c.Visa_Required__c);
            system.debug('visa'+c.Visa_Required__c);
        }
        // System.Test.stopTest();    
         
        //----------------------------------------------------------------------------------------
         
        //bulk testing
        
         canlst=new list<Candidate__c>();
         for (Integer i=0; i<50;i++)
         {
            can=new Candidate__c(First_Name__c='Yuvan'+i,Visa_Required__c=false,Education__c='MCA',Zip_Postal_Code__c='574106');
            canlst.add(can);
         }
         insert canlst;
         system.debug('Candidate List'+canlst);
         
          
         list<Job_Application__c> joblst=new list<Job_Application__c>();
         list <Position__c> poslst=new list<Position__c>();
         for(Integer k=0; k<20; k++)
         {
         	pos=new Position__c(Name='Journalist'+k,Location__c='San Francisco, CA',Min_Pay__c=5, Max_Pay__c=8,Renewal_Date__c=system.today());
         	poslst.add(pos);
         	system.debug('journalist'+k);
         }
         
         for(Integer k=20; k<50; k++)
         {
         	pos=new Position__c(Name='Journalist'+k,Location__c='Mumbai, India',Min_Pay__c=5, Max_Pay__c=8,Renewal_Date__c=system.today());
         	poslst.add(pos);
         	system.debug('journalist'+k);
         }
         insert poslst;
         system.debug('Position List'+poslst);
         
         
          
         for(Integer j=0; j<50;j++)
         {
           // job=new Job_Application__c(Candidate__c=can[j].id,Position__c=pos.id);
          // Eror : Save error: Expression must be a list type: Candidate__c
            
            job=new Job_Application__c(Candidate__c=canlst[j].id,Position__c=poslst[j].id);
            system.debug('candidateID'+canlst[j].id);
            system.debug('PositionId'+poslst[j].id);
            joblst.add(job);
           
         }
            insert joblst;
            system.debug('Job List '+joblst);
         
            canlst=[select First_Name__c,Visa_Required__c,id from Candidate__c where First_Name__c like : 'Yuvan%' ];
      
      for(Candidate__c c : canlst)
      {
      	System.assertEquals(c.Visa_Required__c, true);
      	system.debug('visa required' + c.Visa_Required__c);
      }
       
         
         System.Test.stopTest();
        
    }
}