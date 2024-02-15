/*
 *  @classname  		: ApplicationLoggerTest
 *  @author 			: Purushottam Bhaigade
 *  @ param             : none
 *  @description  		: This is the class which helps to Test all the loged exceptions.

 *  @modificationlog
 *  	#		Date				 Description				Modified By
 *		1.	    22-12-2023			 Added Comments			    sarjerao Pujari
*/
@isTest
public class ApplicationLoggerTest {

/**
 * @ methodname             : logExceptionTest.
 * @ author                 : Purushottam Bhaigade.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : This is generic exception log Test method which Test the loged exceptions.
 * @ return                 : none.
 */    
    @isTest 
    public static void logExceptionTest(){
        Test.StartTest();
        try{
            Integer i = 0;
            Decimal d = 10 / i; 
        }catch(Exception ex){
            ApplicationLogger.logException(ex);
        }
        Test.StopTest();
        
        List<Error_Log__c> errorList = [Select Id from Error_Log__c];
        system.debug('errorList '+errorList);
        system.assert(errorList.size() > 0);
    }
}