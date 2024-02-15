/**  
*  @classname  : WhatsappWebhookService
*  @author : Shriram Mahamuni
*  @date : 22-10-2023
*  @description  : 	This class provides functionality related to WhatsApp Webhooks. 
										It includes method to parse and handle webhook payloads, validate requests, and perform actions based on the received data via handler classes.
*  @modificationlog
*  	#		Date(DD/MM/YYYY)		Description				Modified By
*	1.		22-10-2023				Initial Version	  		Shriram Mahamuni													
*/

public inherited Sharing class WhatsappWebhookService Implements IWebhookService{
	/**  
	  *  @methodname : process
		*  @author : Shriram Mahamuni
		*  @objectreferenced  : Webhook_Configuration__mdt
		*  @param  : Object (It expect the request body received from webhook.)
		*  @description  : This method is responsible for processing the whatsapp specific payload and invoke the specific service handler class. 
		*  @return : void
	*/
  public static void process(Object requestBodyString){
	    string channelName = Constants.WHATSAPPSTRING;
		Map<String,Webhook_Configuration__mdt> allWebhookConfigurationsMap = (Map<String,Webhook_Configuration__mdt>)Utility.getAllWebhookConfigurations(channelName);
		Map<String,Webhook_Configuration__mdt> allWebhookConfigurationsMapInLowerCase = new Map<String,Webhook_Configuration__mdt>();
		Map<String,Object> inputMap = new Map<String,Object>();

		for(String key : allWebhookConfigurationsMap.keySet()){
			allWebhookConfigurationsMapInLowerCase.put(key.toLowerCase(),allWebhookConfigurationsMap.get(key));
		}


		Object msgObject;
		Object statusesObj;
		Object valueObject;
		String eventString;
		String fieldString;
		String serviceHandlerClassName;


		try{
			//Parse the value object to identify from which service, the request is received.
			Map<String, Object> requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(String.valueOf(requestBodyString));
			for(object entryObj : (List<Object>)requestBodyMap.get(Constants.PAYLOADENTRY)) {
				Map<String, Object> entryMap = (Map<String, Object>) entryObj;
				for(object changeObj : (List<Object>)entryMap.get(Constants.PAYLOADCHANGES)) {
					Map<String, Object> changeMap = (Map<String, Object>) changeObj;
					valueObject = (Object) changeMap.get(Constants.PAYLOADVALUE);
					Map<String, Object> valueMap = (Map<String, Object>) valueObject;
					msgObject = valueMap.get(Constants.MESSAGESSTRING);
    			statusesObj = valueMap.get(Constants.STATUSESSTRING);
    			eventString = (String)valueMap.get(Constants.EVENTSTRING);
				}
			}
		}catch(Exception ex){
            system.debug('@@@@@ex'+ex.getMessage());
            system.debug('@@@@@ex Line'+ex.getLineNumber());
            system.debug('@@@@@ex Line'+ex.getStackTraceString());
			ApplicationLogger.logException(new CustomException(Constants.ERRORMSGINCORRECTWEBHOOKPAYLOAD));
		}

		//Identify the service type to be invoked
    if (msgObject != null) {
        fieldString = Constants.MESSAGESSTRING;
    } else if(statusesObj != null){
        fieldString = Constants.STATUSESSTRING;
    } else if(String.isNotBlank(eventString)){
        fieldString = Constants.SERVICESMESSAGETEMPLATESTATUSUPDATESTRING;
    }

		//get the service class name based on service type from metadata
		if(allWebhookConfigurationsMapInLowerCase.containsKey(fieldString)){
			serviceHandlerClassName = allWebhookConfigurationsMapInLowerCase.get(fieldString).Service_Handler_Class__c;
			inputMap.put('confgData',allWebhookConfigurationsMapInLowerCase.get(fieldString));
		}else{
			ApplicationLogger.logException(new CustomException(Constants.ERRORMSGINCORRECTWASERVICEHANDLERCLASS));
		}

		//Make an instance of service handler class and pass data for further processing.
		if(String.isNotBlank(serviceHandlerClassName)){
			try{
				Type classType = Type.forName(serviceHandlerClassName); 
				if (classType != null && classType.newInstance() instanceof IWebhookServiceHandler) {
					IWebhookServiceHandler instance = (IWebhookServiceHandler) classType.newInstance();
					inputMap.put('payload',valueObject);
					instance.execute(inputMap); // Call a method on the dynamically instantiated instance
				}else{
					ApplicationLogger.logException(new CustomException(Constants.ERRORMSGINCORRECTWASERVICEHANDLERCLASS));
				}
            }catch(Exception ex){
                system.debug('@@@@@ex'+ex.getMessage());
				Applicationlogger.logException(ex);
			}
		}
  }
}