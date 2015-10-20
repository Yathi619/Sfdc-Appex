@isTest(SeeAllData=true)
private class TestClassAccount {

    static testMethod void myTest(){

        //start test class method
        System.Test.startTest();
        
        //Instantiate the AddAccountRecord 
        
        PageReference AddAccPg = page.AddAccountRecord;
        System.Test.setCurrentPage(AddAccPg);
        
        //Instantiate the class which is used in the page above
       
        Account acc= new Account();
        ApexPages.StandardController stdCon = new
ApexPages.StandardController(acc);
        AccountController TstAccExtn = new AccountController(stdCon);

    //Set the Value of the Name field

        TstAccExtn.acc.Name = 'Kishan Account';

    //Call the Save method of the Controller
        TstAccExtn.save();

        //Stop Test Class
        System.Test.stopTest();
    }
}