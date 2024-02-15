/**  
*  @classname  : WhatsAppOutboundHandler
*  @author : Shriram Mahamuni
*  @date : 17-10-2023
*  @description  : This class responsible for handling and processing outbound messages and interactions from WhatsApp (WA).
*                  It serves as the intermediary layer which will process outgoing incoming message and process it in system.
*  @modificationlog
*  	#		    Date		        Description		    Modified By
*	  1.	   	17-10-2023      Initial version 	Shriram Mahamuni	  												
*/
public inherited sharing class WhatsAppOutboundHandler implements IWebhookServiceHandler{

  /**  
  *  @methodname : execute
  *  @author : Shriram Mahamuni
  *  @objectreferenced  : Outbound_Message__c
  *  @param  : Object (Deserialized value Payload received in Whatsapp payload )
  *  @description  : This method is processing the object and prepare the outbound message record.
  *  @return : void
  */
  public static void execute(Object valueObj) {
    try {

        Map<String, Object> objMap = (Map<String, Object>) valueObj;
        Webhook_Configuration__mdt objWbkConfg = (Webhook_Configuration__mdt)objMap.get('confgData');
        if (objWbkConfg != null && objWbkConfg.Enable_Logging__c) {
          String payload = JSON.serialize(objMap.get('payload'));
          Utility.createWebhookLog(Constants.WHATSAPPSTRING,payload);
        }

        List<String> obFieldList = new List<String>{Constants.SENTTIMESTRING,Constants.DELIVEREDTIMESTRING,Constants.READTIMESTRING};

        //Map<String, Object> objMap = (Map<String, Object>)valueObj;

        String whatsappId;
        String status;
        String timeStamp;
				String errorMsgString;
      try {
        if(objMap != null){
          Map<String,Object> vMap =  (Map<String,Object>)objMap.get('payload');
          for(Object statusesObj : (List<Object>)vMap.get(Constants.STATUSESSTRING)){
            Map<String,Object> statusesMap = (Map<String,Object>)statusesObj;
            whatsappId = (String)statusesMap.get(Constants.IDFIELDSTRING);
            status = (String)statusesMap.get(Constants.OUTBOUNDSTATUSSTRING);
            timestamp = (String)statusesMap.get(Constants.TIMESTAMPSTRING);
            if(status == Constants.FAILEDSTRING){
              for(Object errorObj : (List<Object>)statusesMap.get(Constants.ERRORSSTRING)){
                Map<String,Object> errorsMap = (Map<String,Object>)errorObj;
                errorMsgString = (String)errorsMap.get(Constants.TITLESTRING);
              }
            }
          }
        }
      } catch (Exception ex) {
        ApplicationLogger.logException(new CustomException(Constants.ERRORMSGINCORRECTWEBHOOKPAYLOAD));
      }

        List<Outbound_Message__c> outboundMsgList = new List<Outbound_Message__c>();
        Outbound_Message__c outboundObj = new Outbound_Message__c();

        if((status == Constants.SENTSTATUSESTRING || status == Constants.READSTATUSESTRING || status == Constants.DELIVEREDSTATUSESTRING || status == Constants.FAILEDSTRING) &&( status != null)){
          if(status == Constants.SENTSTATUSESTRING){
            outboundObj.SentTime__c = DateTime.newInstance(Long.valueOf(timeStamp)*1000);
          }
          if(status == Constants.DELIVEREDSTATUSESTRING){
            outboundObj.DeliveredTime__c = DateTime.newInstance(Long.valueOf(timeStamp)*1000);
          }
          if(status == Constants.READSTATUSESTRING){
              outboundObj.ReadTime__c = DateTime.newInstance(Long.valueOf(timeStamp)*1000);
          }
					if(status == Constants.FAILEDSTATUSESTRING){
						outboundObj.FailedTime__c = DateTime.newInstance(Long.valueOf(timeStamp)*1000);
						outboundObj.Failure_Reason__c = errorMsgString;
				  }
            if(String.isNotBlank(WhatsAppOutboundHandler.getOutboundMessageId(whatsappId))){
                outboundObj.Id = (Id)WhatsAppOutboundHandler.getOutboundMessageId(whatsappId);
                outboundMsgList.add(outboundObj);   
            }

        }else{
          ApplicationLogger.logException(new CustomException(Constants.ERRORMSGINCORRECTSTATUS));
        } 

        DatabaseService.DB_Input dbInput = new DatabaseService.DB_Input(outboundMsgList,true,true,Constants.WAOUTBOUNDHANDLERCLASS);

        //Invoke the update call.
        DatabaseService.DB_Result dbResult = DatabaseService.dbUpdate(dbInput);
        } catch (Exception ex) {
          ApplicationLogger.logException(ex);
      }
  }

  /**  
    *  @methodname : getOutboundMessageId
    *  @author : Shriram Mahamuni
    *  @objectreferenced  : Outbound_Message__c
    *  @param  : String
    *  @description  : This method is responsible for getting a unique outbound record with the help of whatspp id. 
    *  @return : String
  */
  public static String getOutboundMessageId(String idString) {
    String userType = UserInfo.getUserType();
    String obTemplateId = '';
    try{
      List<Outbound_Message__c> outBoundMsgList = new List<Outbound_Message__c>();
      
      String queryMode = userType.equalsIgnoreCase(Constants.GUESTSTRING) ? 'SYSTEM_MODE' : 'USER_MODE';
      String query = 'SELECT Id FROM Outbound_Message__c Where External_ID__c =: idString WITH '+queryMode+' Limit 1';
      
      outBoundMsgList = database.query(query);
      
      if(outBoundMsgList.size() > 0){
        obTemplateId = outBoundMsgList[0].Id;
      }
    }catch(Exception ex){
      ApplicationLogger.logException(ex);
    }
    return obTemplateId; 
  }
}