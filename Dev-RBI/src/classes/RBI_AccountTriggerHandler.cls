public with sharing class RBI_AccountTriggerHandler {
	
	// This method acts as a uniqueness checker for the Developer Accounts
    private  void hasDuplicates(Account[] accountslst){
        //Define a map for unique Projects
        Map <String,Account> accMap = new Map<String, Account> ();
        for (Account acc: accountslst) {
                String accName     = (acc.name==null)?'':acc.name.toLowerCase();
                String city     = (acc.BillingCity==null)?'':acc.BillingCity.toLowerCase();
                String ukey = accName + city;
                if (accMap.containsKey(ukey)) {
                    acc.addError('An Account with the same Name already exists in the system');
                }
                else accMap.put(ukey,acc);
        }
        //Check DB for dupes
        if (!accMap.isEmpty()){  
            for(Account[] AccCheck:[select Id, Unique_Key__c from Account where Unique_Key__c IN :accMap.keySet()]) {
                for(Account accnt:AccCheck) {
                    String currentId = accnt.Id;
                    //if there's a dupe and this isn't the current record, then add the error.
                    if(accMap.containsKey(accnt.Unique_Key__c) && (currentId != accMap.get(accnt.Unique_Key__c).Id)) {
                        accMap.get(accnt.Unique_Key__c).addError('Duplicate record with the same Name and City found in salesforce(id: ' + accnt.id + ')');
                    }
                }
            }
        }
    }
    
    public void OnBeforeInsert(list<Account> accountList){
    	list<Account> accountListIns = new list<Account>();   
        for(Account ac : accountList){
        	//if(ac.Record_Type_Name__c == 'Developer'){
        		accountListIns.add(ac);
        	//}
        }
        if(accountListIns!=null && accountListIns.size()>0){
        	//Need to check for uniqueness for Developer accounts	
    		hasDuplicates(accountListIns);
        }
    }
    
    public void OnBeforeUpdate(list<Account> accNew, list<Account> accOld, Map<Id, Account> ObjectMap){
    	list<Account> ListforUpdate = new list<Account>();
            for(Account acc : accNew){
            	system.debug('XXX'+acc.Record_Type_Name__c+'XXX'+acc.RecordTypeId+'XXX'+acc.RecordType.Name);
            	//if(acc.Record_Type_Name__c == 'Developer'){
	                if(acc.Id == ObjectMap.get(acc.Id).Id && ObjectMap.get(acc.Id).BillingCity != acc.BillingCity){
	                    ListforUpdate.add(acc);
	                }
	                else if(acc.Id == ObjectMap.get(acc.Id).Id && ObjectMap.get(acc.Id).Name != acc.Name){
	                    ListforUpdate.add(acc);
	               }
               //}                                
            }
            //function call to check duplicate project records
            if(ListforUpdate!=null && ListforUpdate.size()>0){
                hasDuplicates(ListforUpdate);
            }
    }
}