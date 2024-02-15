/* 
* @ classname          : WhatsAppTemplateBITest 
* @ author             : Rati Kulkarni.
* @ date               : 03-Nov-2023
* @ description        : This class Tests the Template creation activity
It includes Template creation, WhatsApp Template Creation and JSON Body creation.

* @ modificationlog
* 1.
*/
@isTest
public class WhatsAppTemplateBITest {
    
    /**
* @methodname			testSetupForCreateTemplate
* @author				Rati Kulkarni
* @objectreferenced	    WhatsApp_Template__c
* @params				None
* @description			Test setup Method.
* @return				None
*/    
    @TestSetup
    public static Void testSetupForCreateTemplate(){
        List <Template__c> templateList = testDataFactory.createTemplate(5, true);
        List<WhatsApp_Template__c> whtasAppTemplateList = testDataFactory.createWhatsAppTemplate(templateList[0].Id, 5, true);
    }    
    
    /**
* @methodname			createTemplateRecordTest
* @author				Rati Kulkarni
* @objectreferenced	    Template__c
* @params				None
* @description			This Method is to test the Created or updated template Records.
* @return				None
*/  
    @isTest
    static void createTemplateRecordTest(){
        List<Template__c> templatelist = [Select Id, Name From Template__c];
        test.startTest();
        WhatsAppTemplateBI.createTemplateRecord(templatelist[0]);
        test.stopTest();
    }
    
    /**
* @methodname			createWhatsAppTemplateRecordTest
* @author				Rati Kulkarni
* @objectreferenced	    WhatsApp_Template__c
* @params				None
* @description			This Method is to test the Created or updated whatsAppTemplate Records.
* @return				None
*/   
    @isTest
    static void createWhatsAppTemplateRecordTest(){
        List<WhatsApp_Template__c>whatsAppTemplate = [Select Id, Name__c From WhatsApp_Template__c];
        system.debug('whatsAppTemplate=='+whatsAppTemplate);
        Test.startTest();
        WhatsAppTemplateBI.createWhatsAppTemplateRecord(whatsAppTemplate[0]);
        Test.stopTest();
    }
    
    
    /**
* @methodname			generateHeaderTest
* @author				Rati Kulkarni
* @objectreferenced	    None
* @params				None
* @description			This Method is to test Whether Header JSON for BI template is created or not.
* @return				None
*/ 
    @isTest
    Static void generateHeaderTest(){
        JSONGenerator gen = JSON.createGenerator(true);
        String type = 'text';
        String headerBody = 'This is a header text';
        String mediaUrl = null; 
        Test.startTest();
        gen = WhatsAppTemplateBI.generateHeader(type, headerBody, mediaUrl, gen);
        Test.stopTest();
        if(gen != null){
            System.assertNotEquals(Null, gen);
        }
        
    }
    
    /**
* @methodname			testGenerateFooter
* @author				Rati Kulkarni
* @objectreferenced	    None
* @params				None
* @description			This Method is to test Whether Footer JSON for BI template is created or not.
* @return				None
*/     
    @isTest
    public static void testGenerateFooter() {
        JSONGenerator gen = JSON.createGenerator(true);
        String footerBody = 'This is a footer text';
        Test.startTest();
        gen = WhatsAppTemplateBI.generateFooter(footerBody, gen);
        Test.stopTest();
        system.debug('gen =='+gen);
        if(gen != null){
            System.assertNotEquals(Null, gen);
        }
    }
    
    /**
* @methodname			testGenerateBody
* @author				Rati Kulkarni
* @objectreferenced	    None
* @params				None
* @description			This Method is to test Whether Body JSON for BI template is created or not.
* @return				None
*/ 
    @isTest
    public static void testGenerateBody() {
        JSONGenerator gen = JSON.createGenerator(true);
        String messageBody = 'Hello {!sample1}, this is a {!sample2} message.';
        WhatsAppTemplateBI.SampleValue createSampleValue = new WhatsAppTemplateBI.SampleValue();
        createSampleValue.index = '{{1}}';
        createSampleValue.sampleValue = '{{Name}}';
        createSampleValue.sfFieldName = '{{Name}}';
        List<WhatsAppTemplateBI.SampleValue> createSampleValueList = new List<WhatsAppTemplateBI.SampleValue>();
        createSampleValueList.add(createSampleValue);
        Test.startTest();
        gen = WhatsAppTemplateBI.generateBody(messageBody, createSampleValueList, gen);
        Test.stopTest();
        if(gen != null){
            System.assertNotEquals(Null, gen);
        }
        
    }
    
    /**
* @methodname			testGenerateButton
* @author				Rati Kulkarni
* @objectreferenced	    None
* @params				None
* @description			This Method is to test Whether Button JSON for BI template is created or not.
* @return				None
*/
    @isTest
    public static void testGenerateButton() {
        JSONGenerator gen = JSON.createGenerator(true);
        WhatsAppTemplateBI.ButtonValue createButtonValue = new WhatsAppTemplateBI.ButtonValue();
        createButtonValue.id = 123;
        createButtonValue.interActiveType = 'Button';
        createButtonValue.phone_number_OR_url = '917083702341';
        createButtonValue.text = 'Test';
        createButtonValue.type = 'PHONE_NUMBER';
        List<WhatsAppTemplateBI.ButtonValue> createButtonValueList = new List<WhatsAppTemplateBI.ButtonValue>();
        createButtonValueList.add(createButtonValue);
        Test.startTest();
        gen = WhatsAppTemplateBI.generateButton(createButtonValueList, gen);
        Test.stopTest();
        system.debug('gen =='+gen);
        if(gen != null){
            System.assertNotEquals(Null, gen);
        }
    }
    
    /**
* @methodname			testGenerateButtonTypeURL
* @author				Rati Kulkarni
* @objectreferenced	    None
* @params				None
* @description			This Method is to test Whether URL JSON for BI template is created or not.
* @return				None
*/    
    @isTest
    public static void testGenerateButtonTypeURL() {
        JSONGenerator gen = JSON.createGenerator(true);
        WhatsAppTemplateBI.ButtonValue createButtonValue = new WhatsAppTemplateBI.ButtonValue();
        createButtonValue.id = 123;
        createButtonValue.interActiveType = 'Button';
        createButtonValue.phone_number_OR_url = '917083702341';
        createButtonValue.text = 'Test';
        createButtonValue.type = 'URL';
        List<WhatsAppTemplateBI.ButtonValue> createButtonValueList = new List<WhatsAppTemplateBI.ButtonValue>();
        createButtonValueList.add(createButtonValue);
        Test.startTest();
        gen = WhatsAppTemplateBI.generateButton(createButtonValueList, gen);
        Test.stopTest();
        if(gen != null){
            System.assertNotEquals(Null, gen);
        }
    }
    
    /**
* @methodname			testGenerateButtonTypeQUICK_REPLY
* @author				Rati Kulkarni
* @objectreferenced	    None
* @params				None
* @description			This Method is to test Whether ButtonTypeQUICK_REPLY JSON for BI template is created or not.
* @return				None
*/   
    @isTest
    public static void testGenerateButtonTypeQUICK_REPLY() {
        JSONGenerator gen = JSON.createGenerator(true);
        WhatsAppTemplateBI.ButtonValue createButtonValue = new WhatsAppTemplateBI.ButtonValue();
        createButtonValue.id = 123;
        createButtonValue.interActiveType = 'Button';
        createButtonValue.phone_number_OR_url = '917083702341';
        createButtonValue.text = 'Test';
        createButtonValue.type = 'QUICK_REPLY';
        List<WhatsAppTemplateBI.ButtonValue> createButtonValueList = new List<WhatsAppTemplateBI.ButtonValue>();
        createButtonValueList.add(createButtonValue);
        Test.startTest();
        gen = WhatsAppTemplateBI.generateButton(createButtonValueList, gen);
        Test.stopTest();
        if(gen != null){
            System.assertNotEquals(Null, gen);
        }
    }
    
    
    /**
* @methodname			createTemplateJSONBuilderTest
* @author				Rati Kulkarni
* @objectreferenced	    Template__c,WhatsApp_Template__c.
* @params				None
* @description			This Method is to test whether the JSON for Business Initiated template dynamically created or not.
* @return				None
*/  
    @isTest
    public static void createTemplateJSONBuilderTest() {
        
        List<Template__c> templateList = [Select Id, Name From Template__c];
        List<WhatsApp_Template__c> whatsAppTmpList = [Select Id, Name__c, WhatsApp_Category__c From WhatsApp_Template__c];
        
        String messageBody = 'Hello {!sample1}, this is a {!sample2} message.';
        WhatsAppTemplateBI.SampleValue createSampleValue = new WhatsAppTemplateBI.SampleValue();
        createSampleValue.index = '{{1}}';
        createSampleValue.sampleValue = '{{Name}}';
        createSampleValue.sfFieldName = '{{Name}}';
        List<WhatsAppTemplateBI.SampleValue> createSampleValueList = new List<WhatsAppTemplateBI.SampleValue>();
        createSampleValueList.add(createSampleValue);
        
        WhatsAppTemplateBI.ButtonValue createButtonValue = new WhatsAppTemplateBI.ButtonValue();
        createButtonValue.id = 123;
        createButtonValue.interActiveType = 'Button';
        createButtonValue.phone_number_OR_url = '917083702341';
        createButtonValue.text = 'Test';
        createButtonValue.type = 'QUICK_REPLY';
        List<WhatsAppTemplateBI.ButtonValue> createButtonValueList = new List<WhatsAppTemplateBI.ButtonValue>();
        createButtonValueList.add(createButtonValue);
        
        WhatsAppTemplateBI.TemplateWrapper tempWrapper = new WhatsAppTemplateBI.TemplateWrapper();
        tempWrapper.body = 'Hi {!Name} Good Morning';
        tempWrapper.buttonValues = createButtonValueList;
        tempWrapper.fieldMapping = '[{"index":"{{1}}","sfFieldName":"FirstName","sampleValue":""}]';
        tempWrapper.footerBody = 'ThankYou';
        tempWrapper.headerBody = 'Test';
        tempWrapper.language = 'en_US';
        tempWrapper.media = '';
        tempWrapper.mediaURL='';
        tempWrapper.messageType = ' ';
        tempWrapper.sampleValues = createSampleValueList;
        tempWrapper.templateObject = templateList[0];
        tempWrapper.whatsAppTemplateObject = whatsAppTmpList[0];
        
        system.debug('tempWrapper =='+tempWrapper);
        Test.startTest();
        string getResult =  WhatsAppTemplateBI.createTemplateJSONBuilder(tempWrapper, createSampleValueList); 
        system.debug('getResult =='+getResult);
        Test.stopTest();
        if(getResult != Null){
            system.assertNotEquals(null, getResult);
        }
    }
}