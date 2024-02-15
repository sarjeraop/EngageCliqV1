/**
 * @classname			WhatsAppAPICallOutController
 * @author				Rati Kulkarni
 * @date                28-August-2023
 * @description			This class is used to perform communication with WhatsApp
 * @modificationlog
 */


public with sharing class WhatsAppAPIService {
     /**
   * @methodname		    createWhatsAppTemplateAPIService
   * @author				Rati Kulkarni
   * @objectreferenced	    API_Key_Configuration__mdt,HttpRequest,HttpResponse
   * @params 				json
   * @description			This method call API service to create New WhatsAPP Template at WhatsApp.
   * @return				Id of Schedule_Communication__c
   */
    @AuraEnabled //Map<String,Object>
    public static Map<String,String> createWhatsAppTemplateAPIService(String json){
        //ApexResultSet apexResult = new ApexResultSet();
        Map<String,String> resultMap = new Map<String,String>();
        try{
            String whatsAppBusinessID;
            String apiKEY;

            // get API and BusinessID from metadata
            Channel_Configuration__mdt apiObject =  new Channel_Configuration__mdt();
            String channelName = Constants.whatsappString;
            apiObject = [Select API_key__c, Business_ID__c,Endpoint_URL__c from Channel_Configuration__mdt WHERE DeveloperName =:channelName  WITH USER_MODE  Limit 1];

            whatsAppBusinessID =apiObject.Business_ID__c;
            apiKEY =apiObject.API_Key__c;
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://graph.facebook.com/v17.0/' + whatsAppBusinessID + '/message_templates');
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');       
            req.setBody(json);        
            req.setHeader('Authorization', 'Bearer '+apiKEY);  
            
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            String jsonResponse = res.getBody();
            
            Map<String,Object> responseMap = (Map<String, Object>) System.JSON.deserializeUntyped(jsonResponse);
            //if(responseMap.get('error'))
            resultMap.put('statusCode',String.valueOf(res.getStatusCode()));
            if(responseMap.containsKey('error'))
            {
                Map<String, Object> errorData = new Map<String, Object>();
            	errorData = (Map<String, Object>)responseMap.get('error');
                if(errorData != null){
                    resultMap.put('error',String.valueOf(errorData.get('message')));
                    resultMap.put('code',String.valueOf(errorData.get('code')));
                    resultMap.put('error_user_msg',String.valueOf(errorData.get('error_user_msg')));
                }
            // get templateId from response.
            }else{
                resultMap.put('templateId', String.valueOf(responseMap.get('id')));
                resultMap.put('templateStatus', String.valueOf(responseMap.get('status')));
                
                 }
             //resultMap;
             system.debug('resultMap :'+resultMap);
            return resultMap;
        }catch(Exception e){
            resultMap.put('error',e.getMessage());
            //apexResult.isSuccess = false;
            //apexResult.data = resultMap;
            return resultMap;
            //throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
   * @methodname		    editWhatsAppTemplateAPIService
   * @author				Rati Kulkarni
   * @objectreferenced	    API_Key_Configuration__mdt,HttpRequest,HttpResponse
   * @params 				json
   * @description			This method call API service to edit existing WhatsAPP Template at WhatsApp.
   * @return				Id of Schedule_Communication__c
   */
    @AuraEnabled //Map<String,Object>
    public static Map<String,String> editWhatsAppTemplateAPIService(String json,String templateId){
        Map<String,String> resultMap = new Map<String,String>();
        try{
           // String whatsAppBusinessID;
            String apiKEY;

            // get API and BusinessID from metadata
            Channel_Configuration__mdt apiObject =  new Channel_Configuration__mdt();
            String channelName = Constants.whatsappString;
            apiObject = [Select API_key__c, Business_ID__c,Endpoint_URL__c from Channel_Configuration__mdt WHERE DeveloperName =:channelName  WITH USER_MODE  Limit 1];

            //whatsAppBusinessID =apiObject.Business_ID__c;
            apiKEY =apiObject.API_Key__c;
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
           // req.setEndpoint('https://graph.facebook.com/v17.0/' + whatsAppBusinessID + '/message_templates');
            req.setEndpoint('https://graph.facebook.com/v17.0/' + templateId);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');       
            req.setBody(json);        
            req.setHeader('Authorization', 'Bearer '+apiKEY);  
            // Send the request, and return a response‸
            HttpResponse res = h.send(req);
            String jsonResponse = res.getBody();
            Map<String,Object> responseMap = (Map<String, Object>) System.JSON.deserializeUntyped(jsonResponse);
            resultMap.put('statusCode',String.valueOf(res.getStatusCode()));
            System.debug('responseMap :'+responseMap);
            if(responseMap.containsKey('error'))
            {
                Map<String, Object> errorData = new Map<String, Object>();
            	errorData = (Map<String, Object>)responseMap.get('error');
                if(errorData != null){
                    resultMap.put('error',String.valueOf(errorData.get('message')));
                    resultMap.put('error_user_msg',String.valueOf(errorData.get('error_user_msg')));
                    resultMap.put('code',String.valueOf(errorData.get('code')));
                }
            // get templateId from response.
            }else{
                if((Boolean)responseMap.get('success')){
                    resultMap.put('success','true');    
                }else{
                    resultMap.put('success','false');
                }
            }
			return resultMap;
        }catch(Exception e){
            resultMap.put('error',e.getMessage());
            return resultMap;
            //throw new AuraHandledException(e.getMessage());
        }
        
    }
    /**
   * @methodname		    getApprovedWhatsAppTemplatesAPIService
   * @author				Rati Kulkarni
   * @objectreferenced	    API_Key_Configuration__mdt,HttpRequest,HttpResponse
   * @params 				json
   * @description			This method calls API service to get all Apprved WhatsAPP Template from WhatsApp for given Business Id Account.
   * @return				Map of Approved template Name vs template details.
   */
    
    //@AuraEnabled(cacheable=true) //Map<String,Object>
    public static Map<String,Object> getApprovedWhatsAppTemplatesAPIService(string templatejson){
        try{
            String whatsAppBusinessID;
            String apiKEY;
            
            // get API and BusinessID from metadata
            Channel_Configuration__mdt apiObject =  new Channel_Configuration__mdt();
            String channelName = Constants.whatsappString;
            apiObject = [Select API_key__c, Business_ID__c,Endpoint_URL__c from Channel_Configuration__mdt WHERE DeveloperName =:channelName  WITH USER_MODE  Limit 1];

            whatsAppBusinessID =apiObject.Business_ID__c;
            apiKEY =apiObject.API_Key__c;
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(templatejson);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('GET');       
            req.setHeader('Authorization', 'Bearer '+apiKEY);  
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            String jsonResponse = res.getBody();
            system.debug('response ==='+res);
            system.debug('Template Response Body=== '+ jsonResponse);
            //system.debug('Next URL === '+res.data);
            
            Map<String,Object> responseMap = (Map<String, Object>) System.JSON.deserializeUntyped(jsonResponse);
            
            Map<String, Object> errorData = new Map<String, Object>();
            errorData = (Map<String, Object>)responseMap.get('error');
            if(errorData != null){
                throw new AuraHandledException('Error in sending Message');
            }
            // get approved templates from response.
            List<Object> templateData = new List<Object>();
            Map<String,Object> mapTemplate = new Map<String,Object>();
            Map<String,Object> resultTemplates = new Map<String,Object>();

            //resultTemplates.put('whatsAppBusinessID',whatsAppBusinessID);
            
            templateData = (List<Object>)responseMap.get('data');
            
            // Get Next URL & Get Befor And After Values
            Map<String,Object> pagingMap = new Map<String,Object>();
            if(responseMap.containsKey('paging')){
                pagingMap = (Map<String,Object>)responseMap.get('paging');
                string nextURL = string.valueOf(pagingMap.get('next'));
                string previous = string.valueOf(pagingMap.get('previous'));
                system.debug('next url === '+nextURL);

                Map<string,object> nextUrlObject = new Map<string,object>();
                //Map<string,object> previousURLObject = new Map<string,object>();

                if(nextURL != null){
                    nextUrlObject.put('nextURL',nextURL);
                    resultTemplates.put('nextURL',nextUrlObject); 
                }

                //if(previous != null){
                 //   previousURLObject.put('previous',previous);
                 //   resultTemplates.put('previous',previousURLObject);
                //}
                
            }  
            


            if(templateData != null){
                for(Object template : templateData){
                    mapTemplate = (Map<String,Object>)template;
                    resultTemplates.put(String.valueOf(mapTemplate.get('name')), mapTemplate);
                }
            }
            
            if (res.getStatusCode() == 200) { 
                return resultTemplates;
            }else if (res.getStatusCode() == 190) {
                throw new AuraHandledException('Error in sending Message');
                //throw new AuraHandledException('Error in sending Message');
            }else{
                return null;
            } 
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static string getBusinessId(){
           Channel_Configuration__mdt apiObject =  new Channel_Configuration__mdt();
           String channelName = Constants.whatsappString;
           apiObject = [Select API_key__c, Business_ID__c,Endpoint_URL__c from Channel_Configuration__mdt WHERE DeveloperName =:channelName  WITH USER_MODE  Limit 1];

           string whatsAppBusinessID =apiObject.Business_ID__c;
           system.debug('WhatsAppBusiness Id==='+whatsAppBusinessID);
           return whatsAppBusinessID;
    }
}