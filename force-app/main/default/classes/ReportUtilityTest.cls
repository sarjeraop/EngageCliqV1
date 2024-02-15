/**  @classname     : ReportUtilityTest.
  *  @author        : Ganesh Bhakare.
  *  @date          :
  *  @description   : This class is used to Test the functionality of folder selection and
                      and analyse the reports selected by user corresponding to particular folder

  *  @modificationlog
  *  1. Sarjerao Pujari      04-Oct-2023     Add Code Comments.    
*/
@isTest
public class ReportUtilityTest {
    
    static list<Folder> reportFolders=[SELECT Id,Name,DeveloperName FROM Folder where type='report'and DeveloperName!='' WITH USER_MODE];
    static string folderName = reportFolders[0].Name;
    
/**  @methodname            : GetReportFolders.
  *  @objectreferenced      : Folder.
  *  @param                 : None.
  *  @description           : This method is used to Test all the folders accesible to logged in user.
  *  @return                : None.
*/   
    @isTest
    static void GetReportFolders() {
        
        Test.startTest();
        List<Folder> resultFolders = ReportUtility.getReportFolders();
        Test.stopTest();        
        
        System.assertNotEquals(null, resultFolders, 'List of report folders should not be null.');
        
    }

/**  @methodname            : GetReports.
  *  @objectreferenced      : Folder.
  *  @param                 : None.
  *  @description           : This method is used to Test the reports in selected folder.
  *  @return                : None.
*/    
    @isTest
    static void GetReports() {
        
        Test.startTest();
        List<Report> resultReports = ReportUtility.getReports(folderName);
        Test.stopTest();
        System.assertNotEquals(null, resultReports, 'List of reports should not be null.');
        
    }

/**  @methodname            : GetReportDetails.
  *  @objectreferenced      : Folder.
  *  @param                 : None.
  *  @description           : This method used  to Test all the Collected recordIds corresponding to primary object in selected report.
  *  @return                : None.
*/    
    @isTest(SeeAllData = true)
    static void GetReportDetails() {
        list<Report> reportsList=[select Id,Name from Report Limit 10];
        for(Report rpt : reportsList){
            string reportId = rpt.Id;
            list<Id> getReportDetailsResult = ReportUtility.getReportDetails(reportId);
            System.assertNotEquals(null, getReportDetailsResult, 'Report details should not be null.');
        }
    }

/**  @methodname            : getReportBaseObjectTest.
  *  @objectreferenced      : Folder.
  *  @param                 : None.
  *  @description           : This method is used to Test primary object in selected report
  *  @return                : None.
*/     
     @isTest
    static void getReportBaseObjectTest() {
        
        List<Account> accList = TestDataFactory.getAccounts(1, true);
        List<Contact> conList = TestDataFactory.getAccountContacts(1, accList[0].Id, true);
        Test.startTest();
        Map<String,String> resultReports = ReportUtility.getReportBaseObject(conList[0].Id);
        Test.stopTest();
        System.assertNotEquals(null, resultReports);
        
    }
}