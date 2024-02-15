/*
 *  @classname  		: WhatsAppServiceTest
 *  @author 			: Nikita pawar
 *  @ param             : none
 *  @description  		: Class to test the processing of message sending though WhatsApp.

 *  @modificationlog
 *  	#		Date				 Description				Modified By
 *		1.	    22-12-2023			 Added Comments			    sarjerao Pujari
*/
@isTest
public class WhatsAppServiceTest {

/**
 * @ methodname             : testProcessMethod.
 * @ author                 : Nikita Pawar.
 * @ ObjectReferenced       : Account,Contact,Template__c,WhatsApp_Template__c,Send_Configuration__c.
 * @ param                  : none.
 * @ description            : This method Test the message sending process of WhatsApp channel.
 * @ return                 : none.
 */    
    @isTest
    static void testProcessMethod() {
        Map<String, Object> mapChannelRequest = new Map<String, Object>();

        List<Account> accList = TestDataFactory.getAccounts(2, true);
        List<Contact> contactRecordsList = TestDataFactory.getAccountContacts(10, accList[0].Id, true);
        List<Template__c> templateList = TestDataFactory.createTemplate(5, true);
        List<WhatsApp_Template__c> whtasAppTemplateList = TestDataFactory.createWhatsAppTemplate(templateList[0].Id, 5, true);
        List<Send_Configuration__c> sbc = TestDataFactory.createSBCRecords(1, 'Contact');
        String myTemplateId = whtasAppTemplateList[0].Id;
        List<String> recordIds = new List<String>();
        recordIds.add(contactRecordsList[0].Id);
        mapChannelRequest.put('recordIds', recordIds);
        mapChannelRequest.put('records', contactRecordsList);
        mapChannelRequest.put('objectAPIName', 'Contact');
        mapChannelRequest.put('mobileFieldAPIName', 'Phone');
        mapChannelRequest.put('nameFieldAPIName', 'Name');
        mapChannelRequest.put('templateId', myTemplateId);
        mapChannelRequest.put('messageText', 'Hello Good Morning');

        Test.setMock(HttpCalloutMock.class, new WhatsAppServiceMock());

        WhatsAppServiceHandler handler = new WhatsAppServiceHandler();
        Test.startTest();
        ApexResultSet result =  WhatsAppService.process(mapChannelRequest);
        handler.init(mapChannelRequest);
        Test.stopTest();
           
        System.assert(result != null, 'Result should not be null');
        system.assertEquals(true, result.isSuccess);

    }
    
}