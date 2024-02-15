public with sharing class WhatsAppChatController{
/** @methodname         : approvedWhatsAppTemplate
 * @author              : Suhas Mankar
 * @objectreferenced    : WhatsApp_Template__c
 * @param               : Boolean, String
 * @description         : This method is used to find approved whtasApp template based on object name and active checkbox
 * @return              : ApexResultSet
 */
@AuraEnabled (cacheable=true)
public static ApexResultSet approvedWhatsAppTemplate(Boolean active, String objectName){ 
  ApexResultSet apexResult = new ApexResultSet();
  
  try{
    apexResult.data = Utility.approvedWhatsAppTemplate(active, objectName); 
  }
  catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
  }
  return apexResult; 
} 

/**
* @ methodname             : getQuickTextList.
* @ author                 : Sarjerao Pujari. 
* @ objectreferenced       : QuickText.
* @ param                  : None.
* @ description            : This getQuickTextList Method With @AuraEnabled Annotation is used get the all Created QuickTexts.
* @ return                 : ApexResultSet. 
*/
@AuraEnabled(cacheable=true)
public static ApexResultSet getQuickTextList(){
   
ApexResultSet apexResult = new ApexResultSet();
  
  try{
    apexResult.data = Utility.getQuickTextList(); 
  }
  catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
  }
  return apexResult;

} 

/** @methodname         : getFileUrl
 * @author              : Suhas Mankar
 * @objectreferenced    : StaticResourceInfo, ContentDistribution
 * @param               : None
 * @description         : This method is used to get all file with download url
 * @return              : ApexResultSet
 */   
@AuraEnabled(cacheable=true)
public static ApexResultSet getFileUrl(){
  ApexResultSet apexResult = new ApexResultSet();
  List<StaticResourceInfo> resourceInfoList = new List<StaticResourceInfo>();
  try{
    for (ContentDistribution resource : [SELECT ContentDocumentId, ContentVersion.ContentDocument.Title, PreferencesAllowOriginalDownload,PreferencesAllowViewInBrowser,
                                        ContentVersion.ContentDocument.FileType,DistributionPublicUrl,ContentDownloadUrl 
                                        FROM ContentDistribution 
                                        WHERE PreferencesAllowViewInBrowser = true 
                                        AND PreferencesAllowOriginalDownload=true 
                                        WITH  USER_MODE]) {
      resourceInfoList.add(new StaticResourceInfo(resource.ContentDocumentId, resource.ContentVersion.ContentDocument.Title, resource.ContentDownloadUrl, resource.ContentVersion.ContentDocument.FileType));  
      apexResult.data = resourceInfoList;
    }
  }
  catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
  }
  return apexResult;
}

/** @methodname        : createContentDistribution
* @author              : Suhas Mankar
* @objectreferenced    : ContentDistribution, ContentDistribution
* @param               : Id
* @description         : This method is use to create ContentDistribution record
* @return              : ApexResultSet
*/ 
@AuraEnabled
public static ApexResultSet createContentDistribution(Id contentVersionId){
  ApexResultSet apexResult = new ApexResultSet();
  ContentDistribution newDist = new ContentDistribution();
  try{
      newDist.ContentVersionId = contentVersionId;
      newDist.Name = 'External Link';
      newDist.PreferencesNotifyOnVisit = false;
      newDist.PreferencesAllowViewInBrowser = true;
      insert newDist;
      newDist = [Select ContentDocumentId, ContentVersion.ContentDocument.Title, ContentVersion.ContentDocument.FileType,DistributionPublicUrl,ContentDownloadUrl from ContentDistribution WHERE ContentVersionId =: contentVersionId WITH  SECURITY_ENFORCED ];
      apexResult.data = (new StaticResourceInfo(newDist.ContentDocumentId, newDist.ContentVersion.ContentDocument.Title, newDist.ContentDownloadUrl, newDist.ContentVersion.ContentDocument.FileType));
    }
  catch(Exception ex){
          apexResult.isSuccess = false;
          apexResult.message = ex.getMessage();
  }
  return apexResult;
  }

/** @methodname        : StaticResourceInfo
* @author              : Suhas Mankar
* @objectreferenced    : none
* @param               : none
* @description         : This is wrapper class used for Attachment Model
* @return              : none
*/
public class StaticResourceInfo{
  @AuraEnabled
  public String id;
  @AuraEnabled
  public String name;
  @AuraEnabled
  public String url;
  @AuraEnabled
  public String type;

/** @methodname         : StaticResourceInfo
* @author              : Suhas Mankar
* @objectreferenced    : none
* @param               : String
* @description         : This is wrapper class used for Attachment Model
* @return              : none
*/

  public StaticResourceInfo(String id, String name, String url, String type){
    this.id = id;
    this.name = name;
    this.url = url;
    this.type = type;
  }
}
}