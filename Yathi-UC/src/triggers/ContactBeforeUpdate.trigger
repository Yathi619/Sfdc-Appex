trigger ContactBeforeUpdate on Contact (before update) {

	for(Contact concat : Trigger.New)
	{
		concat.Description='Contact submitted successfully by ' + Userinfo.getUserName();
		
	}

}