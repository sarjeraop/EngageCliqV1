/**  @classname     : MergeUtility
  *  @author        : Abhishek
  *  @date : 
  *  @description   : This class represents the apex class utility for merging strings containing merge fields and replacing with values.  
  *  @modificationlog
  *  		Version#		Date(DD/MM/YYYY)		Description		Modified By
  *	1.   1.0                                          created     Abhishek
  * 2.                      20/10/2023                Added bulkification logic for replaceMergeFieldsWithValues     Suhas
  */
 public with sharing class MergeUtility {

    private static String startPattern = Constants.STARTPATTERN;
    private static String endPattern = Constants.ENDPATTERN;
    private static Boolean createParameterMap = false;
   // private static Map<String,String> mapParameters = new Map<String,String>();
    private static Map<String,Map<String,String>> mapIdvsParameters = new Map<String,Map<String,String>>();
    /** @methodname          : replaceMergeFieldsWithValues
      * @author              : Abhishek
      * @objectreferenced    : None 
      * @param               : String, String, String, String, List<String>
      * @description         : This method  is used to prepare map of recordId and merged message
      * @return              : Map<String,String>
      */
        public static Map<String,String> replaceMergeFieldsWithValues (String startPattern, String endPattern, String stringToMerge, String objectName, List<String> lstRecordIds) {
                
            // Query for the SObject and all related fields
            List<SObject> listRecords = getRecord (startPattern, endPattern, stringToMerge, objectName, lstRecordIds);
            
            return replaceMergeFieldsWithValues(startPattern, endPattern, stringToMerge, listRecords);
        }

    /** @methodname          : replaceMergeFieldsWithValues
      * @author              : Suhas
      * @objectreferenced    :   
      * @param               : String, String, List<String>
      * @description         : This method  is used to prepare map of recordId and merged message
      * @return              : Map<String,String>
      */ 
     public static Map<String,String> replaceMergeFieldsWithValues (String stringToMerge, String objectName, List<String> lstRecordIds) {
                
        // Query for the SObject and all related fields
        List<SObject> listRecords = getRecord (stringToMerge, objectName, lstRecordIds);
        
        return replaceMergeFieldsWithValues(stringToMerge, listRecords);
    }

    /** @methodname          : replaceMergeFieldsWithValues
      * @author              : Suhas
      * @objectreferenced    :   
      * @param               : String, String, List<String>
      * @description         : This method  is used to prepare map of recordId and merged message
      * @return              : Map<String,String>
      */ 
      public static Map<String,Object> replaceMergeFieldsWithValues (String stringToMerge, String objectName, List<String> lstRecordIds,Boolean isParameterisedBI) {
        //mapParameters = mapComponentParameters;
        createParameterMap = isParameterisedBI;
        Map<String,Object> mapData = new Map<String,Object>();
        // Query for the SObject and all related fields
        List<SObject> listRecords = getRecord (stringToMerge, objectName, lstRecordIds);
        mapData.put('mapIdVsMergedMessage',replaceMergeFieldsWithValues(stringToMerge, listRecords));
        mapData.put('mapIdvsParameters',mapIdvsParameters);
        return mapData;
    }
      
    /** @methodname          : getRecord
      * @author              : Abhishek
      * @objectreferenced    : Matcher  
      * @param               : String, String, String, String, List<String>
      * @description         : This method  is used prepare list of record based on recordId
      * @return              : List<SObject>
      */     
        public static List<SObject> getRecord (String startPattern, String endPattern, String stringToMerge, String objectName, List<String> lstRecordIds) {
    
            Set<String> fieldsForQuery = new Set<String>();
            
            // The matcher which returns the matched fields from the given string
            Matcher theMatcher = thePattern(startPattern, endPattern).matcher(stringToMerge); 
            // Loop through each match
            while (theMatcher.find()) {
                
                // Get the merge field from the match
                String mergeField = theMatcher.group(1).trim();            
                fieldsForQuery.add(mergeField);
                
            }
            String idList =  String.join(new List<String>(lstRecordIds), '\',\'');
            // Build the query. The set of fields needs to be converted to a list to use String.join()
            String theQuery = 'SELECT ' + String.join(fieldsForQuery, ',');
            theQuery += ' FROM ' + objectName;
            theQuery += ' WHERE Id IN (\''+ idList +'\')';
            
            // Execute the query and record the record
            return Database.query(theQuery);
        }

    /** @methodname          : getRecord
      * @author              : Suhas
      * @objectreferenced    : Matcher  
      * @param               : String, String, List<String>
      * @description         : This method  is used prepare list of record based on recordId
      * @return              : List<SObject>
      */     
     public static List<SObject> getRecord (String stringToMerge, String objectName, List<String> lstRecordIds) {
    
        Set<String> fieldsForQuery = new Set<String>();
        
        // The matcher which returns the matched fields from the given string
        Matcher theMatcher = thePattern().matcher(stringToMerge); 
        // Loop through each match
        while (theMatcher.find()) {
            
            // Get the merge field from the match
            String mergeField = theMatcher.group(1).trim();            
            fieldsForQuery.add(mergeField);
            
        }
        String idList =  String.join(new List<String>(lstRecordIds), '\',\'');
        // Build the query. The set of fields needs to be converted to a list to use String.join()
        String theQuery = 'SELECT ' + String.join(fieldsForQuery, ',');
        theQuery += ' FROM ' + objectName;
        theQuery += ' WHERE Id IN (\''+ idList +'\')';
        
        // Execute the query and record the record
        return Database.query(theQuery);
    }
    
    /** @methodname          : replaceMergeFieldsWithValues
      * @author              : Abhishek
      * @objectreferenced    : None
      * @param               : String, String, String, String, List<SObject>
      * @description         : This method  is used to prepare map of recordId and merged message
      * @return              : Map<String,String>
      */
        public static Map<String,String> replaceMergeFieldsWithValues (String startPattern, String endPattern, String stringToMerge, List<SObject> listRecords) {
            
            Map<String,String> mapIdVsMergedMessage = new  Map<String,String>();
            // If blank, return a blank value
            if (String.isBlank(stringToMerge)) {
                
                return mapIdVsMergedMessage;
            }
            
            // The matcher which returns the matched fields from the given string
            Matcher theMatcher = thePattern(startPattern, endPattern).matcher(stringToMerge);
            
            // Iterate over each match
            while (theMatcher.find()) {
                
                // Get the field name based on the match
                String mergeField = theMatcher.group(1).trim();        
                
                // Support getting parent fields for the object
                // Need to determine if there is a relationship in the field. This decides how many levels to go
                List<String> objectsAndField = mergeField.split('\\.');
                
                // The record to get the data from
                for (Sobject theRecordForData : listRecords) {
                    
    
                // If there is a relationship
                if (objectsAndField.size() > 1) {
                    
                    // Run through the list but skip the last item (the field)
                    for (Integer i = 0; i < objectsAndField.size() - 1; i++) {
                        
                        // Only run if not null
                        // Will be null if the lookup field is blank
                        if (theRecordForData != null) {
                            
                            // Get the new record to draw data from
                            theRecordForData = theRecordForData.getSObject(objectsAndField[i]);
                            
                        }
                    }
                    
                    // Since we should have the correct record now we can replace the list with only it's last item (the field)
                    objectsAndField = new List<String>{objectsAndField[objectsAndField.size()-1]};
                                
                }
                
                // Default merge value to blank string
                String mergeValue = '';
                
                // Process if the source record isn't null
                if (theRecordForData != null) {
                    
                    // Attempt to replace the merge value. If it fails, it will return a blank value
                    try {
                        
                        mergeValue = String.valueOf(theRecordForData.get(objectsAndField[0]));
                            
                    }
                    catch (Exception ex) {
                        
                        ApplicationLogger.logException(ex);
                    }
                }
                
                // Set any null values to an empty string
                mergeValue = mergeValue == null ? '' : mergeValue;
                
                // Replace the matching field name with the value
                
                stringToMerge = stringToMerge.replace(startPattern + mergeField + endPattern, mergeValue);
                mapIdVsMergedMessage.put(String.valueOf(theRecordForData.get('Id')),stringToMerge);
                }
            }
            
            // Return the Map of Id vs merge fields replaced with their values, yay!
    
            return mapIdVsMergedMessage;
        }

    /** @methodname          : replaceMergeFieldsWithValues
      * @author              : Abhishek
      * @objectreferenced    : None
      * @param               : String, String, List<SObject>
      * @description         : This method  is used to prepare map of recordId and merged message
      * @return              : Map<String,String>
      */
     public static Map<String,String> replaceMergeFieldsWithValues (String stringToMerge, List<SObject> listRecords) {
       
       System.debug('stringToMerge :'+stringToMerge);
       String unmergedString = stringToMerge;
        Map<String,String> mapIdVsMergedMessage = new  Map<String,String>();
        // If blank, return a blank value
        if (String.isBlank(stringToMerge)) {
            
            return mapIdVsMergedMessage;
        }
        
        // The matcher which returns the matched fields from the given string
        Matcher theMatcher = thePattern().matcher(stringToMerge);
        
        // Iterate over each match
        while (theMatcher.find()) {
            
            // Get the field name based on the match
            String mergeField = theMatcher.group(1).trim();        
            
            // Support getting parent fields for the object
            // Need to determine if there is a relationship in the field. This decides how many levels to go
            List<String> objectsAndField = mergeField.split('\\.');
            String mergerdMessage = '';
            // The record to get the data from
            for (Sobject theRecordForData : listRecords) {
             
				
            // If there is a relationship
            if (objectsAndField.size() > 1) {
                
                // Run through the list but skip the last item (the field)
                for (Integer i = 0; i < objectsAndField.size() - 1; i++) {
                    
                    // Only run if not null
                    // Will be null if the lookup field is blank
                    if (theRecordForData != null) {
                        
                        // Get the new record to draw data from
                        theRecordForData = theRecordForData.getSObject(objectsAndField[i]);
                        
                    }
                }
                
                // Since we should have the correct record now we can replace the list with only it's last item (the field)
                objectsAndField = new List<String>{objectsAndField[objectsAndField.size()-1]};
                            
            }
            
            // Default merge value to blank string
            String mergeValue = '';
            
            // Process if the source record isn't null
            if (theRecordForData != null) {
                
                // Attempt to replace the merge value. If it fails, it will return a blank value
                try {
                    
                    mergeValue = String.valueOf(theRecordForData.get(objectsAndField[0]));
                        
                }
                catch (Exception ex) {
                    
                    ApplicationLogger.logException(ex);
                }
            }
            
            // Set any null values to an empty string
            mergeValue = mergeValue == null ? '' : mergeValue;
            String currentRecordId = (String)theRecordForData.get('Id');
            // check whether to create map of IdVsParameters
            if(createParameterMap)
            {
            Map<String,String> mapParams = new Map<String,String>();
            if(mapIdvsParameters.containsKey(currentRecordId)){
                mapParams = (Map<String,String>) mapIdvsParameters.get(currentRecordId);
                mapParams.put(mergeField,mergeValue);
            }else{
               // Map<String,String> mapParams = new Map<String,String>();
                mapParams.put(mergeField,mergeValue);
            }
            mapIdvsParameters.put(currentRecordId,mapParams);
              //  mapParameters.put(mergeField,mergeValue);
            }
            
            // Replace the matching field name with the value
            // new logic by rati
            if(mapIdVsMergedMessage.containsKey(currentRecordId)){
                stringToMerge = mapIdVsMergedMessage.get(currentRecordId);
            }else{
                stringToMerge = unmergedString;
            }
            /////////////////////////////

            stringToMerge = stringToMerge.replace(startPattern + mergeField + endPattern, mergeValue);
           // if(!mapIdVsMergedMessage.containsKey(currentRecordId)){
                mapIdVsMergedMessage.put(currentRecordId,stringToMerge);
           // }
            System.debug('310 mapIdVsMergedMessage : '+mapIdVsMergedMessage);
            }
        }
        
        // Return the Map of Id vs merge fields replaced with their values, yay!
        return mapIdVsMergedMessage;
    }

    /** @methodname          : thePattern
      * @author              : Abhishek
      * @objectreferenced    : None 
      * @param               : String, String
      * @description         : This method  is build pattern matched fields from the given string
      * @return              : Pattern
      */    
        private static Pattern thePattern(String startPattern, String endPattern) {
            
            if (String.isBlank(startPattern.trim()) || String.isBlank(endPattern.trim())) {
                throw new FieldMergeUtilException('Start and End pattern required!');
            }
            
            // Regex to capture grouping
            String theRegex = '';
            
            // Convert the start pattern to regex
            for (String character : startPattern.split('')) {
                theRegex += character == ' ' ? '' : '\\' + character;
            }
            
            // Add Capturing Group to regex and include first end charcter to close grouping
            theRegex += '([^'+ endPattern.trim().left(1) +'}]*)';
            
            // Convert the end pattern to regex
            for (String character : endPattern.split('')) {
                theRegex += character == ' ' ? '' : '\\' + character;
            }
            
            // Replace all spaces with whitespace capturing
            theRegex = theRegex.replace(' ', '\\s');
            
            return Pattern.compile(theRegex);
        }

    /** @methodname          : thePattern
      * @author              : Abhishek
      * @objectreferenced    : None 
      * @param               : None
      * @description         : This method  is build pattern matched fields from the given string
      * @return              : Pattern
      */    
        private static Pattern thePattern() {
            
            if (String.isBlank(startPattern.trim()) || String.isBlank(endPattern.trim())) {
                throw new FieldMergeUtilException('Start and End pattern required!');
            }
            
            // Regex to capture grouping
            String theRegex = '';
            
            // Convert the start pattern to regex
            for (String character : startPattern.split('')) {
                theRegex += character == ' ' ? '' : '\\' + character;
            }
            
            // Add Capturing Group to regex and include first end charcter to close grouping
            theRegex += '([^'+ endPattern.trim().left(1) +'}]*)';
            
            // Convert the end pattern to regex
            for (String character : endPattern.split('')) {
                theRegex += character == ' ' ? '' : '\\' + character;
            }
            
            // Replace all spaces with whitespace capturing
            theRegex = theRegex.replace(' ', '\\s');
            
            return Pattern.compile(theRegex);
        }
        
        // Custom Exceptions
        public class FieldMergeUtilException extends Exception {}
    }