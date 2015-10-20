@isTest
private class TestClassAccConInsurance2 {

    static testMethod void myUnitTest() {
    	
       // check for blank values in contact and account
       AccConInsurance2 acc=new AccConInsurance2();
       //initialise the class to access the method
      
       //create a new account 
       Account acct=new Account(Name='Tugboat Ltd');
       insert acct;
       
       acc.AccName='';
       acc.ConName='';
       acc.AccConSearch();
      // acc.getins();
       
       
       Contact con=new Contact(LastName='ajay',AccountId=acct.id);
       insert con;
       acc.AccName='Tug';
       acc.AccConSearch();
       acc.ConName='aj';
       acc.AccConSearch();
       acc.getins();
       
       
     
        
       
       
       
    }
}