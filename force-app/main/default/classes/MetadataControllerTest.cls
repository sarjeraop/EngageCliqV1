/* 
 * @ classname          : MetadataControllerTest 
 * @ author             : Sarjerao Pujari.
 * @ date               : 28-Jan-2024
 * @ description        : This class with @isTest anotation is used to test the metadataController.
 
 * @ modificationlog
 * 1.
 */
@isTest
public class MetadataControllerTest
{
    
/**
 * @ methodname             : getMetadataTest.
 * @ author                 : Sarjerao Pujari. 
 * @ ObjectReferenced       : Channel_Configuration__mdt.
 * @ param                  : None.
 * @ description            : This method is used to test the getMetadata method.
 * @ return                 : List. 
 */
@isTest
public static void getMetadataTest()
{
  
  Test.startTest();
    List<Channel_Configuration__mdt> channelConfigList = metadataController.getMetadata();
  Test.stopTest();
  system.debug('size of list === '+channelConfigList.size());
  boolean isNotEmpty ;
   if(channelConfigList.size() > 0)
   {
       isNotEmpty = true;
   }else
   {
       isNotEmpty = false;
   }
  system.assertEquals(channelConfigList.size()>0,isNotEmpty);
} 

       
/**
 * @ methodname             : createMetadataRecordTest.
 * @ author                 : Sarjerao Pujari. 
 * @ ObjectReferenced       : Channel_Configuration__mdt.
 * @ param                  : None.
 * @ description            : This method is used to test the getMetadata createMetadataRecord.
 * @ return                 : List. 
 */
@isTest
public static void createMetadataRecordTest()        
{
    Channel_Configuration__mdt objChannelConfig = new Channel_Configuration__mdt();
    objChannelConfig.API_key__c = '897';
    objChannelConfig.Business_ID__c = '897';
    objChannelConfig.PhoneNo_Id__c = '897';
    objChannelConfig.DeveloperName = 'Slack8';
    objChannelConfig.Endpoint_URL__c = 'slack.com';
    Test.startTest();
    	metadataController.createMetadataRecord(objChannelConfig);
    Test.stopTest();
    List<Channel_Configuration__mdt> channelConfigList = [SELECT Id FROM Channel_Configuration__mdt];
    system.assertEquals(channelConfigList.size()>0, true);
}

}