/**  @classname    : EngageAPI
  *  @author       : Suhas Mankar
  *  @date         : 25-JAN-2024
  *  @description  : class representing calling IChannelService outside package.
  *  @version      : 1.0   Created global class - Suhas Mankar
*/
global with sharing class EngageAPI {

String whatsAppTmeplateId;
String channel;
String recepientField; 
String objectApiName;
List<SObject> sobjectList = new List<SObject>();
Map<string,Send_Configuration__c> sbcMap = new Map<string,Send_Configuration__c>();
Map<String,Object> mapChannelRequest = new Map<String,Object>();
List<String> recordIds = new List<String>();

/**
  * @methodname		     send
  * @author				 Suhas Mankar
  * @objectreferenced	 None   
  * @params				 String, List<String>, String, String
  * @description		 This method performs actual message send functionality through callout 
  * @return				 Void.
  */
global void send(String whatsAppTmeplateId, List<String> recordIds, String channel, String recepientField) {
try{
        System.debug('@@whatsAppTmeplateId = '+whatsAppTmeplateId);
        System.debug('@@recordIds = '+recordIds);
        init(whatsAppTmeplateId, recordIds, channel, recepientField);
        validate();
        processData();
        verifyContext();
    }
    catch(Exception ex){
        
        ApplicationLogger.logException(ex);
    }
}

/**
  * @methodname		     init
  * @author				 Suhas Mankar
  * @objectreferenced	 None   
  * @params				 String, List<String>, String, String
  * @description		 This method initialises all parameters required to send message through IChannelService 
  * @return				 EngageAPI.
  */
private EngageAPI init(String whatsAppTmeplateId, List<String> recordIds, String channel, String recepientField) {
    
    this.whatsAppTmeplateId = whatsAppTmeplateId;
    this.channel = channel;
    this.recepientField = recepientField;
    this.recordIds = recordIds;

    return this;
}

/**
  * @methodname		     validate
  * @author				 Suhas Mankar
  * @objectreferenced	 None   
  * @params				 None
  * @description		 This method validates input paramenters before performing any operation
  * @return				 EngageAPI.
  */
private EngageAPI validate(){
       
    if(String.isBlank(this.whatsAppTmeplateId)){
        exceptionLogger('WhatsApp Template  Id Is Blank ......');
    }

    if(String.isBlank(this.channel)){
        exceptionLogger('Channel Is Blank ......');
    }

    if(String.isBlank(this.recepientField)){
        exceptionLogger('RecepientField Is Blank ......');
    }

    if(this.recordIds.size() <= 0 ){
        exceptionLogger('RecordIds Is Blank ......');
    }
    
    
    return this;
}

/**
  * @methodname		     verifyContext
  * @author				 Suhas Mankar
  * @objectreferenced	 None   
  * @params				 None
  * @description		 This method to check the context from where class is called
  * @return				 Void.
  */
private void verifyContext() {
    if(Trigger.isExecuting || System.isFuture()) {
        // removing recordIds from map as it is throwing error for processing
        this.mapChannelRequest.remove('recordIds');
        execute(JSON.serialize(this.mapChannelRequest), this.recordIds);
    }

   if (System.isBatch()) {  
    execute(this.mapChannelRequest);     
   }
   
   if (System.isQueueable()) {
    execute(this.mapChannelRequest);
   }
   
   if (System.isScheduled()) {
    execute(this.mapChannelRequest);
   }
}

/**
  * @methodname		     execute
  * @author				 Suhas Mankar
  * @objectreferenced	 Object   
  * @params				 String, List<String>
  * @description		 This method future method which call execute method to perform call out
  * @return				 Void.
  */
@Future(callout=true)
private static void execute(String jsonRequest, List<String> recordIds) {
    Map<String,Object> requestMap = (Map<String,Object>)System.JSON.deserializeUntyped(jsonRequest);
    // adding recordId to map to process further
    requestMap.put('recordIds',recordIds);
    execute(requestMap);
}

/**
  * @methodname		     execute
  * @author				 Suhas Mankar
  * @objectreferenced	 IChannelService   
  * @params				 Map<String,Object>
  * @description		 This method is to call IChannelService and process callout
  * @return				 Void.
  */
private static void execute(Map<String,Object> mapChannelRequest){
    String channelName;
    ApexResultSet resultSet = new ApexResultSet();
    channelName = String.valueOf(mapChannelRequest.get('channel'));
    // get configured channel from metadata
    map<String,Channel__mdt> mapChannels = (map<String,Channel__mdt>) Utility.getAllChannelsMap();
    Channel__mdt channel = mapChannels.get(channelName);
    if(channel != null ){
        IChannelService whatsAppService = (IChannelService)Type.forName(channel.Service_Class__c).newInstance();
        resultSet = whatsAppService.process(mapChannelRequest);
    }else{
        resultSet.isSuccess = false;
        resultSet.message = System.Label.channel_not_created;
    }
}

/**
  * @methodname		     processData
  * @author				 Suhas Mankar
  * @objectreferenced	 Utility   
  * @params				 None
  * @description		 This method is to prepare map for making callout
  * @return				 EngageAPI.
  */
private  EngageAPI processData() {
    if(String.isNotBlank(Utility.getTargetSource(this.whatsAppTmeplateId))){
        //get object from whatsApp Template Id
        this.objectApiName = Utility.getTargetSource(this.whatsAppTmeplateId);
        Id recordId = this.recordIds[0];
        String objectName = String.valueOf(recordId.getsobjecttype());
        if(objectName == this.objectApiName){
            //get sbc record based on object name
            this.sbcMap = Utility.getAllSendButtonConfigs(this.objectApiName);
            if(this.sbcMap.keySet().size() > 0 && this.sbcMap.containsKey(this.objectApiName)){
                if((this.sbcMap.get(this.objectApiName).Phone_Fields__c).contains(this.recepientField)){ 
                    this.mapChannelRequest.put('recordIds',this.recordIds);
                    this.mapChannelRequest.put('templateId',this.whatsAppTmeplateId);
                    this.mapChannelRequest.put('objectAPIName',this.objectApiName);
                    this.mapChannelRequest.put('mobileFieldAPIName',this.recepientField);
                    this.mapChannelRequest.put('channel',this.channel);              
                    
                }
                else{
                    exceptionLogger('RecepientField is not configured in button configuration...'); 
                }
            }
            else{
                exceptionLogger('Button configuration not created...'); 
            }
        }
        else{
            exceptionLogger('Selected record and selected template object is mismatched...'); 
        }
    }
    else{
        exceptionLogger('Rocord for provided WhatsAppTemplate Id not found...'); 
    }
    return this;
}

/**
  * @methodname		     exceptionLogger
  * @author				 Suhas Mankar
  * @objectreferenced	 CustomException   
  * @params				 String
  * @description		 This method is log and throw exception.
  * @return				 Void.
  */
private void exceptionLogger(String msg){
    CustomException customEx = new CustomException(msg);
    ApplicationLogger.logException(customEx); 
    throw customEx;
}

}