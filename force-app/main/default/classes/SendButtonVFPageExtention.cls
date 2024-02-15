/**  
*  @classname           : SendButtonVFPageExtention
*  @author              : Shriram Mahamuni
*  @date                : 1-Nov-2023
*  @description         : 
*  @modificationlog
*  		#		Date		            Description		      Modified By
*/
public with sharing class SendButtonVFPageExtention {
	public List<sObject> getIDs;
    @testvisible
  public String recIds{get;set;} 
  
// constructor
  public SendButtonVFPageExtention(ApexPages.StandardSetController controller)
  {
    getIDs = controller.getSelected();
    recIds = '';  
    for(sObject rec : getIDs)
    {
        recIds += rec.Id + ','; 
    }
    recIds = recIds.removeEnd(',');       
  }  
}