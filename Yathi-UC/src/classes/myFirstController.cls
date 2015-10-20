public class myFirstController{ 
    public myFirstController(ApexPages.StandardController controller) {

    }


    public myFirstController(){ }

 

 public Account[] getAccountList() {
  
            return [select id,name from Account limit 25]; 
                                 }    
            public String getName()
            
             { return 'My First Custom Controller';
             
             }
            
             }