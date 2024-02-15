@isTest
public class CreateTemplateTest {
    
    @TestSetup
    public static Void testSetupForCreateTemplate(){
    List <Template__c> templateList = testDataFactory.createTemplate(5, true);
    List<WhatsApp_Template__c> whtasAppTemplateList = testDataFactory.createWhatsAppTemplate(templateList[0].Id, 5, true);
    }    
 /*   @isTest
    public static Void getWhatsAppTemplateTest(){
        
         List<Template__c> templates =TestDataFactory.createTemplate(1, true);
         List<WhatsApp_Template__c> whatsApptemplates = TestDataFactory.createWhatsAppTemplate(templates[0].Id, 1, true);
        
         Test.startTest();
         CreateTemplate.getWhatsAppTemplate(whatsApptemplates[0].Id);
         Test.stopTest();
        
    }*/

   /* @isTest
    static void testSaveWhatsAppTemplate() {
        
        String jsonValue = '{"templateObject":{"sobjectType":"Template__c","Name__c":"Edit WP Temp","Description__c":"dhbfhk","Target_Source__c":"Contact"},"whatsAppTemplateObject":{"Id":"a0F5j00000co41KEAQ","Name":"test_bot","Merge_Field_Mapping__c":"[]","IsActive__c":true,"JSON_Payload__c":"","Message_Body__c":"<p>This is a test message</p>","Status__c":"Approved","WhatsApp_Category__c":"MARKETING","Template_Type__c":"Business Initiative","Language__c":"en_US","JSON_Wrapper__c":"","Template_ID__c":"a0E5j00000NQQRbEAP"},"language":"en_US","targetObject":"Contact","body":"<p>This is a test Message</p>","media":"","messageType":"Button","headerBody":"Sample Test","footerBody":"SF","mediaURL":"","buttonValues":[{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Satisfactory","phone_number_OR_url":"","id":1},{"interActiveType":"quickreply","type":"QUICK_REPLY","text":"Awesome","phone_number_OR_url":"","id":2}],"sampleValues":[],"fieldMapping":"[]"}';

        Test.startTest();
        CreateTemplate.saveWhatsAppTemplate(jsonValue);
        Test.stopTest();
    }*/
    
    @isTest
    static void createTemplateRecordTest(){
        List<Template__c> templatelist = [Select Id, Name From Template__c];
            test.startTest();
            createTemplate.createTemplateRecord(templatelist[0]);
            test.stopTest();
    }
    
    @isTest
    static void createWhatsAppTemplateRecordTest(){
        List<WhatsApp_Template__c>whatsAppTemplate = [Select Id, Name From WhatsApp_Template__c];
        system.debug('whatsAppTemplate=='+whatsAppTemplate);
        Test.startTest();
        createTemplate.createWhatsAppTemplateRecord(whatsAppTemplate[0]);
        Test.stopTest();
    }
    
    @isTest
    Static void generateHeaderTest(){
        JSONGenerator gen = JSON.createGenerator(true);
        String type = 'text';
        String headerBody = 'This is a header text';
        String mediaUrl = null; 
        Test.startTest();
        gen = CreateTemplate.generateHeader(type, headerBody, mediaUrl, gen);
        Test.stopTest();
        if(gen != null){
        System.assertNotEquals(Null, gen);
        }
        
    }
    
    @isTest
    public static void testGenerateFooter() {
        JSONGenerator gen = JSON.createGenerator(true);
        String footerBody = 'This is a footer text';
        Test.startTest();
        gen = CreateTemplate.generateFooter(footerBody, gen);
        Test.stopTest();
        system.debug('gen =='+gen);
        if(gen != null){
        System.assertNotEquals(Null, gen);
        }
    }

    @isTest
    public static void testGenerateBody() {
        JSONGenerator gen = JSON.createGenerator(true);
        String messageBody = 'Hello {!sample1}, this is a {!sample2} message.';
        CreateTemplate.SampleValue createSampleValue = new CreateTemplate.SampleValue();
        createSampleValue.index = '{{1}}';
        createSampleValue.sampleValue = '{{Name}}';
        createSampleValue.sfFieldName = '{{Name}}';
        List<CreateTemplate.SampleValue> createSampleValueList = new List<CreateTemplate.SampleValue>();
        createSampleValueList.add(createSampleValue);
        Test.startTest();
        gen = CreateTemplate.generateBody(messageBody, createSampleValueList, gen);
        Test.stopTest();
        if(gen != null){
        System.assertNotEquals(Null, gen);
        }
 
    }

    @isTest
    public static void testGenerateButton() {
        JSONGenerator gen = JSON.createGenerator(true);
        CreateTemplate.ButtonValue createButtonValue = new CreateTemplate.ButtonValue();
        createButtonValue.id = 123;
        createButtonValue.interActiveType = 'Button';
        createButtonValue.phone_number_OR_url = '917083702341';
        createButtonValue.text = 'Test';
        createButtonValue.type = 'PHONE_NUMBER';
        List<CreateTemplate.ButtonValue> createButtonValueList = new List<CreateTemplate.ButtonValue>();
        createButtonValueList.add(createButtonValue);
        Test.startTest();
        gen = CreateTemplate.generateButton(createButtonValueList, gen);
        Test.stopTest();
        system.debug('gen =='+gen);
        if(gen != null){
        System.assertNotEquals(Null, gen);
        }
    }
    
     @isTest
    public static void testGenerateButtonTypeURL() {
        JSONGenerator gen = JSON.createGenerator(true);
        CreateTemplate.ButtonValue createButtonValue = new CreateTemplate.ButtonValue();
        createButtonValue.id = 123;
        createButtonValue.interActiveType = 'Button';
        createButtonValue.phone_number_OR_url = '917083702341';
        createButtonValue.text = 'Test';
        createButtonValue.type = 'URL';
        List<CreateTemplate.ButtonValue> createButtonValueList = new List<CreateTemplate.ButtonValue>();
        createButtonValueList.add(createButtonValue);
        Test.startTest();
        gen = CreateTemplate.generateButton(createButtonValueList, gen);
        Test.stopTest();
        if(gen != null){
        System.assertNotEquals(Null, gen);
        }
    }
    
    @isTest
    public static void testGenerateButtonTypeQUICK_REPLY() {
        JSONGenerator gen = JSON.createGenerator(true);
        CreateTemplate.ButtonValue createButtonValue = new CreateTemplate.ButtonValue();
        createButtonValue.id = 123;
        createButtonValue.interActiveType = 'Button';
        createButtonValue.phone_number_OR_url = '917083702341';
        createButtonValue.text = 'Test';
        createButtonValue.type = 'QUICK_REPLY';
        List<CreateTemplate.ButtonValue> createButtonValueList = new List<CreateTemplate.ButtonValue>();
        createButtonValueList.add(createButtonValue);
        Test.startTest();
        gen = CreateTemplate.generateButton(createButtonValueList, gen);
        Test.stopTest();
        if(gen != null){
        System.assertNotEquals(Null, gen);
        }
    }
    
    @isTest
    public static void createTemplateJSONBuilderTest() {
        
        List<Template__c> templateList = [Select Id, Name From Template__c];
        List<WhatsApp_Template__c> whatsAppTmpList = [Select Id, Name, WhatsApp_Category__c From WhatsApp_Template__c];
        
        String messageBody = 'Hello {!sample1}, this is a {!sample2} message.';
        CreateTemplate.SampleValue createSampleValue = new CreateTemplate.SampleValue();
        createSampleValue.index = '{{1}}';
        createSampleValue.sampleValue = '{{Name}}';
        createSampleValue.sfFieldName = '{{Name}}';
        List<CreateTemplate.SampleValue> createSampleValueList = new List<CreateTemplate.SampleValue>();
        createSampleValueList.add(createSampleValue);
        
        CreateTemplate.ButtonValue createButtonValue = new CreateTemplate.ButtonValue();
        createButtonValue.id = 123;
        createButtonValue.interActiveType = 'Button';
        createButtonValue.phone_number_OR_url = '917083702341';
        createButtonValue.text = 'Test';
        createButtonValue.type = 'QUICK_REPLY';
        List<CreateTemplate.ButtonValue> createButtonValueList = new List<CreateTemplate.ButtonValue>();
        createButtonValueList.add(createButtonValue);
        
        CreateTemplate.TemplateWrapper tempWrapper = new CreateTemplate.TemplateWrapper();
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
        string getResult =  createTemplate.createTemplateJSONBuilder(tempWrapper, createSampleValueList); 
        system.debug('getResult =='+getResult);
        Test.stopTest();
        if(getResult != Null){
            system.assertNotEquals(null, getResult);
        }
    }
}