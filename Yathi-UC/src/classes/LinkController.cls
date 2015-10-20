public class LinkController {

   public PageReference Save()

    {

String newPageUrl = 'http://www.rediff.com/';

   PageReference newPage = new PageReference(newPageUrl);

   newPage.setRedirect(true);

   return newPage;

    }
}