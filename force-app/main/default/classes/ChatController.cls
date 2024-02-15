/**  @classname    : ChatController
  *  @author       : Rati Kulkarni
  *  @date         :
  *  @description  : class representing Chat Controller to perform channel wise Chat request.
  *  @version      : 1.0
*/

public with sharing class ChatController {
 /**
   * @methodname		         Initialise
   * @author				     Rati Kulkarni
   * @objectreferenced	         SecurityService
   * @params				     None
   * @description			     Constructor to check whether user has permission to perform Chat Feature.
   * @return				     If will return whether User has Permissions or not.
   */
    @AuraEnabled
    public static ApexResultSet initialise() {
        // Check Whether user has access to required objects to perform chat feature.
        ApexResultSet apexResult = new ApexResultSet();
        try{
            List<String> outboundMessageFieldsList = new List<String>{'Channel__c','Message_Text__c','Mobile__c','WhatsApp_Template__c','External_ID__c','FailedTime__c','Failure_Reason__c','Media__c'};
            SecurityService.checkInsertable('Outbound_Message__c',OutboundMessageFieldsList);
            apexResult.isSuccess = true;
        }catch(Exception ex){
            apexResult.isSuccess = false;
            apexResult.message = ex.getMessage();
            ApplicationLogger.logException(ex);
        }
        return apexResult;
    }

 /**
   * @methodname		        : getActiveChannel
   * @author				        : Suhas
   * @objectreferenced	    : None
   * @params				        : None
   * @description			      : This method provides list of channels those are active.
   * @return				        : Object
   */
    @AuraEnabled
    public static ApexResultSet getActiveChannel(){
      ApexResultSet resultSet = new ApexResultSet();
       try{
      resultSet.data = Utility.getAllChannelsMap();
       }
       catch(Exception ex){
        resultSet.isSuccess = false;
        resultSet.message = ex.getMessage();
        ApplicationLogger.logException(ex);
    }
    return resultSet;
    }


     /**
   * @methodname		        : getSessionId
   * @author				        : Suhas
   * @objectreferenced	    : None
   * @params				        : None
   * @description			      : This method provide current user sesssion Id.
   * @return				        : String
   */
  @AuraEnabled(cacheable=true)
  public static Object getSessionId(){
      return Utility.getSessionId();
  }

 /**
   * @methodname			chatMessageSend
   * @author				Rati Kulkarni
   * @objectreferenced	    IChannelService,ApexResultSet
   * @params				Map<String,Object>
   * @description			This method redirects to prepare message as per Channel.
   * @return
   */
    @AuraEnabled
    public static ApexResultSet chatMessageSend(Map<String,Object> mapChannelRequest){
        String channelName;
        List<String> recordIds = new List<String>();
        ApexResultSet resultSet = new ApexResultSet();
        recordIds.add(String.valueOf(mapChannelRequest.get('recordId')));
        
        try {
      		channelName = String.valueOf(mapChannelRequest.get('channel'));
            map<String,Channel__mdt> mapChannels = (map<String,Channel__mdt>) Utility.getAllChannelsMap();
            Channel__mdt channel = mapChannels.get(channelName);
                if(channel != null ){
                  
                    mapChannelRequest.put('recordIds',recordIds);
                 
                    IChannelService whatsAppService = (IChannelService)Type.forName(channel.Service_Class__c).newInstance();
                    resultSet = whatsAppService.process(mapChannelRequest);
                }else{
                    resultSet.isSuccess = false;
                    resultSet.message = System.Label.channel_not_created;
                }

            } catch (Exception e) {
              resultSet.isSuccess= false;
              resultSet.message= e.getMessage();
              ApplicationLogger.logException(e);
            }
        
            
        return resultSet;
    }

/** @methodname         : conversationData
 * @author              : Suhas Mankar
 * @objectreferenced    : Conversation__c, Outbound_Communication_Message__c, Inbound_Communication_Message__c
 * @param               : Id
 * @description         : This method is used to find conversation record based on recordId
 * @return              : List<MessageListWrapper>
 */

@AuraEnabled(Cacheable = true)
public static List<MessageListWrapper> conversationData(Id recId, String channel){

  List<MessageListWrapper> listMessageWrapper = new List<MessageListWrapper>();
  List<Conversation__c> conversationList = new List<Conversation__c>();

    conversationList = [SELECT CreatedDate,Inbound_Communication_Message__r.Message_Text__c,Inbound_Communication_Message__r.Mobile__c,
                        Inbound_Communication_Message__r.Owner.Name, Inbound_Communication_Message__r.CreatedDate,
                        Outbound_Communication_Message__r.Message_Text__c, Outbound_Communication_Message__r.Owner.Name,
                        Outbound_Communication_Message__r.CreatedDate, Outbound_Communication_Message__r.Mobile__c,
                        Outbound_Communication_Message__r.Media__c,Outbound_Communication_Message__r.SentTime__c,
                        Outbound_Communication_Message__r.FailedTime__c, Outbound_Communication_Message__r.ReadTime__c,
                        Outbound_Communication_Message__r.DeliveredTime__c, Related_To__c
                        FROM Conversation__c
                        WHERE Related_To__c =: recId
                        AND (Outbound_Communication_Message__r.Channel__c  =: channel OR Inbound_Communication_Message__r.Channel__c =: channel)
                        AND (Inbound_Communication_Message__c != null OR Outbound_Communication_Message__c != null)
                        WITH USER_MODE  Order By CreatedDate];

      for (Conversation__c objMsg : conversationList) {
            MessageListWrapper objWrapper = new MessageListWrapper();
            objWrapper.isInbound = false;
            objWrapper.isActive = false;
            datetime dt = System.now()-1;
            InboundOutBoundWrapper inOutMessage = new InboundOutBoundWrapper();
            InboundWrapper inBound = new InboundWrapper();
            OutBoundWrapper outBound = new OutBoundWrapper();
            if(objMsg.Outbound_Communication_Message__c != null) {
                if(objMsg.Outbound_Communication_Message__r.Message_Text__c != null)
                  outBound.msg = objMsg.Outbound_Communication_Message__r.Message_Text__c;
                if(objMsg.Outbound_Communication_Message__r.Mobile__c != null)
                  outBound.mobile= objMsg.Outbound_Communication_Message__r.Mobile__c;
                  outBound.ownerName = objMsg.Outbound_Communication_Message__r.Owner.Name;
                if(objMsg.Outbound_Communication_Message__r.FailedTime__c != null)
                  outBound.failedTime = objMsg.Outbound_Communication_Message__r.FailedTime__c;
                if(objMsg.Outbound_Communication_Message__r.ReadTime__c != null)
                  outBound.readTime = objMsg.Outbound_Communication_Message__r.ReadTime__c;
                if(objMsg.Outbound_Communication_Message__r.DeliveredTime__c != null)
                  outBound.deliveredTime = objMsg.Outbound_Communication_Message__r.DeliveredTime__c;
                if(objMsg.Outbound_Communication_Message__r.SentTime__c != null)
                  outBound.sentTime = objMsg.Outbound_Communication_Message__r.SentTime__c;
                }

            if(objMsg.Inbound_Communication_Message__c != null) {
                objWrapper.isInbound = true;
                if(objMsg.Inbound_Communication_Message__r.Message_Text__c != null)
                inBound.msg = objMsg.Inbound_Communication_Message__r.Message_Text__c;
                if(objMsg.Inbound_Communication_Message__r.Mobile__c != null)
                inBound.mobile= objMsg.Inbound_Communication_Message__r.Mobile__c;
                if(objMsg.Inbound_Communication_Message__r.CreatedDate != null)
                inBound.createddate = objMsg.Inbound_Communication_Message__r.CreatedDate;
                inBound.ownerName = objMsg.Inbound_Communication_Message__r.Owner.Name;
                }


            if(objMsg.Inbound_Communication_Message__c != null){
                if(objMsg.Inbound_Communication_Message__r.CreatedDate != null && objMsg.Inbound_Communication_Message__r.CreatedDate > dt){
                    objWrapper.isActive = true;
                }
            }
            if(objMsg.Outbound_Communication_Message__r.Media__c  != null){
              outBound.media = objMsg.Outbound_Communication_Message__r.Media__c;
                objWrapper.isMedia = true;
                if(objMsg.Outbound_Communication_Message__r.Media__c.length() == 18){
                    ContentDistribution contentDistributionObject = new ContentDistribution();
                    contentDistributionObject = contentDocumentFinder(objMsg.Outbound_Communication_Message__r.Media__c);
                    if(contentDistributionObject != null){
                        objWrapper.mediaName = contentDistributionObject.ContentVersion.ContentDocument.Title;
                        objWrapper.mediaType = iconFinder(contentDistributionObject.ContentVersion.FileExtension);
                        objWrapper.mediaUrl = Constants.MEDIAURL+objMsg.Outbound_Communication_Message__r.Media__c;
                    }
                    else{
                        objWrapper.isMedia = false;
                    }
                }
            }else{
                objWrapper.isMedia = false;
            }
            inOutMessage.inBound = inBound;
            inOutMessage.id = objMsg.Id;
            inOutMessage.outBound = outBound;
            objWrapper.inOutMessage = inOutMessage;
            listMessageWrapper.add(objWrapper);

        }
    return listMessageWrapper;
   }


/** @methodname          : contentDocumentFinder
  * @author              : Suhas Mankar
  * @objectreferenced    : ContentDistribution
  * @param               : Id
  * @description         : This method is used to find ContentDistribution record based on recordId
  * @return              : ContentDistribution
  */
@AuraEnabled
public static ContentDistribution contentDocumentFinder(String recId){
    ContentDistribution contentDistributionObject = new ContentDistribution();
    List<ContentDistribution> dataList = new List<ContentDistribution>();

      dataList = [SELECT ContentDocumentId ,ContentVersion.FileExtension, ContentVersion.ContentDocument.Title
                  FROM ContentDistribution
                  WHERE ContentDocumentId  =:recId
                  WITH USER_MODE ];

      if (dataList.size() > 0) {
          // There are records in contentDistribution
          contentDistributionObject = dataList[0];
        }
        else{
            // There are no records in contentDistribution
            contentDistributionObject = null;
        }

          return contentDistributionObject;


}

/** @methodname        : iconFinder
* @author              : Suhas Mankar
* @objectreferenced    : None
* @param               : String
* @description         : This method is used to get lightning icon  based type
* @return              : String
*/
@AuraEnabled
public static string iconFinder(String type){
    String iconName = '';

    if (type == 'pdf') {
        iconName = 'doctype:pdf';
      }
      if (type == 'ppt') {
        iconName =  'doctype:ppt';
      }
      if (type == 'xls') {
        iconName =  'doctype:excel';
      }
      if (type == 'csv') {
        iconName = 'doctype:csv';
      }
      if (type == 'txt') {
        iconName =  'doctype:txt';
      }

      if (type == 'doc') {
        iconName =  'doctype:word';
      }
      if (type == 'docx') {
        iconName =  'doctype:word';
      }
      if (type == 'jpeg' || type == 'jpg' || type == 'png') {
        iconName =  'doctype:image';
      }

      if (type == '3gp' || type == 'mp4') {
        iconName =  'doctype:video';
      }

      return iconName;

}

/** @methodname          : sbcRecordFinder
  * @author              : Suhas Mankar
  * @objectreferenced    : Send_Configuration__c
  * @param               : String
  * @description         : This method is used to send button configuration record based on objectApiName
  * @return              : ApexResultSet
  */
@AuraEnabled
public static ApexResultSet sbcRecordFinder(String objName){
  ApexResultSet resultSet = new ApexResultSet();
    try {
      resultSet.data = Utility.getAllSendButtonConfigs(objName);
    } catch (Exception e) {
      resultSet.isSuccess= false;
      resultSet.message= e.getMessage();
      ApplicationLogger.logException(e);
    }
    return resultSet;
}

/** @methodname          : recordDetailFinder
  * @author              : Suhas Mankar
  * @objectreferenced    : SObject
  * @param               : Id, String, String
  * @description         : This method is used to get list of record based on param
  * @return              : ApexResultSet
  */
@AuraEnabled(Cacheable = true)
public static ApexResultSet recordDetailFinder(Id recId, String objName,String queryField ){
  Map<String,Object> queryBindValues = new Map<String, Object>{'recId'=>recId};
  ApexResultSet resultSet = new ApexResultSet();
    String query ='SELECT  {0} FROM {1} WHERE Id =: recId';
    List<String> queryVariables = new List<String>();
    queryVariables.add(String.escapeSingleQuotes(queryField));
    queryVariables.add(String.escapeSingleQuotes(objName));
    query = String.format(query, queryVariables);

    try {
      resultSet.data =  Database.queryWithBinds(query,queryBindValues,AccessLevel.USER_MODE);
    } catch (Exception e) {
      resultSet.isSuccess= false;
      resultSet.message= e.getMessage();
    }
    return resultSet;
}


/** @methodname          : convertObjectListToSObjectList
  * @author              : Suhas Mankar
  * @objectreferenced    : SObject
  * @param               : Map<String,Object>
  * @description         : This method is used convert object into SObject list and call ChatController.chatMessageSend method to send message
  * @return              : ApexResultSet
  */
    /*
@AuraEnabled
public static ApexResultSet convertObjectListToSObjectList(Map<String,Object> mapRequest) {
    List<SObject> sobjectList = new List<SObject>();
    ApexResultSet resultSet = new ApexResultSet();
    String query;
    Map<String,Object> queryBindValues = new Map<String, Object>{'recId'=>(String)mapRequest.get('recordId')};
    
    List<String> queryVariables = new List<String>();
    queryVariables.add(String.escapeSingleQuotes((String)mapRequest.get('mobileFieldAPIName')));
    queryVariables.add(String.escapeSingleQuotes((String)mapRequest.get('objectAPIName')));
    
    if (String.isNotBlank(String.valueOf(mapRequest.get('optField')))){
      query ='SELECT Id, {0} FROM {1} WHERE Id =: recId and {2} = false';
      queryVariables.add(String.escapeSingleQuotes((String)mapRequest.get('optField')));
    }else{
      query ='SELECT Id, {0} FROM {1} WHERE Id =: recId';
    }
   
    query = String.format(query, queryVariables);
    sobjectList = Database.queryWithBinds(query,queryBindValues,AccessLevel.USER_MODE);
    mapRequest.put('records', sobjectList);
    try {
      resultSet = chatMessageSend(mapRequest);

    } catch (Exception e) {
      resultSet.isSuccess= false;
      resultSet.message= e.getMessage();
      ApplicationLogger.logException(e);
    }
    return resultSet;
}
*/

/** @methodname          : MessageListWrapper
  * @author              : Suhas Mankar
  * @objectreferenced    : InboundOutBoundWrapper
  * @param               :
  * @description         : This is wrapper class used for conversation data which is used to show on chat screen
  * @return              :
  */
public class MessageListWrapper{
    @AuraEnabled
    public InboundOutBoundWrapper inOutMessage{get;set;}
    @AuraEnabled
    public Boolean isInbound {get;set;}
    @AuraEnabled
    public Boolean isActive {get;set;}
    @AuraEnabled
    public Boolean isMedia {get;set;}
    @AuraEnabled
    public String mediaName {get;set;}
    @AuraEnabled
    public String mediaType {get;set;}
    @AuraEnabled
    public String mediaUrl {get;set;}
    }

/** @methodname          : InboundOutBoundWrapper
  * @author              : Suhas Mankar
  * @objectreferenced    : InboundWrapper, OutBoundWrapper
  * @param               :
  * @description         : This is wrapper class used for conversation data which is used to show on chat screen for inbound outbound message
  * @return              :
  */
public class InboundOutBoundWrapper{
    @AuraEnabled
    public String id {get;set;}
    @AuraEnabled
    public InboundWrapper inBound {get;set;}
    @AuraEnabled
    public OutBoundWrapper outBound {get;set;}
}

/** @methodname          : InboundWrapper
  * @author              : Suhas Mankar
  * @objectreferenced    :
  * @param               :
  * @description         : This is wrapper class used for conversation data with inbound message field value
  * @return              :
  */
public class InboundWrapper{
    @AuraEnabled
    public String msg {get;set;}
    @AuraEnabled
    public DateTime createdDate {get;set;}
    @AuraEnabled
    public String mobile {get;set;}
    @AuraEnabled
    public String ownerName {get;set;}
}

/** @methodname          : OutBoundWrapper
  * @author              : Suhas Mankar
  * @objectreferenced    :
  * @param               :
  * @description         : This is wrapper class used for conversation data with outbound message field value
  * @return              :
  */
public class OutBoundWrapper{
    @AuraEnabled
    public String msg{get;set;}
    @AuraEnabled
    public DateTime failedTime {get;set;}
    @AuraEnabled
    public DateTime readTime {get;set;}
    @AuraEnabled
    public DateTime deliveredTime {get;set;}
   @AuraEnabled
    public DateTime sentTime {get;set;}
    @AuraEnabled
    public String mobile {get;set;}
    @AuraEnabled
    public String ownerName {get;set;}
    @AuraEnabled
    public String media {get;set;}
}

}