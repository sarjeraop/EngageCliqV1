/**  	
	 *	@classname  				: ApplicationLogger
	*  @author 					    : Purushottam Bhaigade
	*  @description  				: This is the ApplicationLogger class which helps to log all the exceptions.
	*  @modificationlog
	*  	#		Date						Description							Modified By
	*		1.	01-10-2023			Initital Version				Purushpttam Bhaigade  																				
*/
public with sharing class ApplicationLogger {

 /**  
	 *  @methodname 					    : logException
	 *  @author 							: Purushottam Bhaigade
	 *  @objectreferenced  		            : Error_Log__c
	 *  @param  							: Exception
	 *  @description  				        : This is generic exception log method which log all exceptions
	 *  @return 							: none
 */
	public static void logException(Exception error){
		List<String> stackTrace = error.getStackTraceString().split('\n')[0].replaceAll('Class.','').split('\\:');
 		String className = '';
		if(stackTrace != null || stackTrace.size() >= 1 ){
 			className = stackTrace[0];
 		}
 		Error_Log__c errorLog = new Error_Log__c();
 		errorLog.Error_Message__c = error.getMessage()+'\n\n'+error.getStackTraceString();
 		errorLog.Error_Type__c = error.getTypeName();
 		errorLog.Component_Name__c = className;
        insert errorLog;
        String stackTrace1 = error.getStackTraceString().substringBefore('\n');
		String className1 = stackTrace1.substringAfter('.').substringBefore('.');	
		String methodName = stackTrace1.substringBefore(':').substringAfter(className1).substringAfter('.');
	}
}