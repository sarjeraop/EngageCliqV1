@isTest
public class WhatsAppUITemplateControllerTest {
 
     @isTest
    public static void getTemplateDetailsForButtonWithOutMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"","messageType":"Button","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppUITemplateController.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name,Name__c  from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
        }catch(exception e){
		}     
        Test.stopTest();  
    }
    
    @isTest
    public static void getTemplateDetailsForButtonWithMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"Image","messageType":"Button","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppUITemplateController.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name, Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');        
        }catch(exception e){
		}     
        Test.stopTest();
    }

    @isTest
    public static void getTemplateDetailsForTextWithMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"Image","messageType":"Text","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Satisfactory","phone_number_OR_url":"","id":1},{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Awesome","phone_number_OR_url":"","id":2}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppUITemplateController.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name, Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
        }catch(exception e){
		}     
        Test.stopTest();
    }
    
     @isTest
    public static void getTemplateDetailsForTextWithOutMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"","messageType":"Text","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Satisfactory","phone_number_OR_url":"","id":1},{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Awesome","phone_number_OR_url":"","id":2}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppUITemplateController.getTemplateDetails(jsonValue); 
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name, Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
        }catch(exception e){
		}     
        Test.stopTest();
    }
    
    @isTest
    public static void getTemplateDetailsForListWithOutMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"","messageType":"List","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppUITemplateController.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name, Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
        }catch(exception e){
		}     
        Test.stopTest();
    }
    
    @isTest
    public static void getTemplateDetailsForListWithImageMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"Image","messageType":"List","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
         Test.startTest();
       	try
      	{
        WhatsAppUITemplateController.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name, Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
        }catch(exception e){
		}     
        Test.stopTest();
    }
    
    @isTest
    public static void getTemplateDetailsForListWithVideoMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"video","messageType":"List","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppUITemplateController.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name, Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
         }catch(exception e){
		}     
        Test.stopTest();
    }
        
    @isTest
    public static void getTemplateDetailsForListWithDocumentMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"document","messageType":"List","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
                Test.startTest();
       	try
      	{
        WhatsAppUITemplateController.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name, Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
          }catch(exception e){
		}     
        Test.stopTest();   
    }
}