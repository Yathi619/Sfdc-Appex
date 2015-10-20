public with sharing class LeadExtension2 {

	public Lead Led {get;set;}
	public LeadExtension2 (ApexPages.Standardcontroller controller)
	{
		Led=new Lead();
	}
	public void save()
	{
		insert Led;
	}
}