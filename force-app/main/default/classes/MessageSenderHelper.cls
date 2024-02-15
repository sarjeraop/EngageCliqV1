global with sharing class MessageSenderHelper {
global static Boolean messageSender(Map<String,Object> mapChannelRequest){
    String channelName;
    ApexResultSet resultSet = new ApexResultSet();
    channelName = String.valueOf(mapChannelRequest.get('channel'));
    map<String,Channel__mdt> mapChannels = (map<String,Channel__mdt>) Utility.getAllChannelsMap();
    Channel__mdt channel = mapChannels.get(channelName);
    if(channel != null ){
        IChannelService whatsAppService = (IChannelService)Type.forName(channel.Service_Class__c).newInstance();
        resultSet = whatsAppService.process(mapChannelRequest);
    }else{
        resultSet.isSuccess = false;
        resultSet.message = System.Label.channel_not_created;
    }
    return resultSet.isSuccess;
}

global static void messageSenderContext(String templateId, List<String> recordIds, String recipientField, List<String> channels){
		   
        if (System.isFuture()) { 
             
             sendMessage(templateId, recordIds, recipientField, channels); 
        }
        
        if (System.isBatch()) {       
        }
        
        if (System.isQueueable()) {
        }
        
        if (System.isScheduled()) {
        }
        
        if (Trigger.isExecuting) {
           sendMessage(templateId, recordIds, recipientField, channels);
           //messageSender(recordIds, channelTemplateMap,channelrecipientFieldMap); 
        }
        
        if (ApexPages.currentPage() != null) {
        }
        
        if (RestContext.request != null) { 
            
        }	
       
       
    }

@AuraEnabled @Future(callout=true)
global static void sendMessage(String templateId, List<String> recordIds, String recipientField, List<String> channels){
    
        Map<String,Object> mapChannelRequest = prepareData(templateId, recordIds, recipientField, channels);
        Boolean sucess;
        Map<String, String> channelVStemplateId =(Map<String, String>) mapChannelRequest.get('channelVsId');
        for(String channelSelected : channels){
            if(!channelVStemplateId.isEmpty()){
                if(channelVStemplateId.containsKey(channelSelected.toLowercase())){
                    mapChannelRequest.put('templateId',channelVStemplateId.get(channelSelected.toLowercase()));
                    mapChannelRequest.put('channel',channelSelected);
                    sucess = messageSender(mapChannelRequest);
                }
                else{
                    CustomException customEx = new CustomException(System.Label.channel_not_created);
                    ApplicationLogger.logException(customEx);
                    throw customEx;
                }
            }

}
}

@AuraEnabled 
public static Map<String,Object> prepareData(String templateId, List<String> recordIds, String recipientField, List<String> channels){

    String objectApiName;
    String optOutIn = 'IsDeleted';
    Map<String,Object> mapChannelRequest = new Map<String,Object>();
    map<String, String> channelVStemplateId = new map<String, String> ();   
    String query;        

        // get Channel vs template id and object name based on provided template recordId
        if(String.isNotBlank(templateId)){
        // get all active channel subscribe by user
        map<String,Channel__mdt> mapChannel = (map<String,Channel__mdt>) Utility.getAllChannelsMap();         
        query = 'Select Id, Name, Target_Source__c';
        for (String channel : mapChannel.keySet()) {
            if(channel != null ){
                if (mapChannel.containsKey(channel) &&  mapChannel.get(Channel).Template_Object_Name__c != null) {
                query += ',(Select Id, Name From '+ mapChannel.get(Channel).Template_Object_Name__c +'__r' + ')';
            }
            }
        }
        query = query + ' FROM Template__c Where Id =: templateId ';
        Map<String, Object> tempBinds = new Map<String, Object>{'templateId' => templateId};
        List<String> queryVariables = new List<String>();
        queryVariables.add(String.escapeSingleQuotes(templateId));
        query = String.format(query, queryVariables);
        
        system.debug('query : '+query);
        Template__c objTemplate = Database.queryWithBinds(query,tempBinds, AccessLevel.USER_MODE); 
        for (String channel : mapChannel.keySet()) {
            if (channel != null) {
                for(sobject childRecord : objTemplate.getSObjects(mapChannel.get(Channel).Template_Object_Name__c +'__r')) { 
                    for(String channelSelected : channels){
                        if(channelSelected.toLowercase() == channel.toLowercase()){
                        channelVStemplateId.put(channel.toLowercase(),childRecord.Id);
                        objectApiName = objTemplate.Target_Source__c;
                        mapChannelRequest.put('objectAPIName',objectApiName);
                        }
                        else{
                        CustomException customEx = new CustomException(System.Label.channel_not_created);
                        ApplicationLogger.logException(customEx);
                        throw customEx;
                        }
                    }
                    mapChannelRequest.put('channelVsId',channelVStemplateId);
                }                     
            }
        } 
        system.debug('channelVStemplateId' +channelVStemplateId);
        }
        //assign phone field to whome message is going to receive
        if(String.isNotBlank(recipientField)){
            mapChannelRequest.put('mobileFieldAPIName',recipientField);
            recipientField = recipientField;
        }
        else{
            //get buttonconfiguration for template based on object name
            if(String.isNotBlank(objectApiName)){
            // Map<string,Send_Configuration__c> sbcMap = Utility.getAllSendButtonConfigs(objectApiName);
                Send_Configuration__c sbcRecord = [SELECT Name, Id, Object_Name__c, Phone_Fields__c, Name_Field__c,Consent_Field__c
                                                FROM Send_Configuration__c
                                                Where Object_Name__c =: objectApiName
                                                WITH  USER_MODE];
                
                if(sbcRecord.Phone_Fields__c != null){
                if(sbcRecord.Phone_Fields__c.contains(',')){
                    recipientField = sbcRecord.Phone_Fields__c.split(',')[0];
                }
                else{
                    recipientField = sbcRecord.Phone_Fields__c;
                    }
                }
                if(sbcRecord.Consent_Field__c != null){
                optOutIn = sbcRecord.Consent_Field__c;
                }
                mapChannelRequest.put('mobileFieldAPIName',recipientField);
            }
        }
        
        // get record details for selected record Ids
        List<SObject> sobjectList = new List<SObject>();
        List<String> queryVariable = new List<String>();
        Map<String,List<String>> queryBindValues = new Map<String, List<String>>();
        queryBindValues.put('recId',recordIds);
        queryVariable.add(String.escapeSingleQuotes(recipientField));    
        queryVariable.add(String.escapeSingleQuotes(objectApiName));
        
        if(String.isNotBlank(optOutIn)){
            query ='SELECT Id, {0} FROM {1} WHERE Id IN : recId AND {2} = false';
            queryVariable.add(String.escapeSingleQuotes(optOutIn));
        }
        else{
            query ='SELECT Id, {0} FROM {1} WHERE Id IN : recId';
        }
        query = String.format(query, queryVariable);           
        sobjectList = Database.queryWithBinds(query,queryBindValues,AccessLevel.USER_MODE);
        if(sobjectList.size()>0){
            mapChannelRequest.put('records',sobjectList);   
        }
        else{
            CustomException customEx = new CustomException('No record found.....');
                    ApplicationLogger.logException(customEx);
                    throw customEx;
        }
        system.debug('mapChannelRequest : '+mapChannelRequest);
        return mapChannelRequest;
    
}

/*    
 @InvocableMethod
  global static void sendMessage(List<MapWrapper> request) {
    
      Map<String, Object> mapChannels = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(request[0]));
      
     Boolean flag = messageSender(mapChannels);
      
      
    
  }*/

}