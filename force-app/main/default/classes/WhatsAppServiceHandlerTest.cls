/**  @classname  		: WhatsAppServiceHandlerTest
  *  @author 			: Nikita Pawar
  *  @date              : 22-oct-2023
  *  @param             : none
  *  @description  		: class Test the implementation of message sending structure through WhatsApp channel.
  *  @modificationlog
  *  	#		Date				 Description				Modified By
  *		1.	    22-12-2023			 Added Comments			    sarjerao Pujari
*/
@isTest
public class WhatsAppServiceHandlerTest {

/**
 * @ methodname             : createTestData.
 * @ author                 : Nikita Pawar.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this createTestData method is used to create a data for testing.
 * @ return                 : none.
 */    
    @testSetup
    public static void createTestData(){
        
        List<Account> accList = TestDataFactory.getAccounts(2, true);
        List<Contact> contactRecordsList = TestDataFactory.getAccountContacts(10, accList[0].Id, true);
        List<Template__c> templateList = TestDataFactory.createTemplate(5, true);
        List<WhatsApp_Template__c> whtasAppTemplateList = TestDataFactory.createWhatsAppTemplate(templateList[0].Id, 5, true);
        List<Outbound_Message__c> getOutboundMsg = TestDataFactory.createOutboundMessage(whtasAppTemplateList[0].Id, contactRecordsList[0].Id, 10, true);
        List<Send_Configuration__c> sbc = TestDataFactory.createSBCRecords(1, 'Contact');
    }

/**
 * @ methodname             : initTest.
 * @ author                 : Nikita Pawar.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : This method Test all parameters required to send message from UI request
 * @ return                 : none.
 */    
    @isTest
    public static void initTest(){
        Map<String, Object> mapChannelRequest = new Map<String, Object>();
        Id myTemplateId = [Select Id From WhatsApp_Template__c Limit 1].Id;
        List<Contact> getContactRecordsList = [Select Id, Name From Contact];
        mapChannelRequest.put('records', getContactRecordsList);
        mapChannelRequest.put('objectAPIName', 'Contact');
        mapChannelRequest.put('mobileFieldAPIName', 'Phone');
        mapChannelRequest.put('nameFieldAPIName', 'Name');
        mapChannelRequest.put('templateId', myTemplateId);
        mapChannelRequest.put('messageText', '{! Hello Good Morning }');
        
        
        test.startTest();
        WhatsAppServiceHandler handler = new WhatsAppServiceHandler();
        handler.init(mapChannelRequest);
        test.stopTest();
    }
    
    
       

/**
 * @ methodname             : validateTest.
 * @ author                 : Nikita Pawar.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : This method Test all the input paramenters before performing send operation
 * @ return                 : none.
 */      
    @isTest
    public static void validateTest(){
        test.startTest();
        WhatsAppServiceHandler handler = new WhatsAppServiceHandler();
        handler.validate();
        test.stopTest();
    }

/**
 * @ methodname             : processRequestTest.
 * @ author                 : Nikita Pawar.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : This method Test actual message send functionality through callout.
 * @ return                 : none.
 */     
    @isTest
    public static void processRequestTest(){
        
        Map<String, Object> mapChannelRequest = new Map<String, Object>();
        List<Account> accList = [Select Id, name From Account];
        List<Contact> contactRecordsList = [Select Id, name, Phone From Contact limit 2];
        List<Template__c> templateList = [Select Id, Name From Template__c];
        List<WhatsApp_Template__c> whtasAppTemplateList = [Select Id From WhatsApp_Template__c];
        String myTemplateId = whtasAppTemplateList[0].Id;
        System.debug('myTemplateId == '+myTemplateId);
        List<String> recordIds = new List<String>();
        recordIds.add(contactRecordsList[0].Id);
        //mapChannelRequest.put('records', contactRecordsList);
        mapChannelRequest.put('recordIds', recordIds);
        
        mapChannelRequest.put('records', contactRecordsList);
        mapChannelRequest.put('objectAPIName', 'Contact');
        mapChannelRequest.put('mobileFieldAPIName', 'Phone');
        mapChannelRequest.put('nameFieldAPIName', 'Name');
        mapChannelRequest.put('templateId', '');
        mapChannelRequest.put('messageText', 'Hello Good Morning');
        system.debug('mapChannelRequest'+mapChannelRequest);

        Test.setMock(HttpCalloutMock.class, new WhatsAppServiceHandlerMock());
        WhatsAppServiceHandler handler = new WhatsAppServiceHandler();
        test.startTest();
        ApexResultSet result =  WhatsAppService.process(mapChannelRequest);
        test.stopTest();
        System.assert(result != null, 'Result should not be null');
        system.assertEquals(true, result.isSuccess);
    }

/**
 * @ methodname             : processRequestUITempTest.
 * @ author                 : Nikita Pawar.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : This method Test request of UI template.
 * @ return                 : none.
 */    
    @isTest
    public static void processRequestUITempTest(){
        
        Map<String, Object> mapChannelRequest = new Map<String, Object>();
        List<Account> accList = [Select Id, name From Account];
        List<Contact> contactRecordsList = [Select Id, name, Phone From Contact limit 2];
        List<Template__c> templateList = [Select Id, Name From Template__c];
        List<WhatsApp_Template__c> whtasAppTemplateList = [Select Id,Message_Body__c, Name__c From WhatsApp_Template__c];
        List<WhatsApp_Template__c> whatsAppTempUpdate = new List<WhatsApp_Template__c>();
        for(WhatsApp_Template__c wt : whtasAppTemplateList){
            wt.Template_Type__c = 'Business Initiative';
            wt.Status__c = 'Approved';
            whatsAppTempUpdate.add(wt);
        }
        update whatsAppTempUpdate;
        String myTemplateId = whtasAppTemplateList[0].Id;
        System.debug('myTemplateId == '+myTemplateId);
        List<String> recordIds = new List<String>();
        recordIds.add(contactRecordsList[0].Id);
        //mapChannelRequest.put('records', contactRecordsList);
        mapChannelRequest.put('recordIds', recordIds);
        
        mapChannelRequest.put('records', contactRecordsList);
        mapChannelRequest.put('objectAPIName', 'Contact');
        mapChannelRequest.put('mobileFieldAPIName', 'Phone');
        mapChannelRequest.put('nameFieldAPIName', 'Name');
        mapChannelRequest.put('templateId', myTemplateId);
        mapChannelRequest.put('messageText', '<p>Hello, {!Name}Good Morning</p>');
        system.debug('mapChannelRequest'+mapChannelRequest);

        Test.setMock(HttpCalloutMock.class, new WhatsAppServiceHandlerMock());
        WhatsAppServiceHandler handler = new WhatsAppServiceHandler();
        test.startTest();
        ApexResultSet result =  WhatsAppService.process(mapChannelRequest);
        test.stopTest();
        System.assert(result != null, 'Result should not be null');
        system.assertEquals(true, result.isSuccess);
    }
    
    
     @isTest
    public static void processRequestNullMsgBodyTest(){
        
        Map<String, Object> mapChannelRequest = new Map<String, Object>();
        List<Account> accList = [Select Id, name From Account];
        List<Contact> contactRecordsList = [Select Id, name, Phone From Contact limit 2];
        List<Template__c> templateList = [Select Id, Name From Template__c];
        List<WhatsApp_Template__c> whtasAppTemplateList = [Select Id,Message_Body__c, Name__c From WhatsApp_Template__c];
        List<WhatsApp_Template__c> whatsAppTempUpdate = new List<WhatsApp_Template__c>();
        for(WhatsApp_Template__c wt : whtasAppTemplateList){
            wt.Template_Type__c = 'User Initiative';
            wt.Message_Body__c = '';
            whatsAppTempUpdate.add(wt);
        }
        update whatsAppTempUpdate;
        String myTemplateId = whtasAppTemplateList[0].Id;
        System.debug('myTemplateId == '+myTemplateId);
        List<String> recordIds = new List<String>();
        recordIds.add(contactRecordsList[0].Id);
        //mapChannelRequest.put('records', contactRecordsList);
        mapChannelRequest.put('recordIds', recordIds);
        mapChannelRequest.put('objectAPIName', 'Contact');
        mapChannelRequest.put('mobileFieldAPIName', 'Phone');
        mapChannelRequest.put('nameFieldAPIName', 'Name');
        mapChannelRequest.put('templateId', myTemplateId);
        mapChannelRequest.put('messageText', '');
        system.debug('mapChannelRequest'+mapChannelRequest);

        Test.setMock(HttpCalloutMock.class, new WhatsAppServiceHandlerMock());
        WhatsAppServiceHandler handler = new WhatsAppServiceHandler();
        test.startTest();
        ApexResultSet result =  WhatsAppService.process(mapChannelRequest);
        test.stopTest();
        System.assert(result != null, 'Result should not be null');
        system.assertEquals(true, result.isSuccess);
    }
    
/**
 * @ methodname             : processRequestNullTempTest.
 * @ author                 : Nikita Pawar.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : This method Test request of Null template.
 * @ return                 : none.
 */ 
/*    
    @isTest
    public static void processRequestNullTempTest(){
        
        Map<String, Object> mapChannelRequest = new Map<String, Object>();
        List<Account> accList = [Select Id, name From Account];
        List<Contact> contactRecordsList = [Select Id, name, Phone From Contact limit 2];
        String myTemplateId = '' ;
        
        mapChannelRequest.put('records', contactRecordsList);
        mapChannelRequest.put('objectAPIName', 'Account');
        mapChannelRequest.put('mobileFieldAPIName', 'Phone');
        mapChannelRequest.put('nameFieldAPIName', 'Name');
        mapChannelRequest.put('templateId', myTemplateId);
        mapChannelRequest.put('messageText', '');
       
        ApexResultSet result =new ApexResultSet();
        Test.setMock(HttpCalloutMock.class, new WhatsAppServiceHandlerMock());
        WhatsAppServiceHandler handler = new WhatsAppServiceHandler();
        test.startTest();
        try{
        result =  WhatsAppService.process(mapChannelRequest);
            
        }catch(Exception e){
            System.debug('Test Fail');
        }
        test.stopTest();
        
        System.assertEquals(null , result.data);
    }*/

/**
 * @ methodname             : processResponseTest.
 * @ author                 : Nikita Pawar.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : This method Test the process reason.
 * @ return                 : none.
 */      
     @isTest
    public static void processResponseTest(){
        test.startTest();
        WhatsAppServiceHandler handler = new WhatsAppServiceHandler();
        handler.processResponse();
        test.stopTest();
        System.assertNotEquals(null,handler);
    }
}