/** @classname          :WhatsAppTemplateHandler 
 * @author              :Suhas Mankar
 * @date : 
 * @description         :WhatsAppUITemplateController class is used for WhatsApp Template creation for user inititive type
 * @modificationlog
 * .   
*/
public with sharing class WhatsAppUITemplateController {

// This variableis use to get map of media used for json creation
    private static final Map<String, String> MEDIAMAP = new Map<String, String>{
        'Image' => 'image' ,
        'Video' => 'video',
        'Document' => 'document'
    };
   
/** @methodname         : getTemplateDetails
 * @author              : Suhas Mankar
 * @objectreferenced    : Template__c, WhatsApp_Template__c
 * @param               : String
 * @description         : This method is use to create template and whatsApp template record also build json as per type
 * @return              : WhatsApp_Template__c
 */
    @AuraEnabled
    public static WhatsApp_Template__c getTemplateDetails(String jsonValue) {
        
        TemplateWrapper objWrapper = (TemplateWrapper)System.JSON.deserialize(jsonValue, TemplateWrapper.class);
        String jsonPayload = '';
        if (objWrapper.messageType.equalsIgnoreCase('button')) {
            jsonPayload = buttonJsonBuilder(objWrapper);
        } else if (objWrapper.messageType.equalsIgnoreCase('list')) {
            jsonPayload = listJsonBuilder(objWrapper);
        } else {
            jsonPayload = textJsonBuilder(objWrapper);
        }
		
        // create/update parent template record

        Template__c objTemplate = new Template__c();
        objTemplate = objWrapper.templateObject;
        objTemplate = CreateTemplate.createTemplateRecord(objTemplate);

        // create/update WhatsApp template record
        WhatsApp_Template__c objWhatsAppTemplate = new WhatsApp_Template__c();
        objWhatsAppTemplate = objWrapper.whatsAppTemplateObject;
        objWhatsAppTemplate.Template_ID__c = objTemplate.Id;
        objWhatsAppTemplate.Json_Payload__c = jsonPayload;
        objWhatsAppTemplate.JSON_Wrapper__c = jsonValue;
        objWhatsAppTemplate.WhatsApp_Message_Body__c = objWrapper.body; //before conversion required to store WA formatted body for UI. 
        objWhatsAppTemplate.Message_Body__c = covertWAmessageToSFMessage(objWrapper.body,objWrapper.sampleValues);
        objWhatsAppTemplate = CreateTemplate.createWhatsAppTemplateRecord(objWhatsAppTemplate);
        return objWhatsAppTemplate;
    }
    
/** @methodname         : buttonJsonBuilder
 * @author              : Suhas Mankar
 * @objectreferenced    : TemplateWrapper
 * @param               : TemplateWrapper
 * @description         : This method is use to build button json based on TemplateWrapper data
 * @return              : String
 */
    public static String buttonJsonBuilder (TemplateWrapper objWrapper) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('messaging_product', 'whatsapp');
        gen.writeStringField('recipient_type', 'individual');
        gen.writeStringField('to', '<MOBILEPHONE>');
        gen.writeStringField('type', 'interactive');
        gen.writeFieldName('interactive');
        gen.writeStartObject();
        gen.writeStringField('type', 'button');
        /* Header */
        if (string.isNotBlank(objWrapper.headerBody) || String.isNotBlank(objWrapper.mediaURL)) {
            if (string.isNotBlank(objWrapper.media) && MEDIAMAP.containskey(objWrapper.media) && string.isNotBlank(objWrapper.mediaURL))
            {
                gen.writeFieldName('header');
                gen.writeStartObject();
                gen.writeStringField('type', objWrapper.media);
                gen.writeStringField('text', MEDIAMAP.get(objWrapper.media));
                gen.writeFieldName(MEDIAMAP.get(objWrapper.media));
                gen.writeStartObject();
                gen.writeStringField('link', objWrapper.mediaURL);
                gen.writeEndObject();//image
                gen.writeEndObject();//header
            } else {
                gen.writeFieldName('header');
                gen.writeStartObject();
                gen.writeStringField('type', 'text');
                gen.writeStringField('text', objWrapper.headerBody);
                gen.writeEndObject();//header
            }
        }
       
        gen.writeFieldName('body');
        gen.writeStartObject();
        if (objWrapper != null && String.isNotBlank(objWrapper.body)) {
            gen.writeStringField('text', '<MESSAGEBODY>');
        }
        gen.writeEndObject();//body
        /** footer **/
        if (String.isNotBlank(objWrapper.footerBody)) {
            gen.writeFieldName('footer');
            gen.writeStartObject();
            gen.writeStringField('text', objWrapper.footerBody);
            gen.writeEndObject();//footer
        }
        gen.writeFieldName('action');
        gen.writeStartObject();
    
        gen.writeFieldName('buttons');
        // aaray of buttons
            gen.writeStartArray();
            
            for(ButtonValue objBtn : objWrapper.buttonValues){
                if (objBtn.value == null) {
                    continue;
                }
                gen.writeStartObject();
                gen.writeStringField('type', 'reply');
                gen.writeFieldName('reply');
                gen.writeStartObject();
                gen.writeStringField('id', 'unique-id-'+objBtn.id);
                gen.writeStringField('title', objBtn.value);
                gen.writeEndObject();//reply
                gen.writeEndObject();
                
            }
            gen.writeEndArray();
        gen.writeEndObject();//actions
        gen.writeEndObject();//interactive   
        gen.writeEndObject();
        return gen.getAsString();

    }

/** @methodname         : textJsonBuilder
 * @author              : Suhas Mankar
 * @objectreferenced    : TemplateWrapper
 * @param               : TemplateWrapper
 * @description         : This method is use to build text json based on TemplateWrapper data
 * @return              : String
 */    
    public static String textJsonBuilder (TemplateWrapper objWrapper) {      

     
       JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('messaging_product', 'whatsapp');
        gen.writeStringField('recipient_type', 'individual');
        gen.writeStringField('to', '<MOBILEPHONE>');
        
        if (MEDIAMAP.containskey(objWrapper.media)) {
            gen.writeStringField('type', MEDIAMAP.get(objWrapper.media));
            gen.writeStringField('text', objWrapper.media);
            gen.writeFieldName(MEDIAMAP.get(objWrapper.media));
            gen.writeStartObject();
            gen.writeStringField('link', objWrapper.mediaURL);
        } else {
            gen.writeStringField('type', 'text');
            gen.writeFieldName('text');
            gen.writeStartObject();
            if (objWrapper != null && String.isNotBlank(objWrapper.body)) {
                gen.writeStringField('body', '<MESSAGEBODY>');
            }
        }        
        gen.writeEndObject();//body
        gen.writeEndObject();//end
        return gen.getAsString(); 


    } 

/** @methodname         : listJsonBuilder
 * @author              : Suhas Mankar
 * @objectreferenced    : TemplateWrapper
 * @param               : TemplateWrapper
 * @description         : This method is use to build list json based on TemplateWrapper data
 * @return              : String
 */ 
    public static String listJsonBuilder (TemplateWrapper objWrapper) {      

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('messaging_product', 'whatsapp');
        gen.writeStringField('recipient_type', 'individual');
        gen.writeStringField('to', '<MOBILEPHONE>');
        gen.writeStringField('type', 'interactive');
        gen.writeFieldName('interactive');
        gen.writeStartObject();
        gen.writeStringField('type', 'list');
        if (string.isNotBlank(objWrapper.headerBody) || String.isNotBlank(objWrapper.mediaURL)) {
            if (string.isNotBlank(objWrapper.media) && objWrapper.media.equalsIgnoreCase('image')&& string.isNotBlank(objWrapper.mediaURL))
            {
                gen.writeFieldName('header');
                gen.writeStartObject();
                gen.writeStringField('type', 'image');
                gen.writeStringField('text', 'Image');
                gen.writeFieldName('image');
                gen.writeStartObject();
                gen.writeStringField('link', objWrapper.mediaURL);
                gen.writeEndObject();//image
                gen.writeEndObject();//heade
            } else if (string.isNotBlank(objWrapper.media) && objWrapper.media.equalsIgnoreCase('video')) {
                gen.writeFieldName('header');
                gen.writeStartObject();
                gen.writeStringField('type', 'video');
                gen.writeStringField('text', 'Video');
                gen.writeFieldName('video');
                gen.writeStartObject();
                gen.writeStringField('link', objWrapper.mediaURL);
                gen.writeEndObject();//image
                gen.writeEndObject();//heade
            } else if (string.isNotBlank(objWrapper.media) && objWrapper.media.equalsIgnoreCase('document')) {
                gen.writeFieldName('header');
                gen.writeStartObject();
                gen.writeStringField('type', 'document');
                gen.writeStringField('text', 'Document');
                gen.writeFieldName('document');
                gen.writeStartObject();
                gen.writeStringField('link', objWrapper.mediaURL);
                gen.writeEndObject();//image
                gen.writeEndObject();//heade
            } else {
                gen.writeFieldName('header');
                gen.writeStartObject();
                gen.writeStringField('type', 'text');
                gen.writeStringField('text', objWrapper.headerBody);
                gen.writeEndObject();//header
            }
        }

        gen.writeFieldName('body');
        gen.writeStartObject();
        if (objWrapper != null && String.isNotBlank(objWrapper.body)) {
            gen.writeStringField('text', '<MESSAGEBODY>');
        }        
        gen.writeEndObject();//body
        if (String.isNotBlank(objWrapper.footerBody)) {
            gen.writeFieldName('footer');
            gen.writeStartObject();
            gen.writeStringField('text', objWrapper.footerBody);
            gen.writeEndObject();//footer
        }
       

        gen.writeFieldName('action');
        gen.writeStartObject();
        gen.writeStringField('button', 'Select');

            gen.writeFieldName('sections');
            gen.writeStartArray();
            for(ButtonValue objBtn :objWrapper.buttonValues){

                if (objBtn.value == null) {
                    continue;
                }
                gen.writeStartObject();
                gen.writeStringField('title', objBtn.value);
                gen.writeFieldName('rows');
                gen.writeStartArray();
                    //Integer counter = 1;
                    gen.writeStartObject();
                    gen.writeStringField('id', 'unique-id-'+objBtn.id);
                    gen.writeStringField('title', objBtn.value);
                    gen.writeEndObject();//loop
                    //counter +=1;
                
                    gen.writeEndArray();// rows
                gen.writeEndObject();//sections
            }
            gen.writeEndArray();
            gen.writeEndObject();//action

        gen.writeEndObject();//interactive
        gen.writeEndObject();//end
        return gen.getAsString();


    } 
    
/** @methodname         : TemplateWrapper
 * @author              : Suhas Mankar
 * @objectreferenced    : Template__c, whatsAppTemplateObject, ButtonValue, SampleValue
 * @param               : 
 * @description         : This is wrapper class used for template, whatsApp template and json creation
 * @return              :
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
     
    } 
	/**
   * @methodname				    covertWAmessageToSFMessage
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


/** @methodname         : ButtonValue
 * @author              : Suhas Mankar
 * @objectreferenced    : 
 * @param               : 
 * @description         : This is wrapper class used for button value creation in whatsApp template creation
 * @return              :
 */
    public class ButtonValue {
        @AuraEnabled
        public Integer id {get;set;}
        @AuraEnabled
        public String value {get;set;}
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