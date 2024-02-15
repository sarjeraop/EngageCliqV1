/**  @classname     : ReportUtility.
  *  @author        : Ganesh Bhakare.
  *  @date          :
  *  @description   : This class is used to support the functionality of folder selection and
                      and analyse the reports selected by user corresponding to particular folder

  *  @modificationlog
  *  1. Ganesh Bhakare      04-Oct-2023     Add Code Comments.    
*/
public with sharing class ReportUtility {
   
/**  @methodname            : getReportFolders.
  *  @author                : Ganesh Bhakare.
  *  @objectreferenced      : Folder.
  *  @param                 : None.
  *  @description           : This method is used to get all the folders accesible to logged in user.
  *  @return                : list.
*/
    @AuraEnabled(cacheable=true)
    public static list<Folder> getReportFolders(){
        try {
            list<Folder> reportFolders=[SELECT Id,Name,DeveloperName FROM Folder where type='report' and DeveloperName!='' WITH USER_MODE];
            return reportFolders;
        }
        catch(Exception e){
        }  
        return null;
    }
   
/**  @methodname            : getReports.
  *  @author                : Ganesh Bhakare.
  *  @objectreferenced      : Folder.
  *  @param                 : None.
  *  @description           : This method is used to get reports in selected folder.
  *  @return                : list.
*/
    @AuraEnabled(cacheable=true)
    public static list<report> getReports(string fldrName){
        try {
            list<report> reports=[select Id,Name from Report where folderName =:fldrName WITH USER_MODE];
            return reports;
        }
        catch(Exception e){
        }  
        return null;
    }
   
/**  @methodname            : getReportDetails.
  *  @author                : Ganesh Bhakare.
  *  @objectreferenced      : Folder.
  *  @param                 : Id of the report selected by user.
  *  @description           : This method used  to collect all recordIds corresponding to primary object in selected report.
  *  @return                : list.
*/
    @AuraEnabled(cacheable=true)
    public static list<Id> getReportDetails(string reportId){
        try{
            Set<Id> selectedIds = new Set<Id>();
            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
            Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
            List<Reports.ReportDetailRow> listOfDetailRow = factDetails.getRows();
            for(Reports.ReportDetailRow detailRow : listOfDetailRow){
                String recordId;                        
                for(Reports.ReportDataCell dataCell : detailRow.getDataCells()){                            
                    if(recordId == null){
                        recordId = (String)dataCell.getValue();
                    }                                                    
                }                        
                if(recordId != null){                            
                    selectedIds.add(recordId);
                }
            }
             List<Id> uniqueIds=new List<Id>(selectedIds);

            return uniqueIds;
        }catch(Exception e){
        }
        return null;
    }
   
/**  @methodname            : getReportBaseObject.
  *  @author                : Ganesh Bhakare.
  *  @objectreferenced      : Folder.
  *  @param                 : Id of record in report.
  *  @description           : This method is used to get primary object in selected report.
  *  @return                : list.
*/
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getReportBaseObject(Id recorId){
        try{
            Map<String,String> objNameVsLabelMap =new Map<String,String>();
            String sObjName = recorId.getSObjectType().getDescribe().getName();
            String  sObjLabel = recorId.getSObjectType().getDescribe().getLabel();
            objNameVsLabelMap.put(sObjName,sObjLabel);
            return objNameVsLabelMap;
        }catch(Exception e){
        }
        return null;
    }
}