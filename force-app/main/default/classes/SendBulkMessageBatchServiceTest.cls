/* 
 * @ classname          : SendBulkMessageBatchServiceTest 
 * @ author             : Rati Kulkarni.
 * @ date               : 03-Nov-2023
 * @ description        : class for test the Service to perform batch specific post callout oprations like get success and failure count..
 
 * @ modificationlog
 * 1.
 */
@isTest
public class SendBulkMessageBatchServiceTest {

/**
 * @ methodname             : processDataTest.
 * @ author                 : Rati Kulkarni. 
 * @ ObjectReferenced       : None.
 * @ param                  : None.
 * @ description            : method to test the WhatsApp message send method and calculate success and failure count of messages sent.
 * @ return                 : None. 
 */
    @isTest
    public static void processDataTest(){
        Map<String,Object> inputData = TestDataFactory.getChannelRequestMap();
        Test.setMock(HttpCalloutMock.class, new SendBulkMessageBatchServiceMock());
        List<Send_Configuration__c> sbcList = TestDataFactory.createSBCRecords(1, 'Contact');
        Test.startTest();
       	Map<String,Integer> processedData = SendBulkMessageBatchService.processData(inputData);
        Integer failCount = (Integer)processedData.get('failCount');
        System.assertEquals(failCount, null);
        Test.stopTest();
    }
}