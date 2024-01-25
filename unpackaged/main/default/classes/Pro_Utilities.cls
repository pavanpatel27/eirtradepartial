/*
 * Created by Prodigy Ltd on 15-03-2023.
 *
 * Description: Utility class for Inserts, Updates, Deletes & Reads to/from Database.
 *
 * Last modified by Johnny in Prodigy on 15-03-2023.
*/
public with sharing class Pro_Utilities {
    /*
    * Description: Retrieves records from Database.
    *
    * Last modified by Johnny in Prodigy on 15-03-2023.
    */
    public static List<SObject> GetRecords(String objectApiName, List<String> recordIds, String searchField, String extraFields){
        String query = 'SELECT ' + String.join( GetObjectFields(objectApiName), ',' );
        
        if( (extraFields != '') && (extraFields != null) ){ query += ',' + extraFields; }
        
        query += ' FROM ' + objectApiName;
        
        if( (searchField != '') && (searchField != null) ){ query += ' WHERE ' + searchField + ' =: recordIds'; }
        
        return database.query(query);
    }
    
    /*
    * Description: Retrieved list of all fields from sepcified object.
    *
    * Last modified by Johnny in Prodigy on 15-03-2023.
    */
    public static List<String> GetObjectFields(String objectApiName){
        return new List<String>( Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().keySet() );
    }
    
    /*
    * Description: Deletes records from Database.
    *
    * Last modified by Johnny in Prodigy on 15-03-2023.
    */
    public static Pro_Utilities.ResultWrap DeleteRecords(List<SObject> records, Savepoint savePoint){
        Pro_Utilities.ResultWrap result = new Pro_Utilities.ResultWrap();
        result.Result = false;
        
        result.Type = 'error';
        result.ErrorTitle = '';
        result.ErrorMessage = '';
        
        String recordIds = ''; 
        
        for( SObject o : records ){ 
            recordIds += o.Id + ','; 
        }  
        
        recordIds.removeEnd(',');
        
        try {
            delete records;
            
            result.Result = true;

            result.Type = 'success';
        } catch(Exception e){

            if (!Test.isRunningTest()) {
                Database.rollback(savePoint);
            }

            result.ErrorTitle = e.getMessage();
            result.ErrorMessage = e.getStackTraceString();
            
            insert new pro_Error_Log__c(
                pro_Related_Records__c = recordIds,
                pro_Error_Message__c = e.getMessage(),
                pro_Error_Trace__c = e.getStackTraceString()
            );
        }
        
        return result;
    }
    
    /*
    * Description: Updates records in Database.
    *
    * Last modified by Johnny in Prodigy on 15-03-2023.
    */
    public static Pro_Utilities.ResultWrap UpdateRecords(List<SObject> records, Savepoint savePoint){
        Pro_Utilities.ResultWrap result = new Pro_Utilities.ResultWrap();
        result.Result = false;
        
        result.Type = 'error';
        result.ErrorTitle = '';
        result.ErrorMessage = '';
        
        String recordIds = ''; 
        
        for( SObject o : records ){ 
            recordIds += o.Id + ','; 
        }
        
        recordIds.removeEnd(',');
        
        try {
            update records;
            
            result.Result = true;

            result.Type = 'success';
        } catch(Exception e){

            if (!Test.isRunningTest()) {
                Database.rollback(savePoint);
            }

            result.ErrorTitle = e.getMessage();
            result.ErrorMessage = e.getStackTraceString();
            
            insert new pro_Error_Log__c(
                pro_Related_Records__c = recordIds,
                pro_Error_Message__c = e.getMessage(),
                pro_Error_Trace__c = e.getStackTraceString()
            );
        }
        
        return result;
    }
    
    /*
    * Description: Inserts records into Database.
    *
    * Last modified by Johnny in Prodigy on 15-03-2023.
    */
    public static Pro_Utilities.ResultWrap InsertRecords(List<SObject> records, Savepoint savePoint){
        Pro_Utilities.ResultWrap result = new Pro_Utilities.ResultWrap();
        result.Result = false;
        
        result.Type = 'error';
        result.ErrorTitle = '';
        result.ErrorMessage = '';
        
        try {
            insert records;
            
            result.Result = true;

            result.Type = 'success';
        } catch(Exception e){

            if (!Test.isRunningTest()) {
                Database.rollback(savePoint);
            }

            result.ErrorTitle = e.getMessage();
            result.ErrorMessage = e.getStackTraceString();
            
            insert new pro_Error_Log__c(
                pro_Error_Message__c = e.getMessage(),
                pro_Error_Trace__c = e.getStackTraceString()
            );
        }
        
        return result;
    }
    
    /*
    * Description: Wrapper class for returning results after CRUD operations.
    *
    * Last modified by Johnny in Prodigy on 15-03-2023.
    */
    public class ResultWrap {
        public Boolean Result { get; set; }
        
        public String Type { get; set; }
        public String ErrorTitle { get; set; }
        public String ErrorMessage { get; set; }
    }
}