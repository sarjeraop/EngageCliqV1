/**  @classname    : ChatController
  *  @author       : Rati Kulkarni
  *  @date         :
  *  @description  : class representing Chat Controller to perform channel wise Chat request.
  *  @version      : 1.0
*/

public with sharing class BulkMessageController{
    /**
   * @methodname                 Initialise
   * @author                     Rati Kulkarni
   * @objectreferenced           SecurityService
   * @params                     None
   * @description                Constructor to check whether user has permission to perform Chat Feature.
   * @return                     If will return whether User has Permissions or not.
   */
  @AuraEnabled
  public static ApexResultSet initialise() {
      // Check Whether user has access to required objects to perform chat feature.
      ApexResultSet apexResult = new ApexResultSet();
      try{
          List<String> outboundMessageFieldsList = new List<String>{'Channel__c','Message_Text__c','Mobile__c','WhatsApp_Template__c','Source_Record_Id__c','External_ID__c','FailedTime__c','Failure_Reason__c','Media__c'};
          SecurityService.checkInsertable('Outbound_Message__c',outboundMessageFieldsList);
          List<String> conversationFieldsList = new List<String>{'Outbound_Communication_Message__c','Related_To__c'};
          SecurityService.checkInsertable('Conversation__c',conversationFieldsList);
          /*List<String> conversationFieldsList = new List<String>{'Outbound_Communication_Message__c','Related_To__c','Name'};
          SecurityService.checkInsertable('Conversation__c',conversationFieldsList);*/
          
          apexResult.isSuccess = true;
      }catch(Exception ex){
          apexResult.isSuccess = false;
          system.debug('Line29 : '+ex.getLineNumber());
          apexResult.message = ex.getMessage();
      }
      return apexResult;
  }

   /**
   * @methodname                 CheckForAccess
   * @author                     Rati Kulkarni
   * @objectreferenced           SecurityService
   * @params                     None
   * @description                Generalised method to check for Object and fields access dynamically.
   * @return                     ApexResultSet
   */
  @AuraEnabled
  public static ApexResultSet CheckForAccess(String objectName,List<String> fieldList,String access) {

    return Utility.CheckForAccess(objectName, fieldList, access);
  }
  /**  @methodname    : initiateMessageSending
  *  @author        : Rati Kulkarni
  *  @param         : String,String,String,String
  *  @description   : This method used to start the message sending.
  *  @return        : Map
*/
@AuraEnabled
public static ApexResultSet initiateMessageSending(Map<String,Object> mapChannelRequest){
    ApexResultSet resultSet = new ApexResultSet();
    try{
    
        List<String> recordIdsList = String.valueOf(mapChannelRequest.get('recordIds')).split(',');
        String phoneList = String.valueOf(mapChannelRequest.get('phoneFieldName'));
        List<String> phoneFieldList = String.valueOf(mapChannelRequest.get('phoneFieldName')).split(',');
        mapChannelRequest.put('recordIds',recordIdsList);
       
        if(recordIdsList.size() >= 50 || phoneFieldList.size()>1){
             mapChannelRequest.put('phoneFieldName',phoneFieldList);
            SendBulkMessagesBatch sendBulkMsg = new SendBulkMessagesBatch(mapChannelRequest);
            system.debug('mapChannelRequest :'+mapChannelRequest);
            System.debug('recordIdsList.size() :'+recordIdsList.size());
            System.debug('phoneFieldName : '+ mapChannelRequest.get('phoneFieldName'));
            resultSet.data =  Database.executeBatch(sendBulkMsg, 50);
        }else{
            String channelName = String.valueOf(mapChannelRequest.get('channel'));
            mapChannelRequest.put('mobileFieldAPIName',phoneList);
            mapChannelRequest.put('nameFieldAPIName',mapChannelRequest.get('nameFieldName'));
            mapChannelRequest.put('objectAPIName',mapChannelRequest.get('objectName'));
            map<String,Channel__mdt> mapChannels = (map<String,Channel__mdt>) Utility.getAllChannelsMap();
            Channel__mdt channel = mapChannels.get(channelName);
            if(channel != null ){
                IChannelService channelService = (IChannelService)Type.forName(channel.Service_Class__c).newInstance();
                resultSet = channelService.process(mapChannelRequest);
            }else{
                resultSet.isSuccess = false;
                resultSet.message = System.Label.channel_not_created;
            }
        }
        }
    catch(Exception ex){
            resultSet.isSuccess = false;
            resultSet.message = ex.getMessage();
            ApplicationLogger.logException(ex);
        }
    return resultSet;
}


/**  @methodname    : getMeargedMessage
  *  @author        : Shriram Mahamuni
  *  @param         : String,String
  *  @description   : This method is used to generate the user readable message by replacening the veriables from string with actual values for fields.
  *  @return        : ApexResultSet
*/
    @AuraEnabled
    public static ApexResultSet getMeargedMessage(String message,String recordId, String objName){
        ApexResultSet resultSet = new ApexResultSet();
        try{
        String str = Utility.replaceMessageWhatsApp(message);
        List<String> idList = new List<String>();
        IdList.add(recordId);
        Map<String,String> idMessageMap = MergeUtility.replaceMergeFieldsWithValues('{!','}',str,objName,idList);
        resultSet.data = idMessageMap.get(recordId);
        }
         catch(Exception ex){
            resultSet.isSuccess = false;
            resultSet.message = ex.getMessage();
            ApplicationLogger.logException(ex);
        }
    return resultSet;
    }


/**  @methodname    : getSObjectRecords
  *  @author        : Shriram Mahamuni
  *  @param         : String,String,String,String
  *  @description   : This method will return the sobject records based on parameters provided.
  *  @return        : ApexResultSet
  */
    @AuraEnabled
    //public static ApexResultSet getSObjectRecords(String objectName,String nameField, String phonefield, String recordIds,String optField){
        public static ApexResultSet getSObjectRecords(Map<String,Object> mapRequest){
            //public static ApexResultSet getSObjectRecords(Object mapRequest1){
        //System.debug('strRequest :'+strRequest);
        //Map<String,Object> mapRequest = (Map<String,Object>)JSON.deserializeUntyped(strRequest);
        System.debug('mapRequest :'+mapRequest);
        //Map<String,Object> mapRequest = (Map<String,Object>)mapRequest1;
        ApexResultSet resultSet = new ApexResultSet();
        List<String> recIdsList = new List<String>();
        recIdsList = String.valueOf(mapRequest.get('recordIds')).split(',');

        /*String selectStatement = 'SELECT Id, ';
        String nameStatement =  nameField+', ';
        String fieldNameStatement = phonefield+' ';
        String fromStatement = 'FROM ';
        string objNameStatement = objectName+' ';

        string whereStatement = 'Where Id IN : recIdsList and '+optField+ ' = false';
        //string limitStatement = ' LIMIT 200';
        String query = selectStatement + nameStatement + fieldNameStatement + fromStatement + objNameStatement + whereStatement;
        */
        String phonefield = (String)mapRequest.get('phonefield');
        String optField = (String)mapRequest.get('optField');
        String query;
        Map<String,Object> queryBindValues = new Map<String, Object>{'recId'=>recIdsList};
        //Map<String,Object> queryBindValues = new Map<String, String>{'recId'=>(String)mapRequest.get('recordIds')};
        List<String> queryVariables = new List<String>();
        queryVariables.add(String.escapeSingleQuotes(phonefield));
        queryVariables.add(String.escapeSingleQuotes((String)mapRequest.get('nameField')));
        queryVariables.add(String.escapeSingleQuotes((String)mapRequest.get('objectName')));
        
        if (String.isNotBlank(optField)){
            query ='SELECT Id, {0}, {1} FROM {2} WHERE Id IN: recId and {3} = false';
            queryVariables.add(String.escapeSingleQuotes(optField));
        }else{
            query ='SELECT Id, {0}, {1} FROM {2} WHERE Id IN: recId';
        }
    
        query = String.format(query, queryVariables);
        
       // mapRequest.put('records', sobjectList);
        
        Map<String,Object> dataToBeReturned = new Map<String,Object>();
        List<String> phoneFieldsList = phonefield.split(',');
        Integer totalRecordsWithoutPhoneNo = 0;
        Integer totalRecordsWithPhoneNo = 0;
        try{
            system.debug('query :'+query);
             List<sObject> sObjList = Database.queryWithBinds(query,queryBindValues,AccessLevel.USER_MODE);
             System.debug('sObjList :'+sObjList);
            for(sObject sobj : sObjList){
                for(String phoneFieldString : phoneFieldsList){
                    if(String.isNotBlank(String.valueOf(sobj.get(phoneFieldString)))){
                        totalRecordsWithPhoneNo = totalRecordsWithPhoneNo + 1;
                    }else{
                        totalRecordsWithoutPhoneNo = totalRecordsWithoutPhoneNo + 1;
                    }
                }
            }
            Integer totalRecords = (sobjList.size() * phoneFieldsList.size());
            dataToBeReturned.put('phoneField',phonefield);
            dataToBeReturned.put('totalRecords',totalRecords);
            dataToBeReturned.put('records',sObjList);
            dataToBeReturned.put('totalRecordsWithoutPhoneNo',totalRecordsWithoutPhoneNo);
            dataToBeReturned.put('totalRecordsWithPhoneNo',totalRecordsWithPhoneNo);
            resultSet.data = dataToBeReturned;
    }
    catch(Exception ex){
            resultSet.isSuccess = false;
            resultSet.message = ex.getMessage();
            ApplicationLogger.logException(ex);
        }
    return resultSet;
    }


/**  @methodname    : getFieldLabel
  *  @author        : Shriram Mahamuni
  *  @param         : String,String
  *  @description   : This method is uses to get the label with respect to its api name to be rendered on table.
  *  @return        : ApexResultSet
*/
    @AuraEnabled
    public static ApexResultSet getFieldLabel(String objectName,String fieldNames){
        ApexResultSet resultSet = new ApexResultSet();
        try{
        String type=objectName;
        List<String> fieldNameList = fieldNames.split(',');
        Map<String,String> fieldLabelMap = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        for(String fieldName : fieldNameList){
            for(String fieldNameFromApex: fieldMap.keySet()){
                if(fieldMap.containsKey(fieldName) && fieldName == fieldNameFromApex){
                    fieldLabelMap.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
                }
            }
        }
        resultSet.data = fieldLabelMap;
      }
    catch(Exception ex){
            resultSet.isSuccess = false;
            resultSet.message = ex.getMessage();
            ApplicationLogger.logException(ex);
        }
    return resultSet;
    }
    /**
   * @methodname                : getActiveChannel
   * @author                    : Suhas
   * @objectreferenced          : None
   * @params                    : None
   * @description               : This method provides list of channels those are active.
   * @return                    : ApexResultSet
   */
  @AuraEnabled(cacheable=true)
  public static Object getActiveChannel(){
      try {
          return  Utility.getAllChannelsMap();
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
      }
  }

/**  @methodname    : getAllSendButtonConfigs
  *  @author        : Shriram Mahamuni
  *  @param         : String
  *  @description   : This method act as a helper method for getDataFromApex.
  *  @return        : ApexResultSet
*/
@AuraEnabled
public static ApexResultSet getAllSendButtonConfigs(String objectName){
    ApexResultSet resultSet = new ApexResultSet();
    try{
    Map<string,Send_Configuration__c> objNameVsSBCRec = new Map<string,Send_Configuration__c>();
    for( Send_Configuration__c sbcRecord : [SELECT Name, Id, Object_Name__c, Phone_Fields__c, Name_Field__c,Consent_Field__c
                                                   FROM Send_Configuration__c
                                                   WHERE Object_Name__c =: objectName 
                                                   ORDER BY CreatedDate 
                                                   LIMIT 1]){
                                                       objNameVsSBCRec.put(sbcRecord.Object_Name__c,sbcRecord);
                                                   }
    if(objNameVsSBCRec.size() > 0){
        resultSet.data = objNameVsSBCRec;
    }else{
        throw new AuraHandledException('No send button configuration for given object');
    }
    }
    catch(Exception ex){
            resultSet.isSuccess = false;
            resultSet.message = ex.getMessage();
    }
    return resultSet;

}

/**  @methodname    : getAllActiveApprovedTemplates
  *  @author        : Shriram Mahamuni
  *  @param         : String
  *  @description   : This method act as a helper method for getDataFromApex.
  *  @return        : ApexResultSet
*/
@AuraEnabled(cacheable = true)
public static ApexResultSet getAllActiveApprovedTemplates(String objectName,String channelName){
    ApexResultSet resultSet = new ApexResultSet();
    try{
    if(String.isBlank(channelName) || String.isBlank(objectName)){
        return null;
    }
    Map<String, Channel__mdt > allChannelsMap = (Map<String, Channel__mdt >)Utility.getAllChannelsMap();
    Channel__mdt channel = allChannelsMap.get(channelName);
    String templateObjectName = String.valueOf(channel.get('Template_Object_Name__c'));
    Map<string,WhatsApp_Template__c> templateIdVsNameMap = new Map<string,WhatsApp_Template__c>();
   if(channelName == 'WhatsApp'){
    for( Template__c templateRecord : [SELECT Id, Name__c, Description__c, Target_Source__c, IsActive__c,
                                          (SELECT Id,Name__c,IsActive__c, Status__c, Message_Body__c, WhatsApp_Template_ID__c,Template_Type__c
                                           FROM WhatsApp_Template__r)//WhatsApp_Comunication_Templates__r)
                                            FROM Template__c
                                            Where Target_Source__c =: objectName ORDER BY CreatedDate]){
                                           for(WhatsApp_Template__c  wt : templateRecord.WhatsApp_Template__r){
                                               if((wt.IsActive__c) && (wt.Status__c == 'Approved') && (wt.Template_Type__c == 'Business Initiative'))
                                                   templateIdVsNameMap.put(wt.Name__c,wt);
                                           }
                                       }
        }
    resultSet.data = templateIdVsNameMap;
    }
    catch(Exception ex){
            resultSet.isSuccess = false;
            resultSet.message = ex.getMessage();
    }
    return resultSet;

}


/**  @methodname    : getDataFromApex
  *  @author        : Shriram Mahamuni
  *  @param         : String
  *  @description   : This method gives the data required for sendmessagecontainer lwc component.It is invoked after component initialization.
  *  @return        : ApexResultSet
*/
@AuraEnabled
public static ApexResultSet getDataFromApex(String selectedRecords){
    ApexResultSet resultSet = new ApexResultSet();
    try{
    //Get Object name from record ids
    Map<String,Object> dataFromApex = new Map<String,Object>();
    String objectName = getObjectName(selectedRecords);
    dataFromApex.put('objectName',objectName);

    //Get all available channels
    List<String> allAvailableChannels = getAllAvailableChannels();
    dataFromApex.put('allAvailableChannels',allAvailableChannels);

    //Get all send button configurations
    Map<string,Send_Configuration__c> allSendButtonConfigs = (Map<string,Send_Configuration__c>)getAllSendButtonConfigs(objectName).data;
    dataFromApex.put('allSBCs',allSendButtonConfigs);

    resultSet.data = dataFromApex;
    }
    catch(Exception ex){
            resultSet.isSuccess = false;
            resultSet.message = ex.getMessage();
            ApplicationLogger.logException(ex);
        }
    return resultSet;

}

/**  @methodname    : getAllAvailableChannels
  *  @author        : Shriram Mahamuni
  *  @param         : None
  *  @description   : This method act as a helper method for getDataFromApex.
  *  @return        : List
*/
@AuraEnabled
public static List<String> getAllAvailableChannels(){
    List<String> channelList = new List<String>();
    //for(ChannelV1__c channelRecord : [SELECT Id, Name FROM ChannelV1__c where Active__c = TRUE ORDER BY Name Desc]){
    for(Channel__mdt channelRecord : [SELECT Channel__c, Id, Active__c, Label FROM Channel__mdt where Active__c = TRUE ORDER BY Channel__c Desc]){
        channelList.add(channelRecord.Channel__c);
    }
    return channelList;
}


/**  @methodname    : getObjectName
  *  @author        : Shriram Mahamuni
  *  @param         : String
  *  @description   : This method act as a helper method for getDataFromApex.
  *  @return        : String
*/

@AuraEnabled
public static String getObjectName(String selectedRecords){
    String objName = '';
    Map<string,Object> objNameMap = new Map<string,Object>();
    try{
        List<String> selectedRecordList = new List<String>();
        selectedRecordList = selectedRecords.split(',');
        if(selectedRecordList.size() > 0){
            Id selectedRecord = selectedRecordList[0];
            objName = String.valueOf(selectedRecord.getsobjecttype());
        }
    }catch(Exception ex){
        system.debug(ex.getMessage());
        system.debug(ex.getStackTraceString());
    }
    return objName;
}


// Report Selection LWC components methods

/**  @methodname            : getReportFolders.
  *  @author                : Ganesh Bhakare.
  *  @objectreferenced      : Folder.
  *  @param                 : None.
  *  @description           : This method is used to get all the folders accesible to logged in user.
  *  @return                : ApexResultSet.
*/
@AuraEnabled
public static ApexResultSet getReportFolders(){
    ApexResultSet resultSet = new ApexResultSet();
    try {
        resultSet.data = ReportUtility.getReportFolders();
    }
    catch(Exception e){
        resultSet.isSuccess= false;
        resultSet.message= e.getMessage();
        ApplicationLogger.logException(e);
    }  
    return resultSet;
}

/**  @methodname            : getReports.
  *  @author                : Ganesh Bhakare.
  *  @objectreferenced      : Folder.
  *  @param                 : None.
  *  @description           : This method is used to get reports in selected folder.
  *  @return                : ApexResultSet.
*/
@AuraEnabled
public static ApexResultSet getReports(string fldrName){
    ApexResultSet resultSet = new ApexResultSet();
    try {
        resultSet.data = ReportUtility.getReports(fldrName);
    }
    catch(Exception e){
        resultSet.isSuccess= false;
        resultSet.message= e.getMessage();
        ApplicationLogger.logException(e);
    }  
    return resultSet;
}

/**  @methodname            : getReportDetails.
*  @author                : Ganesh Bhakare.
*  @objectreferenced      : Folder.
*  @param                 : Id of the report selected by user.
*  @description           : This method used  to collect all recordIds corresponding to primary object in selected report.
*  @return                : ApexResultSet.
*/
@AuraEnabled
public static ApexResultSet getReportDetails(string reportId){
    ApexResultSet resultSet = new ApexResultSet();
    try{       
         resultSet.data = ReportUtility.getReportDetails(reportId);
        }catch(Exception e){
            resultSet.isSuccess= false;
            resultSet.message= e.getMessage();
            ApplicationLogger.logException(e);
        }  
        return resultSet;
}

/**  @methodname            : getReportBaseObject.
*  @author                : Ganesh Bhakare.
*  @objectreferenced      : Folder.
*  @param                 : Id of record in report.
*  @description           : This method is used to get primary object in selected report.
*  @return                : ApexResultSet.
*/
@AuraEnabled
public static ApexResultSet getReportBaseObject(Id recorId){
    ApexResultSet resultSet = new ApexResultSet();
    try{
        resultSet.data = ReportUtility.getReportBaseObject(recorId);
    }catch(Exception e){
        resultSet.isSuccess= false;
        resultSet.message= e.getMessage();
        ApplicationLogger.logException(e);
    }  
    return resultSet;
}

}