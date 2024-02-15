/**  @classname    : SendBulkMessageBatchService
  *  @author       : Rati Kulkarni
  *  @date         : 21-Oct-2023
  *  @description  : class representing Service to perform batch specific post callout oprations like get success and failure count.
  *  @version      : 1.0
*/
public with sharing class SendBulkMessageBatchService {

    /**
   * @methodname		         processData
   * @author				     Rati Kulkarni
   * @objectreferenced	         IChannelService,Outbound_Message__c
   * @params				     Map<String,Object>
   * @description			     method to call WhatsApp message send method and calculate success and failure count of messages sent.
   * @return				     Map<String,Object>
   */
public static Map<String,Integer> processData (Map<String,Object> mapParameters){
    // call WhatsAppService to send bulk data recieved from batch
    system.debug('@@ inside processdata');
  ApexResultSet resultSet = new ApexResultSet();
  String channelName = String.valueOf(mapParameters.get('channel'));
    system.debug('@@ channelName '+channelName);
  map<String,Channel__mdt> mapChannels = (map<String,Channel__mdt>) Utility.getAllChannelsMap();
    system.debug('@@ mapChannels '+mapChannels);
  Channel__mdt channel = mapChannels.get(channelName);
    system.debug('@@ channel '+channel);
  Map<String,Integer> mapSuccessFailure = new Map<String,Integer>();
  if(channel != null ){
    IChannelService whatsAppService = (IChannelService)Type.forName(channel.Service_Class__c).newInstance();
    resultSet = whatsAppService.process(mapParameters);
    
    System.debug('@@ resultSet =='+resultSet);

    //get Outboundmessages from resultset   
    Map<String,Object> mapResult = (Map<String,Object>)resultSet.data;
    System.debug('@@ mapResult =='+mapResult);
    List<Outbound_Message__c> outboundMessages = (List<Outbound_Message__c>)mapResult.get('outboundMessages');
    system.debug('@@ outboundMessages '+outboundMessages.size());
    // initialise count
    integer successCount =0;
    integer failCount = 0;
    // get success and failure count of messages
    for(Outbound_Message__c objOutboundMessage : outboundMessages){
      system.debug('@@ objOutboundMessage.External_ID__c '+objOutboundMessage.External_ID__c);
      if(String.isBlank(objOutboundMessage.External_ID__c)){
        system.debug('@@ inside if 41');
        if(mapSuccessFailure.containsKey('failCount')){
          system.debug('@@ inside if 43');
          failCount = 1 + mapSuccessFailure.get('failCount');
          mapSuccessFailure.put('failCount',failCount);
          system.debug('failCount =='+failCount);

          system.debug('mapSuccessFailure if #='+mapSuccessFailure);
        }else{
          system.debug('@@ else 49');
          mapSuccessFailure.put('failCount',1);
          system.debug('mapSuccessFailure @@ =='+mapSuccessFailure);
        }
      }else{
        system.debug('@@ inside else');
        if(mapSuccessFailure.containsKey('successCount')){
          successCount = 1 + mapSuccessFailure.get('successCount');
          mapSuccessFailure.put('successCount',successCount);
          system.debug('mapSuccessFailure ** ='+mapSuccessFailure);
        }else{
          mapSuccessFailure.put('successCount',1);
          system.debug('mapSuccessFailure $$ ='+mapSuccessFailure);
        }
      }
    }
    }
    // return map of success and failure count.
    system.debug('@@ mapSuccessFailure ##'+mapSuccessFailure);
    return mapSuccessFailure;
  }
}