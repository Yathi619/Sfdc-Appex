@isTest(seeAllData=true)
private class TestClassOpportunity
{
    static testMethod void MyTest()
    {
        System.Test.startTest();
        
        PageReference AddOppPg = page.AddOpportunity;
        System.Test.setCurrentPage(AddOppPg);
        
        Opportunity opp1=new Opportunity();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opp1);
        OpportunityExt OpExt = new OpportunityExt (stdCon);
        
        OpExt.opp.Name='Sales Requirement';
        OpExt.opp.CloseDate=Date.newInstance(2008,11,20);
        OpExt.opp.StageName='Closed Won';
        OpExt.save();
        System.Test.stopTest();
        
    } 
}