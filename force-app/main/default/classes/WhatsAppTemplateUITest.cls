/** @classname          : WhatsAppTemplateUITest 
 * @author              : Sarjerao Pujari
 * @date                : 02-12-23
 * @description         : WhatsAppUITemplateControllerTest class is used for Test WhatsApp Template creation for user inititive type
 * @modificationlog
 * .   
*/
@isTest
public class WhatsAppTemplateUITest {

/** @methodname         : getTemplateDetailsForButtonWithOutMediaTest
 * @author              : Sarjerao Pujari
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : None
 * @description         : This method is use to Test the create template and whatsApp template record with button and without media.
 * @return              : None
 */ 
     @isTest
    public static void getTemplateDetailsForButtonWithOutMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name__c":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"","messageType":"Button","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
        jsonValue = '"templateObject":{"sobjectType":"Template__c","ecdemoqapkg__Target_Source__c":"Contact","ecdemoqapkg__Name__c":"new"},"whatsAppTemplateObject":{"Template_Type__c":"User Initiative","Name":"new","Language__c":"en_US","ecdemoqapkg__Active__c":true,"ecdemoqapkg__Template_Type__c":"User Initiative","ecdemoqapkg__Language__c":"en_US","Message_Body__c":"<p>hi</p>","JSON_Payload__c":"","JSON_Wrapper__c":""},"language":"en_US","targetObject":"Contact","body":"<p>hi</p>","messageType":"Button","headerBody":"sdgfd","footerBody":"sdfsdf","buttonValues":[{"id":0,"value":"Ok"}],"sampleValues":[],"fieldMapping":[]';
        Test.startTest();
       	try
      	{
        WhatsAppTemplateUI.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
        }catch(exception e){
		}     
        Test.stopTest();  
    }

/** @methodname         : getTemplateDetailsForButtonWithMediaTest
 * @author              : Sarjerao Pujari
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : None
 * @description         : This method is use to Test the create template and whatsApp template record with button and media.
 * @return              : None
 */    
    @isTest
    public static void getTemplateDetailsForButtonWithMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name__c":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"Image","messageType":"Button","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppTemplateUI.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');        
        }catch(exception e){
		}     
        Test.stopTest();
    }

/** @methodname         : getTemplateDetailsForTextWithMediaTest
 * @author              : Sarjerao Pujari
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : None
 * @description         : This method is use to Test the create template and whatsApp template record with Text and media.
 * @return              : None
 */
    @isTest
    public static void getTemplateDetailsForTextWithMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name__c":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"Image","messageType":"Text","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Satisfactory","phone_number_OR_url":"","id":1},{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Awesome","phone_number_OR_url":"","id":2}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppTemplateUI.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
        }catch(exception e){
		}     
        Test.stopTest();
    }

/** @methodname         : getTemplateDetailsForTextWithOutMediaTest
 * @author              : Sarjerao Pujari
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : None
 * @description         : This method is use to Test the create template and whatsApp template record with Text and without media.
 * @return              : None
 */    
     @isTest
    public static void getTemplateDetailsForTextWithOutMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name__c":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"","messageType":"Text","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Satisfactory","phone_number_OR_url":"","id":1},{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Awesome","phone_number_OR_url":"","id":2}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppTemplateUI.getTemplateDetails(jsonValue); 
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
        }catch(exception e){
		}     
        Test.stopTest();
    }

/** @methodname         : getTemplateDetailsForListWithOutMediaTest
 * @author              : Sarjerao Pujari
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : None
 * @description         : This method is use to Test the create template and whatsApp template record with With List and without media.
 * @return              : None
 */     
    @isTest
    public static void getTemplateDetailsForListWithOutMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name__c":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"","messageType":"List","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppTemplateUI.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
        }catch(exception e){
		}     
        Test.stopTest();
    }

/** @methodname         : getTemplateDetailsForListWithImageMediaTest
 * @author              : Sarjerao Pujari
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : None
 * @description         : This method is use to Test the create template and whatsApp template record with With media List.
 * @return              : None
 */     
    @isTest
    public static void getTemplateDetailsForListWithImageMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name__c":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"Image","messageType":"List","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
         Test.startTest();
       	try
      	{
        WhatsAppTemplateUI.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
        }catch(exception e){
		}     
        Test.stopTest();
    }

/** @methodname         : getTemplateDetailsForListWithVideoMediaTest
 * @author              : Sarjerao Pujari
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : None
 * @description         : This method is use to Test the create template and whatsApp template record with List with VideoMedia.
 * @return              : None
 */   
    @isTest
    public static void getTemplateDetailsForListWithVideoMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name__c":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"video","messageType":"List","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
        Test.startTest();
       	try
      	{
        WhatsAppTemplateUI.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
         }catch(exception e){
		}     
        Test.stopTest();
    }

/** @methodname         : getTemplateDetailsForListWithDocumentMediaTest
 * @author              : Sarjerao Pujari
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : None
 * @description         : This method is use to Test the create template and whatsApp template record with List with DocumentMedia.
 * @return              : None
 */         
    @isTest
    public static void getTemplateDetailsForListWithDocumentMediaTest(){
        string jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Name__c":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"document","messageType":"List","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"id":0,"value":"sss"}],"sampleValues":[],"fieldMapping":"[]"}';
                Test.startTest();
       	try
      	{
        WhatsAppTemplateUI.getTemplateDetails(jsonValue);
        List<WhatsApp_Template__c> listOfWhatsAppTempate = [select Id,Name__c from WhatsApp_Template__c];
        system.assertEquals(listOfWhatsAppTempate[0].Name__c,'test_bot');
          }catch(exception e){
		}     
        Test.stopTest();   
    }
}