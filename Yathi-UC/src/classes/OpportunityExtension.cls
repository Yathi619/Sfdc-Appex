public class OpportunityExtension
{
    public Opportunity opp{get;set;}
    public OpportunityExtension()
    {
    opp=new Opportunity();
    }
    public void save()
    {
    insert opp;
    }
}