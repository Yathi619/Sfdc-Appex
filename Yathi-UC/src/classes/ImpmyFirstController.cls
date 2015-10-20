public with sharing class ImpmyFirstController {




    public ImpmyFirstController(ApexPages.StandardController controller) {

    }


    public ImpmyFirstController(){ }

 

 public Account[] getAccountList() {
  
            return [select id,name from Account limit 25]; 
                                 }    
            public String getName()
            
             { return 'My First Custom Controller';
             
             }
            
}