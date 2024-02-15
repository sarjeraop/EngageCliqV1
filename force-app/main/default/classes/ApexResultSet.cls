/**  @classname  : ApexResultSet
  *  @author : Abhishek Daware
  *  @date : 
  *  @description  : This is generic class which is return via any lightning component   
*/
public class ApexResultSet {
    // Holds value to be sent to component
    @AuraEnabled
    public Object data;
    
    // Whether success response or not
    @AuraEnabled
    public boolean isSuccess;
    
    // Can be used to send success message
    @AuraEnabled
    public String message;
    
    public ApexResultSet() {
        isSuccess = true;
        message = '';
    }

     // Constructor
     public ApexResultSet(boolean isSuccess, String message){
        this.isSuccess = isSuccess;
        this.message = message;
    }

}