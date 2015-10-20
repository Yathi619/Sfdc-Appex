public with sharing class ImpDisplayAccountContact 
{
    public string accid;
	public list <Account> acclist{get;set;}
	public list <Contact> con{get;set;}

	public ImpDisplayAccountContact( Apexpages.Standardcontroller std)
	{
	
	acclist=new list<Account>();
	acclist=[select id,name from Account];
	}
    public void populateContact()
    {
    	con=new list<Contact>();
    	con=[select id,name from Contact where AccountId = :accid];
    	
    	
    }
}