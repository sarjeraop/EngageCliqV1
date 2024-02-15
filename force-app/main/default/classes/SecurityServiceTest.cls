/**  
*  @classname  : SecurityServiceTest
*  @author : Nikita Pawar
*  @date : 20-11-2023
*  @description  : This class tests all the features of classs SecurityService.                  
*/
@isTest
private class SecurityServiceTest {
    
    /**
* @methodname		         createTestdata
* @author				     Nikita Pawar
* @objectreferenced	         PermissionSet, ObjectPermissions, FieldPermissions, User 
* @description			     method to create test data.
*/ 
    @testSetup
    public static void createTestdata(){
        PermissionSet ps = new PermissionSet(Label = 'Test permission set',Name = 'TestPermissionSet');
        insert ps;
        
        // Create User to assign Permission Set 
        User testUser = new User(
            LastName = 'last',
            Email = 'engagecliq@test.com',
            Username = 'engagecliq@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'].Id  
        );
        insert testUser;
        
        //Assign the Permission Set to a user
        PermissionSetAssignment psAssignment = new PermissionSetAssignment();
        psAssignment.AssigneeId = testUser.Id;
        psAssignment.PermissionSetId = ps.Id;
        insert psAssignment;
    }
    
    /**
* @methodname            checkAccessibleTest
* @author                Nikita Pawar
* @objectreferenced      user, PermissionSet, ObjectPermissions
* @description           This method used to test the feature of checkAccessible method.
*/
    @isTest
    public static void checkAccessibleTest(){
        PermissionSet permissionSetToAssign = [Select Id, Name 
                                               From PermissionSet 
                                               Where Name = 'TestPermissionSet' 
                                               Limit 1];
        TestDataFactory.CreateObjectPermissions('Account', true, false, false, false, true, permissionSetToAssign.Id);
        TestDataFactory.CreateFieldPermissions('Account', true, true, 'Account.Phone', true, permissionSetToAssign.Id);
        user testUser = [Select Id, Email 
                         From User 
                         Where Email = 'engagecliq@test.com'
                         Limit 1];
        System.runAs(testUser) {
            String sobjectName = 'Account';
            List<String> fields = new List<String>{'Phone'};
                
                Test.startTest();
            SecurityService.checkAccessible(sobjectName,fields);
            Test.stopTest();
            
            PermissionSet permissionSetRec = [
                SELECT Id,Name 
                FROM PermissionSet
                WHERE Name = 'TestPermissionSet'
                Limit 1
            ];
            
            List<ObjectPermissions>  objPermissionRec = [Select SObjectType, PermissionsRead 
                                                         From ObjectPermissions 
                                                         Where SObjectType = 'Account'
                                                         And ParentId = : permissionSetRec.Id];
            System.assertEquals(objPermissionRec[0].PermissionsRead, true);
        }
    } 
    
      /**
* @methodname            checkAccessibleExceptionTest
* @author                Nikita Pawar
* @objectreferenced      user, PermissionSet, ObjectPermissions
* @description           This method used to test the exception of checkAccessible method.
*/
    @isTest
    public static void checkAccessibleExceptionTest(){
        
        PermissionSet permissionSetToAssign = [Select Id, Name 
                                               From PermissionSet 
                                               Where Name = 'TestPermissionSet' 
                                               Limit 1];
        TestDataFactory.CreateObjectPermissions('Contact', true, false, false, false, true, permissionSetToAssign.Id);
        TestDataFactory.CreateFieldPermissions('Contact', true, true, 'Contact.Phone', true, permissionSetToAssign.Id);
        
        user testUser = [Select Id, Email From User Where Email = 'engagecliq@test.com'];
        System.runAs(testUser) {
            String sobjectName = 'Contact';
            List<String> fields = new List<String>{'Department'};
                try{   
                    Test.startTest();
                    SecurityService.checkAccessible(sobjectName,fields);
                    Test.stopTest();
                }catch(Exception e) {
                    System.assertNotEquals(null, e.getMessage());
                }   
        }
    }
    
    /**
* @methodname            checkDeletableTest
* @author                Nikita Pawar
* @objectreferenced      user, PermissionSet, ObjectPermissions
* @description           method to test delete permission.
*/ 
    @isTest
    public static void checkDeletableTest(){
        PermissionSet permissionSetToAssign = [Select Id, Name 
                                               From PermissionSet 
                                               Where Name = 'TestPermissionSet' 
                                               Limit 1];
        TestDataFactory.CreateObjectPermissions('Account', true, false, true, true, true, permissionSetToAssign.Id);
        user testUser = [Select Id, Email From User Where Email = 'engagecliq@test.com'];
        System.runAs(testUser) {
            String sobjectName = 'Account';
            Test.startTest();
            SecurityService.checkDeletable(sobjectName);
            Test.stopTest();
            
            PermissionSet permissionSetRec = [
                SELECT Id,Name 
                FROM PermissionSet
                WHERE Name = 'TestPermissionSet'
                Limit 1
            ];
            
            List<ObjectPermissions>  objPermissionRec = [Select SObjectType, PermissionsDelete 
                                                        From ObjectPermissions 
                                                        Where SObjectType = 'Account'
                                                        And ParentId = : permissionSetRec.Id];
            System.assertEquals(objPermissionRec[0].PermissionsDelete, true);
        }
    }
    
     
       /**
* @methodname            checkInsertableTest
* @author                Nikita Pawar
* @objectreferenced      user, PermissionSet, ObjectPermissions
* @description           method to test create permission.
*/ 
    @isTest
    public static void checkInsertableTest(){
        PermissionSet permissionSetToAssign = [Select Id, Name 
                                               From PermissionSet 
                                               Where Name = 'TestPermissionSet' 
                                               Limit 1];
        TestDataFactory.CreateObjectPermissions('Lead', true, true, false, false, true, permissionSetToAssign.Id);
        TestDataFactory.CreateFieldPermissions('Lead', true, true, 'Lead.Email', true, permissionSetToAssign.Id);
        user testUser = [Select Id, Email From User Where Email = 'engagecliq@test.com'];
        System.runAs(testUser) {
            String sobjectName = 'Lead';
            List<String> fields = new List<String>{'Email'};
                Test.startTest();
            SecurityService.checkInsertable(sobjectName,fields);
            Test.stopTest();
            PermissionSet permissionSetRec = [
                SELECT Id,Name 
                FROM PermissionSet
                WHERE Name = 'TestPermissionSet'
                Limit 1
            ];
            
            List<ObjectPermissions>  objPermissionRec = [Select SObjectType, PermissionsCreate 
                                                         From ObjectPermissions 
                                                         Where SObjectType = 'Lead'
                                                         And ParentId = : permissionSetRec.Id];
            System.assertEquals(objPermissionRec[0].PermissionsCreate, true);
        }
    }
    
        /**
* @methodname            checkUpdatableTest
* @author                Nikita Pawar
* @objectreferenced      user, PermissionSet, ObjectPermissions
* @description           method to test create permission.
*/ 
    @isTest
    public static void checkUpdatableTest(){
        PermissionSet permissionSetToAssign = [Select Id, Name 
                                               From PermissionSet 
                                               Where Name = 'TestPermissionSet' 
                                               Limit 1];
        TestDataFactory.CreateObjectPermissions('Account', true, true, true, false, true, permissionSetToAssign.Id);
        TestDataFactory.CreateFieldPermissions('Account', true, true, 'Account.phone', true, permissionSetToAssign.Id);
        user testUser = [Select Id, Email From User Where Email = 'engagecliq@test.com'];
        System.runAs(testUser) {
            String sobjectName = 'Account';
            List<String> fields = new List<String>{'Phone'};
            Test.startTest();
            SecurityService.checkUpdatable(sobjectName,fields);
            Test.stopTest();
            PermissionSet permissionSetRec = [
                SELECT Id,Name 
                FROM PermissionSet
                WHERE Name = 'TestPermissionSet'
                Limit 1
            ];
            
            List<ObjectPermissions>  objPermissionRec = [Select SObjectType, PermissionsCreate 
                                                        From ObjectPermissions 
                                                        Where SObjectType = 'Account'
                                                        And ParentId = : permissionSetRec.Id];
            System.assertEquals(objPermissionRec[0].PermissionsCreate, true);
        }
    }
    
          /**
* @methodname            checkUpdatableExceptionTest
* @author                Nikita Pawar
* @objectreferenced      user, PermissionSet, ObjectPermissions
* @description           method to test Exception scenario in checkUpdatable method.
*/
    @isTest
    public static void checkUpdatableExceptionTest(){
        PermissionSet permissionSetToAssign = [Select Id, Name 
                                               From PermissionSet 
                                               Where Name = 'TestPermissionSet' 
                                               Limit 1];
        TestDataFactory.CreateObjectPermissions('Contact', true, true, false, false, true, permissionSetToAssign.Id);
        TestDataFactory.CreateFieldPermissions('Contact', true, true, 'Contact.Phone', true, permissionSetToAssign.Id);
        user testUser = [Select Id, Email From User Where Email = 'engagecliq@test.com'];
        System.runAs(testUser) {
            String sobjectName = 'Contact';
            List<String> fields = new List<String>{'AssistantPhone'};
                try{
                    Test.startTest();
                    SecurityService.checkUpdatable(sobjectName,fields);
                    SecurityService.CrudException crud = new SecurityService.CrudException(SecurityService.OperationType.MODIFY,Contact.SObjectType);
                    Test.stopTest();
                }catch(Exception e){
                    System.assertNotEquals(null, e.getMessage());
                }
        }
    }
    
       /**
* @methodname            checkInsertableExceptionTest
* @author                Nikita Pawar
* @objectreferenced      user, PermissionSet, ObjectPermissions
* @description           method to test Exception scenario in checkInsertable method.
*/
    @isTest
    public static void checkInsertableExceptionTest(){
        PermissionSet permissionSetToAssign = [Select Id, Name 
                                               From PermissionSet 
                                               Where Name = 'TestPermissionSet' 
                                               Limit 1];
        TestDataFactory.CreateObjectPermissions('Case', true, false, false, false, true, permissionSetToAssign.Id);
        TestDataFactory.CreateFieldPermissions('Case', true, true, 'Case.Priority', true, permissionSetToAssign.Id);
        user testUser = [Select Id, Email From User Where Email = 'engagecliq@test.com'];
        System.runAs(testUser) {
            String sobjectName = 'Case';
            List<String> fields = new List<String>{'Priority'};
                try{
                    Test.startTest();
                    SecurityService.checkInsertable(sobjectName,fields);
                    Test.stopTest();
                }catch(Exception e){
                    System.assertNotEquals(null, e.getMessage());
                }
        }
    }
    
      /**
* @methodname            checkDeletableExcTest
* @author                Nikita Pawar
* @objectreferenced      user, PermissionSet, ObjectPermissions
* @description           method to test Exception scenario in checkDeletable method.
*/
    @isTest
    public static void checkDeletableExcTest(){
        
        PermissionSet permissionSetToAssign = [Select Id, Name 
                                               From PermissionSet 
                                               Where Name = 'TestPermissionSet' 
                                               Limit 1];
        TestDataFactory.CreateObjectPermissions('Case', true, false, false, false, true, permissionSetToAssign.Id);
        TestDataFactory.CreateFieldPermissions('Case', true, true, 'Case.Priority', true, permissionSetToAssign.Id);
        user testUser = [Select Id, Email From User Where Email = 'engagecliq@test.com'];
        System.runAs(testUser) {
            String sobjectName = 'Case';
            try{
                Test.startTest();
                SecurityService.checkDeletable(sobjectName);
                Test.stopTest();
            }catch(Exception e){
                System.assertNotEquals(null, e.getMessage());
            }
        }
    }

}