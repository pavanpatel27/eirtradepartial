/*
 * Created by Prodigy Ltd on 19/10/2023.
 *
 * Description: Test class for Pro_CancelRemoteWorkRequest_con.
 *
 * Last modified by Finbar in Prodigy on 23/10/2023.
*/
@isTest
public class Pro_CancelRemoteWorkRequest_tst {
    
    /*
    * Description: Sets up test data for the class.
    *
    * Last modified by Finbar in Prodigy on 23/10/2023.
    */
    @TestSetup
    static void MakeData() {

        Pro_DataFactory_dat.CreateResource();

        Pro_DataFactory_dat.CreateRemoteWorkRequest();
    }

    /*
    * Description: Tests CancelRemoteWorkRequest.
    *
    * Last modified by Finbar in Prodigy on 19/10/2023.
    */
    @isTest
    static void testCancelRemoteWorkRequest(){
        Id recordid = [
            SELECT
                Id
            FROM
                Remote_Work_Request__c
            LIMIT 1
        ].Id;

        Test.startTest();
        
        Pro_CancelRemoteWorkRequest_con.CancelRemoteWorkRequest(recordId);
        
        Test.stopTest();
        
    }
}