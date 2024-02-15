/**
 * @methodname			WhatsAppTemplateBI
 * @TestClass			WhatsAppTemplateBITest
 * @author				Rati Kulkarni
 * @description			This class performes Template creation activity.
 *                      It includes Template creation, WhatsApp Template Creation and JSON Body creation.
 * @createddate			15-July-2023
 * * @modificationlog
 */
public with sharing class WhatsAppTemplateBI {
    // This Map is used to map Header category selected for WhatsApp Template. 
    private static final Map<String, String> MEDIAMAP = new Map<String, String>{
        'Image' => 'image' ,
        'Video' => 'video',
        'Document' => 'document'
    };
   

    /**
   * @methodname			saveWhatsAppTemplate
   * @author				Rati Kulkarni
   * @objectreferenced	    WhatsApp_Template__c,TemplateWrapper
   * @params				jsonValue (input data from UI js file)
   * @description			This method creates/updates Template and WhatsAppTemplate Object.
   * @return				WhatsApp_Template__c
   */
    @AuraEnabled
    public static WhatsApp_Template__c saveWhatsAppTemplate(String jsonValue) {
        System.debug('jsonValue ==> '+jsonValue);
        TemplateWrapper objWrapper = (TemplateWrapper)System.JSON.deserialize(jsonValue, TemplateWrapper.class);
        
        // create/update parent template record
        Template__c objTemplate = createTemplateRecord(objWrapper.templateObject);
		System.debug('objTemplate ==> '+objTemplate);
        // update other attributes of WhatsApp template record before upsertion
        WhatsApp_Template__c objWhatsAppTemplate = new WhatsApp_Template__c();
        
        objWhatsAppTemplate = objWrapper.whatsAppTemplateObject;
        system.debug('objWhatsAppTemplate ==> '+objWhatsAppTemplate);
        objWhatsAppTemplate.Template_ID__c = objTemplate.Id;  // add reference of parent record
        objWhatsAppTemplate.JSON_Wrapper__c = jsonValue;      // store actual jsonValue from js.
        objWhatsAppTemplate.Merge_Field_Mapping__c = objWrapper.fieldMapping; // Remove field mappring extra parameter and add to Merge_Field_Mapping__c at JSON side.
        objWhatsAppTemplate.WhatsApp_Message_Body__c = objWrapper.body; //before conversion required to store WA formatted body. 
        List<SampleValue> sampleValues = (List<SampleValue>) JSON.deserialize(objWrapper.fieldMapping,List<SampleValue>.class);
        
        // generate JSON for 'WhatsApp Template'.
        objWhatsAppTemplate.Json_Payload__c = createTemplateJSONBuilder(objWrapper,sampleValues); 
       
        if(objWrapper.body.contains('{{')){ // Already WhatsApp created Template ?
            // convert WhatsApp understandable message to Salesforce Understandable message.
            objWhatsAppTemplate.Message_Body__c = covertWAmessageToSFMessage(objWrapper.body,sampleValues);
        }else{
            objWhatsAppTemplate.Message_Body__c = objWrapper.body;
        }
        // create / update WhatsAppTemplate record
        return createWhatsAppTemplateRecord(objWhatsAppTemplate);
         
    }

    /**
   * @methodname			covertWAmessageToSFMessage
   * @author				Rati Kulkarni
   * @objectreferenced	    sampleValue
   * @params				templateBody, List<SampleValue> sampleValues
   * @description			This method converts templateBody from WhatsApp formatted message to Salesforce understandable format.
   * @return				String
   */
    public static String covertWAmessageToSFMessage(String templateBody,List<SampleValue> sampleValues){
        String replacedString;
            for(sampleValue sample : sampleValues){
                replacedString = templateBody.replace(sample.index,'{!'+sample.sfFieldName+'}'); 
                templateBody = replacedString;
            }
            return templateBody;
    }

    /**
   * @methodname			createTemplateRecord
   * @author				Rati Kulkarni
   * @objectreferenced	    Template__c
   * @params				Template__c
   * @description			This method create/update Template record.
   * @return				Template__c
   */
    @AuraEnabled
    public static Template__c createTemplateRecord(Template__c templateObj){
        	//Schema.sObjectField uniqueFiledName1 = templateObj.Id; // holds the unique field which will be used in upsert
        	List<Template__c> templateList = new List<Template__c>();
        	templateList.add(templateObj);
            //Prepare the input parameter.
    		 DatabaseService.DB_Input dbInput = new DatabaseService.DB_Input(templateList,true,true,'CreateTemplate');
        	 dbInput.uniqueFiledName = Schema.getGlobalDescribe().get(Constants.NAMESPACEPREFIX+'Template__c').getDescribe().fields.getMap().get('Id');
             DatabaseService.DB_Result dbResult = DatabaseService.dbUpsert(dbInput);
            
            return (Template__c)dbResult.idToSObjectMap.get(dbResult.successRecordIds[0]);
    
    }

    /**
   * @methodname				    createWhatsAppTemplateRecord
   * @author				Rati Kulkarni
   * @objectreferenced	    WhatsApp_Template__c
   * @params				WhatsApp_Template__c
   * @description			This method create/update Template record.
   * @return				WhatsApp_Template__c
   */
    @AuraEnabled
    public static WhatsApp_Template__c createWhatsAppTemplateRecord(WhatsApp_Template__c whatsApptemplateObj){
        	List<WhatsApp_Template__c> whatsAppTemplateList = new List<WhatsApp_Template__c>();
        	whatsAppTemplateList.add(whatsApptemplateObj);
            system.debug('whatsApptemplateObj'+whatsApptemplateObj);
            
             //Prepare the input parameter.
    		 DatabaseService.DB_Input dbInput = new DatabaseService.DB_Input(whatsAppTemplateList,true,true,Constants.CREATETEMPLATECLASS);
			 dbInput.uniqueFiledName = Schema.getGlobalDescribe().get(Constants.NAMESPACEPREFIX+'WhatsApp_Template__c').getDescribe().fields.getMap().get('Id');
			 
             //Invoke the Insert call.
             DatabaseService.DB_Result dbResult = DatabaseService.dbUpsert(dbInput);
            
            return (WhatsApp_Template__c)dbResult.idToSObjectMap.get(dbResult.successRecordIds[0]);
    }

    /**
   * @methodname				    createTemplateJSONBuilder
   * @author				Rati Kulkarni
   * @objectreferenced	    SampleValue,JSONGenerator
   * @params				TemplateWrapper,List<SampleValue>
   * @description			This method generates JSON for Business Initiated template dynamically.
   * @return				String
   */
   public static String createTemplateJSONBuilder(TemplateWrapper objWrapper,List<SampleValue> sampleValues)
    {
        JSONGenerator gen = JSON.createGenerator(true);
        String headerJSON;
        String buttonJSON;
        String createTemplateJSON;
        
        
        gen.writeStartObject();
        gen.writeStringField('name', objWrapper.whatsAppTemplateObject.Name__c);
        gen.writeStringField('language', objWrapper.language);  
        gen.writeStringField('category', objWrapper.whatsAppTemplateObject.WhatsApp_Category__c);
        
        //gen.writeStringField('type', 'interactive');
        gen.writeFieldName('components');
        gen.writeStartArray();
        //createTemplateJSON = gen.getAsString();
        if (string.isNotBlank(objWrapper.headerBody) || String.isNotBlank(objWrapper.mediaURL)) {
            if (string.isNotBlank(objWrapper.media) && MEDIAMAP.containskey(objWrapper.media)){
                gen = generateHeader(objWrapper.media,'',objWrapper.mediaURL,gen);
            }else{
                gen = generateHeader('text',objWrapper.headerBody,'',gen);
            }  
        }
        // Append Body JSON
         gen = generateBody(objWrapper.body,sampleValues,gen);
        
        /** footer **/
        if (String.isNotBlank(objWrapper.footerBody)) {
            // Append footer JSON
            gen = generateFooter(objWrapper.footerBody,gen);
        }
        if(objWrapper.buttonValues.size()>0 && objWrapper.buttonValues[0].text != ''){
            // Append Button JSON 
            gen = generateButton(objWrapper.buttonValues,gen);
        }
        gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }

    
    /**
   * @methodname			generateHeader
   * @author				Rati Kulkarni
   * @objectreferenced	    JSONGenerator
   * @params				String type -  type of header ,String headerBody, String mediaUrl,JSONGenerator - to append generated header
   * @description			This method generates Header JSON for BI template.
   * @return				JSONGenerator
   */
    public static JSONGenerator generateHeader(String type,String headerBody, String mediaUrl,JSONGenerator gen){
        if(type == 'text'){
            gen.writeStartObject();
            gen.writeStringField('type', 'HEADER');
            gen.writeStringField('format', 'TEXT');
            gen.writeStringField('text', headerBody);
            gen.writeEndObject();
        }else{

            // code to handle media Headers
        }
        return gen;
    }

    /**
   * @methodname				    generateFooter
   * @author				Rati Kulkarni
   * @objectreferenced	    JSONGenerator
   * @params				String footerBody, JSONGenerator - to append generated footer
   * @description			This method generates Header JSON for BI template.
   * @return				JSONGenerator
   */
    public static JSONGenerator generateFooter(String footerBody,JSONGenerator gen){
        gen.writeStartObject();
        gen.writeStringField('type', 'FOOTER');
        gen.writeStringField('text', footerBody);
        gen.writeEndObject();
        return gen;
    }

    /**
   * @methodname				    generateBody
   * @author				Rati Kulkarni
   * @objectreferenced	    JSONGenerator
   * @params				String messageBody,List<SampleValue> sampleValues, JSONGenerator - to append generated footer
   * @description			This method generates Body JSON for BI template.
   * @return				JSONGenerator
   */
    public static JSONGenerator generateBody(String templateBody,List<SampleValue> sampleValues,JSONGenerator gen){
        String replacedString;
        for(sampleValue sample : sampleValues){
                replacedString = templateBody.replace('{!'+sample.sfFieldName+'}',sample.index); 
                templateBody = replacedString;
        }
        // replace html tags by WhatsApp conventions
        templateBody = Utility.replaceMessageWhatsApp(templateBody);

        // prepare sample values List
        List<String> valueList = new List<String>();
        for(SampleValue objSample : sampleValues){
            valueList.add(objSample.sampleValue);
        }
         // generate Body JSON   
        gen.writeStartObject();
        gen.writeStringField('type', 'BODY');
        gen.writeStringField('text', templateBody);
        if(sampleValues.size() > 0){
            gen.writeFieldName('example');
            gen.writeStartObject();
            gen.writeFieldName('body_text');
            gen.writeStartArray();
            gen.writeObject(valueList);
            gen.writeEndArray();
            gen.writeEndObject();
        }
        gen.writeEndObject();
        return gen;
    }
   
    /**
   * @methodname				    generateBody
   * @author				Rati Kulkarni
   * @objectreferenced	    ButtonValue,JSONGenerator
   * @params				List<ButtonValue>, JSONGenerator - to append generated footer
   * @description			This method generates Button JSON for BI template.
   * @return				JSONGenerator
   */
    public static JSONGenerator generateButton(List<ButtonValue> buttonValues,JSONGenerator gen){
        gen.writeStartObject();
        gen.writeStringField('type', 'BUTTONS');
        gen.writeFieldName('buttons');
        gen.writeStartArray();
        for(ButtonValue objButton : buttonValues){
            gen.writeStartObject();
            if(objButton.type == 'PHONE_NUMBER'){
                gen.writeStringField('type', 'PHONE_NUMBER');
                gen.writeStringField('text', objButton.text);
                gen.writeStringField('phone_number', objButton.phone_number_OR_url);
            }else if(objButton.type == 'URL'){
                gen.writeStringField('type', 'URL');
                gen.writeStringField('text', objButton.text);
                gen.writeStringField('url', objButton.phone_number_OR_url);
            }else if(objButton.type == 'QUICK_REPLY'){
                gen.writeStringField('type', 'QUICK_REPLY');
                gen.writeStringField('text', objButton.text);
            }//else if(objButton.type == '') MArketing-Opt-Out JSON format not found
            gen.writeEndObject(); 
        }
        gen.writeEndArray();            
        gen.writeEndObject();
        return gen;
    }

     /**
   * @methodname				    TemplateWrapper
   * @author				Rati Kulkarni
   * @objectreferenced	    Template__c,WhatsApp_Template__c,ButtonValue,SampleValue
   * @description			This wrapper class holds UI data provided by User from LWC-js file.
   */
    public class TemplateWrapper {
        @AuraEnabled
        public Template__c templateObject {get;set;}
        @AuraEnabled
        public WhatsApp_Template__c whatsAppTemplateObject {get;set;}
        @AuraEnabled
        public String language {get;set;}
        @AuraEnabled
        public String body {get;set;}
        @AuraEnabled
        public String headerBody {get;set;}
        @AuraEnabled
        public String footerBody {get;set;}
        @AuraEnabled
        public String media {get;set;}
        @AuraEnabled
        public String mediaURL {get;set;}
        @AuraEnabled
        public String messageType {get;set;}
        @AuraEnabled
        public List<ButtonValue> buttonValues {get;set;}
        @AuraEnabled
        public List<SampleValue> sampleValues {get;set;}
        @AuraEnabled 
        public String fieldMapping{get;set;} 
    } 

    /**
   * @methodname				    ButtonValue
   * @author				Rati Kulkarni
   * @objectreferenced	    
   * @description			This wrapper class holds Button information
   */
    public class ButtonValue {
        @AuraEnabled
        public Integer id {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String typeAction {get;set;}
        @AuraEnabled
        public String interActiveType {get;set;}
        @AuraEnabled
        public String text {get;set;}
        @AuraEnabled
        public String phone_number_OR_url {get;set;}
    }

    /**
   * @methodname				    TemplateWrapper
   * @author				Rati Kulkarni
   * @objectreferenced	    
   * @description			This wrapper class holds mapping of WhatsApp value associated to corrosponding Salesforce field.
   */
    public class SampleValue {
        @AuraEnabled
        public String index {get;set;}
        @AuraEnabled
        public String sampleValue {get;set;}
        @AuraEnabled
        public String sfFieldName {get;set;}
    }
}