/*
 * @ classname          : BulkMessageControllerTest.
 * @ author             : Sarjerao Pujari.
 * @ date               : 11-11-2023
 * @ description        : This is test class for BulkMessageController Apex Class.

 * @ modificationlog
 * 1.Sarjerao Pujari       20-Nov-2023        Add Code Comments
 */
@isTest
public class BulkMessageControllerTest {

/**
* @ methodname             : BulkMessageControllerTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test parameter initialisation.
* @ return                 : None.
*/   
@isTest
public static void initialiseTest()
{ ApexResultSet resultset = new ApexResultSet();
 try
 {
     Test.startTest();
     resultset = BulkMessageController.initialise();
     Test.stopTest();
 }
 catch(Exception ex)
 {
     system.assertEquals(resultset.isSuccess,false);
 }	
}
    

/**
* @ methodname             : getDataFromApexTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test data required for sendmessagecontainer lwc component.
* @ return                 : None.
*/ 
@isTest
public static void getDataFromApexTest()
{  
    List<Account> getAccounts = TestDataFactory.getAccounts(1, true);
    List<Contact> getContacts = TestDataFactory.getAccountContacts(1, getAccounts[0].Id, true);
    List<Send_Configuration__c> ConfigurationList = TestDataFactory.createSBCRecords(1, 'Contact');
    //String objectName = 'Contact';
    List<Contact> createContact = [Select Id, Name From Contact Limit 1];
    test.startTest();
    try{
        ApexResultSet resultSet = new ApexResultSet();
        resultSet = BulkMessageController.getDataFromApex(createContact[0].Id);
        test.stopTest();
        system.debug('resultset1 : '+resultset);
        system.assertNotEquals(resultSet.data,null);
    }catch(exception e){
        
    } 
}
    

/**
* @ methodname             : getSObjectRecordsTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test data SObject record.
* @ return                 : None.
*/     
@isTest
public static void getSObjectRecordsTest()
{  
    boolean isEmptyData;
    List<Account> getAccounts = TestDataFactory.getAccounts(1, true);
    List<Contact> getContacts = TestDataFactory.getAccountContacts(1, getAccounts[0].Id, true);
    List<Contact> createContact = [Select Id, Name,AssistantPhone From Contact Limit 1];
    system.debug('createContact === '+createContact);
    Map<String,Object> parameters = new Map<String,Object>();
    parameters.put('objectName','Contact');
    parameters.put('nameField','Name');
    parameters.put('phonefield','Phone, AssistantPhone');
    parameters.put('optField','isDeleted');
    List<Id> idList = new List<Id>();
    String recordId = createContact[0].Id;
    idList.add(recordId);
    parameters.put('recordIds',idList);
    ApexResultSet resultSet = new ApexResultSet();
    test.startTest();
    resultSet =BulkMessageController.getSObjectRecords(parameters);
    test.stopTest();
    if(resultSet.data != null)
    {
       isEmptyData = true; 
    }else{
        isEmptyData = false;
    }
    system.assertEquals(resultSet.data != null,isEmptyData);
}
    
 
/**
* @ methodname             : getMeargedMessageTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test mearged message.
* @ return                 : None.
*/    
@isTest
public static void getMeargedMessageTest()
{  
    List<Account> getAccounts = TestDataFactory.getAccounts(1, true);
    List<Contact> getContacts = TestDataFactory.getAccountContacts(1, getAccounts[0].Id, true);
    List<Contact> createContact = [Select Id, Name, email, Department, Phone From Contact Limit 1];
    String recordId = createContact[0].Id;
    String messageBody = '<p>Hello {!Name}</p>';
    ApexResultSet resultSet = new ApexResultSet();
    Test.startTest();
    resultSet = BulkMessageController.getMeargedMessage(messageBody, recordId, 'Contact');
    string mergedMsg = (String)resultSet.data;
    Test.stopTest();
    system.assertEquals('Hello Name0',mergedMsg.trim());
}
    
    /**
* @ methodname             : getMeargedMessageExcTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test mearged message.
* @ return                 : None.
*/    
@isTest
public static void getMeargedMessageExcTest()
{  
    List<Account> getAccounts = TestDataFactory.getAccounts(1, true);
    List<Contact> getContacts = TestDataFactory.getAccountContacts(1, getAccounts[0].Id, true);
    List<Contact> createContact = [Select Id, Name, email, Department, Phone From Contact Limit 1];
    String recordId = createContact[0].Id;
    String messageBody = '<p>Hello {!Name} </p>';
    ApexResultSet resultSet = new ApexResultSet();
    Test.startTest();
    resultSet = BulkMessageController.getMeargedMessage(messageBody, recordId, Null);
    string mergedMsg = (String)resultSet.data;
    Test.stopTest();
    system.assertEquals(null,mergedMsg);
}
    

/**
* @ methodname             : getAllActiveApprovedTemplatesTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test all active approved template.
* @ return                 : None.
*/
@isTest
public static void getAllActiveApprovedTemplatesTest()
{
    ApexResultSet resultSet = new ApexResultSet();
    Test.startTest();
    resultSet = BulkMessageController.getAllActiveApprovedTemplates('Contact', 'WhatsApp');
    Map<string,WhatsApp_Template__c> approvedTempMap = (Map<string,WhatsApp_Template__c>)resultSet.data;
    Test.stopTest();
    system.assertEquals(0,approvedTempMap.keySet().Size());
}
    
/**
* @ methodname             : getActiveChannelTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test all active channel.
* @ return                 : None.
*/   
@isTest
public static void getActiveChannelTest()
{
    Test.startTest();
    Map<String, Channel__mdt> allChannelsMap = (Map<String, Channel__mdt>)BulkMessageController.getActiveChannel();
    Test.stopTest();
    system.assertNotEquals(0,allChannelsMap.keySet().Size());        
}
    
    
/**
* @ methodname             : initiateMessageSendingTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test start the message sending.
* @ return                 : None.
*/
@isTest
Public static Void initiateMessageSendingTest()
{
    map<String,Object> mapChannels = (map<String,Object>)TestDataFactory.CreateChannelRequestMap();
    List<Account> getAccounts = TestDataFactory.getAccounts(1, true);
    List<Contact> getContacts = TestDataFactory.getAccountContacts(1, getAccounts[0].Id, true);
    List<Send_Configuration__c> sbcList = TestDataFactory.createSBCRecords(1, 'Contact');
    Test.setMock(HttpCalloutMock.class, new BulkMessageControllerMock());
    Test.startTest();
    ApexResultSet resultset = BulkMessageController.initiateMessageSending(mapChannels);
    Test.stopTest();
    System.assertNotEquals(null,resultset.data);
}
    
    
    /**
* @ methodname             : initiateMessageSendingNullTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test start the message sending.
* @ return                 : None.
*/
@isTest
Public static Void initiateMessageSendingNullTest()
{
    map<String,Object> mapChannels = (map<String,Object>)TestDataFactory.CreateChannelRequestMap();
    mapChannels.put('channel',Null);
    List<Account> getAccounts = TestDataFactory.getAccounts(1, true);
    List<Contact> getContacts = TestDataFactory.getAccountContacts(1, getAccounts[0].Id, true);
    List<Send_Configuration__c> sbcList = TestDataFactory.createSBCRecords(1, 'Contact');
    Test.setMock(HttpCalloutMock.class, new BulkMessageControllerMock());
    Test.startTest();
    ApexResultSet resultset = BulkMessageController.initiateMessageSending(mapChannels);
    Test.stopTest();
    system.debug('### resultset =='+resultset);
    system.assertEquals(null,resultset.data);
}
    
    /**
* @ methodname             : initiateMessageSendingBulkIDTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test start the message sending.
* @ return                 : None.
*/
@isTest
Public static Void initiateMessageSendingBulkIDTest()
{
    map<String,Object> mapChannels = (map<String,Object>)TestDataFactory.CreateChannelRequestMap();
     List<Contact> conList = TestDataFactory.createContacts(52);
    List<String> recordIds = new List<String>();
    for(Contact con : conList){
        recordIds.add(con.Id);
    }
    mapChannels.put('recordIds',recordIds);
    system.debug('@@ recordIds =='+recordIds.size());
    system.debug('@@ mapChannels =='+mapChannels);
    mapChannels.put('mobileFieldAPIName','phone, AssistantPhone');
    List<Account> getAccounts = TestDataFactory.getAccounts(1, true);
    List<Contact> getContacts = TestDataFactory.getAccountContacts(1, getAccounts[0].Id, true);
    List<Send_Configuration__c> sbcList = TestDataFactory.createSBCRecords(1, 'Contact');
    Test.setMock(HttpCalloutMock.class, new BulkMessageControllerMock());
    Test.startTest();
    ApexResultSet resultset = BulkMessageController.initiateMessageSending(mapChannels);
    Test.stopTest();
    System.assertNotEquals(null,resultset.data);
}
    
 
/**
* @ methodname             : getFieldLabelTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test all field labels of perticular object.
* @ return                 : None.
*/   
@isTest
public static void getFieldLabelTest()
{
    List<Account> getAccounts = TestDataFactory.getAccounts(1, true);
    List<Contact> getContacts = TestDataFactory.getAccountContacts(1, getAccounts[0].Id, true);
    List<Contact> conList = [Select Id,Phone,AssistantPhone from Contact];
    string phoneFields = conList[0].Phone+','+conList[0].AssistantPhone;
    string objName = 'Contact';
    ApexResultSet resultSet = new ApexResultSet();
    Test.startTest();
    resultSet = BulkMessageController.getFieldLabel(objName, phoneFields);
    Map<String,String> fieldLabelMap = (Map<String,String>)resultSet.data;
    Test.stopTest();
    system.assertEquals(True,fieldLabelMap.isEmpty());
}
 
    
    /**
* @ methodname             : getFieldLabelCatchExcTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test all field labels of perticular object.
* @ return                 : None.
*/   
@isTest
public static void getFieldLabelCatchExcTest()
{
    List<Account> getAccounts = TestDataFactory.getAccounts(1, true);
    List<Contact> getContacts = TestDataFactory.getAccountContacts(1, getAccounts[0].Id, true);
    List<Contact> conList = [Select Id,Phone,AssistantPhone from Contact];
    string phoneFields = conList[0].Phone+','+conList[0].AssistantPhone;
    string objName = Null;
    ApexResultSet resultSet = new ApexResultSet();
    Test.startTest();
    resultSet = BulkMessageController.getFieldLabel(objName, phoneFields);
    Map<String,String> fieldLabelMap = (Map<String,String>)resultSet.data;
    Test.stopTest();
    system.assertEquals(Null,resultSet.data);
}
    

/**
* @ methodname             : getReportFoldersTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : method to test if getting all the folders accesible to logged in user.
* @ return                 : None.
*/ 
@isTest
public static void getReportFoldersTest()
{
    ApexResultSet resultSet = new ApexResultSet();
    Test.startTest();
    resultSet = BulkMessageController.getReportFolders();
    Test.stopTest();
    System.assertEquals(true,resultSet.isSuccess);
}
  
 
/**
* @ methodname             : getReportTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : This method is used to test if user get reports in selected folder.
* @ return                 : None.
*/   
@isTest
public static void getReportTest()
{
    ApexResultSet resultSet = new ApexResultSet();
    String reportFolders = [SELECT Id, Name FROM Folder Limit 1].Name;
    Test.startTest();
    resultSet = BulkMessageController.getReports(reportFolders);
    Test.stopTest();
    System.assertEquals(true,resultSet.isSuccess);
}
  

/**
* @ methodname             : getReportIdExcTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : This method is used to test if user get reports in selected folder.
* @ return                 : None.
*/    
@isTest(seeAllData = true)
public static void getReportIdExcTest()
{
    ApexResultSet resultSet = new ApexResultSet();
    List<Report> reportList = [Select Id, Name From Report Where Name = 'Contact Test Report' Limit 1];
    String reportID = reportList[0].Id;
    Test.startTest();
    resultSet = BulkMessageController.getReportDetails(reportID);
    Test.stopTest();
    System.assertEquals(true,resultSet.isSuccess);
}
    

/**
* @ methodname             : getReportBaseObjectTest.
* @ author                 : Sarjerao Pujari.
* @ param                  : None.
* @ description            : This method test if user get primary object in selected report.
* @ return                 : None.
*/     
@isTest
public static void getReportBaseObjectTest()
{
    List<Account> getAccounts = TestDataFactory.getAccounts(1, true);
    List<Contact> getContacts = TestDataFactory.getAccountContacts(1, getAccounts[0].Id, true);
    Id recordId = getContacts[0].Id;
    ApexResultSet resultSet = new ApexResultSet();
    Test.startTest();
    resultSet = BulkMessageController.getReportBaseObject(recordId);
    Test.stopTest();
    System.assertNotEquals(null, resultSet, 'ApexResultSet should not be null');
    System.assertEquals(true,resultSet.isSuccess);
}

}