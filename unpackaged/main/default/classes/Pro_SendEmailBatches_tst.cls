/*
 * Created by Johnny in Prodigy on 23-06-2023.
 *
 * Description: Test class for the Pro_SendEmailBatches batch class.
 *
 * Last modified by Johnny in Prodigy on 23-06-2023.
*/
@isTest
class Pro_SendEmailBatches_tst {
    
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
    * Description: Tests the Pro_SendEmailBatches_btc constructor with a Cash Disbursement.
    *
    * Last modified by Johnny in Prodigy on 23-06-2023.
    */
    @isTest
    static void testPro_SendEmailBatches_btcWithRecordName() {

        Test.startTest();
        
        Database.executeBatch(new Pro_SendEmailBatches_btc('Cash Disbursement'));
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the Pro_SendEmailBatches_btc constructor with a Cash Disbursement and a ID.
    *
    * Last modified by Johnny in Prodigy on 23-06-2023.
    */
    @isTest
    static void testPro_SendEmailBatches_btcWithRecordNameAndId() {

        AcctSeed__Cash_Disbursement__c testRecord = [
            SELECT
                Id
            FROM
                AcctSeed__Cash_Disbursement__c
            LIMIT
                1
        ];

        Test.startTest();
        
        Database.executeBatch(new Pro_SendEmailBatches_btc(testRecord.Id, 'Cash Disbursement'));
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the Pro_SendEmailBatches_btc constructor with a Cash Disbursement and multiple Ids.
    *
    * Last modified by Johnny in Prodigy on 23-06-2023.
    */
    @isTest
    static void testPro_SendEmailBatches_btcWithRecordNameAndIds() {

        List<AcctSeed__Cash_Disbursement__c> testRecords = [
            SELECT
                Id
            FROM
                AcctSeed__Cash_Disbursement__c
        ];

        List<String> testIds = new List<String>();

        for (AcctSeed__Cash_Disbursement__c currentDisbursement : testRecords) {
            
            testIds.add(currentDisbursement.Id);
        }

        Test.startTest();
        
        Database.executeBatch(new Pro_SendEmailBatches_btc(testIds, 'Cash Disbursement'));
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }
}