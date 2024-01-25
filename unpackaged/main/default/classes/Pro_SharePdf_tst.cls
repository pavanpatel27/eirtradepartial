/*
 * Created by Prodigy on 13-04-2023.
 *
 * Description: Test class for the Pro_SharePdf controller class.
 *
 * Last modified by Johnny in Prodigy on 30-06-2023.
*/
@isTest
class Pro_SharePdf_tst {
    
    /*
    * Description: Setup of data used in testing.
    *
    * Last modified by Johnny in Prodigy on 30-06-2023.
    */
    @TestSetup
    static void MakeData(){
        
        Pro_DataFactory_dat.CreateAcctSeedRecords();

        Pro_DataFactory_dat.CreateAccounts();

        Pro_DataFactory_dat.CreateProducts();

        Pro_DataFactory_dat.CreatePurchaseOrder();

        Pro_DataFactory_dat.CreateCashDisbursementsWithoutPayable();
    }

    /*
    * Description: Tests the SeedWrap.
    *
    * Last modified by Johnny in Prodigy on 14-04-2023.
    */
    @isTest
    static void testSeedWrap() {

        pro_Purchase_Order__c testOrder = [
            SELECT
                Id
            FROM
                pro_Purchase_Order__c
            LIMIT
                1
        ];

        Test.startTest();
        
        Pro_SharePdf_con.SeedWrap dataWrapper = new Pro_SharePdf_con.SeedWrap();
        dataWrapper.emailBody = 'Test';
        dataWrapper.emailSubject = 'Test';
        dataWrapper.listOfEmails = 'Test@email.com';
        dataWrapper.orgUrl = System.Url.getSalesforceBaseUrl().toExternalForm();
        dataWrapper.userCanSharePdf = true;
        dataWrapper.visualforcePage = 'Test';
        dataWrapper.record = testOrder;
        dataWrapper.recordType = 'Purchase Order';
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the SeedData Method.
    *
    * Last modified by Johnny in Prodigy on 18-04-2023.
    */
    @isTest
    static void testSeedDataPurchaseOrder() {

        pro_Purchase_Order__c testRecord = [
            SELECT
                Id
            FROM
                pro_Purchase_Order__c
            LIMIT
                1
        ];

        Test.startTest();
        
        String jsonResult = Pro_SharePdf_con.SeedData(testRecord.Id);
        
        Test.stopTest();


        Pro_SharePdf_con.SeedWrap dataWrapper = (Pro_SharePdf_con.SeedWrap)JSON.deserialize(
            jsonResult,
            Pro_SharePdf_con.SeedWrap.class
        );
        
        Boolean expected = true, actual = (dataWrapper != null);
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the SharePDF Method with a Purchase Order.
    *
    * Last modified by Johnny in Prodigy on 17-04-2023.
    */
    @isTest
    static void testSharePDFPurchaseOrder() {

        String recipientEmailAddress = 'test@email.com',
            senderEmailAddress = 'test@email.com',
            ccEmailAddresses = 'test@email.com',
            emailSubject = 'Test Subject',
            emailBody = 'Test Body',
            recordId = '';

        pro_Purchase_Order__c testRecord = [
            SELECT
                Id
            FROM
                pro_Purchase_Order__c
            LIMIT
                1
        ];

        recordId = testRecord.Id;

        Test.startTest();
        
        Pro_SharePdf_con.SharePDF(recipientEmailAddress, senderEmailAddress, ccEmailAddresses, emailSubject, emailBody, recordId);
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the SavePDF Method with a Purchase Order.
    *
    * Last modified by Johnny in Prodigy on 17-04-2023.
    */
    @isTest
    static void testSavePDFPurchaseOrder() {

        pro_Purchase_Order__c testRecord = [
            SELECT
                Id
            FROM
                pro_Purchase_Order__c
            LIMIT
                1
        ];

        Test.startTest();
        
        String jsonResult = Pro_SharePdf_con.SavePDF(testRecord.Id);
        
        Test.stopTest();

        Pro_Utilities.ResultWrap dataWrapper = (Pro_Utilities.ResultWrap) JSON.deserialize(jsonResult, Pro_Utilities.ResultWrap.class);
        
        Boolean expected = true, actual = dataWrapper.Result;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the SeedData Method with a Cash Disbursement.
    *
    * Last modified by Johnny in Prodigy on 18-04-2023.
    */
    @isTest
    static void testSeedDataRemittance() {

        AcctSeed__Cash_Disbursement__c testRecord = [
            SELECT
                Id
            FROM
                AcctSeed__Cash_Disbursement__c
            LIMIT
                1
        ];

        Test.startTest();
        
        String jsonResult = Pro_SharePdf_con.SeedData(testRecord.Id);
        
        Test.stopTest();


        Pro_SharePdf_con.SeedWrap dataWrapper = (Pro_SharePdf_con.SeedWrap)JSON.deserialize(
            jsonResult,
            Pro_SharePdf_con.SeedWrap.class
        );
        
        Boolean expected = true, actual = (dataWrapper != null);
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the SharePDF Method with a Cash Disbursement.
    *
    * Last modified by Johnny in Prodigy on 18-04-2023.
    */
    @isTest
    static void testSharePDFRemittance() {

        String recipientEmailAddress = 'test@email.com',
        senderEmailAddress = 'test@email.com',
        ccEmailAddresses = 'test@email.com',
        emailSubject = 'Test Subject',
        emailBody = 'Test Body',
        recordId = '';

        AcctSeed__Cash_Disbursement__c testRecord = [
            SELECT
                Id
            FROM
                AcctSeed__Cash_Disbursement__c
            LIMIT
                1
        ];

        recordId = testRecord.Id;

        Test.startTest();
        
        Pro_SharePdf_con.SharePDF(recipientEmailAddress, senderEmailAddress, ccEmailAddresses, emailSubject, emailBody, recordId);
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the SavePDF Method with a Cash Disbursement.
    *
    * Last modified by Johnny in Prodigy on 18-04-2023.
    */
    @isTest
    static void testSavePDFRemittance() {

        AcctSeed__Cash_Disbursement__c testRecord = [
            SELECT
                Id
            FROM
                AcctSeed__Cash_Disbursement__c
            LIMIT
                1
        ];

        Test.startTest();
        
        String jsonResult = Pro_SharePdf_con.SavePDF(testRecord.Id);
        
        Test.stopTest();

        Pro_Utilities.ResultWrap dataWrapper = (Pro_Utilities.ResultWrap) JSON.deserialize(jsonResult, Pro_Utilities.ResultWrap.class);
        
        Boolean expected = true, actual = dataWrapper.Result;
        
        System.assertEquals(expected, actual);
    }
}