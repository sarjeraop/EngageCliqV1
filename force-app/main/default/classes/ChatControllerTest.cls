/*
 * @ classname          : ChatControllerTest.
 * @ author             : Sarjerao Pujari.
 * @ date               : 23-Oct-2023
 * @ description        : ChatControllerTest Class with @isTest Annotation is designed to Test the ChatController Class.

 * @ modificationlog
 * 1.Sarjerao Pujari       20-Nov-2023        Add Code Comments
 */
@isTest
public class ChatControllerTest
{

/**
* @ methodname             : initialiseTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : None.
* @ description            : Test the Constructor to check whether user has permission to perform Chat Feature.
* @ return                 : None.
*/
@isTest
public static void initialiseTest()
{
  try
  {
    Test.startTest();
		ChatController.initialise();
    Test.stopTest();
  }
  catch(Exception ex)
  {
    system.assertEquals(ex.getmessage(),'true');
  }
}

/**
* @ methodname             : getActiveChannelTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : None.
* @ description            : This method is to Test the getActiveChannel method which gives all active Channels.
* @ return                 : None.
*/
@isTest
public static void getActiveChannelTest()
{
  ApexResultSet resultSet = new ApexResultSet();
	Test.startTest();
	resultSet.data = ChatController.getActiveChannel();
  Test.stopTest();
  List<Channel__mdt> activeChannelsList = [SELECT Id, Active__c, Channel__c FROM Channel__mdt WHERE Active__c = true limit 1];
  string channelName = activeChannelsList[0].Channel__c;
  system.assertEquals(resultSet.isSuccess, true);
}

/**
* @ methodname             : chatMessageSendTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : map<String,Object>.
* @ description            : This method is to Test the chatMessageSend method  which is used to redirects to prepare message as per Channel.
* @ return                 : None.
*/
@isTest
public static void chatMessageSendTest()
{
  string channelName;
  map<String,Object> mapChannels = (map<String,Object>)TestDataFactory.createChannelMap();
  channelName = string.valueOf(mapChannels.get('channel'));
    List<Send_Configuration__c> sbc = TestDataFactory.createSBCRecords(1, 'Contact');
    ApexResultSet result = new ApexResultSet();
  Test.setMock(HttpCalloutMock.class, new ChatControllerMock());
  Test.startTest();
  result = ChatController.chatMessageSend(mapChannels);
  Test.stopTest();
  system.assertNotEquals(result.data,null);
}

    @isTest
    public static void chatMessageSendNullChannelTest()
    {
        List<Contact> contactList = TestDataFactory.createContacts(1);
        map<string,object> ChannelMap = new map<string,object>();
        ChannelMap.put('records',contactList);
        ChannelMap.put('channel',' ');
        ChannelMap.put('objectAPIName','Contact');
        ChannelMap.put('messageText','Hello World');
        ChannelMap.put('mobileFieldAPIName','phone');
        ApexResultSet result = new ApexResultSet();
        Test.setMock(HttpCalloutMock.class, new ChatControllerMock());
        Test.startTest();
        result = ChatController.chatMessageSend(ChannelMap);
        Test.stopTest();
        system.assertEquals(result.isSuccess,false);
    }

/**
* @ methodname             : conversationDataTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the conversationData method  which is used to find conversation record based on recordId.
* @ return                 : None.
*/
@isTest
public static void conversationDataTest()
{
  TestDataFactory.createInboundRecords();
    List<Account> accList = TestDataFactory.getAccounts(2, true);
    List<Contact> contactRecordsList = TestDataFactory.getAccountContacts(10, accList[0].Id, true);
    List<Template__c> templateList = TestDataFactory.createTemplate(5, true);
    List<WhatsApp_Template__c> whtasAppTemplateList = TestDataFactory.createWhatsAppTemplate(templateList[0].Id, 5, true);
    List<Outbound_Message__c> getOutboundMsg = TestDataFactory.createOutboundMessage(whtasAppTemplateList[0].Id, contactRecordsList[0].Id, 10, true);
    List<Send_Configuration__c> sbc = TestDataFactory.createSBCRecords(1, 'Contact');

  string channelName = 'WhatsApp';
  List<Contact> conList = TestDataFactory.createContacts(1);
  string recId = conList[0].id;
  TestDataFactory.createConversationData(recId);
  Test.StartTest();
  ChatController.conversationData(recId,channelName);

  Test.StopTest();
}

/**
* @ methodname             : contentDocumentFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the contentDocumentFinder method  which is used to find ContentDistribution record based on recordId.
* @ return                 : None.
*/
@isTest
public static void contentDocumentFinderTest()
{
  string docId = TestDataFactory.createDocumentData();
  Test.StartTest();
  ContentDistribution doc = ChatController.contentDocumentFinder(docId);
  Test.StopTest();
  system.assertEquals(doc,null);
}

/**
* @ methodname             : pdficonFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the pdficonFinder method which is used to  get lightning icon of pdf type.
* @ return                 : None.
*/
@isTest
public static void pdficonFinderTest()
{
  string type = 'pdf';
  Test.StartTest();
  string iconName = ChatController.iconFinder(type);
  Test.StopTest();
  system.assertEquals(iconName,'doctype:pdf');
}

/**
* @ methodname             : ppticonFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the pdficonFinder method which is used to  get lightning icon of ppt type.
* @ return                 : None.
*/
@isTest
public static void ppticonFinderTest()
{
  string type = 'ppt';
  Test.StartTest();
  string iconName = ChatController.iconFinder(type);
  Test.StopTest();
  system.assertEquals(iconName,'doctype:ppt');
}

/**
* @ methodname             : xlsiconFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the pdficonFinder method which is used to  get lightning icon of xls type.
* @ return                 : None.
*/
@isTest
public static void xlsiconFinderTest()
{
  string type = 'xls';
  Test.StartTest();
  string iconName = ChatController.iconFinder(type);
  Test.StopTest();
  system.assertEquals(iconName,'doctype:excel');
}

/**
* @ methodname             : csviconFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the pdficonFinder method which is used to  get lightning icon of csv type.
* @ return                 : None.
*/
@isTest
public static void csviconFinderTest()
{
  string type = 'csv';
  Test.StartTest();
  string iconName = ChatController.iconFinder(type);
  Test.StopTest();
  system.assertEquals(iconName,'doctype:csv');
}

/**
* @ methodname             : txticonFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the pdficonFinder method which is used to  get lightning icon of txt type.
* @ return                 : None.
*/
@isTest
public static void txticonFinderTest()
{
  string type = 'txt';
  Test.StartTest();
  string iconName = ChatController.iconFinder(type);
  Test.StopTest();
  system.assertEquals(iconName,'doctype:txt');
}

/**
* @ methodname             : dociconFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the pdficonFinder method which is used to  get lightning icon of doc type.
* @ return                 : None.
*/
@isTest
public static void dociconFinderTest()
{
  string type = 'doc';
  Test.StartTest();
  string iconName = ChatController.iconFinder(type);
  Test.StopTest();
  system.assertEquals(iconName,'doctype:word');
}

/**
* @ methodname             : docxiconFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the pdficonFinder method which is used to  get lightning icon of docx type.
* @ return                 : None.
*/
@isTest
public static void docxiconFinderTest()
{
  string type = 'docx';
  Test.StartTest();
  string iconName = ChatController.iconFinder(type);
  Test.StopTest();
  system.assertEquals(iconName,'doctype:word');
}

/**
* @ methodname             : jpgxiconFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the pdficonFinder method which is used to  get lightning icon of jpg type.
* @ return                 : None.
*/
@isTest
public static void jpgxiconFinderTest()
{
  string type = 'jpg';
  Test.StartTest();
  string iconName = ChatController.iconFinder(type);
  Test.StopTest();
  system.assertEquals(iconName,'doctype:image');
}

/**
* @ methodname             : gpxiconFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the pdficonFinder method which is used to  get lightning icon of 3gp type.
* @ return                 : None.
*/
@isTest
public static void gpxiconFinderTest()
{
  string type = '3gp';
  Test.StartTest();
  string iconName = ChatController.iconFinder(type);
  Test.StopTest();
  system.assertEquals(iconName,'doctype:video');
}

/**
* @ methodname             : sbcRecordFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the sbcRecordFinderTest method which is used to  send button configuration record based on objectApiName.
* @ return                 : None.
*/
@isTest
public static void sbcRecordFinderTest()
{
  List<Send_Configuration__c> sbc = TestDataFactory.createSBCRecords(1, 'Contact');
  string objName = sbc[0].Object_Name__c;
  ApexResultSet resultSet = new ApexResultSet();
  Test.StartTest();
  resultSet.data = ChatController.sbcRecordFinder(objName);
  Test.StopTest();
  system.assertEquals(resultSet.isSuccess,true);
}
    
 /**
* @ methodname             : sbcRecordFinderNullTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string.
* @ description            : This method is to Test the sbcRecordFinderTest method which is used to  send button configuration record based on objectApiName.
* @ return                 : None.
*/
@isTest
public static void sbcRecordFinderNullTest()
{
  List<Send_Configuration__c> sbc = TestDataFactory.createSBCRecords(1, 'Contact');
  string objName = Null;
  ApexResultSet resultSet = new ApexResultSet();
  Test.StartTest();
  resultSet.data = ChatController.sbcRecordFinder(objName);
  Test.StopTest();
  system.assertEquals(resultSet.isSuccess,true);
}

/**
* @ methodname             : recordDetailFinderTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : string,string,string.
* @ description            : This method is to Test the recordDetailFinder method which is used to  get list of record based on param.
* @ return                 : None.
*/
@isTest
public static void recordDetailFinderTest()
{
  list<Contact> conList = TestDataFactory.createContacts(1);
  string recId = conList[0].id;
  List<Send_Configuration__c> sbc = TestDataFactory.createSBCRecords(1, 'Contact');
  ApexResultSet resultSet = new ApexResultSet();
  string objName = sbc[0].Object_Name__c;
  string queryField = sbc[0].Phone_Fields__c;
  Test.StartTest();
  resultSet.data = ChatController.recordDetailFinder(recId,objName,queryField);

  Test.StopTest();
  system.assertEquals(resultSet.isSuccess,true);
}

    @isTest
    public static void recordDetailFinderExcTest()
    {
        list<Contact> conList = TestDataFactory.createContacts(1);
        string recId = conList[0].id;
        List<Send_Configuration__c> sbc = TestDataFactory.createSBCRecords(1, 'Contact');
        ApexResultSet resultSet = new ApexResultSet();
        string objName = 'ABC';
        string queryField = sbc[0].Phone_Fields__c;
        Test.StartTest();
        resultSet.data = ChatController.recordDetailFinder(recId,objName,queryField);
        Test.StopTest();
    }

/**
* @ methodname             : convertObjectListToSObjectListTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : map<String,Object>.
* @ description            : This method is to Test the convertObjectListToSObjectList method which is used to convert object into SObject list and call ChatController.
* @ return                 : None.
*/
/*
@isTest
public static void convertObjectListToSObjectListTest()
{
  map<String,Object> mapChannels = (map<String,Object>)TestDataFactory.createChannelMap();
  Test.StartTest();
  ApexResultSet resultSet = ChatController.convertObjectListToSObjectList(mapChannels);
  Test.StopTest();
  system.assertEquals(resultSet.isSuccess,true);
}
*/
/**
* @ methodname             : MessageListWrapperTest.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : None.
* @ param                  : None.
* @ description            : This method is to Test the MessageListWrapper method which is used for conversation data which is used to show on chat screen.
* @ return                 : None.
*/
@isTest
public static void MessageListWrapperTest()
{
	ChatController.MessageListWrapper msgWrapper = new ChatController.MessageListWrapper();
  //Conversation__c conObj = new Conversation__c();
  //msgWrapper.message = conObj;
  msgWrapper.isInbound = true;
  msgWrapper.isActive = true;
  msgWrapper.isMedia = true;
  msgWrapper.mediaName = 'WhatsApp';
  msgWrapper.mediaType = 'Media Type';
  msgWrapper.mediaUrl = 'media URL';
}
}