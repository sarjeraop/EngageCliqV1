/**  
*  @classname           : SendButtonVFPageExtension
*  @author              : Shriram Mahamuni
*  @date                : 1-Nov-2023
*  @description         : 
*  @modificationlog
*  		#		Date		            Description		      Modified By
*/
global with sharing class SendButtonVFPageExtension {
	global List<sObject> getIDs;
  @testvisible
  global String recIds{get;set;} 
  
// constructor
  global SendButtonVFPageExtension(ApexPages.StandardSetController controller){
    getIDs = controller.getSelected();
    recIds = '';  
    for(sObject rec : getIDs){
        recIds += rec.Id + ','; 
    }
    recIds = recIds.removeEnd(',');
  }  
}