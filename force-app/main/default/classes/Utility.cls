/**
  *  @classname  : Utility
  *  @author : Shriram Mahamuni
  *  @date : 22-10-2023
  *  @description  : This utility class provides a collection of static methods that can be used to perform common operations in Salesforce Apex code.
                     It is designed to encapsulate reusable functionality to improve code maintainability and reusability.
  *  @modificationlog
  *   #   Date            Description         Modified By
  *   1.  22-10-2023      Initital version    Shriram Mahamuni
  */

public inherited sharing class Utility {

  /**
 * @methodname            replaceMessageWhatsApp
 * @author                Suhas Mankar
 * @objectreferenced
 * @params                String
 * @description           This method used to replace message to whatsApp supported formate(bold, italic and strike).
 * @return                String
 */
public static String replaceMessageWhatsApp(String msgBody){
    string changeBody ='';
    Map<String, String> converterMap = new Map<String, String>();
        converterMap.put('<strong>', '*');
        converterMap.put('</strong>', '*');
        converterMap.put('<em>', '_');
        converterMap.put('</em>', '_');
        converterMap.put('<strike>', '~');
        converterMap.put('</strike>', '~');
        converterMap.put('<p>', '');
        converterMap.put('</p>', '');
        converterMap.put('<br>', '\\n');
        converterMap.put('<br/>', '\\n');

        for(String body:converterMap.keyset()){
            changeBody =  msgBody.replace(body, converterMap.get(body));
            msgBody = changeBody;
        }
        changeBody = changeBody.unescapeHtml4();
        return changeBody;
}

/**
 * @methodname            replaceMessageTemplate
 * @author                Suhas Mankar
 * @objectreferenced
 * @params                String
 * @description           This method used to replace message to richtext supported formate(bold, italic and strike).
 * @return                String
 */
public static String replaceMessageTemplate(String msgBody){
  string changeBody ='';
  Map<String, String> converterMap = new Map<String, String>();
      
  converterMap.put('*', '<strong>');
  converterMap.put('_', '<em>');
  converterMap.put('~', '<strike>');
  converterMap.put('\\n\\n', '\\n');
  converterMap.put('\\n', '<br>');
  for(String body:converterMap.keyset()){
      changeBody =  msgBody.replace(body, converterMap.get(body));
      msgBody = changeBody;
  }
  changeBody = changeBody.unescapeHtml4();
  return changeBody;
}

    /**
      *  @methodname : getAllChannelsMap
      *  @author : Shriram Mahamuni
      *  @objectreferenced  : Channel__mdt
      *  @param  : None
      *  @description  : This method returns the active channel records in the form of map.
      *  @return : Object
    */
    public static Object getAllChannelsMap(){
      Map<String, Channel__mdt > allChannelsMap = new Map<String,Channel__mdt>();
      List<Channel__mdt> activeChannelsList = [SELECT Id, Active__c, Channel__c, Service_Class__c, Service_Handler_Class__c, Webhook_Service_Class__c, Webhook_URL__c ,Template_Object_Name__c,LogoUrl__c
                                               FROM Channel__mdt
                                               WHERE Active__c = true];
      for(Channel__mdt channelRecord : activeChannelsList){
          allChannelsMap.put(channelRecord.Channel__c,channelRecord);
      }
      return allChannelsMap;
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
      // Check Whether user has access to required objects to perform chat feature.
      ApexResultSet apexResult = new ApexResultSet();
      try{
          if(!String.isBlank(objectName)){
            if(access == System.label.create_access && fieldList.size()> 0){
                SecurityService.checkInsertable(objectName,fieldList);
            }else if(access == System.label.read_access && fieldList.size()> 0){
                SecurityService.checkAccessible(objectName,fieldList);
            }else if(access == System.label.delete_access){
                SecurityService.checkDeletable(objectName);
            }else if(access == System.label.modify_access && fieldList.size()> 0){
                SecurityService.checkUpdatable(objectName,fieldList);
            }
         }
          apexResult.isSuccess = true;
      }catch(Exception ex){
          apexResult.isSuccess = false;
          system.debug('Line29 : '+ex.getLineNumber());
          apexResult.message = ex.getMessage();
      }
      return apexResult;
  }

    /**
      *  @methodname : getAllWebhookConfigurations
      *  @author : Shriram Mahamuni
      *  @objectreferenced  : Webhook_Configuration__mdt
      *  @param  : None
      *  @description  : This method returns the active Webhook configuration records in the form of map.
      *  @return : Object
    */
    public static Object getAllWebhookConfigurations(String channelName){
      Map<String,Webhook_Configuration__mdt> allWebhookConfigurations = new Map<String,Webhook_Configuration__mdt>();
    List<Webhook_Configuration__mdt> activeWebhookConfigList = [SELECT Id, Active__c, Service_Handler_Class__c, SubCategory__c, DeveloperName, Label, Channel_Name__c,QualifiedApiName,Enable_Logging__c FROM Webhook_Configuration__mdt Where Active__c = true And Channel_Name__c =: channelName];
    system.debug('@@ activeWebhookConfigList =='+activeWebhookConfigList);
      for(Webhook_Configuration__mdt webConfigRecord  : activeWebhookConfigList){
          allWebhookConfigurations.put(webConfigRecord.SubCategory__c, webConfigRecord);
      }
      return allWebhookConfigurations;
    }

     /** @methodname          : createOutboundMessagesAndConversations
      * @author              : Suhas Mankar
      * @objectreferenced    : Conversation__c, Outbound_Message__c,
      * @param               : List<Outbound_Message__c>
      * @description         : This method send outbound record and conversation to Dataservice classs to create record
      * @return              : void
      */
/*
      public static void createOutboundMessagesAndConversations(List<Outbound_Message__c>  msgList){

        List<Conversation__c> objConversationList = new List<Conversation__c>();
        DatabaseService.DB_Result dbResult = DatabaseService.dbInsert(new DatabaseService.DB_Input(msgList,true, true, 'MessageUtility'));

        if(dbResult.successRecordIds.size() > 0){

              for( String objDb :dbResult.successRecordIds){
                Conversation__c objConversation = new Conversation__c();
                objConversation.Outbound_Communication_Message__c = objDb;

                if((dbResult.idToSObjectMap.get(objDb)).get('Source_Record_Id__c') != null){
                    objConversation.Related_To__c = String.valueOf((dbResult.idToSObjectMap.get(objDb)).get('Source_Record_Id__c'));
                }

                objConversationList.add(objConversation);
            }

        dbResult = DatabaseService.dbInsert(new DatabaseService.DB_Input(objConversationList, true, true, 'MessageUtility'));
        }

      }
*/
public static void createOutboundMessagesAndConversations(List<Outbound_Message__c>  msgList, String objectAPIName){

  List<Conversation__c> objConversationList = new List<Conversation__c>();
  DatabaseService.DB_Result dbResult = DatabaseService.dbInsert(new DatabaseService.DB_Input(msgList,true, true, 'MessageUtility'));

  Set<String> objectFields = Schema.SObjectType.Outbound_Message__c.fields.getMap().keySet();
  System.debug('objectFields ====> '+objectFields);
  System.debug('OBJECT ====> '+objectAPIName);  
  
  if(dbResult.successRecordIds.size() > 0){

        for( String objDb :dbResult.successRecordIds){
          Conversation__c objConversation = new Conversation__c();
          objConversation.Outbound_Communication_Message__c = objDb;

         
       if(!Test.isRunningTest()){
           
            if(objectAPIName.endsWith(Constants.CUSTOMOBJECTSUFFIX)) {
                // custom object
                String fieldNameWithoutC = objectAPIName.substring(0,objectAPIName.lastIndexOf('__'));
                //Manage package check
                if(String.isNotEmpty(fieldNameWithoutC) && fieldNameWithoutC.contains('__')){ 
                    String fieldNameWithoutPkgPrefix =fieldNameWithoutC.substring(fieldNameWithoutC.IndexOf('__')+2);
                    if(objectFields.contains((fieldNameWithoutPkgPrefix+Constants.CUSTOMOBJECTSUFFIX).toLowerCase())){
                        // field lookup created on outbound_message__c
                        objConversation.Related_To__c  = String.valueOf((dbResult.idToSObjectMap.get(objDb)).get(fieldNameWithoutPkgPrefix+Constants.CUSTOMOBJECTSUFFIX));
                        }
                    else{ 
                        // field lookup not found
                        CustomException customEx = new CustomException(System.Label.reference_field_error);
                        throw customEx;           
                    }  
                }
                else{
                    // Custom object without manage package
                    if(objectFields.contains(objectAPIName.toLowerCase())){
                        // field lookup created on outbound_message__c
                        objConversation.Related_To__c  = String.valueOf((dbResult.idToSObjectMap.get(objDb)).get(objectAPIName));
                    }
                    else{ 
                        // field lookup not created on outbound_message__c
                        CustomException customEx = new CustomException(System.Label.reference_field_error);
                        throw customEx;           
                    } 
                }
                
            } 
            else{ // standard object
                String referenceField = objectAPIName+Constants.CUSTOMOBJECTSUFFIX;
                // field lookup created on outbound_message__c
                if(objectFields.contains(referenceField.toLowerCase())){ 
                    objConversation.Related_To__c  = String.valueOf((dbResult.idToSObjectMap.get(objDb)).get(referenceField));
                }
                else{ 
                    // field lookup not created on outbound_message__c
                    CustomException customEx = new CustomException(System.Label.reference_field_error);
                    throw customEx;           
                }
            }
       }

          objConversationList.add(objConversation);
      }

  dbResult = DatabaseService.dbInsert(new DatabaseService.DB_Input(objConversationList, true, true, 'MessageUtility'));
  }

}


       /**
         * @methodname		    : getTemplateFromTemplateId
         * @author				    : Rati Kulkarni
         * @objectreferenced	: WhatsApp_Template__c
         * @params 				    : String
         * @description			  : This method returns WhatsApp_Template__c object for specified template Id
         * @return				    : WhatsApp_Template__c
         */
        public static WhatsApp_Template__c getTemplateFromTemplateId(String templateId){
          return [SELECT Id, Name__c,Message_Body__c, Json_Payload__c,Template_Type__c,Language__c
                  FROM WhatsApp_Template__c
                  WHERE Id =:templateId
                  WITH USER_MODE
                  LIMIT 1];
      }

/** @methodname          : sbcRecordFinder
  * @author              : Suhas Mankar
  * @objectreferenced    : Send_Configuration__c
  * @param               : String
  * @description         : This method is used to send button configuration record based on objectApiName
  * @return              : Send_Configuration__c
  */
@AuraEnabled
public static Send_Configuration__c sbcRecordFinder(String objName){


      return [SELECT Name_Field__c, Phone_Fields__c, Object_Name__c
                        FROM Send_Configuration__c
                        WHERE Object_Name__c =:objName
                        WITH SECURITY_ENFORCED];



}


      /**
        * @methodname		    : getMergedMessage
        * @author				    : Rati Kulkarni
        * @objectreferenced	: WhatsApp_Template__c
        * @params 				  : List<sObject>,  String,  String, String
        * @description			: This method updates SF fields by values.
        * @return				    : List<Map<String,Object>>
        */
      public static Map<String,Object> getMergedMessage(List<sObject> recordList, String unmergedMessage, String objectAPIName,String templateId){

          Map<String,Object> mapIdVsMergedMessage = new Map<String,Object>();
          List<String> listRecordIds = new List<String>();
          String mergedMessage = unmergedMessage;
          for(sObject sobj : recordList){
              Map<String,Object> recordMap = new Map<String,Object>();

              if(unmergedMessage.contains('strong') || unmergedMessage.contains('em') || unmergedMessage.contains('strike') || unmergedMessage.contains('p')){
                  mergedMessage = replaceMessageWhatsApp(unmergedMessage);
              }

              if(unmergedMessage.contains('{!') && unmergedMessage.contains('}')){
                  if(String.valueOf((sobj.get('Id'))) != null){
                  listRecordIds.add(String.valueOf((sobj.get('Id'))));
                  }
              }
          }
          if(listRecordIds.size() > 0){
           mapIdVsMergedMessage = MergeUtility.replaceMergeFieldsWithValues(mergedMessage, objectAPIName,  listRecordIds);
          }
          return mapIdVsMergedMessage;
      }

      /**
        * @methodname		    : getMergedMessage
        * @author				    : Rati Kulkarni
        * @objectreferenced	: WhatsApp_Template__c
        * @params 				  : List<sObject>,  String,  String, String,Map<String,String>
        * @description			: This method updates SF fields by values.
        * @return				    : List<Map<String,Object>>
        */
        public static Map<String,Object> getMergedMessage(List<sObject> recordList, String unmergedMessage, String objectAPIName,String templateId,Boolean isParameterizedBI){
          Map<String,Object> mapData = new Map<String,Object>();
          //Map<String,Object> mapIdVsMergedMessage = new Map<String,Object>();
          List<String> listRecordIds = new List<String>();
          
          String mergedMessage = unmergedMessage;
          for(sObject sobj : recordList){
              Map<String,Object> recordMap = new Map<String,Object>();

              if(unmergedMessage.contains('strong') || unmergedMessage.contains('em') || unmergedMessage.contains('strike') || unmergedMessage.contains('p')){
                  mergedMessage = replaceMessageWhatsApp(unmergedMessage);
              }

              if(unmergedMessage.contains('{!') && unmergedMessage.contains('}')){
                  if(String.valueOf((sobj.get('Id'))) != null){
                  listRecordIds.add(String.valueOf((sobj.get('Id'))));
                  }
              }
          }
          if(listRecordIds.size() > 0){
            mapData = MergeUtility.replaceMergeFieldsWithValues(mergedMessage, objectAPIName,  listRecordIds,isParameterizedBI);
          }

          return mapData;
      }

      /** @methodname          : getJsonFromStaticResource
        * @author              : Rati Kilkarni
        * @objectreferenced    : StaticResource
        * @param               : String
        * @description         : This method provides Json Payload from StaticResource Name.
        * @return              : String
        */
        public static String getJsonFromStaticResource(String staticResourceName){
            if(Test.isRunningTest()){
               return '';
            }
            else{
                  StaticResource sr = [SELECT Id,SystemModstamp FROM StaticResource WHERE Name = 'engagecliq'];
            return (new PageReference('/resource/' + sr.SystemModstamp.getTime() + '/'+Constants.NAMESPACEPREFIX+'engagecliq/JSON/'+staticResourceName).getContent().toString());

            }
        }

/** @methodname         : approvedWhatsAppTemplate
 * @author              : Suhas Mankar
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : Boolean, String
 * @description         : This method is used to find approved whtasApp template based on object name and active checkbox
 * @return              : List<Template__c>
 */
  public static List< WhatsApp_Template__c> approvedWhatsAppTemplate(Boolean active, String objectName){
      List< WhatsApp_Template__c> whatsappTemplateList = new List< WhatsApp_Template__c>();
      if(active){
        whatsappTemplateList = [SELECT Id,Name, Name__c, Message_Body__c, Template_Type__c, Status__c, Template_ID__r.Target_Source__c, JSON_Payload__c
                                FROM WhatsApp_Template__c
                                WHERE  Status__c ='Approved'
                                AND Template_ID__r.Target_Source__c =: objectName
                                WITH USER_MODE];
    }
    else{
        whatsappTemplateList =  [SELECT Id,Name, Name__c, Message_Body__c, Template_Type__c, Status__c, Template_ID__r.Target_Source__c, JSON_Payload__c
                                 FROM WhatsApp_Template__c
                                 WHERE Status__c ='Approved'
                                 AND Template_Type__c = 'Business Initiative'
                                 AND Template_ID__r.Target_Source__c =: objectName
                                 WITH USER_MODE];}
      return whatsappTemplateList;
  }
/**
* @ methodname             : getQuickTextList.
* @ author                 : Sarjerao Pujari.
* @ objectreferenced       : QuickText.
* @ param                  : None.
* @ description            : This getQuickTextList Method With @AuraEnabled Annotation is used get the all Created QuickTexts.
* @ return                 : List.
*/
  @AuraEnabled
  public static List<QuickText> getQuickTextList()
  {
      List<QuickText> listofQuickText = new List<QuickText>();
      listofQuickText = [SELECT name,Message from QuickText];
      return listofQuickText;
  }

    /**
	  *  @methodname : getExistingSBCs
		*  @author : Shriram Mahamuni
		*  @objectreferenced  : Send_Configuration__c
		*  @param  : None
		*  @description  : This apex method is responsible for retrieving and providing information about existing "Send Button Configurations" stored within the Salesforce environment.
		*  @return : ApexResultSet
	*/
	@AuraEnabled
	public static ApexResultSet getExistingSBCs(){
		ApexResultSet aResult = new ApexResultSet();
		List<String> sbConfigObjectsList = new List<String>();
		try{
			for(Send_Configuration__c sbcRecord : [SELECT Id, Name, Object_Name__c, Phone_Fields__c, Name_Field__c,Consent_Field__c FROM Send_Configuration__c WHERE Object_Name__c != '' WITH USER_MODE ORDER BY Object_Name__c Asc ]){
				sbConfigObjectsList.add(sbcRecord.Object_Name__c);
			}
			aResult.data = sbConfigObjectsList;
			aResult.isSuccess = true;
		}catch(Exception ex){
			aResult.isSuccess = false;
			aResult.data = null;
			aResult.message = Constants.errorExistingSBCAccess;
			ApplicationLogger.logException(new CustomException(Constants.errorExistingSBCAccess));
		}
		return aResult;
	}

	/**  @methodname : getLatestAPIVersion
		*  @author : Shriram Mahamuni
		*  @objectreferenced  : None
		*  @param  : None
		*  @description  : This method is used to retrieve the latest API version available for use in Salesforce.
											 This method would typically be used to determine the most up-to-date version of the Salesforce REST or SOAP API that our code should interact with.
		*  @return : String
	*/
	public static String getLatestAPIVersion(){
		JSONGenerator gen = JSON.createGenerator(false);
		gen.writeObject(new User(Id = UserInfo.getUserId()));
		Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(gen.getAsString());
		Map<String, Object> resultAttributes = (Map<String, Object>) result.get('attributes');
		String resultAttributesURL = (String) resultAttributes.get('url');
		String apiVersion = resultAttributesURL.substringAfter('/services/data/v').substringBefore('/');
		return apiVersion;
	}

    /**
	  *  @methodname : getAllObjectsMap
		*  @author : Shriram Mahamuni
		*  @objectreferenced  : None
		*  @param  : None
		*  @description  : This method is developed to retrieve information about all sObjects (standard and custom objects) available in the Salesforce organization.
											 It generates a map where the keys are object API names and the values are label of an object.
		*  @return : ApexResultSet
	*/
	@AuraEnabled 
	public static Map<String,String> getAllObjects(){
	//public static ApexResultSet getAllObjects(){

		Map<String,String> objectMap = new Map<String,String>();
		Map<String,String> objectMapToBeReturned = new Map<String,String>();
		ApexResultSet aResult = new ApexResultSet();

		//loop through the all objects in org.
		for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){

			String name = objTyp.getDescribe().getName();
			String label = objTyp.getDescribe().getLabel();

			//ignore the objects which are the setup objects
			if(!name.containsignorecase(Constants.historyString) && !name.containsignorecase(Constants.tagString) &&
						!name.containsignorecase(Constants.shareString) && !name.containsignorecase(Constants.feedString) &&
						 !name.containsignorecase(Constants.groupString) && !name.containsignorecase(Constants.publicString) &&
						!objTyp.getDescribe().isCustomSetting() && objTyp.getDescribe().isCreateable()){
						objectMap.put(name,label);
			 }
		}
		Set<String> keysSet =  objectMap.keySet();
		List<String> keysList = new List<String>();
		keysList.addAll(keysSet);
		keysList.sort();
		for(String key : keysList){
			objectMapToBeReturned.put(key,objectMap.get(key));
		}

		if(objectMapToBeReturned != null && objectMapToBeReturned.size() > 0){
			aResult.data = objectMapToBeReturned;
			aResult.isSuccess = true;
		}else{
				ApplicationLogger.logException(new CustomException(Constants.errorMsgErrorInFetchingAllObjects));
				aResult.data = null;
				aResult.isSuccess = false;
				aResult.message = Constants.errorMsgErrorInFetchingAllObjects;
		}
		return objectMapToBeReturned;
	}

    /**  @methodname    : getAllSendButtonConfigs
  *  @author        : Shriram Mahamuni
  *  @param         : String
  *  @description   : This method act as a helper method for getDataFromApex.
  *  @return        : Map
*/
    public static Map<string,Send_Configuration__c> getAllSendButtonConfigs(String objectName){
      
        Map<string,Send_Configuration__c> objNameVsSBCRec = new Map<string,Send_Configuration__c>();
        List<String> fieldsList = new List<String>();

        Send_Configuration__c sbcRecords = [SELECT Name, Id, Object_Name__c, Phone_Fields__c, Name_Field__c, Consent_Field__c
                                            FROM Send_Configuration__c
                                            Where Object_Name__c =: objectName 
                                            WITH USER_MODE  
                                            ORDER BY CreatedDate 
                                            LIMIT 1];
      
      
      
        if(String.isNotBlank(sbcRecords.Name_Field__c)){
          fieldsList.add(sbcRecords.Name_Field__c);
        }
        if(String.isNotBlank(sbcRecords.Consent_Field__c)){
          fieldsList.add(sbcRecords.Consent_Field__c);
        }
        if(sbcRecords.Phone_Fields__c.contains(',')){
          for(String s :sbcRecords.Phone_Fields__c.split(',')){
            fieldsList.add(s);
          }
        }
        else{
          fieldsList.add(sbcRecords.Phone_Fields__c);
        }
        SecurityService.checkAccessible(objectName,fieldsList);

        if(String.isNotBlank(sbcRecords.Object_Name__c)){
        objNameVsSBCRec.put(sbcRecords.Object_Name__c,sbcRecords);
        } 

      return objNameVsSBCRec;
    }

        /**  @methodname    : getAllActiveApprovedTemplates
  *  @author        : Shriram Mahamuni
  *  @param         : String
  *  @description   : This method act as a helper method for getDataFromApex.
  *  @return        : Map
*/
public static Map<string,WhatsApp_Template__c> getAllActiveApprovedTemplates(String objectName,String channelName){
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
                                                   templateIdVsNameMap.put(wt.Name,wt);
                                           }
                                       }
    }
    return templateIdVsNameMap;
}

         /**
   * @methodname                : getSessionId
   * @author                        : Suhas
   * @objectreferenced      : None
   * @params                        : None
   * @description                 : This method provide current user sesssion Id.
   * @return                        : String
   */
  @AuraEnabled
  public static Object getSessionId(){
      return UserInfo.getSessionId();

  }

 /** @methodname         : getApprovedWhatsAppTemplate
 * @author              : Rati Kulkarni
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : Boolean, String
 * @description         : This method is used to find approved whtasApp template
 * @return              : List<Template__c>
 */
@AuraEnabled
public static List< WhatsApp_Template__c> getApprovedWhatsAppTemplate(){


    return [SELECT Id,Name__c, Message_Body__c, Template_Type__c, Status__c, Template_ID__r.Target_Source__c, JSON_Payload__c FROM WhatsApp_Template__c WHERE Status__c ='Approved' AND Whatsapp_Approval_Status__c = 'APPROVED' AND Template_Type__c = 'Business Initiative' WITH USER_MODE];

}

/** @methodname         : getSupportdLanguageWhatsApp
 * @author              : Rati Kulkarni
 * @objectreferenced    : Supported_Language__mdt
 * @param               :
 * @description         : This method is used get supported language metadata for whatsApp Template
 * @return              : List<Supported_Language__mdt>
 */
@AuraEnabled
public static List<Supported_Language__mdt> getSupportdLanguageWhatsApp(){

        return [select DeveloperName, MasterLabel  from Supported_Language__mdt
                 WITH USER_MODE];

}

/**
   * @methodname			      getWhatsAppTemplate
   * @author				        Rati Kulkarni
   * @objectreferenced	    WhatsApp_Template__c
   * @params				        String
   * @description			      This method returns WhatsAppTemplate Object based on whatsAppTemplaterecordId.
   * @return				        WhatsApp_Template__c
   */
  @AuraEnabled
  public static WhatsApp_Template__c getWhatsAppTemplate(String whatsAppTemplaterecordId){

    return [SELECT Id,Name__c,Merge_Field_Mapping__c,IsActive__c,Json_Payload__c,Message_Body__c,Status__c,WhatsApp_Category__c,Template_type__c,Language__c,JSON_Wrapper__c,Template_Id__c,WhatsApp_Message_Body__c,Whatsapp_Approval_Status__c,WhatsApp_Template_ID__c
            FROM  WhatsApp_Template__c
            WHERE Id = :whatsAppTemplaterecordId
            WITH  USER_MODE
            LIMIT 1];


  }

        /**
   * @methodname			      getTemplate
   * @author				        Rati Kulkarni
   * @objectreferenced	    Template__c
   * @params				        None
   * @description			      This method returns all template from org .
   * @return				        List<Template__c>
   */
  @AuraEnabled
  public static List<Template__c> getTemplate(){

    return [SELECT Id, Name__c, Target_Source__c, Description__c
            FROM  Template__c
            WHERE Name__c != NULL
            WITH  USER_MODE];


  }
    
          /**
   * @methodname			      	getTemplateData
   * @author				        Rati Kulkarni
   * @objectreferenced	    		Template__c
   * @params				        String
   * @description			      	This method returns template data based on recordId .
   * @return				        Template__c
   */
  @AuraEnabled
  public static Template__c getTemplateData(String recId){

    return [SELECT Id, Name__c, Target_Source__c, Description__c
            FROM  Template__c
            WHERE Id =: recId
            WITH  USER_MODE];


  }

  /**
   * @methodname			      	getTargetSource
   * @author				          Suhas Mankar
   * @objectreferenced	    	WhatsApp_Template__c
   * @params				          String
   * @description			      	This method returns whatsApp template data based on recordId  .
   * @return				          String
   */
  public static String getTargetSource(String recId){

    WhatsApp_Template__c objWhatsaAppTemplate = new WhatsApp_Template__c();

    objWhatsaAppTemplate = [select Id, Name, Name__c,Template_ID__r.Target_Source__c from WhatsApp_Template__c
                            WHERE Id =: recId
                            WITH  USER_MODE];
    if(objWhatsaAppTemplate.Template_ID__r.Target_Source__c != Null){
      return objWhatsaAppTemplate.Template_ID__r.Target_Source__c;
    }
    else{
      return '';
    }


  }


 /**
   * @methodname			      	getRecordData
   * @author				          Suhas Mankar
   * @objectreferenced	    	SObject
   * @params				          List<String>, String, String, String
   * @description			      	This method returns List of SObject base on object name  .
   * @return				          List<SObject>
   */
  
  public static List<SObject> getRecordData(List<String> recordIds, String recipientField, String objectApiName){

    Map<string,Send_Configuration__c> mapSBCRec = new Map<string,Send_Configuration__c>();
    List<SObject> sobjectList = new List<SObject>();
    List<String> queryVariable = new List<String>();
    String query;
    Map<String,List<String>> queryBindValues = new Map<String, List<String>>();
    Send_Configuration__c objSBC = new Send_Configuration__c();

    mapSBCRec = Utility.getAllSendButtonConfigs(objectApiName);

    if(mapSBCRec.containsKey(objectApiName)){
      objSBC =   mapSBCRec.get(objectApiName); 
    //optOutIn = objSBC.Consent_Field__c;
    }
    queryBindValues.put('recId',recordIds);
    queryVariable.add(String.escapeSingleQuotes(recipientField));    
    queryVariable.add(String.escapeSingleQuotes(objectApiName));
    
    if(String.isNotBlank(objSBC.Consent_Field__c)){
        query ='SELECT Id, {0} FROM {1} WHERE Id IN : recId AND {2} = false';
        queryVariable.add(String.escapeSingleQuotes(objSBC.Consent_Field__c));
    }
    else{
        query ='SELECT Id, {0} FROM {1} WHERE Id IN : recId';
    }
    query = String.format(query, queryVariable);           
    sobjectList = Database.queryWithBinds(query,queryBindValues,AccessLevel.USER_MODE);
    
    if(sobjectList.size()>0){
      return sobjectList; 
    }
    else{
        
        CustomException customEx = new CustomException('No record found you might have optout');
        ApplicationLogger.logException(customEx);
        if(!Test.isRunningTest()){
        throw customEx;
        }
        else{
          return sobjectList;  
        }
        }
    
       
  }
    /**
   * @methodname			      	createWebhookLog
   * @author				        Nikita Pawar
   * @objectreferenced	    	    Webhook_Log__c
   * @params				        String channel, String payload
   * @description			      	This method creates webhook log record.
   * @return				        
   */
    public static void createWebhookLog(String channel, String payload){
        Webhook_Log__c webhookInstace = new Webhook_Log__c();
        webhookInstace.Channel__c = channel;
        webhookInstace.Payload__c = payload;
        
        Insert webhookInstace;
        System.debug('webhookInstace rec == '+webhookInstace);
  }

  }