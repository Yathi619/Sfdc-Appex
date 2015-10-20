public with sharing class MyHelloWorld 
{
	public static void applyDiscount(Book__c[] books )	
	//Book__c A list of Book Records which is assigned to the variable books
	{
		for(Book__c b : books )
		{
			b.Price__c*=0.9;
			 //b.Price__c = b.Price__c * 0.9;
		}
	}

}