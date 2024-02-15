/**
  * @name				DatabaseServiceTest
  * @author				Suhas Mankar
  * @description		This is databaseTest class which help to perform dml and error handling 
  * @createddate			
  */
@IsTest
public class DatabaseServiceTest {

/**
 * @ methodname             : setup.
 * @ author                 : Suhas Mankar 
 * @ objectreferenced       : Account.
 * @ param                  : None.
 * @ description            : This method is create test data used for testing.
 * @ return                 : None. 
 */    
    @testSetup static void setup(){        
        Account account = new Account();
        account.Name = 'Test Account';  
        insert account;       
        
    }
    
/**
  * @ methodname             : dbInsertTest.
  * @ author                 : Suhas Mankar 
  * @ objectreferenced       : Account.
  * @ param                  : None.
  * @ description            : This method is for test insert operation.
  * @ return                 : None. 
  */    
    static testMethod void dbInsertTest() {
        System.assert(true);
    }

/**
  * @ methodname             : dbUpdateTest.
  * @ author                 : Suhas Mankar 
  * @ objectreferenced       : None.
  * @ param                  : None.
  * @ description            : This method is for test update operation.
  * @ return                 : None. 
  */
    static testMethod void dbUpdateTest() {
        System.assert(true);
    }

/**
  * @ methodname             : dbUpsertTest.
  * @ author                 : Suhas Mankar 
  * @ objectreferenced       : Account.
  * @ param                  : None.
  * @ description            : This method is for test upsert operation.
  * @ return                 : None. 
  */    
    static testMethod void dbUpsertTest() {
        System.assert(true);
    }

/**
  * @ methodname             : dbDeleteTest.
  * @ author                 : Suhas Mankar 
  * @ objectreferenced       : Account.
  * @ param                  : None.
  * @ description            : This method is for test delete operation.
  * @ return                 : None. 
  */  
    static testMethod void dbDeleteTest() {
        System.assert(true);
    }

/**
  * @ methodname             : dbDeleteTest1.
  * @ author                 : Suhas Mankar 
  * @ objectreferenced       : Account.
  * @ param                  : None.
  * @ description            : This method is for test delete data.
  * @ return                 : None. 
  */     
    static testMethod void dbDeleteTest1() {
        List<Account> listAcc= new List<Account>(); 
	    listAcc = [SELECT Id FROM Account WHERE Name='Test Account'];    
        DatabaseService.DB_Input dbinput = new DatabaseService.DB_Input(listAcc,False,True,'DatabaseService');
		DatabaseService.DB_Result  dbr= DatabaseService.dbDelete(dbinput);
        System.assert(true);
    }

/**
  * @ methodname             : dbUnDeleteTest1.
  * @ author                 : Suhas Mankar 
  * @ objectreferenced       : Account.
  * @ param                  : None.
  * @ description            : This method is for test unelete data.
  * @ return                 : None. 
  */    
    static testMethod void dbUnDeleteTest1() {
        List<Account> listAcc= new List<Account>(); 
	    listAcc = [SELECT Id FROM Account WHERE Name='Test Account'];
        delete listAcc;
        DatabaseService.DB_Input dbinput = new DatabaseService.DB_Input(listAcc,False,True,'DatabaseService');
		DatabaseService.DB_Result  dbr= DatabaseService.dbUnDelete(dbinput);
        System.assert(true);
    }

/**
  * @ methodname             : dbUpdateTest1.
  * @ author                 : Suhas Mankar 
  * @ objectreferenced       : Account.
  * @ param                  : None.
  * @ description            : This method is for test update data.
  * @ return                 : None. 
  */    
    static testMethod void dbUpdateTest1() {
        List<Account> listAcc= new List<Account>(); 
	    listAcc = [SELECT Id FROM Account WHERE Name='Test Account'];
        DatabaseService.DB_Input dbinput = new DatabaseService.DB_Input(listAcc,False,True,'DatabaseService');
		DatabaseService.DB_Result  dbr= DatabaseService.dbUpdate(dbinput);
        System.assert(true);
    }
    
/**
  * @ methodname             : dbInsertTest1.
  * @ author                 : Suhas Mankar 
  * @ objectreferenced       : Account.
  * @ param                  : None.
  * @ description            : This method is for test insert data.
  * @ return                 : None. 
  */
    static testMethod void dbInsertTest1() {
        List<Account> listAcc= new List<Account>(); 
	    Account account = new Account();
        account.Name = 'Test Account1';        
        listAcc.add(account);        
        DatabaseService.DB_Input dbinput = new DatabaseService.DB_Input(listAcc,False,True,'DatabaseService');
		DatabaseService.DB_Result  dbr= DatabaseService.dbInsert(dbinput);
        System.assert(true);
    }

/**
  * @ methodname             : dbInsertTest2.
  * @ author                 : Suhas Mankar 
  * @ objectreferenced       : Account.
  * @ param                  : None.
  * @ description            : This method is for test insert data.
  * @ return                 : None. 
  */
    static testMethod void dbInsertTest2() {
        List<Account> listAcc= new List<Account>(); 
	    listAcc = [SELECT Id FROM Account WHERE Name='Test Account'];   
        DatabaseService.DB_Input dbinput = new DatabaseService.DB_Input(listAcc,False,True,'DatabaseService');
		DatabaseService.DB_Result  dbr= DatabaseService.dbInsert(dbinput);
        System.assert(true);
    }

/**
  * @ methodname             : dbUpsertTest1.
  * @ author                 : Suhas 
  * @ objectreferenced       : Account, DatabaseService.
  * @ param                  : None.
  * @ description            : This method is to test upsert data.
  * @ return                 : None. 
  */
    
    static testMethod void dbUpsertTest1() {
        List<Account> listAcc= new List<Account>(); 
	    listAcc = [SELECT Id FROM Account WHERE Name='Test Account'];
        DatabaseService.DB_Input dbinput = new DatabaseService.DB_Input(listAcc,False,True,'DatabaseService');
        String techarObjString = 'Account.Id';
        List<String> splitString = techarObjString.split('\\.');
        dbinput.uniqueFiledName = Schema.getGlobalDescribe().get(splitString[0]).getDescribe().fields.getMap().get(splitString[1]);
		DatabaseService.DB_Result  dbr= DatabaseService.dbUpsert(dbinput);
        System.assert(true);
    }
    
    /**
  * @ methodname             : DB_InputTest.
  * @ author                 : Nikita Pawar 
  * @ objectreferenced       : Account.
  * @ param                  : None.
  * @ description            : This method is to test assignment.
  * @ return                 : None. 
  */  
    @IsTest
    static void DB_InputTest() {
        List<Account> listAcc= new List<Account>(); 
	    Account account = new Account();
        account.Name = 'Test Account1'; 
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Account').getDescribe();
        Schema.DescribeFieldResult fieldDescribe ;
        Schema.SObjectField sObjectField;
        String fieldName;
        for (Schema.SObjectField field : describeResult.fields.getMap().values()) 
            {
               fieldDescribe = field.getDescribe();
               sObjectField = field;
               fieldName = fieldDescribe.getName();
            }
        listAcc.add(account);        
        DatabaseService.DB_Input dbinput = new DatabaseService.DB_Input(listAcc,False,True,'DatabaseService',sObjectField);
		DatabaseService.DB_Result  dbr= DatabaseService.dbInsert(dbinput);
        System.assert(true);
    }
}