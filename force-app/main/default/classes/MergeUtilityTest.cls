/**
  * @name				MergeUtilityTest
  * @author				Suhas Mankar
  * @description		This is MergeUtilityTest class for MergeUtility Class
  * @createddate			
  */
@isTest
public class MergeUtilityTest {
    
/**
 * @ methodname             : createTestData.
 * @ author                 : Suhas Mankar 
 * @ objectreferenced       : Account, Contact.
 * @ param                  : None.
 * @ description            : This method is create test data used for testing.
 * @ return                 : None. 
 */
	@testSetup
     static void createTestData(){
        Account newAccount = new Account(Name='Test Account', Phone ='1234567890');
        insert newAccount;
        Contact newContact = new Contact(FirstName='Test', LastName='Contact', Email='test@test.com', AccountId=newAccount.Id);
        insert newContact;    
    }

/**
 * @ methodname             : replaceMergeFieldsWithValuesTest.
 * @ author                 : Suhas Mankar 
 * @ objectreferenced       : Account, Contact.
 * @ param                  : Contact.
 * @ description            : This method is test merge message with start and end pattern.
 * @ return                 : None. 
 */    
    @isTest
    static void replaceMergeFieldsWithValuesTest(){
        List<Contact> conList = [Select Id, FirstName,Email From Contact Where FirstName = 'Test'];
        List<String> recordIdList = new List<String>();
        recordIdList.add(conList[0].Id);
        String myTemplate = 'Hey {!FirstName}, your email address is {!Email}';
        String StartPattern = '{!';
        String EndPattern = '}';
        String objectName = 'Contact';
        Test.startTest();
        String myResult = (MergeUtility.replaceMergeFieldsWithValues (startPattern, endPattern, myTemplate, objectName, recordIdList)).get(conList[0].Id);
        System.assertEquals('Hey Test, your email address is test@test.com', myResult);
        Test.stopTest();
    }

/**
 * @ methodname             : replaceMergeFieldsWithValuesTest1.
 * @ author                 : Suhas Mankar 
 * @ objectreferenced       : Account, Contact.
 * @ param                  : Contact.
 * @ description            : This method is test merge message without start and end pattern.
 * @ return                 : None. 
 */        
     @isTest
    static void replaceMergeFieldsWithValuesTest1(){
        List<Contact> conList = [Select Id, FirstName,Email From Contact Where FirstName = 'Test'];
        List<String> recordIdList = new List<String>();
        recordIdList.add(conList[0].Id);
        String myTemplate = 'Hey {!FirstName}, your email address is {!Email}';
        String objectName = 'Contact';
    	Test.startTest();
  		String myResult = (MergeUtility.replaceMergeFieldsWithValues (myTemplate, objectName, recordIdList)).get(conList[0].Id);
		Test.stopTest();
        System.assertEquals('Hey Test, your email address is test@test.com', myResult);
    }

/**
 * @ methodname             : replaceMergeFieldsWithValuesWithParentTest.
 * @ author                 : Suhas Mankar 
 * @ objectreferenced       : Account, Contact.
 * @ param                  : Contact.
 * @ description            : This method is test merge message with parent Merge field without start and end pattern.
 * @ return                 : None. 
 *       
     @isTest
    static void replaceMergeFieldsWithValuesWithParentTest(){
        List<Contact> conList = [Select Id, FirstName,Email,AccountId, Account.Name, Account.Phone From Contact Where FirstName = 'Test'];
        List<String> recordIdList = new List<String>();
        recordIdList.add(conList[0].Id);
        String myTemplate = 'Hey {!FirstName}, your email address is {!Email} Account Name {!Account.Name} Phone {!Account.Phone}';
        String objectName = 'Contact';
    	Test.startTest();
  		Map<String,String> myResult = MergeUtility.replaceMergeFieldsWithValues (myTemplate, objectName, recordIdList);
		Test.stopTest();
        System.assertEquals(myResult.isEmpty(), false);
        System.assertEquals('Hey Test, your email address is test@test.com Account Name Test Account Phone 1234567890', myResult.get(conList[0].AccountId));
    } 
    */
/**
 * @ methodname             : replaceMergeFieldsWithValuesWithParentTest1.
 * @ author                 : Suhas Mankar 
 * @ objectreferenced       : Account, Contact.
 * @ param                  : Contact.
 * @ description            : This method is test merge message with parent Merge field without start and end pattern.
 * @ return                 : None. 
 */        
     @isTest
    static void replaceMergeFieldsWithValuesWithParentTest1(){
        List<Contact> conList = [Select Id, FirstName,Email,AccountId, Account.Name, Account.Phone From Contact Where FirstName = 'Test'];
        List<String> recordIdList = new List<String>();
        recordIdList.add(conList[0].Id);
        String myTemplate = 'Hey {!FirstName}, your email address is {!Email} Account Name {!Account.Name} Phone {!Account.Phone}';
        String objectName = 'Contact';
        String StartPattern = '{!';
        String EndPattern = '}';
    	Test.startTest();
  		Map<String,String> myResult = MergeUtility.replaceMergeFieldsWithValues(startPattern, endPattern, myTemplate, objectName, recordIdList);
		Test.stopTest();
        System.assertEquals(myResult.isEmpty(), false);
        System.assertEquals('Hey Test, your email address is test@test.com Account Name Test Account Phone 1234567890', myResult.get(conList[0].AccountId));
    }
}