/*
 *  @classname  		: SendButtonConfigurationControllerTest
 *  @author 			: Sarjerao Pujari
 *  @ param             : none
 *  @description  		: This Apex class with @isTest anotation is specialy designed to test the SendButtonConfigurationController.

 *  @modificationlog
 *  	#		Date				 Description				Modified By
 *		1.	    29-10-2023			 Initial Version			Shriram mahamuni
*/
@isTest
public class SendButtonConfigurationControllerTest
{
/**
 * @ methodname             : initializeComponentTest.
 * @ author                 : Sarjerao Pujari.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this method is used to test the initializeComponent method for checking the user accesibility.
 * @ return                 : none.
 */
    @isTest
    public static void initializeComponentTest()
    {
        try
        {
            Test.startTest();
			SendButtonConfigurationController.initializeComponent();
            Test.stopTest();
		}
        catch(Exception ex)
        {
            system.assertEquals(ex.getmessage(),'true');
		}
    }

/**
 * @ methodname             : createSendButtonConfigurationTest.
 * @ author                 : Sarjerao Pujari.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : This method is used to test the sendButtonconfiguration record and vfpage is created or not.
 * @ return                 : none.
 */
    @isTest
    public static void createSendButtonConfigurationTest()
    {
    	string objName = 'Account';
        string phoneFields = 'Phone';
        string nameField = 'Name';
        string optInField = 'Site';
        Test.startTest();
        SendButtonConfigurationController.createSendButtonConfiguration(objName, phoneFields, nameField, optInField);
        Test.stopTest();
		List<Send_Configuration__c> sbcList = new List<Send_Configuration__c>();
		sbcList = [select id from Send_Configuration__c];
		system.assertEquals(sbcList.size(),1);
    }


/**
 * @ methodname             : prepareVFPageWithStandardObjectTest.
 * @ author                 : Sarjerao Pujari.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this method is used to test the  prepareVFPage method by passing the standard object name.
 * @ return                 : none.
 */
    @isTest
    public static void prepareVFPageWithStandardObjectTest()
    {
    	string objName = 'Contact';
        Test.setMock(HttpCalloutMock.class, new SendButtonConfigurationControllerMock());
        Test.startTest();
        SendButtonConfigurationController.prepareVFPage(objName);
        Test.stopTest();

        List<Apexpage> pagelist = new List<Apexpage>();
        pagelist = [select name from Apexpage];
        system.assertNotEquals(pagelist[0].name,'ContactsendButtonConfiguration');
    }


    /**
 * @ methodname             : prepareVFPageNameTest.
 * @ author                 : Sarjerao Pujari.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this method is used to test the  prepareVFPage method by passing parameter as Object name greater than 40 character.
 * @ return                 : none.
 */
    @isTest
    public static void prepareVFPageNameGreateThan40Test()
    {
    	string objName = 'OpportunityLineItem';
        Test.setMock(HttpCalloutMock.class, new SendButtonConfigurationControllerMock());
        Test.startTest();
        SendButtonConfigurationController.prepareVFPage(objName);
        Test.stopTest();

        List<Apexpage> pagelist = new List<Apexpage>();
        pagelist = [select name from Apexpage];
        system.assertNotEquals(pagelist[0].name,'OpportunityLineItemSBConfig');
    }


    /**
 * @ methodname             : prepareVFPageWithCustomObjectTest.
 * @ author                 : Sarjerao Pujari.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this method is used to test the  prepareVFPage method by passing CustomObject Name.
 * @ return                 : none.
 */
    @isTest
    public static void prepareVFPageWithCustomObjectTest()
    {
    	string objName = 'Template__c';
        Test.setMock(HttpCalloutMock.class, new SendButtonConfigurationControllerMock());
        Test.startTest();
        SendButtonConfigurationController.prepareVFPage(objName);
        Test.stopTest();

        List<Apexpage> pagelist = new List<Apexpage>();
        pagelist = [select name from Apexpage];
        system.assertNotEquals(pagelist[0].name,'TemplatesendButtonConfiguration');
    }


    /**
 * @ methodname             : getAllObjectsTest.
 * @ author                 : Sarjerao Pujari.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this method is used to test the getAllObjects method.
 * @ return                 : none.
 */
    @isTest
    public static void getAllObjectsTest()
    {
    	Test.startTest();
        Map<String,String> allObjMap = SendButtonConfigurationController.getAllObjects();
        Test.stopTest();
        system.assert(allObjMap.keySet().size() > 0);
    }

/**
 * @ methodname             : getExistingSBCsTest.
 * @ author                 : Sarjerao Pujari.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this method is used to test the getExistingSBCs method.
 * @ return                 : none.
 */
    @isTest
    public static void getExistingSBCsTest()
    {
    	Test.startTest();
        ApexResultSet aResult = SendButtonConfigurationController.getExistingSBCs();
        Test.stopTest();
        system.assert(aResult.isSuccess);
    }
/**
 * @ methodname             : getfieldsTest.
 * @ author                 : Sarjerao Pujari.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this method is used to test the getExistingSBCs method.
 * @ return                 : none.
 */    
	@isTest
    public static void getfields(){
        Test.startTest();
        	List<FieldDefinition> definationList = SendButtonConfigurationController.getfields('Contact');
        Test.stopTest();
        system.debug('defination List === '+definationList);
        system.assert(definationList != null,true);
        
    }
    
    /**
	* @ methodname             : getRecordDataTest.
	* @ author                 : Sarjerao Pujari.
	* @ objectreferenced       : None.
	* @ param                  : None.
	* @ description            : This method is used to get all the record data based on record Id.
	* @ return                 : None.
	*/
	@isTest
	public static void getRecordDataTest()
	{
        TestDataFactory.createSBCRecords(1,'Contact');
        List<Send_Configuration__c> listOfSBC = [select Id from Send_Configuration__c];
		Id sbcId =  listOfSBC[0].Id;       
        Test.startTest();
        	List<Send_Configuration__c> sbcList = SendButtonConfigurationController.getRecordData(sbcId);
        Test.stopTest();
        system.assertEquals(sbcList != null,true);
	}
}