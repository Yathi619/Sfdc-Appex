public class objectController
{
    public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    
     //System.Debug('AAA'+schemaMap);
     //schemaMap contains all the objects listed AAA{acceptedeventrelation=AcceptedEventRelation,
     //account=Account, accountcleaninfo=AccountCleanInfo whereas account is the String and Account is Schema.SObjectType
    
    public String selectedObject {get; set;}

    public String selectedField {get; set;}

    //constructor,, by default selected object in the picklist will be account object
    Public objectController()
    {   
        System.Debug('AAA'+schemaMap);
        selectedObject = 'account';
    }
     
    // next step List<String> entities = new List<String>(schemaMap.keySet()); (schemaMap.keySet has all the 
   // key values of objects (account,contact (object with lower case letter a,c,l) and storing the values 
   //in entities variable 
   
   //Key{acceptedeventrelation, account, accountcleaninfo, accountcontactrole, etc
   
    
    public List<SelectOption> getObjectNames() 
    {
        List<SelectOption> objNames = new List<SelectOption>();
        List<String> entities = new List<String>(schemaMap.keySet());
       
        
        System.Debug('EEE'+entities );
        //EEE(opportunitystage, leadstatus, casestatus, solutionstatus, 
        //Sort entities alphabetically and loop through the entities
        
        entities.sort();
        for(String name : entities)
        {
         System.Debug('NNN'+name);
          // name has all the object names (key values ex:account,contact,NNNappointmentregistry__c,NNNcandidate__c)
        // List<SelectOption> objNames = new List<SelectOption>();inserting all the keyvalues to objNames list
       
            objNames.add(new SelectOption(name,name));
        }
         System.Debug('objname'+objNames);
         //objname(System.SelectOption[value="acceptedeventrelation", label="acceptedeventrelation", disabled="false"], 
        // System.SelectOption[value="account", label="account", disabled="false"],
        return objNames;
       
     }
     //display the fields based the selected object from the picklist
     public List<SelectOption> getObjectFields() 
     {
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            //schemaMap has all the objects 
            
            Schema.SObjectType ObjectSchema = schemaMap.get(selectedObject);
            System.Debug('OOOO'+ObjectSchema);
            //I have selected the object "AccountShare" from the picklist therefore ObjectSchema
           // variable  has "OOOOAccountShare" S object Type 
            
            Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
            System.Debug('FFFF'+fieldMap);
            //fieldMap has all the fields of selected Object (Hospital__c)
            //FFFF{branch_address__c=Branch_Address__c, city__c=City__c, corp_address__c=Corp_Address__c,
            //where as branch_address__c is String and  Branch_Address__c is SObjectType)
            
            List<SelectOption> fieldNames = new List<SelectOption>();
            //This list to put all the fields in a list
            for (String fieldName: fieldMap.keySet()) 
            {  
                fieldNames.add(new SelectOption(fieldName,fieldName));
              //fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object fields label.
            }
             System.Debug('fieldname'+fieldNames);
             //fieldname(System.SelectOption[value="id", label="id", disabled="false"],
             // System.SelectOption[value="isdeleted", label="isdeleted", disabled="false"],
            return fieldNames;
      }       
}