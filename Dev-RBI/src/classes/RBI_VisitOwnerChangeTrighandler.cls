public without sharing class RBI_VisitOwnerChangeTrighandler{
    public Static boolean FirstUpdate = true;
    list<Visit__c> visitListForUpdate = new list<Visit__c>();
    
    public void OnBeforeUpdate(list<Visit__c>  visNew, list<Visit__c>  visOld, Map<Id, Visit__c> ObjectMap){
        if(FirstUpdate){
            FirstUpdate = false;
            list<Visit__c> ListforUpdate = new list<Visit__c>();
            for(Visit__c vNew : visNew){
                if(vNew.Id ==  ObjectMap.get(vNew.Id).Id && (vNew.ownerId != ObjectMap.get(vNew.Id).ownerId)){
                    if(vNew.Visit_Report__c == 'DVU Report' || vNew.Visit_Report__c == 'TSR Report')
                        vNew.Technical_Head__c = vNew.ownerId;
                    else
                        vNew.Surveyor__c = vNew.ownerId;
                }
                if(vNew.Id == ObjectMap.get(vNew.Id).Id && ObjectMap.get(vNew.Id).Project_Auto_Num__c != vNew.Project_Auto_Num__c && vNew.Visit_Report__c != 'Followup Report'){
    	            ListforUpdate.add(vNew);
    	        }
    	        else if(vNew.Id == ObjectMap.get(vNew.Id).Id && ObjectMap.get(vNew.Id).Visit_Report__c != vNew.Visit_Report__c && vNew.Visit_Report__c != 'Followup Report'){
    	            ListforUpdate.add(vNew);
    	        }
    	        //function call to check duplicate project records
                if(ListforUpdate!=null && ListforUpdate.size()>0){
                    hasDuplicates(ListforUpdate); 
                }
            }
        }
    }
    
    public void OnbeforeInsert(list<Visit__c>  visNew){
    	set<String> siteCity = new set<String>();
        String siteCityString = '';
        map<String, User> userlst = new map<String, User>();
        list<Visit__c> visitListIns = new list<Visit__c>();   
        
        for(Visit__c vis : visNew){
        	if(vis.Project_Site_City__c != null && (siteCity.add(vis.Project_Site_City__c)) && (vis.Visit_Report__c == 'TSR Report' || vis.Visit_Report__c == 'DVU Report'))
		        siteCityString += '\''+vis.Project_Site_City__c+'\',';
		    if(vis.Project__c != null && vis.Visit_Report__c != 'Followup Report'){
		    	visitListIns.add(vis);
		    }    
        }
        if(siteCityString != null && siteCityString != '')
	        siteCityString = siteCityString.substring(0, siteCityString.length()-1); 
	    system.debug('xxxxxxxxxxx'+siteCityString);
        userlst = queryUser(siteCityString);
        for(Visit__c vis : visNew){
            if(vis.Visit_Report__c == 'TSR Report' || vis.Visit_Report__c == 'DVU Report'){
	            String OperationMgrKey = vis.Project_Site_City__c+'-Operation Mgr - Data';
	            if(vis.Project_Site_City__c != null){
		            if(userlst.containsKey(OperationMgrKey) && userlst.get(OperationMgrKey).UserRole.Name == 'Operation Mgr - Data'){
	                	vis.Technical_Head__c = userlst.get(OperationMgrKey).Id;
	                }else{
	                  	vis.Technical_Head__c = system.Label.RBI_DefaultPASMgrId; 
	                } 
	                
	            }
	            vis.OwnerId = vis.Technical_Head__c;
            }
        }
        if(visitListIns!=null && visitListIns.size()>0){
            //Need to check for uniqueness for Developer accounts	
        	hasDuplicates(visitListIns);
        }
    }
    
    public map<String, User> queryUser(String siteCity){
		list<User> userList = new list<User>();
	    system.debug('qqqqqqqqqq'+siteCity);
	    if(siteCity != null && siteCity != ''){	
	     	String userQuery = 'select name, UserRole.Name, Covering_Cities__c, City from User';
			userQuery += ' where (Covering_Cities__c INCLUDES (' + siteCity + ')) and (UserRole.Name = \'Operation Mgr - Data\')';
			system.debug('++++++++'+userQuery);
			userList = database.query(userQuery);
	    }
	    system.debug('yyyyyyyyyyy'+userList);
	    map<String, User> userMap = new map<String, User>();
	    for(User us : userList){
	       	if(us.Covering_Cities__c != null){
	       		list<String> cityList = us.Covering_Cities__c.split(';');
		        for(String strCity : cityList){
		           	userMap.put(strCity+'-'+us.UserRole.Name, us);
		        }
	       	}
	    } 
	    system.debug('asdf'+userMap);
	    return userMap;
    }
    
    // This method acts as a uniqueness checker for the Visit for a project
    private  void hasDuplicates(Visit__c[] Visitlst){
        //Define a map for unique Projects
        Map <String,Visit__c> visMap = new Map<String, Visit__c> ();
        for (Visit__c vis: Visitlst) {
                String projName     = (vis.Project_Auto_Num__c==null)?'':vis.Project_Auto_Num__c.toLowerCase();
                String visitType     = (vis.Visit_Report__c==null)?'':vis.Visit_Report__c.toLowerCase();
                String ukey = projName + visitType;
                if (visMap.containsKey(ukey)) {
                    vis.addError('Visit record with the same type already exists in the system');
                }
                else visMap.put(ukey,vis);
        }
        //Check DB for dupes
        if (!visMap.isEmpty()){  
            for(Visit__c[] visCheck:[select Id, Unique_Key__c from Visit__c where Unique_Key__c IN :visMap.keySet()]) {
                for(Visit__c vis:visCheck) {
                    String currentId = vis.Id;
                    //if there's a dupe and this isn't the current record, then add the error.
                    if(visMap.containsKey(vis.Unique_Key__c) && (currentId != visMap.get(vis.Unique_Key__c).Id)) {
                        visMap.get(vis.Unique_Key__c).addError('Visit record with the same type already exists in the system');
                    }
                }
            }
        }
    }
}