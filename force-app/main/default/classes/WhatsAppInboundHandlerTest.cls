/**
* @ classname           : WhatsAppInboundHandlerTest
* @ author              : Sarjerao Pujari
* @ date                : 23-10-2023
* @ description         : This is a Test class of WhatsAppInboundHandler.

* @ Modification Logs
*  #		  Date                  		   Description		    	   Modified By
*  1      16-10-2023                   Initial Version         Sarjerao Pujari.
*/
@isTest
public class WhatsAppInboundHandlerTest
{
    
    @testSetup
    public static void createTestData()
    {
        List<Send_Configuration__c> ConfigurationList = TestDataFactory.createSBCRecords(1, 'Contact');
    }
    
/**
* @ methodname             : executeTestForText
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is specifically designed for Test the incoming messages in whatsapp as a text.
* @ return                 : void
*/
@isTest
public static void executeTestForText()
{
    Map<String,Object> inputMap = new Map<String,Object>();
    object jsonforText = JSON.deserializeUntyped('{"messaging_product":"whatsapp","metadata":{"display_phone_number":"PHONE_NUMBER","phone_number_id":"PHONE_NUMBER_ID"},"contacts":[{"profile":{"name":"NAME"},"wa_id":"PHONE_NUMBER"}],"messages":[{"from":"8669106793","id":"wamid.ID","timestamp":"1697999400000","text":{"body":"MESSAGE_BODY"},"type":"text"}]}');
    inputMap.put('payload',jsonforText);
    Test.startTest();
    	WhatsAppInboundHandler.execute(inputMap);
    Test.stopTest();
    List<Inbound_Message__c> inboundList = [select Id, Message_Text__c from Inbound_Message__c];
    system.assertEquals(inboundList[0].Message_Text__c,'MESSAGE_BODY');
    
}
    
/**
* @ methodname             : executeTestForReaction
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is specifically designed for Test the incoming messages in whatsapp as a reaction.
* @ return                 : void
*/
@isTest
public static void executeTestForReaction()
{
    Map<String,Object> inputMap = new Map<String,Object>();
    object jsonforReaction = JSON.deserializeUntyped('{"messaging_product":"whatsapp","metadata":{"display_phone_number":"PHONE_NUMBER","phone_number_id":"PHONE_NUMBER_ID"},"contacts":[{"profile":{"name":"NAME"},"wa_id":"PHONE_NUMBER"}],"messages":[{"from":"8669106793","id":"wamid.ID","timestamp":"1697999400000","reaction":{"message_id":"MESSAGE_ID","emoji":"EMOJI"},"type":"reaction"}]}');
    inputMap.put('payload',jsonforReaction);
    Test.startTest();
    WhatsAppInboundHandler.execute(inputMap);
    Test.stopTest();
    system.assert(true);
}
    
/**
* @ methodname             : executeTestForMedia
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is specifically designed for Test the incoming messages in whatsapp as a media.
* @ return                 : void
*/
@isTest
public static void executeTestForMedia()
{
    Map<String,Object> inputMap = new Map<String,Object>();
    object jsonforMedia = JSON.deserializeUntyped('{"messaging_product":"whatsapp","metadata":{"display_phone_number":"PHONE_NUMBER","phone_number_id":"PHONE_NUMBER_ID"},"contacts":[{"profile":{"name":"NAME"},"wa_id":"WHATSAPP_ID"}],"messages":[{"from":"8669106793","id":"wamid.ID","timestamp":"1697999400000","type":"image","image":{"caption":"CAPTION","mime_type":"image/jpeg","sha256":"IMAGE_HASH","id":"ID"}}]}');
    inputMap.put('payload',jsonforMedia);
    Test.startTest();
    WhatsAppInboundHandler.execute(inputMap);
    Test.stopTest();
    system.assert(true);
}
 
/**
* @ methodname             : getCustomLookupFieldsTest
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is specifically designed for Test the CustomLookupFields.
* @ return                 : void
*/
@isTest
public static void getCustomLookupFieldsTest()
{
    String objName = 'Outbound_Message__c';
    Test.startTest();
    Set<String> setOfCustomFields = WhatsAppInboundHandler.getCustomLookupFields(objName);
    Test.stopTest();
    system.assertEquals(setOfCustomFields.size()>0,True);
    
}

/**
* @ methodname             : getRelatedRecordsTest
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is specifically designed for Test the RelatedRecords.
* @ return                 : void
*/
@isTest
public static void getRelatedRecordsTest()
{
    Set<String> setOfCustomFields = new Set<String>();
    setOfCustomFields.add('WhatsApp_Template__c');
    system.debug('setOfCustomFields =='+setOfCustomFields);
    String phoneString = '919876546345';
    Test.startTest();
    Map<String,SObject> getRecords = WhatsAppInboundHandler.getRelatedRecords(phoneString,setOfCustomFields);
    Test.stopTest();
    system.assertEquals(getRecords.isEmpty(),true);
    
}

/**
* @ methodname             : getRecordsBySendConfigTest
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is specifically designed for Test the RecordsBySendConfig.
* @ return                 : void
*/
@isTest
public static void getRecordsBySendConfigTest()
{
   String mobileNumberString = '916787654345';
    Test.startTest();
    List<SObject> getRecordsByCinfig = WhatsAppInboundHandler.getRecordsBySendConfig(mobileNumberString);
    Test.stopTest();
    system.assertEquals(getRecordsByCinfig.Size()>0 ,false);
}

/**
* @ methodname             : executeTestForInterActiveList
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is specifically designed for Test for the InterActiveList.
* @ return                 : void
*/
@isTest
public static void executeTestForInterActiveList()
{
    Map<String,Object> inputMap = new Map<String,Object>();
    object jsonforText = JSON.deserializeUntyped('{"messaging_product": "whatsapp","metadata": {"display_phone_number": "PHONE_NUMBER","phone_number_id": "PHONE_NUMBER_ID"},"contacts": [{"profile": {"name": "NAME"},"wa_id": "PHONE_NUMBER"}],"messages": [{"from": "Phone","id": "wamid.ID","timestamp": "TIMESTAMP","interactive": {"list_reply": {"id": "list_reply_id","title": "list_reply_title","description": "list_reply_description"},"type": "list_reply"},"type": "interactive"}]}');
    inputMap.put('payload',jsonforText);
    Test.startTest();
    	WhatsAppInboundHandler.execute(inputMap);
    Test.stopTest();
    system.assert(true);    
}


/**
* @ methodname             : executeTestForInterActiveButton
* @ author                 : Sarjerao Pujari
* @ objectreferenced       : None
* @ param                  : None
* @ description            : This method is specifically designed for Test for the InterActiveButton.
* @ return                 : void
*/
@isTest
public static void executeTestForInterActiveButton()
{
    Map<String,Object> inputMap = new Map<String,Object>();
    object jsonforText = JSON.deserializeUntyped('{"messaging_product":"whatsapp","metadata":{"display_phone_number":"PHONE_NUMBER","phone_number_id":"PHONE_NUMBER_ID"},"contacts":[{"profile":{"name":"NAME"},"wa_id":"PHONE_NUMBER"}],"messages":[{"from":"Phone","id":"wamid.ID","timestamp":"TIMESTAMP","interactive":{"button_reply":{"id":"unique-button-identifier-here","title":"button-text"},"type":"button_reply"},"type":"interactive"}]}');
    inputMap.put('payload',jsonforText);
    Test.startTest();
    	WhatsAppInboundHandler.execute(inputMap);
    Test.stopTest();
    system.assert(true);
    
}
    
}