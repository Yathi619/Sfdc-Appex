@isTest
Public class TestClassUser
{
    static testMethod void  addNewUser()
    {
    User UserToCreate = new User();
    
    UserToCreate.FirstName ='yathi';
    UserToCreate.LastName  ='bhat';
    UserToCreate.Email ='yathirock@gmail.com';
    UserToCreate.Username ='yathirockers@gmail.com'; 
    UserToCreate.Alias = 'yash'; 
    UserToCreate.ProfileId = '00e28000000dAIY';
    UserToCreate.TimeZoneSidKey='(GMT+05:30) India Standard Time (Asia/Kolkata)';
    UserToCreate.LocaleSidKey='English (India)';
    UserToCreate.EmailEncodingKey='General US & Western Europe (ISO-8859-1, ISO-LATIN-1)';
    UserToCreate.LanguageLocaleKey='English';
    insert UserToCreate;
    
    }
}