public with sharing class WrapperClass2 
{
	
	public list<Accountwrapper2> accwrapedlist=new list<Accountwrapper2>();
	
	public list<Accountwrapper2> getAccounts()
	{
		for(Account a : [select id,name,phone from Account limit 5])
		accwrapedlist.add(new Accountwrapper2(a));
		system.debug('acchecked'+accwrapedlist);
		return accwrapedlist;
	
	}
		
	
	
	public class Accountwrapper2
	{
		public Account acc{get;set;}
		public Boolean selected {get;set;}
		public Accountwrapper2(Account a)
		{
			acc=a;
			selected=false;
			system.debug('aaabbb'+acc);
		}
	}



}