public class AccountController
{
     public Account acc;

    
     public AccountController(ApexPages.StandardController stdController)
    {
      acc=new Account(); 
    } 
    public void save()
    {
    insert acc;
    }
    
}