/*
 * Created by Johnny in Prodigy on 01-08-2023.
 *
 * Description: Controller class for the proPromisedPayment LWC.
 *
 * Last modified by Johnny in Prodigy on 22-08-2023.
*/
public class Pro_PromisedPayment_con {
    
    /*
    * Description: Method used to seed component with Data.
    *
    * Last modified by Johnny in Prodigy on 09-08-2023.
    */
    @AuraEnabled
    public static string SeedData(String recordId){
        
        String jsonResult = '';

        Pro_PromisedPayment_con.DataWrapper dataWrapper = new Pro_PromisedPayment_con.DataWrapper();

        Boolean accessResult = GetAccess();
        List<AcctSeed__Billing__c> billingResult = new List<AcctSeed__Billing__c>();
        billingResult = GetBillings(recordId);

        dataWrapper.hasAccess = accessResult;
        dataWrapper.billingList = billingResult;

        jsonResult = JSON.serialize(dataWrapper);

        return jsonResult;
    }

    /*
    * Description: Method used to save the Promised Payment data to the selected Billings.
    *
    * Last modified by Johnny in Prodigy on 22-08-2023.
    */
    @AuraEnabled
    public static String SaveBillings(String incomingRecords){
        
        Boolean resultBool = false;

        System.debug(incomingRecords);

        List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>();

        try {
            
            billingList = (List<AcctSeed__Billing__c>) JSON.deserialize(incomingRecords, List<AcctSeed__Billing__c>.class);

            if (billingList.size() > 0) {
                
                resultBool = UpdateBillings(billingList);
            }
        } catch (Exception ex) {
            
            insert new pro_Error_Log__c(
                pro_Error_Message__c = ex.getMessage(),
                pro_Error_Trace__c = ex.getStackTraceString()
            );
        }

        return JSON.serialize(resultBool);
    }

    /*
    * Description: Method used to Update the Billings with the Promised Payment data.
    *
    * Last modified by Johnny in Prodigy on 02-08-2023.
    */
    @testvisible
    static Boolean UpdateBillings(List<AcctSeed__Billing__c> incomingRecords) {

        Boolean result = false;

        Savepoint savePoint = Database.setSavepoint();
        
        Pro_Utilities.ResultWrap updateResult = Pro_Utilities.UpdateRecords(incomingRecords, savePoint);

        result = updateResult.Result;
        
        return result;
    }

    /*
    * Description: Method used to Verify if the User has the correct access or permissions to make changes to the Billings.
    *
    * Last modified by Johnny in Prodigy on 01-08-2023.
    */
    @testvisible
    static Boolean GetAccess() {

        Boolean resultBool = false;
        
        String objectApiName = 'PermissionSetAssignment',
            extraFields = 'PermissionSet.Name',
            searchFields = 'AssigneeId';

        List<String> fieldNames = Pro_Utilities.GetObjectFields(objectApiName);

        List<PermissionSetAssignment> assignmentList = Pro_Utilities.GetRecords(objectApiName, new List<String>{ UserInfo.getUserId() }, searchFields, extraFields);

        for (PermissionSetAssignment currentAssignment : assignmentList) {
            
            if ((currentAssignment.PermissionSet.Name.contains('AS') || currentAssignment.PermissionSet.Name.contains('Accounting')) && (!currentAssignment.PermissionSet.Name.contains('AS Apex Classes'))) {
                
                resultBool = true;
            }
        }

        if (resultBool == false) {
            
            Profile userProfile = [
                SELECT
                    Id,
                    Name
                FROM
                    Profile
                WHERE   
                    Id =: UserInfo.getProfileId()
            ];

            String profileName = userProfile.Name;

            if (profileName == 'System Administrator') {
                
                resultBool = true;
            }
        }
        
        return resultBool;
    }

    /*
    * Description: Method used to retrieve all of the outstanding Billings for the given Account.
    *
    * Last modified by Johnny in Prodigy on 16-08-2023.
    */
    @testvisible
    static List<AcctSeed__Billing__c> GetBillings(String recordId) {

        List<AcctSeed__Billing__c> resultList = [
            SELECT
                Id,
                Name,
                AcctSeed__Balance__c,
                AcctSeed__Date__c,
                pro_PP_Amount__c,
                pro_PP_Comment__c,
                pro_PP_Date__c,
                AcctSeed__PO_Number__c
            FROM
                AcctSeed__Billing__c
            WHERE
                (AcctSeed__Customer__c =: recordId)
            AND
                (AcctSeed__Balance__c > 0)
        ];
        
        return resultList;
    }

    /*
    * Description: Wrapper class used to encapsulate data being sent between controller class and lightning web component.
    *
    * Last modified by Johnny in Prodigy on 01-08-2023.
    */
    @testvisible
    class DataWrapper {

        public Boolean hasAccess { get; set; }
        public List<AcctSeed__Billing__c> billingList { get; set; }
    }
}