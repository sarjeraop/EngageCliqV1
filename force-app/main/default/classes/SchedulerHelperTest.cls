/* 
 * @ classname          : SchedulerHelperTest 
 * @ author             : Rati Kulkarni.
 * @ date               : 03-Nov-2023
 * @ description        : This class is to test the performed data preperation for Scheduling activity and schedules a job.
                          It includes Schedule Communication object creation, csv file creation for future references.
 
 * @ modificationlog
 * 1.
 */
@isTest
public class SchedulerHelperTest {

/**
 * @ methodname             : loadTestData.
 * @ author                 : Rati Kulkarni. 
 * @ ObjectReferenced       : None.
 * @ param                  : None.
 * @ description            : This method is used to load a data for testing.
 * @ return                 : None. 
 */     
    @testSetup
    public static void loadTestData(){
        String weeklyCronExpression = '';
        String yearlyCronCronExpression = ''; //SchedulerHelperTest //
        String oneTimeCronExpression = '';
        
                for(integer i=0;i<=3;i++)
                {
                    Account acc = new Account();
                    acc.name = 'test '+i;
                    acc.phone = '919527286478';
                    insert acc;
                }

                Template__c templateObj = new Template__c();
                templateObj.IsActive__c = true;
                templateObj.Description__c = 'this is test template';
                templateObj.Name__c = 'template';
                templateObj.Target_Source__c = 'Account';  
                insert templateObj;
                
        
            WhatsApp_Template__c whatsAppTemplateObj = new WhatsApp_Template__c();
                whatsAppTemplateObj.Name__c = 'Welcome Template';
                whatsAppTemplateObj.IsActive__c = true;
                whatsAppTemplateObj.Template_ID__c = templateObj.Id;
                whatsAppTemplateObj.JSON_Payload__c = '{"messaging_product": "whatsapp","recipient_type":"individual","to":"919765394670","type":"template","template":{"name":"test_bot","language":{"code": "en_US"}}}';
                whatsAppTemplateObj.Message_Body__c ='<p>Hello</p>';
                whatsAppTemplateObj.WhatsApp_Category__c = 'MARKETING';
              insert whatsAppTemplateObj;        
    }

/**
 * @ methodname             : scheduleBatchMethodTest.
 * @ author                 : Rati Kulkarni. 
 * @ ObjectReferenced       : None.
 * @ param                  : None.
 * @ description            : This method is used to Test the schedule batch method.
 * @ return                 : None. 
 */     
    @isTest
    public static void scheduleBatchMethodTest(){
        String templateId = '';
        String objectApiName = 'Account';
        String reportId = '';
        String monthlyCronExression = '0 45 15 1 * ?';
        Date startDate = date.today();
        Date endDate = date.today()+70;
       // Report report=[select Id,Name from Report LIMIT 1];
        reportId = '123456780';
        WhatsApp_Template__c whatsAppTemplateObj = [Select Id from WhatsApp_Template__c LIMIT 1];
        templateId = whatsAppTemplateObj.Id;
        
        Schedule_Communication__c sc = new Schedule_Communication__c();
        List<String> recdsList = new List<String>();
        sc.Cron_Expression__c =monthlyCronExression;
        sc.Template_Id__c =templateId;
        sc.Report_Id__c = reportId;
        sc.Object_Name__c = objectApiName;
        sc.Recipient_Field__c = 'Phone';
        sc.Name_Field__c = 'Name';
        sc.End_Date__c = endDate;
        sc.Start_Date__c = startDate;
        recdsList.add(reportId);
        
        String s = SchedulerHelper.saveSchedule(sc,recdsList);
        system.debug('@@ s '+s);
       //query schedule communication record
       list<Schedule_Communication__c> records = [Select Id from Schedule_Communication__c];
       System.assertEquals(1, records.size());
       //query Child Records
       system.assert(true);
    }

/**
 * @ methodname             : createCSVTest.
 * @ author                 : Rati Kulkarni. 
 * @ ObjectReferenced       : None.
 * @ param                  : None.
 * @ description            : This method Test the list of Record Ids created from a CSV file.
 * @ return                 : None. 
 */    
    @isTest
    public static void createCSVTest(){
        list<String> selectedIdList = new list<String>();
        list<Account> accRecdsList =[Select Id from Account];
        String templateId = '';
        String objectApiName = 'Account';
        String reportId = '';
        String monthlyCronExression = '0 45 15 1 * ?';
        Date startDate = date.today();
        Date endDate = date.today()+70;
       // Report report=[select Id,Name from Report LIMIT 1];
        WhatsApp_Template__c whatsAppTemplateObj = [Select Id from WhatsApp_Template__c LIMIT 1];
        templateId = whatsAppTemplateObj.Id;
        
        Schedule_Communication__c sc = new Schedule_Communication__c();
        List<String> recdsList = new List<String>();
        sc.Cron_Expression__c =monthlyCronExression;
        sc.Template_Id__c =templateId;
        sc.Object_Name__c = objectApiName;
        sc.Recipient_Field__c = 'Phone';
        sc.Name_Field__c = 'Name';
        sc.End_Date__c = endDate;
        sc.Start_Date__c = startDate;
        recdsList.add(reportId);
        
        for(Account acc: accRecdsList){
          selectedIdList.add(acc.Id);  
        }
         String s = SchedulerHelper.saveSchedule(sc,selectedIdList);
         list<Schedule_Communication__c> records = [Select Id from Schedule_Communication__c];
       System.assertEquals(1, records.size());
       //query Child Records
        system.debug('@@@ s '+s);
    }

}