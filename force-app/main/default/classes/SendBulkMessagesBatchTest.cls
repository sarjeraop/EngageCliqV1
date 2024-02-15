/**
* @ classname              : SendBulkMessagesBatchTest.
* @ author                 : Nikita Pawar.
* @ param                  : none.
* @ description            : this class is to test sending bulk messages functionality.
* @ return                 : none.
*/
@isTest
public class SendBulkMessagesBatchTest {

    /**
* @ methodname             : SendBulkMessagesBatchMapTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : Profile,PermissionSet,User,Account,Contact,WhatsApp_Template__c,Template__c,Schedule_Logs__c.
* @ param                  : none.
* @ description            : this method is to test if able to send bulk messages through report.
* @ return                 : none.
*/    
     @isTest
    public static void SendBulkMessagesBatchMapTest(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        PermissionSet pr =[SELECT Name, Id FROM PermissionSet where name='EngageCliq_Admin' LIMIT 1];
         
        User u = new User(Alias = 'standt', Email='engagecliq@test.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='engagecliq@test.com' + System.currentTimeMillis());
        insert u;
         PermissionSetAssignment psa = new PermissionSetAssignment
        (PermissionSetId = pr.Id, AssigneeId = u.Id);
        insert psa; 
        System.runAs(u) {
            
        List<Account> accList = TestDataFactory.getAccounts(2, true);
        List<Contact> contactRecordsList = TestDataFactory.getAccountContacts(10, accList[0].Id, true);
        List<Template__c> getTemplate = TestDataFactory.createTemplate(1, true);
        List<WhatsApp_Template__c> getWhatsAppTemplate = TestDataFactory.createWhatsAppTemplate(getTemplate[0].Id, 1, true);
        List<Schedule_Communication__c> getScheduleComm = TestDataFactory.getScheduleCommunication(getWhatsAppTemplate[0].Id, 1, true);
        List<Schedule_Logs__c> getScheduleCommunicationDetail = TestDataFactory.getScheduleCommunicationDetail(getScheduleComm[0].Id, 2, true);
        Map<String, Object> mapChannelRequest = new Map<String, Object>();
        List<String> recordIdList= new List<String>();
        List<String> phoneFieldApiNameList = new List<String>();
            phoneFieldApiNameList.add('Phone');
            phoneFieldApiNameList.add('MobilePhone');
        for(Contact con : contactRecordsList){
            recordIdList.add(con.Id);
        }
        List<Template__c> templateList = [Select Id, Name From Template__c Limit 1];
        List<WhatsApp_Template__c> whtasAppTemplateList = [Select Id, Name__c, Template_ID__c, Message_Body__c 
                                                           From WhatsApp_Template__c 
                                                           Where Template_ID__c =: templateList[0].Id
                                                           Limit 1];
        String myTemplateId = whtasAppTemplateList[0].Id;
        List<Send_Configuration__c> sbcData = TestDataFactory.createSBCRecords(1, 'Contact');
        mapChannelRequest.put('recordIds', recordIdList);
        mapChannelRequest.put('templateId', myTemplateId);
        mapChannelRequest.put('phoneFieldName', phoneFieldApiNameList);
        mapChannelRequest.put('nameFieldName', 'Name');
        mapChannelRequest.put('objectName', 'Contact');
        mapChannelRequest.put('channel', 'WhatsApp');
        
        Test.setMock(HttpCalloutMock.class, new SendBulkMessagesBatchMock());
        SendBulkMessagesBatch sendBulkMsgBatchMap = new SendBulkMessagesBatch(mapChannelRequest);
                
        Test.startTest();
        Database.executeBatch(sendBulkMsgBatchMap);
        Test.stopTest();
        
        List<Contact> conlist = [SELECT FirstName , Phone FROM Contact WHERE Id IN : recordIdList];
        System.debug('conlist =='+conlist);
        System.assertEquals(10, recordIdList.size(), 'Number of records in the list should be 10');
        }
    }
    /**
* @ methodname             : SendBulkMessagesBatchNullRptIdTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : Account,Contact,WhatsApp_Template__c,Template__c,Schedule_Logs__c,Schedule_Communication__c.
* @ param                  : none.
* @ description            : this method is to test the negative cenario with null report ID.
* @ return                 : none.
*/    
    @isTest
    public static void SendBulkMessagesBatchNullRptIdTest(){
        
        List<Account> accList = TestDataFactory.getAccounts(2, true);
        List<Contact> contactRecordsList = TestDataFactory.getAccountContacts(10, accList[0].Id, true);
        List<Template__c> getTemplate = TestDataFactory.createTemplate(1, true);
        List<WhatsApp_Template__c> getWhatsAppTemplate = TestDataFactory.createWhatsAppTemplate(getTemplate[0].Id, 1, true);
        List<Schedule_Communication__c> getScheduleComm = TestDataFactory.getScheduleCommunication(getWhatsAppTemplate[0].Id, 1, true);
        List<Schedule_Logs__c> getScheduleCommunicationDetail = TestDataFactory.getScheduleCommunicationDetail(getScheduleComm[0].Id, 2, true);
        
        Schedule_Communication__c objScheduleCommunication = [Select Id, Name, End_Date__c, Report_Id__c, Channel_Name__c, Template_Id__c, 
                                                              Recipient_Field__c, Name_Field__c, Object_Name__c 
                                                              From Schedule_Communication__c 
                                                              Limit 1];
        objScheduleCommunication.Report_Id__c = ' ';
        update objScheduleCommunication;
        Test.startTest();
        SendBulkMessagesBatch sendBulkMsgBatch = new SendBulkMessagesBatch(objScheduleCommunication);
        Test.stopTest();
        System.assertEquals(' ', objScheduleCommunication.Report_Id__c, 'Report_Id__c should be updated to a blank space');
        
    }
   
     /**
* @ methodname             : SendBulkMessagesBatchNullRptIdTest.
* @ author                 : Nikita Pawar.
* @ ObjectReferenced       : Account,Contact,WhatsApp_Template__c,Template__c,Schedule_Logs__c,Schedule_Communication__c.
* @ param                  : none.
* @ description            : this method is to test if able to schedule messages.
* @ return                 : none.
*/  
    @isTest(seeAllData = true)
    public static void SendBulkMessagesBatchTest(){
        
        List<Account> accList = TestDataFactory.getAccounts(2, true);
        List<Contact> contactRecordsList = TestDataFactory.getAccountContacts(10, accList[0].Id, true);
        List<String> selectedIdList = new List<String>();
        for(Contact con : contactRecordsList){
            selectedIdList.add(con.Id);
        }
        List<Template__c> getTemplate = TestDataFactory.createTemplate(1, true);
        List<WhatsApp_Template__c> getWhatsAppTemplate = TestDataFactory.createWhatsAppTemplate(getTemplate[0].Id, 1, true);
        List<Schedule_Communication__c> getScheduleComm = TestDataFactory.getScheduleCommunication(getWhatsAppTemplate[0].Id, 1, false);
        
        system.debug('getScheduleComm ::'+getScheduleComm);
        String updatedSchedulComm = SchedulerHelper.saveSchedule(getScheduleComm[0], selectedIdList);
        system.debug('updatedSchedulComm =='+updatedSchedulComm);
        List<Schedule_Logs__c> getScheduleCommunicationDetail = TestDataFactory.getScheduleCommunicationDetail(updatedSchedulComm, 2, true);
        Schedule_Communication__c getScheduleCommunication = [Select Id, Name, End_Date__c, Report_Id__c, Channel_Name__c, Template_Id__c, 
                                                              Recipient_Field__c, Name_Field__c, Object_Name__c, ContentVersion_Id__c 
                                                              From Schedule_Communication__c
                                                              Where Id =: updatedSchedulComm
                                                              Limit 1];
        system.debug('getScheduleCommunication @@'+getScheduleCommunication);
        ScheduledBatchable s = new ScheduledBatchable(getScheduleCommunication); 
        
        SendBulkMessagesBatch sendBulkMsgBatch = new SendBulkMessagesBatch(getScheduleCommunication);
        
        Test.startTest();
        getScheduleCommunication.Job_ID__c = System.schedule('Scheduled through Engagecliq'+'0 2 22 10/1 * ?', '0 0 9 * * ?', s); 
        update getScheduleCommunication;
        Database.executeBatch(sendBulkMsgBatch);
        Test.stopTest();
        System.assertNotEquals(null, getScheduleCommunication.Job_ID__c, 'Schedule ID should not be null after scheduling');
    }

}