@isTest
public with sharing class EngageAPITest {
    @testSetup
    public static void createTestData(){
        
        List<Account> accList = TestDataFactory.getAccounts(2, true);
        List<Contact> contactRecordsList = TestDataFactory.getAccountContacts(10, accList[0].Id, true);
        List<Template__c> templateList = TestDataFactory.createTemplate(5, true);
        List<WhatsApp_Template__c> whtasAppTemplateList = TestDataFactory.createWhatsAppTemplate(templateList[0].Id, 5, true);
        
    }

    @isTest
    public static void sendTest(){
        List<Send_Configuration__c> sbcList = TestDataFactory.createSBCRecords(1, 'Contact');
        Map<String,Object> mapChannelRequest = new Map<String,Object>();
        String myTemplateId = [Select Id From WhatsApp_Template__c Limit 1].Id;
        List<Contact> getContactRecordsList = [Select Id, Name From Contact];
        List<String>recordIds = new List<String>();
        recordIds.add(getContactRecordsList[0].Id);
        Test.setMock(HttpCalloutMock.class, new EngageAPIMock());
        EngageAPIMock handler = new EngageAPIMock();
        test.startTest();
        EngageAPI engageApi = new EngageAPI();
        engageApi.send(myTemplateId, recordIds, 'WhatsApp', 'Phone');
        //mapChannelRequest = engageApi.processData().mapChannelRequest;
        //engageApi.send(myTemplateId, recordIds, 'WhatsApp', 'Phone');
        test.stopTest();
        //system.debug('engageApi => '+engageApi.mapChannelRequest);
        System.assertNotEquals(null,engageApi,'Sucess');
    }
    /*
    @isTest
    public static void futureTest(){
        List<Send_Configuration__c> sbcList = TestDataFactory.createSBCRecords(3, 'Contact');
        Map<String,Object> mapChannelRequest = new Map<String,Object>();
        List<WhatsApp_Template__c> myTemplate = [Select Id From WhatsApp_Template__c];
        String whatsAppTemplateId = myTemplate[1].Id;
        List<Contact> getContactRecordsList = [Select Id, Name, Phone From Contact];
        List<String>recordIds = new List<String>();
        recordIds.add(getContactRecordsList[0].Id);
        recordIds.add(getContactRecordsList[1].Id);
        Test.setMock(HttpCalloutMock.class, new EngageAPIMock());
        EngageAPIMock handler = new EngageAPIMock();
        //EngageAPI engageApi = new EngageAPI();
        
        test.startTest();
        new EngageAPI().send(whatsAppTemplateId, recordIds, 'WhatsApp', 'Phone');
        mapChannelRequest = new EngageAPI().processData().mapChannelRequest;
        //mapChannelRequest.remove('recordIds');
        system.debug('mapChannelRequest => '+new EngageAPI().processData().mapChannelRequest);
        EngageAPI.execute(JSON.serialize(mapChannelRequest),recordIds);
        test.stopTest();
        
        //System.assertNotEquals(null,engageApi,'Sucess');
    }
*/
}