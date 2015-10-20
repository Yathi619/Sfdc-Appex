public with sharing class wrapperClassController 
{
	public List<Contact> contactlist{get;set;}
	
	public wrapperClassController()
	{
		contactlist=new List<Contact>();
		contactlist=[select id,name,Email,Department from Contact];
	
	}
	
	
	
	public class cContact
	{
		public Boolean Selected {get;set;}
		public Contact con {get;set;}
		
		public cContact(Contact c)
		{
			Selected=false;
			con=c;
			
		}
	}
	
}