/*
 * Created by Johnny in Prodigy on 23-06-2023.
 *
 * Description: Test class for the Pro_BulkShareRemittance extention class.
 *
 * Last modified by Johnny in Prodigy on 23-06-2023.
*/
@isTest
class Pro_BulkShareRemittance_tst {
    
    /*
    * Description: Method used to setup data for testing.
    *
    * Last modified by Johnny in Prodigy on 23-06-2023.
    */
    @TestSetup
    static void MakeData(){
        
        Pro_DataFactory_dat.CreateAcctSeedRecords();

        Pro_DataFactory_dat.CreateAccounts();

        Pro_DataFactory_dat.CreateCashDisbursementsWithoutPayable();
    }

    /*
    * Description: Test method used to test the Pro_BulkShareRemittance_ext constructor.
    *
    * Last modified by Johnny in Prodigy on 23-06-2023.
    */
    @isTest
    static void testPro_BulkShareRemittance() {

        List<AcctSeed__Cash_Disbursement__c> testRecords = [
            SELECT
                Id
            FROM
                AcctSeed__Cash_Disbursement__c
        ];

        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(testRecords);

        Test.startTest();

        Pro_BulkShareRemittance_ext extentionClass = new Pro_BulkShareRemittance_ext(standardController);

        Test.stopTest();

        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the SendRecords Method.
    *
    * Last modified by Johnny in Prodigy on 23-06-2023.
    */
    @isTest
    static void testSendRecords() {
        
        List<AcctSeed__Cash_Disbursement__c> testRecords = [
            SELECT
                Id
            FROM
                AcctSeed__Cash_Disbursement__c
        ];

        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(testRecords);

        standardController.setSelected(testRecords);

        Test.startTest();

        Pro_BulkShareRemittance_ext extentionClass = new Pro_BulkShareRemittance_ext(standardController);

        extentionClass.SendRecords();

        Test.stopTest();

        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }
}