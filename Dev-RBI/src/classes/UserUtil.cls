public class UserUtil {
//Protected Members
private static final UserUtil instance = new UserUtil();
private Map<Id, User> mapUsers;

//Properties
public static User CurrentUser {
    get { return getUser(UserInfo.getUserId()); }
}

//Constructor
private UserUtil() {
    mapUsers = new Map<Id, User>(queryUsers());
}

//Public Methods
public static User getUser(Id userId) {
    if (instance.mapUsers.containsKey(userId)) {
        return instance.mapUsers.get(userId);
    }
    else {
        throw new InvalidUserIdException('Unable to locate user id: ' + userId);
    }
}

//Private Methods
private List<User> queryUsers() {
    return [SELECT 
                Id
                , Name
                , UserName
                , Email
                , Alias
                ,AccountId
                ,IsPortalEnabled
                ,contact.account.Current_Contract_End_Date__c
                ,contact.account.Name
                ,Profile.Name
            FROM 
                User];
}

//Internal Classes
public class InvalidUserIdException extends Exception {}
	
}