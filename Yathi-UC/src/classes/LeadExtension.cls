public with sharing class LeadExtension
{
    public Lead mylead {get;set;}
    public CampaignMember campmem {get;set;}

    public LeadExtension(ApexPages.StandardController controller) {
    campmem = new CampaignMember();
    mylead = new Lead();
    }


    public PageReference save() {
       
    
        insert mylead;
        campmem.leadid = mylead.id;
        system.debug('lead id is' +campmem.leadid);
        campmem.leadid = mylead.id;
        insert campmem;
        mylead.clear();
       
        return null;
    }
}