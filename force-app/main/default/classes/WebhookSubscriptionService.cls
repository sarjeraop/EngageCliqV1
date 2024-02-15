global without sharing class WebhookSubscriptionService {

    public static void processRequest (Object requestBody, String channelName) {
        String serviceClassName;

		//get all channels in form of map from org.
		Map<String, Channel__mdt > allChannelsMap = (Map<String,Channel__mdt>)Utility.getAllChannelsMap();
		Map<String, Channel__mdt > allChannelsMapInLowerCase = new Map<String,Channel__mdt>();

		for(String key : allChannelsMap.keySet()){
			allChannelsMapInLowerCase.put(key.toLowerCase(),allChannelsMap.get(key));
		}


		//get the desired webhook service class from metadata.
		if(String.isNotBlank(channelName) && allChannelsMapInLowerCase.containsKey(channelName.toLowerCase())){
	    serviceClassName = (String)allChannelsMapInLowerCase.get(channelName.toLowerCase()).Webhook_Service_Class__c;
	  }else{
			ApplicationLogger.logException(new CustomException(Constants.ERRORMSGINCORRECTCHANNELNAME));
		}

		//
	  if(String.isNotBlank(serviceClassName)){ 
			try{
				Type classType = Type.forName(serviceClassName); 
	    	if (classType != null && classType.newInstance() instanceof IWebhookService) {
	    	  IWebhookService instance = (IWebhookService) classType.newInstance();
	    	  instance.process(requestBody); // Call a method on the dynamically instantiated instance
	    	}else{
					ApplicationLogger.logException(new CustomException(Constants.ERRORMSGINCORRECTSERVICECLASS));
				}
			}catch(Exception ex){
				ApplicationLogger.logException(ex);
			}
	  }
  }
}