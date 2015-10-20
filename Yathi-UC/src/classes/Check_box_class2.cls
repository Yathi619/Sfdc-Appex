public with sharing class Check_box_class2 
{
    public list<accountwrapper1> accountlist {get;set;}
    public list<Account> selectedAccounts=new list<Account>();
    public string sid{get;set;}
    
    
    
    //public list <accountwrapper1> getAccounts()
    public void AccDetails()
    {   accountlist=new list<accountwrapper1>();
        for(Account a :[select id,Name,Phone from Account])
        accountlist.add(new accountwrapper1(a));
    
        
    }
    public void getSelected()
    {
        selectedAccounts.clear();
        for(accountwrapper1 accwrapper:accountlist)
        if(accwrapper.selected==true)
        selectedAccounts.add(accwrapper.acc);
        system.debug('what'+selectedAccounts);
    }
    public list<Account> getSelectedAccounts()
    {
        if(selectedAccounts.size()>0)
        return selectedAccounts;
        else
        return null;
    }
    public void RemoveRec()
    {
    
        for(accountwrapper1 accou :accountlist )
        {
            if(accou.acc.id==sid)
            {
                accou.selected=false;
            }
            
        }
        getSelected();
         
    }
    
    public class accountwrapper1
    {
        public Account acc{get;set;}
        public Boolean selected{get;set;}
        
        public accountwrapper1(Account a)
        {
        acc=a;
        selected=false;
        }
    }
    
}