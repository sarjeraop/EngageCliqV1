/*
* @ classname          : WhatsAppChatController.
* @ author             : Sarjerao Pujari.
* @ date               : 23-Oct-2023
* @ description        : WhatsAppChatControllerTest class is used to Test the WhatsAppChatController class which is a controller of modelPopUp and attachmentModel LWC components.

* @ modificationlog
* 1.Sarjerao Pujari       20-Nov-2023        Add Code Comments
*/
@isTest
public class WhatsAppChatControllerTest
{
    
    /** @methodname         : approvedWhatsAppTemplateTest
* @author              : Sarjerao Pujari
* @objectreferenced    : WhatsApp_Template__c
* @param               : Boolean, String
* @description         : This method is specially to Test approvedWhatsAppTemplate method which is used to find approved whtasApp template based on object name and active checkbox
* @return              : None
*/
    @isTest
    public static void approvedWhatsAppTemplateTest()
    {
        boolean isActive = true;
        List<Send_Configuration__c> sbcList = TestDataFactory.createSBCRecords(1, 'Contact');
        string objName = sbcList[0].Object_Name__c;
        Test.StartTest();
        List<WhatsApp_Template__c> wtempList = (List<WhatsApp_Template__c>)WhatsAppChatController.approvedWhatsAppTemplate(isActive, objName).data;
        Test.StopTest();
        List<WhatsApp_Template__c> whatsappTemplateList = new List<WhatsApp_Template__c>();
        whatsappTemplateList = [SELECT Id,Name, Message_Body__c, Template_Type__c, Status__c, Template_ID__r.Target_Source__c, JSON_Payload__c FROM WhatsApp_Template__c WHERE  Status__c ='Approved' WITH SECURITY_ENFORCED];
        system.assertEquals(whatsappTemplateList.size(),0);
    }
    
    
    /** @methodname         : getQuickTextListTest
* @author              : Sarjerao Pujari
* @objectreferenced    : QuickText
* @param               : None
* @description         : This method is specially to Test getQuickTextList method which is used get the all Created QuickTexts.
* @return              : None
*/
    @isTest
    public static void getQuickTextListTest()
    {
        Test.StartTest();
        List<QuickText> listofQuickText = (List<QuickText>)WhatsAppChatController.getQuickTextList().data;
        Test.StopTest();
        system.assertEquals(listofQuickText.size(),0);
    }
    
    /** @methodname         : getContentDistributionTest
* @author              : Sarjerao Pujari
* @objectreferenced    : QuickText
* @param               : None
* @description         : This method is specially to Test getContentDistribution method which is use to create ContentDistribution record.
* @return              : None
*/
    @isTest
    public static void getContentDistributionTest()
    {
        string conVerId = TestDataFactory.createContentDocument();
        test.startTest();
        WhatsAppChatController.createContentDistribution(conVerId);
        WhatsAppChatController.getFileUrl();
        test.stopTest();
        List<ContentDistribution> contentList = [Select id from ContentDistribution];
        system.assertEquals(1, contentList.size());
    }
    
    /** @methodname         : getContentDistributionNullTest
* @author              : Sarjerao Pujari
* @objectreferenced    : 
* @param               : None
* @description         : This method is specially to Test negative scenario for getContentDistribution method which is use to create ContentDistribution record.
* @return              : None
*/ 
    @isTest
    public static void getContentDistributionNullTest()
    {
        string conVerId = Null;
        test.startTest();
        WhatsAppChatController.createContentDistribution(conVerId);
        WhatsAppChatController.getFileUrl();
        test.stopTest();
        List<ContentDistribution> contentList = [Select id from ContentDistribution];
        system.assertEquals(0, contentList.size());
    }
}