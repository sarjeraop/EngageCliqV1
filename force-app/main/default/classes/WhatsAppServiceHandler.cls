/**  @classname    : WhatsAppServiceHandler
  *  @author       : Rati Kulkarni
  *  @date         : 19-Oct-2023
  *  @description  : class representing implementation of message sending structure through WhatsApp channel.
  *  @version      : 1.0   Created sendMessage - Rati Kulkarni
*/

public with sharing class WhatsAppServiceHandler implements IChannelServiceHandler{
  Map<String,Object> notificationData = new Map<String,Object>();  
  List<SObject> recordList = new List<SObject>();
  List<String> recordIds = new List<String>();
  public String objectAPIName {get; set;}
  String mobileFieldAPIName;
  //List<
  String nameFieldAPIName;
  String templateId;
  String messageText;
  public List<Outbound_Message__c> outboundMessages = new List<Outbound_Message__c>();
  String returnType;
  String json;
  Map<Object,Object> attachment= new Map<Object,Object>();  
  public final static string CONTENT_TYPE = 'application/json';
  public final static string AUTHORIZATION = 'Bearer ';
  
    /**
   * @methodname		     init
   * @author				 Rati Kulkarni
   * @objectreferenced	     HttpRequest,HttpResponse,API_Key_Configuration__mdt   
   * @params				 Map<String,Object>
   * @description			 This method initialises all parameters required to send message from UI request
   * @return				 WhatsAppServiceHandler.
   */
    public WhatsAppServiceHandler init(Map<String,Object> mapChannelRequest) {
        this.notificationData = mapChannelRequest;
        //this.recordList = (List<sObject>)this.notificationData.get('records');
        this.recordIds = (List<String>)this.notificationData.get('recordIds');
        this.objectAPIName = (String)this.notificationData.get('objectAPIName');
        //Send_Button_Configuration__c objSBC = [Select mobileFieldAPIName,nameFieldAPIName FROM Send_Button_Configuration__c Where objectAPIName = :this.objectAPIName limit 1];
        //this.mobileFieldAPIName = (String)this.notificationData.get('mobileFieldAPIName');
        //this.nameFieldAPIName = (String)this.notificationData.get('nameFieldAPIName');
        this.mobileFieldAPIName = (String)this.notificationData.get('mobileFieldAPIName');
        this.nameFieldAPIName = (String)this.notificationData.get('nameFieldAPIName');
        this.templateId = (String)this.notificationData.get('templateId');
        this.messageText = (String)this.notificationData.get('messageText');
        this.attachment = (Map<Object,Object>)this.notificationData.get('document');
        return this;
    }
    
    
    /**
   * @methodname		     validate
   * @author				 Rati Kulkarni
   * @objectreferenced	     
   * @params				 none
   * @description			 This method validates input paramenters before performing send operation
   * @return				 WhatsAppServiceHandler.
   */
    public WhatsAppServiceHandler validate(){// write validation code here.
        return this;
    }
    
    /**
   * @methodname		     processRequest
   * @author				 Rati Kulkarni
   * @objectreferenced	     
   * @params				 none
   * @description			 This method performs actual message send functionality through callout
   * @return				 WhatsAppServiceHandler.
   */
    public WhatsAppServiceHandler processRequest(){
    // write request code to Utility Class.
    Map<String,Object> mapData = new Map<String,Object>();
    Map<String,Object> mapIdvsMergedMessage = new Map<String,Object>(); 
    Map<String,Map<String,String>> mapIdvsParameters = new Map<String,Map<String,String>>();  
    //Map<String,String> mapParameters = new Map<String,String>(); 
    // Prepare the JSON according to type of Json here.i.e. plain message / UI Template / BI Template
    if(this.recordIds.isEmpty()){
      return this;
    }
    //public static List<SObject> getRecordData(List<String> recordIds, String recipientField, String objectApiName, String optOutIn){
    this.recordList = Utility.getRecordData(this.recordIds, this.mobileFieldAPIName, this.objectAPIName);
    if(String.isBlank(this.templateId)){
      if((this.messageText.contains('{!')) && (this.messageText.contains('}'))){
        mapIdvsMergedMessage = Utility.getMergedMessage(this.recordList,Utility.replaceMessageWhatsApp(this.messageText), this.objectAPIName, this.templateId);  
        this.messageText = (String)mapIdvsMergedMessage.get(recordList[0].Id);
      }
      if(this.attachment != null && this.attachment.size() > 0){
        json = Utility.getJsonFromStaticResource('WhatsAppDocumentJSON.json');
        json = json.replace('<DOCUMENT_LINK>',String.valueOf(this.attachment.get('Url')));
        json = json.replace('<DOCUMENT_CAPTION_TO_SEND>',Utility.replaceMessageWhatsApp(this.messageText));
        json = json.replace('<DOCUMENT_FILENAME>',String.valueOf(this.attachment.get('Name')));
      }else{
        // If plain text message
        json = Utility.getJsonFromStaticResource('WhatsAppPlainTextJSON.json');
        json = json.replace('<MESSAGEBODY>', Utility.replaceMessageWhatsApp(this.messageText));
      }
    }else{
     // template message
      WhatsApp_Template__c objTemplate = Utility.getTemplateFromTemplateId(this.templateId);
      if(objTemplate != null){
        
        if(objTemplate.Template_Type__c == System.Label.user_initiative){
          // UI Template json
          json = objTemplate.Json_Payload__c;
        }else{
          // BI template json
          json = Utility.getJsonFromStaticResource('WhatsAppBITemplateJSON.json');
          // Added by Abhi  - Do due diligence and change the Name to Name__c
          json = json.replace('<TEMPLATENAME>', String.valueOf(objTemplate.Name__c));
          // added code to support language by Rati.
          json = json.replace('<LANGUAGE>', String.valueOf(objTemplate.Language__c));
        }
         System.debug('json *** :'+json); 
          
        if(objTemplate.Message_Body__c != null){
        // get merged message 
        if((objTemplate.Message_Body__c.contains('{!')) && (objTemplate.Message_Body__c.contains('}'))){
          
          if(objTemplate.Template_Type__c == System.Label.user_initiative){
            //UI
            mapIdvsMergedMessage = Utility.getMergedMessage(this.recordList,Utility.replaceMessageWhatsApp(objTemplate.Message_Body__c), this.objectAPIName, this.templateId); 
          }else{
              //BI
            
            //mapParameters.put('hasParams','hasParams');
            mapData = Utility.getMergedMessage(this.recordList,Utility.replaceMessageWhatsApp(objTemplate.Message_Body__c), this.objectAPIName, this.templateId,true); 
            mapIdvsMergedMessage = (Map<String,Object>)mapData.get('mapIdVsMergedMessage');
            mapIdvsParameters = (Map<String,Map<String,String>>)mapData.get('mapIdvsParameters');
           }
          
          this.messageText = '';
        }else{
          this.messageText = Utility.replaceMessageWhatsApp(objTemplate.Message_Body__c);
        }
      }
      }
    }
       // set API KEY
       Channel_Configuration__mdt apiObject =  new Channel_Configuration__mdt();
       String channelName = Constants.whatsappString;
       apiObject = [Select API_key__c, PhoneNo_Id__c,Endpoint_URL__c from Channel_Configuration__mdt WHERE DeveloperName =:channelName  WITH USER_MODE  Limit 1];

       String phoneNoId =apiObject.PhoneNo_Id__c;
       String apiKEY =apiObject.API_Key__c;
       String endPointURL = apiObject.EndPoint_URL__c;
        
       String  jsonText = json;
       Map<String,String> mapParameters = new Map<String,String>();
       for(SObject record : recordList){
         // for each record create outbound message.
         json = jsonText;
        Outbound_Message__c objMessage = new Outbound_Message__c();
        objMessage.Channel__c  = channelName;
        if(String.isBlank(this.templateId)){
            objMessage.Message_Text__c = this.messageText;
            objMessage.Mobile__c = (String)record.get(this.mobileFieldAPIName);
            if(this.attachment != null && this.attachment.get('Url') != null){
                    objMessage.Media__c = (String)this.attachment.get('Id');
            }
        }else{
            if(this.messageText == ''){// if merged message
                objMessage.Message_Text__c = (String)mapIdvsMergedMessage.get(record.Id);
                //if(objTemplate.Template_Type__c == 'Business Initiative'){
                  
                if(mapIdvsParameters.size()>0){
                  mapParameters = (Map<String,String>)mapIdvsParameters.get(record.Id);
                  JSONGenerator gen = System.JSON.createGenerator(true);
                  gen.writeStartObject();
                  gen.writeStringField('type', 'body');
                  gen.writeFieldName('parameters');
                  gen.writeStartArray();
                  integer counter = 1;
                  for(String params : mapParameters.keySet()){
                      gen.writeStartObject();
                      gen.writeStringField('type', 'text');
                      if(String.isBlank(mapParameters.get(params))){
                      gen.writeStringField('text', '{{'+counter+'}}');
                       } else {
                        gen.writeStringField('text', mapParameters.get(params));
                      }
                      gen.writeEndObject(); 
                      counter++;
                  }
                  gen.writeEndArray(); 
                  gen.writeEndObject();  
                  json = json.replace('<COMPONENTS>',gen.getAsString());     
                  System.debug('BI JSON :'+ json);
                }
            //  }
            }else{
                objMessage.Message_Text__c = this.messageText;
            }
            objMessage.WhatsApp_Template__c = this.templateId;
        }
        objMessage.Mobile__c = (String)record.get(this.mobileFieldAPIName);
        //objMessage.Source_Record_Id__c = String.valueOf(record.get('Id'));
        // Schema call to get all fields for outbound message
        if(!Test.isRunningTest()){
            Set<String> objectFields = Schema.SObjectType.Outbound_Message__c.fields.getMap().keySet();     
            if(this.objectAPIName.endsWith(Constants.CUSTOMOBJECTSUFFIX)) {
                // custom object
                String fieldNameWithoutC = this.objectAPIName.substring(0,this.objectAPIName.lastIndexOf('__'));
                //Manage package check
                if(String.isNotEmpty(fieldNameWithoutC) && fieldNameWithoutC.contains('__')){ 
                    String fieldNameWithoutPkgPrefix =fieldNameWithoutC.substring(fieldNameWithoutC.IndexOf('__')+2);
                    //Schema.DescribeFieldResult dfr = Outbound_Message__c.this.objectAPIName.getDescribe();
                    if(objectFields.contains((fieldNameWithoutPkgPrefix+Constants.CUSTOMOBJECTSUFFIX).toLowerCase())){
                        // field lookup created on outbound_message__c
                        objMessage.put(fieldNameWithoutPkgPrefix+Constants.CUSTOMOBJECTSUFFIX,String.valueOf(record.get('Id')));
                    }
                    else{ 
                        // field lookup not found
                        CustomException customEx = new CustomException(System.Label.reference_field_error);
                        ////ApplicationLogger.logException(customEx); 
                        throw customEx;           
                    }  
                }
                else{
                    // Custom object without manage package
                    if(objectFields.contains(this.objectAPIName.toLowerCase())){
                        // field lookup created on outbound_message__c
                        objMessage.put(this.objectAPIName,String.valueOf(record.get('Id')));
                    }
                    else{ 
                        // field lookup not created on outbound_message__c
                        CustomException customEx = new CustomException(System.Label.reference_field_error);
                        //ApplicationLogger.logException(customEx); 
                        throw customEx;           
                    } 
                }
                
            } 
            else{ // standard object
                String referenceField = this.objectAPIName+Constants.CUSTOMOBJECTSUFFIX;
                // field lookup created on outbound_message__c
                if(objectFields.contains(referenceField.toLowerCase())){
                    objMessage.put(referenceField,String.valueOf(record.get('Id'))); 
                }
                else{ 
                    // field lookup not created on outbound_message__c
                    CustomException customEx = new CustomException(System.Label.reference_field_error);
                    // ApplicationLogger.logException(customEx); 
                    throw customEx;           
                }
            }
        }
        
        if(record.get(this.mobileFieldAPIName) != null){
            json = json.replace('<MOBILEPHONE>',(String)record.get(this.mobileFieldAPIName) );
        }else{
            continue;
        }
          if(json.containsIgnoreCase('<MESSAGEBODY>')){
            	json = json.replace('<MESSAGEBODY>', String.valueOf(objMessage.get('Message_Text__c')));
        	}
          if(json.containsIgnoreCase('<COMPONENTS>')){
            json = json.replace('<COMPONENTS>','');     
          }
           system.debug('json : '+json);
    // call utility
        /****************** Need to move to Utility **************************/
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        // get APIKey and PhoneNumber Id from metadata
        //req.setEndpoint(endPointURL + phoneNoId + '/messages'); 
        req.setEndpoint('callout:Whatsapp_Credentials');
        req.setHeader('Content-Type', CONTENT_TYPE);
        req.setMethod('POST');       
        req.setBody(json);        
        //req.setHeader('Authorization', AUTHORIZATION +apiKEY);  
         //Send the request to API
           system.debug('request: '+req);
           HttpResponse res = h.send(req);
           system.debug('response: '+res);
        

        
        String jsonResponse = res.getBody();
        /****************** Need to move to Utility **************************/
        Map<String,Object> responseMap = (Map<String, Object>) System.JSON.deserializeUntyped(jsonResponse);                  
        Map<String, Object> errorData = (Map<String, Object>)responseMap.get('error');
           system.debug('errorData :'+errorData);
            if(errorData != null){
                if(errorData.containsKey('error_data')){
                	Map<String, Object> errorDetails = (Map<String, Object>)errorData.get('error_data');
                    objMessage.Failure_Reason__c = (String)errorData.get('message') + '. Error Details : '+ (String)errorDetails.get('details'); //'Error in sending Message';      
                }else{
                    objMessage.Failure_Reason__c = (String)errorData.get('message');
                }
                objMessage.FailedTime__c = System.now();
                
           
                // log in apiLogger
                // throw new applicationException(String.valueOf(errorData.get('details')));
            }
            system.debug('res.getStatusCode() :'+res.getStatusCode());
            if(res.getStatusCode() == Constants.STATUSCODE){ // success
                // get whatsappId from response.
                List<Map<String,Object>> data = new List<Map<String,Object>>();
                Map<String,Object> messageResponse = new Map<String,Object>();
                    if(responseMap.get('messages') != null){
                        for (Object instance : (List<Object>)responseMap.get('messages')){
                            data.add((Map<String, Object>)instance);
                        }
                    }
                    if(data.size() > 0){
                        messageResponse = data[0];
                    }
                    if(messageResponse.get('id') !=null){
                        objMessage.External_ID__c = String.valueOf(messageResponse.get('id')); 
                    }
                   // objMessage.SentTime__c = System.now();
            }/*else{
                objMessage.FailedTime__c = System.now();
                objMessage.Failure_Reason__c = 'Error in sending Message';      
            }*/
            objMessage.Message_Text__c = Utility.replaceMessageTemplate(objMessage.Message_Text__c);
            this.outboundMessages.add(objMessage);
            }
                  
        //}
        return this;
        }
          
   /**
   * @methodname		     processResponse
   * @author				 Rati Kulkarni
   * @objectreferenced	     
   * @params				 none
   * @description			 This method performs post message send activity of creating outbound messages.
   * @return				 WhatsAppServiceHandler.
   */
    public WhatsAppServiceHandler processResponse(){
        // write Response Process code.
        Utility.createOutboundMessagesAndConversations(this.outboundMessages, this.objectAPIName);
        return this;  // return ApexResult for batch 
    }
    /**
   * @methodname		     getResult
   * @author				 Rati Kulkarni
   * @objectreferenced	     
   * @params				 none
   * @description			 This method returns outboundMessages created during message sending process.
   * @return				 ApexResultSet.
   */
    public ApexResultSet getResult(){
        ApexResultSet resultSet = new ApexResultSet();
        Map<String,Object> mapResult = new Map<String,Object>();
        mapResult.put('outboundMessages',this.outboundMessages);
        resultSet.data = mapResult;
        return resultSet;
    }
}