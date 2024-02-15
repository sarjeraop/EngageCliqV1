/**
*  @classname  : WhatsAppInboundHandler
*  @author : Shriram Mahamuni
*  @date : 17-10-2023
*  @description  : This class responsible for handling and processing incoming messages and interactions from WhatsApp (WA).
*                  It serves as the intermediary layer which receives the incoming message and process it in system.
*  @modificationlog
*  	#	Date			Description		    Modified By
*	1   17-10-2023    	Initial Version 	Shriram Mahamuni
*/
public inherited sharing class WhatsAppInboundHandler implements IWebhookServiceHandler{

	/**
	*  @methodname : execute
	*  @author : Shriram Mahamuni
	*  @objectreferenced  : Inbound_Message__c
	*  @param  : Object
	*  @description  : This method is specifically designed for processing the incoming messages in whatsapp.
	*  @return : void
	*/
	public static void execute(Object valueObj) {
	  try{
		  system.debug('valueObj =='+valueObj);        
		  Map<String, Object> valueMap = (Map<String, Object>) valueObj;
		  Webhook_Configuration__mdt objWbkConfg = (Webhook_Configuration__mdt)valueMap.get('confgData');
		  if (objWbkConfg != null && objWbkConfg.Enable_Logging__c) {
			String payload = JSON.serialize(valueMap.get('payload'));
			Utility.createWebhookLog(Constants.WHATSAPPSTRING,payload);
		  }
  
  
		List<String> inboundFields = new List<String>{Constants.CHANNELFIELD,Constants.MESSAGETEXTFIELD,Constants.MOBILEFIELD};
		SecurityService.checkInsertable(Constants.INBOUNDMESSAGESTRING,inboundFields);
  
		List<String> conversationFields = new List<String>{Constants.INBOUNDCOMMSGFIELD,Constants.RELATEDTOFIELD};
		SecurityService.checkInsertable(Constants.CONVERSATIONSTRING,conversationFields);
  
			  Map<String,SObject> phoneNumberVsSObjectMap = new Map<String,SObject>();
  
		//Map<String, Object> valueMap = (Map<String, Object>)valueObj;
  
		String fromMobNo;
		String msgBody;
  
			  if(valueMap != null){
				  Map<String,Object> vMap = (Map<String,Object>)valueMap.get('payload');
				  for(Object messageObj : (List<Object>)vMap.get(Constants.MESSAGESSTRING)){
					  Map<String,Object> messageMap = (Map<String,Object>)messageObj;
					  fromMobNo = (String)messageMap.get(Constants.FROMSTRING);
					  if(messageMap.containsKey(Constants.TEXTSTRING)){
						  Map<String,Object> textMap = (Map<String,Object>)messageMap.get(Constants.TEXTSTRING);
						  msgBody = (String)textMap.get(Constants.BODYSTRING);
					  }else if(messageMap.containsKey(Constants.REACTIONSTRING)){
						  Map<String,Object> reactionMap = (Map<String,Object>)messageMap.get(Constants.REACTIONSTRING);
						  msgBody = (String)reactionMap.get(Constants.EMOJISTRING);
					  }else if(messageMap.containsKey(Constants.IMAGESTRING)){
						  Map<String,Object> imageMap = (Map<String,Object>)messageMap.get(Constants.IMAGESTRING);
						  msgBody= (String)imageMap.get(Constants.IDFIELDSTRING);
                      }else if(messageMap.containsKey(Constants.TYPESTRING) && messageMap.get(Constants.TYPESTRING) == Constants.INTERACTIVESTRING){
                          Map<String,Object> interactiveMap = (Map<String,Object>)messageMap.get(Constants.INTERACTIVESTRING);
                          if(interactiveMap.containsKey(Constants.TYPESTRING) && interactiveMap.get(Constants.TYPESTRING) == 'button_reply'){
                              Map<String,Object> buttonReplyMap = (Map<String,Object>)interactiveMap.get(Constants.BUTTONREPLYSTRING);
                              if(buttonReplyMap.containsKey(Constants.TITLESTRING)){
                                  msgBody = (String)buttonReplyMap.get(Constants.TITLESTRING);
                              }
                          }else if(interactiveMap.containsKey(Constants.TYPESTRING) && interactiveMap.get(Constants.TYPESTRING) == 'list_reply'){
                              Map<String,Object> listReplyMap = (Map<String,Object>)interactiveMap.get(Constants.LISTREPLYSTRING);
                              if(listReplyMap.containsKey(Constants.TITLESTRING)){
                                  msgBody = (String)listReplyMap.get(Constants.TITLESTRING);
                              }
                          }
                      }else if(messageMap.containsKey(Constants.TYPESTRING) && messageMap.get(Constants.TYPESTRING) == Constants.BUTTONSTRING){
						Map<String,Object> buttonMap = (Map<String,Object>)messageMap.get(Constants.BUTTONSTRING);	
                          if(buttonMap.containsKey(Constants.TEXTSTRING)){
                              msgBody = (String)buttonMap.get(Constants.TEXTSTRING);
                          }
                      }
				  }
			  }
  
		List<Inbound_Message__c> inboundList = new List<Inbound_Message__c>();
			  //Prepare the inbound message record.
		Inbound_Message__c  inboundMsg = new Inbound_Message__c();
		inboundMsg.put(Constants.CHANNELFIELD,Constants.WHATSAPPSTRING);
		if(String.isNotBlank(msgBody)){
		  inboundMsg.put(Constants.MESSAGETEXTFIELD,msgBody);
		}
		inboundMsg.put(Constants.MOBILEFIELD,fromMobNo);
  
			  //get the common lookup fields for Inbound_Message__c
			  Set<String> inboundLookupFields = WhatsAppInboundHandler.getCustomLookupFields(Constants.INBOUNDMESSAGESTRING);
  
			  //get the common lookup fields for Outbound_Message__c
			  Set<String> outboundLookupFields = WhatsAppInboundHandler.getCustomLookupFields(Constants.OUTBOUNDMESSAGESTRING);
  
			  //get the outbound message records as we have to First search in the outbound messages for the mobile number from which message has been received.
			  phoneNumberVsSObjectMap = WhatsAppInboundHandler.getRelatedRecords(fromMobNo,outboundLookupFields);
  
			  //get the transactional records from send button configuration object to map with inbound message.
			  List<SObject> sObjRecordsList = WhatsAppInboundHandler.getRecordsBySendConfig(fromMobNo);
  
			  //Boolean to track if match is found in outbound message.
			  boolean relationFound = false;
				//fieldName to identify lookup in inbound which required to createconversation.
				String reletedId; // suhas
			  //get the custom lookup fields which are common on both objects so that we can identify the newly created lookups in future
			  for(String fieldName : WhatsAppInboundHandler.getCommonLookups(inboundLookupFields,outboundLookupFields)){
				  //get sobject record from map
				  SObject outboundRecord = phoneNumberVsSObjectMap.get(fromMobNo);
  
				  //check if mobile map contains the record with respect to mobile number.
				  if(phoneNumberVsSObjectMap.containsKey(fromMobNo)){
					  if(outboundRecord.get(fieldName) != null){
						  //fill the field with relationship.
						  inboundMsg.put(fieldName,outboundRecord.get(fieldName));
						  relationFound = true;
							reletedId = fieldName;// suhas
						  break;
					  }
				  }
			  }
  
			  //if relation is not filled with ooutbound, search for record from send button configuration.
			  if(!relationFound && sObjRecordsList.size() > 0){
				  //loop over the records
				  for(SObject sobj : sObjRecordsList){
					  //get an object name from sobject record.
					  String objNameString = String.valueOf(sobj.getSObjectType());
					  //check whether it is custom or not.
					  if(!objNameString.endsWithIgnoreCase(Constants.CUSTOMOBJECTSUFFIX)){
						  objNameString = objNameString + Constants.CUSTOMOBJECTSUFFIX;
					  }
					  //if lookup for sobject is available on inbound, populate it
					  if(inboundLookupFields.contains(objNameString)){
							reletedId = objNameString; // suhas
						  inboundMsg.put(objNameString,sobj.get(Constants.IDFIELDSTRING));
						  break;
					  }
				  }
			  }
  
			  inboundList.add(inboundMsg);
  
		//Prepare the input parameter.
		DatabaseService.DB_Input dbInput = new DatabaseService.DB_Input(inboundList,true,true,Constants.WAINBOUNDHANDLERCLASS);
  
		//Invoke the update call.
		DatabaseService.DB_Result dbResult = DatabaseService.dbInsert(dbInput);

  
		WhatsAppInboundHandler.createConversations(dbResult, reletedId);
  
		}catch (Exception ex) {
			system.debug('@@Line: '+ex.getLineNumber());
			system.debug('@@msg: '+ex.getMessage());
			system.debug('@@trace '+ex.getstacktracestring());
  
		  ApplicationLogger.logException(ex);
		}
	}
  
	  /**
	  *  @methodname : getRelatedRecords
	  *  @author : Shriram Mahamuni
	  *  @objectreferenced  : Outbound_Message__c
	  *  @param  : String, List<String>
	  *  @description  :  This method finds the record to be attached to inbound message.
											  First it will look into outbound message by matching the mobile munber and attach the relationship accordingly.
	  *  @return : Map<String,SObject>
	  */
	  public static Map<String,SObject> getRelatedRecords(String mobileNumberString,Set<String>outboundFields){
		  Date today = Date.today();
		  Date createdDate = today.addDays(-Constants.OBMESSAGEPASTDAYS);
		  Map<String,SObject> phoneNumberVsSObjectMap = new Map<String,SObject>();
		  outboundFields.add(Constants.IDFIELDSTRING);
		  outboundFields.add(Constants.NAMESTRING);
		  outboundFields.add(Constants.INBOUNDQUERYMOBILESTRING);
		  String fieldsString = String.Join(outboundFields,',');
  
		  List<Object> queryVariables = new List<Object>{String.escapeSingleQuotes(fieldsString)};
		  Map<String,Object> queryBindValues = new Map<String, Object>{'mobileNumberString'=>mobileNumberString,'createdDate'=>createdDate};
  
		  String queryTemplateString = 'SELECT {0} FROM Outbound_Message__c Where Mobile__c =:mobileNumberString  AND CreatedDate >=: createdDate ORDER BY CreatedDate Desc';
  
		  String query = String.format(queryTemplateString, queryVariables);
  
		  List<SObject> relatedRecordList = Database.queryWithBinds(query,queryBindValues,AccessLevel.SYSTEM_MODE);
  
		  for(SObject sObjRecord : relatedRecordList){
				  if(mobileNumberString.equalsIgnoreCase((String)sObjRecord.get(Constants.MOBILEFIELD))){
					  phoneNumberVsSObjectMap.put(mobileNumberString,sObjRecord);
					  break;
				  }
			  }
		  return phoneNumberVsSObjectMap;
	  }
  
	  /**
	  *  @methodname : getRecordsBySendConfig
	  *  @author : Shriram Mahamuni
	  *  @objectreferenced  : Send_Configuration__c
	  *  @param  : String
	  *  @description  : This method finds the record to be attached to inbound message.
										   It will look into Send button configuration object and prepare the query accordingly and then query records by matching the mobile munber and return the result accordingly.
	  *  @return : List<SObject>
	  */
	  public static List<SObject> getRecordsBySendConfig(String mobileNumberString){
		  List<String> queryList = new List<String>();
  
		  //this variable will hold the variable map to be replaced in query.
		  Map<String,Object> queryValuesMap = new Map<String,Object>{'mobileNumberString'=>mobileNumberString};
  
		  //get all send button configurations from org.
		  //we are supporting maximum of 10 records as the query is inside for loop.
		  for(Send_Configuration__c sendBtnConfigRecord : [SELECT Id, Name, Name_Field__c, Object_Name__c, Phone_Fields__c FROM Send_Configuration__c WITH SYSTEM_MODE LIMIT 10]){
			  String phoneField = sendBtnConfigRecord.Phone_Fields__c;
			  String phoneFields = '';
			  String queryString = '';
			  List<String> phoneFieldsList = new List<String>();
  
			  //this variable will hold the variables for query
			  List<Object> queryVariables = new List<Object>();
			  queryVariables.add(String.escapeSingleQuotes(Constants.IDFIELDSTRING));
			  queryVariables.add(String.escapeSingleQuotes(sendBtnConfigRecord.Name_Field__c));
  
			  if(phoneField.contains(',')){
				  phoneFieldsList = phoneField.split(',');
				  phoneFields = String.join(phoneFieldsList,',');
			  }else{
				  phoneFields = phoneField;
			  }
			  queryVariables.add(String.escapeSingleQuotes(phoneFields));
			  queryVariables.add(String.escapeSingleQuotes(sendBtnConfigRecord.Object_Name__c));
			  String whereString = '';
			  if(phoneFieldsList.size() > 0 ){
				  for(String field : phoneFieldsList){
					  whereString = whereString + field +'=: mobileNumberString'+' OR ';
				  }
		  whereString = whereString.removeEnd(' OR ');
			  }else{
				  whereString = whereString + phoneFields + '=: mobileNumberString';
			  }
  
			  queryVariables.add(String.escapeSingleQuotes(whereString));
  
			  queryString = 'Select {0},{1},{2} FROM {3} WHERE {4}';
  
			  queryString = String.format(queryString,queryVariables);
			  queryList.add(queryString);
		  }
  
		  List<SObject> resultList = new List<SObject>();
		  for(String queryString : queryList){
			  List<SObject> sobjList = Database.queryWithBinds(queryString,queryValuesMap,AccessLevel.SYSTEM_MODE);
			  resultList.addAll(sobjList);
		  }
		  return resultList;
	  }
  
  
	  /**
		*  @methodname : getCustomLookupFields
		  *  @author : Shriram Mahamuni
		  *  @objectreferenced : None
		  *  @param  : String
		  *  @description  : This method is responsible for querying and identifying custom lookup fields on an object.
											   It returns a list of API names of the custom lookup fields.
		  *  @return : Set<String>
	  */
	  public static Set<String> getCustomLookupFields(String objectName) {
			  Set<String> customLookupFields = new Set<String>();
			  try{
				  Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
				  Map<String, Schema.SObjectField> fields = describeResult.fields.getMap();
				  for (Schema.SObjectField field : fields.values()) {
					  Schema.DescribeFieldResult fieldResult = field.getDescribe();
					  if (fieldResult.isCustom() && fieldResult.getType() == Schema.DisplayType.REFERENCE) {
						  customLookupFields.add(fieldResult.getName());
					  }
				  }
			  } catch (Exception e) {
				  ApplicationLogger.logException(e);
			  }
			  return customLookupFields;
	  }
  
  /**
	*  @methodname : getCommonLookups
	  *  @author : Shriram Mahamuni
	  *  @objectreferenced  : None
	  *  @param  : List, List
	  *  @description  : This method is responsible for identifying and returning a list of common lookup fields that exist on both of the specified lists.
	  *  @return : Set<String>
  */
	  public static Set<String> getCommonLookups(Set<String> inboundFieldsList, Set<String> outboundFieldsList) {
		  Set<String> commonLookups = new Set<String>();
		  for (String element : inboundFieldsList) {
			  if (outboundFieldsList.contains(element)) {
				  commonLookups.add(element);
			  }
		  }
		  return commonLookups;
	  }
  
	/**
		*  @methodname : createConversations
	  *  @author : Shriram Mahamuni
	  *  @objectreferenced  : Conversation__c
	  *  @param  : DB_Result
	  *  @description  : This method will create the conversation records against the new incoming message.
	  *                  It will also find the appropreate match for the recepient record and tag it to the conversation.
	  *  @return : void
	*/
	public static void createConversations(DatabaseService.DB_Result ibMsgResultSet, String reletedId) {
	  String ibMsgRecordId;
	  if(ibMsgResultSet.successRecordIds.size() > 0){
		  ibMsgRecordId = ibMsgResultSet.successRecordIds[0];
	  }
  
	  List<Conversation__c> conversationList = new List<Conversation__c>();
	  Conversation__c convRecord = new Conversation__c();
	  String relatedTo = '';
	  convRecord.Inbound_Communication_Message__c = ibMsgRecordId;

		if(String.isNotBlank(String.valueOf((ibMsgResultSet.idToSObjectMap.get(ibMsgRecordId)).get(reletedId)))){
			relatedTo = String.valueOf((ibMsgResultSet.idToSObjectMap.get(ibMsgRecordId)).get(reletedId));
		}

		/*if(String.isNotBlank(String.valueOf((ibMsgResultSet.idToSObjectMap.get(ibMsgRecordId)).get(reletedId)))){
			relatedTo = String.valueOf((ibMsgResultSet.idToSObjectMap.get(ibMsgRecordId)).get(reletedId));
		}else if(String.isNotBlank(String.valueOf((ibMsgResultSet.idToSObjectMap.get(ibMsgRecordId)).get('Lead__c')))){
		  relatedTo = String.valueOf((ibMsgResultSet.idToSObjectMap.get(ibMsgRecordId)).get('Lead__c'));
		}*/
  
		if(String.isNotBlank(relatedTo)){
			convRecord.Related_To__c = relatedTo;
		}
  
	  conversationList.add(convRecord);
  
	  //Prepare the input parameter.
	  DatabaseService.DB_Input dbInput = new DatabaseService.DB_Input(conversationList,true,true,Constants.WAINBOUNDHANDLERCLASS);
  
	  //Invoke the Insert call.
	  DatabaseService.DB_Result dbResult = DatabaseService.dbInsert(dbInput);
	}
  }