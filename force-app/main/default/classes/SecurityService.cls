/**
 * @class       : SecurityService
 * @description : Class representing security checks on objects and fields levels
 * @usage       : Depending on the level of detail, return schema level details based on user level access on objects and field access
 * @author      : Abhishek Daware
 * @date        : 22-08-2023
 * @version     : 1.0
 */

public inherited sharing class SecurityService {
    public SecurityService() {

    }
  
    private static String prefix = Constants.NAMESPACEPREFIX;

    @TestVisible
    private enum OperationType { CREATE, READ, MODIFY, DEL }



    
    public virtual class SecurityException extends Exception {
        protected OperationType m_operation;
        protected Schema.SObjectType m_objectType;
    }

    /**  @classname  : SecurityException
      *  @author : Abhishek Daware
      *  @date : 
      *  @description  :  CrudException represents a running user's lack of read/create/update/delete access at a profile (or permission set)
     *  level. Sharing and field level security issues will never cause this.     
    */
    public class CrudException extends SecurityException{
    	@TestVisible
    	private CrudException(OperationType operation, Schema.SObjectType objectType){
    		this.m_operation = operation;
    		this.m_objectType = objectType;
    		if(operation == OperationType.CREATE) {
          this.setMessage(System.Label.security_error_object_not_insertable_label);
        }
    		else if(operation == OperationType.READ) {
          this.setMessage(System.Label.security_error_object_not_readable_label);
        }
    		else if(operation == OperationType.MODIFY) {
          this.setMessage(System.Label.security_error_object_not_updatable_label);
        }
    		else if(operation == OperationType.DEL) {
          this.setMessage(System.Label.security_error_object_not_deletable_label);
        }

    		this.setMessage(
    			String.format(
    				this.getMessage(),
    				new List<String>{
    					objectType.getDescribe().getName()
    				} 
    			)
    		);
    	}
    }

    /**  @classname  : FlsException
      *  @author : Abhishek Daware
      *  @date : 
      *  @description  :  FlsException represents a running user's lack of field level security to a specific field at a profile (or permission set) level
      * Sharing and CRUD security issues will never cause this to be thrown.     
    */
   
    public class FlsException extends SecurityException{
    	private Schema.SObjectField m_fieldToken;
    	private FlsException(OperationType operation, Schema.SObjectType objectType, Schema.SObjectField fieldToken){
    		this.m_operation = operation;
    		this.m_objectType = objectType;
    		this.m_fieldToken = fieldToken;
    		if(operation == OperationType.CREATE) {
          this.setMessage(System.Label.security_error_field_not_insertable_label);
        }
    		else if(operation == OperationType.READ) {
          this.setMessage(System.Label.security_error_field_not_readable_label);
        }
    		else if(operation == OperationType.MODIFY) {
    			this.setMessage(System.Label.security_error_field_not_updatable_label);
        }

    		this.setMessage(
    			String.format(
	    			this.getMessage(),
	    			new List<String>{
	    				objectType.getDescribe().getName(),
	    				fieldToken.getDescribe().getName()
	    			}
	    		)
    		);
    	}
    }

    /**  @methodname : checkAccessible
      *  @author : Abhishek Daware
      *  @objectreferenced  : 
      *  @param  : 
      *  @description  : This method represents a running user's lack of Obejct's and field read access at a profile (or permission set) level
      *  @return : 
    */

    @AuraEnabled
    public static void checkAccessible(String sobjectName, List<String> fields) {
      //String sobjectName = 'Account';
      SObjectType objType = ((SObject)Type.forName('Schema',sobjectName).newInstance()).getSObjectType();
      Schema.DescribeSObjectResult dResult = objType.getDescribe();
      if (!dResult.isAccessible()) {
        throw new CrudException(OperationType.READ, objType);
      }

      Map<String,Schema.SObjectField> fieldMap = dResult.fields.getMap();
      for ( String fieldToCheck : fields ) {
        if ( !fieldMap.get(prefix+fieldToCheck).getDescribe().isAccessible()) {
          throw new FlsException(OperationType.READ, objType, fieldMap.get(fieldToCheck));
        }
      }
    }

    /**  @methodname : checkDeletable
      *  @author : Abhishek Daware
      *  @objectreferenced  : 
      *  @param  : 
      *  @description  : This method represents a running user's lack of Obejct's delete access at a profile (or permission set) level
      *  @return : 
    */

    @AuraEnabled
    public static void checkDeletable(String sobjectName) {
      //String sobjectName = 'Account';
      SObjectType objType = ((SObject)Type.forName('Schema',sobjectName).newInstance()).getSObjectType();
      Schema.DescribeSObjectResult dResult = objType.getDescribe();
      if (!dResult.isDeletable()) {
        throw new CrudException(OperationType.DEL, objType);
      }
    }

    /**  @methodname : checkInsertable
      *  @author : Abhishek Daware
      *  @objectreferenced  : 
      *  @param  : 
      *  @description  : This method represents a running user's lack of Obejct's and field create access at a profile (or permission set) level
      *  @return : 
    */

    @AuraEnabled
    public static void checkInsertable(String sobjectName, List<String> fields) {
      //String sobjectName = 'Account';
      SObjectType objType = ((SObject)Type.forName('Schema',sobjectName).newInstance()).getSObjectType();
      Schema.DescribeSObjectResult dResult = objType.getDescribe();
      if (!dResult.isCreateable()) {
        throw new CrudException(OperationType.CREATE, objType);
      }

      Map<String,Schema.SObjectField> fieldMap = dResult.fields.getMap();
      for ( String fieldToCheck : fields ) {
        if ( !fieldMap.get(prefix+fieldToCheck).getDescribe().isCreateable()) {
          throw new FlsException(OperationType.CREATE, objType, fieldMap.get(fieldToCheck));
        }
      }
    }

    /**  @methodname : checkAccessible
      *  @author : Abhishek Daware
      *  @objectreferenced  : 
      *  @param  : 
      *  @description  : This method represents a running user's lack of Obejct's and field update access at a profile (or permission set) level
      *  @return : 
    */

    @AuraEnabled
    public static void checkUpdatable(String sobjectName, List<String> fields) {
      //String sobjectName = 'Account';
      SObjectType objType = ((SObject)Type.forName('Schema',sobjectName).newInstance()).getSObjectType();
      Schema.DescribeSObjectResult dResult = objType.getDescribe();
      if (!dResult.isUpdateable()) {
        throw new CrudException(OperationType.MODIFY, objType);
      }

      Map<String,Schema.SObjectField> fieldMap = dResult.fields.getMap();
      for ( String fieldToCheck : fields ) {
        if ( !fieldMap.get(prefix+fieldToCheck).getDescribe().isUpdateable()) {
          throw new FlsException(OperationType.MODIFY, objType, fieldMap.get(fieldToCheck));
        }
      }
    }
  }