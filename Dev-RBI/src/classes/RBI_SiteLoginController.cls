global with sharing class RBI_SiteLoginController {
  //set username/ password variables via page
    global String username  {get; set;}
    global String password  {get; set;}
    global String strregion {get; set;}    

    global PageReference login() {
	  PageReference p = null;	
      //static org-id and portal id
      string currentprofile;
     // String strOrgID = '00DO0000000YoJV';
      string strOrgID 	 = System.Label.RBI_OrgId;
      String strPortalID = System.Label.RBI_UserPortalId;
     String strURL 	= System.Label.RBI_EnvURL;
      String startUrl = strUrl + '/secur/login_portal.jsp?orgId=' + strOrgID + '&portalId=' + strPortalID;
	  PageReference portalPage;
        startUrl += '&un=' + username;
        startUrl += '&pw='+ password;
        //PageReference p = Site.login(username, password, startUrl);
         //if p==null, no login
        /*if (p == null) {
              return Site.login(username, password, null);
        } else {*/
        user u =[SELECT 
                Id
                , Name
                , UserName
                , Email
                , Alias
          		, ProfileId
          		, Profile.Name
            FROM 
                User where UserName=:username];
              currentprofile = u.Profile.Name;
              if(currentprofile == 'RBI Customer Portal Manager'){
				system.debug('Manager'+currentprofile);
              	strPortalID = System.Label.RBI_ManagerPortalId;
              	startUrl =  strUrl+'/secur/login_portal.jsp?orgId=' + strOrgID + '&portalId=' + strPortalID;
        		startUrl += '&un=' + username;
        		startUrl += '&pw='+ password;
              	portalPage = new PageReference(startUrl);        		
              	portalPage.setRedirect(true);            		              	
              	p=Site.login(username, password, startUrl);              	
			   }
              else{
              	system.debug('User'+currentprofile);
              	strPortalID = System.Label.RBI_UserPortalId;
              	startUrl =  strUrl+'/secur/login_portal.jsp?orgId=' + strOrgID + '&portalId=' + strPortalID;
        		startUrl += '&un=' + username;
        		startUrl += '&pw='+ password;
              	portalPage = new PageReference(startUrl);        		
              	portalPage.setRedirect(true);  
				system.debug('before p'+p);      		               	
              	p= Site.login(username, password, startUrl);
              	system.debug('after p'+p);
			  }
             if(p == null){
              	system.debug('nulcondition');
              	return Site.login(username, password, null);
              }else{
              	return portalPage;
              }
      //  }        
        //set reference and attempt login
        
        
    }


    //test data provided by salesforce
     global RBI_SiteLoginController () {
        
     }

    
    @IsTest(SeeAllData=true) global static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456';
        System.assertEquals(controller.login(),null);
    }
}