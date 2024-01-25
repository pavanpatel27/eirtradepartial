/*
 * Created by Prodigy Ltd on 19/10/2023.
 *
 * Description: Controller class for c-pro-cancel-remote-work-request.
 *
 * Last modified by Finbar in Prodigy on 26/10/2023.
*/
public without sharing class Pro_CancelRemoteWorkRequest_con {
    /*
    * Description: Checks if record is locked.
    *
    * Last modified by Finbar in Prodigy on 26/10/2023.
    */
    @AuraEnabled
    public static Boolean CancelRemoteWorkRequest( Id recordId ){
        Boolean result = false;

        Remote_Work_Request__c rwr = [
            SELECT 
                Id, 
                pro_Status__c
            FROM 
                Remote_Work_Request__c
            WHERE 
                Id =: recordId
            AND 
                pro_Status__c = 'Approved'
        ];

        if (rwr != null) {

            if (System.Approval.isLocked(rwr.Id)) {
                System.Approval.unlock(rwr.Id);
            }

            rwr.pro_Status__c = 'Cancelled';

            Savepoint savePoint = Database.setSavepoint();
            
            Pro_Utilities.ResultWrap updateResult = Pro_Utilities.UpdateRecords(new List<Remote_Work_Request__c>{ rwr }, savePoint);
                
            result = updateResult.Result;
        
        }

        return result;
    }
}