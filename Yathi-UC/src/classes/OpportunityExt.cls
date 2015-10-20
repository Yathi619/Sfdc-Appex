public class OpportunityExt
{
    public Opportunity opp {get;set;}
    public OpportunityExt(ApexPages.StandardController stdcontroller)
    {
    opp=new Opportunity();
    
    } 
    public void save()
    {
    insert opp;
    }
}