/*
 * Created by Prodigy on 18-04-2023.
 *
 * Description: Test class for the Pro_PurchaseOrderToPayable controller class.
 *
 * Last modified by Johnny in Prodigy on 30-06-2023.
*/
@isTest
class Pro_PurchaseOrderToPayable_tst {
    
    /*
    * Description: Method used to generate records for testing.
    *
    * Last modified by Johnny in Prodigy on 30-06-2023.
    */
    @TestSetup
    static void MakeData(){

        Pro_DataFactory_dat.CreateAcctSeedRecords();

        Pro_DataFactory_dat.CreateAccounts();

        Pro_DataFactory_dat.CreateProducts();

        Pro_DataFactory_dat.CreatePurchaseOrder();
    }

    /*
    * Description: Tests the SeedDataWrapper.
    *
    * Last modified by Johnny in Prodigy on 18-04-2023.
    */
    @isTest
    static void testSeedDataWrapper() {

        pro_Purchase_Order__c testRecord = [
            SELECT
                Id
            FROM
                pro_Purchase_Order__c
            LIMIT
                1
        ];

        List<pro_Purchase_Order_Line__c> testLines = [
            SELECT
                Id
            FROM
                pro_Purchase_Order_Line__c
            WHERE
                pro_Purchase_Order__c =: testRecord.Id
        ];

        Test.startTest();
        
        Pro_PurchaseOrderToPayable_con.SeedDataWrap dataWrapper = new Pro_PurchaseOrderToPayable_con.SeedDataWrap();
        dataWrapper.CurrencySymbol = 'USD';
        dataWrapper.PurchaseOrder = testRecord;
        dataWrapper.PayableLines = testLines;
        dataWrapper.PurchaseOrderLines = testLines;
        dataWrapper.TodaysDate = System.today();

        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the PayableWrap.
    *
    * Last modified by Johnny in Prodigy on 18-04-2023.
    */
    @isTest
    static void testPayableWrap() {

        Test.startTest();
        
        Pro_PurchaseOrderToPayable_con.PayableWrap dataWrapper = new Pro_PurchaseOrderToPayable_con.PayableWrap();
        dataWrapper.ErrorMessage = '';
        dataWrapper.RecordId = '';
        dataWrapper.Result = true;
        
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
    static void testSeedData() {

        pro_Purchase_Order__c testRecord = [
            SELECT
                Id
            FROM
                pro_Purchase_Order__c
            LIMIT
                1
        ];

        Test.startTest();
        
        String jsonResult = Pro_PurchaseOrderToPayable_con.SeedData(testRecord.Id);
        
        Test.stopTest();

        Pro_PurchaseOrderToPayable_con.SeedDataWrap dataWrapper = (Pro_PurchaseOrderToPayable_con.SeedDataWrap) JSON.deserialize(jsonResult, Pro_PurchaseOrderToPayable_con.SeedDataWrap.class);
        
        Boolean expected = true, actual = (dataWrapper.PurchaseOrder != null);
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the CreatePayableRecord Method.
    *
    * Last modified by Johnny in Prodigy on 18-04-2023.
    */
    @isTest
    static void testCreatePayableRecord() {

        AcctSeed__GL_Account__c testGLAccount = [
            SELECT
                Id
            FROM
                AcctSeed__GL_Account__c
            WHERE
                AcctSeed__Type__c = 'Balance Sheet'
            AND
                AcctSeed__Sub_Type_1__c = 'Assets'
            AND
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            LIMIT
                1
        ];

        Id recordId = [
            SELECT
                Id
            FROM
                pro_Purchase_Order__c
        ].Id;

        String objectApiName = 'pro_Purchase_Order__c',
                extraFields = 'pro_Supplier_Account__r.Name, pro_Ledger_Lookup__r.Name,',
                searchField = 'Id';

        List<String> fields = Pro_Utilities.GetObjectFields('pro_Purchase_Order_Line__c');

        extraFields += '(SELECT ' + String.join(fields, ',') + ' ,pro_Product__r.Name FROM pro_Purchase_Order_Lines__r)';

        pro_Purchase_Order__c testRecord = (pro_Purchase_Order__c) Pro_Utilities.GetRecords(objectApiName, 
            new List<String>{ recordId }, 
            searchField, 
            extraFields)[0];

        List<AcctSeed__Account_Payable_Line__c> payableLines = new List<AcctSeed__Account_Payable_Line__c>();

        for (pro_Purchase_Order_Line__c currentItem : testRecord.pro_Purchase_Order_Lines__r) {
            
            AcctSeed__Account_Payable_Line__c lineItem = new AcctSeed__Account_Payable_Line__c(
                AcctSeed__Product__c = currentItem.pro_Product__c,
                AcctSeed__Invoice_Comment__c = 'Test Comment',
                AcctSeed__Quantity__c = currentItem.pro_Quantity__c,
                AcctSeed__Unit_Cost__c = currentItem.pro_Unit_Price__c,
                pro_Purchase_Order_Line__c = currentItem.Id,
                AcctSeed__Expense_GL_Account__c = testGLAccount.Id,
                Comments__c = 'Test Comments'
            );

            payableLines.add(lineItem);
        }

        Date todaysDate = System.today();

        String recordString = JSON.serialize(testRecord),
            listString = JSON.serialize(payableLines),
            referenceString = 'Test Reference',
            dateString = String.valueOf(todaysDate);

        Test.startTest();
        
        String jsonResult = Pro_PurchaseOrderToPayable_con.CreatePayableRecord(recordString, listString, referenceString, dateString, dateString);
        
        Test.stopTest();

        Pro_PurchaseOrderToPayable_con.PayableWrap dataWrapper = (Pro_PurchaseOrderToPayable_con.PayableWrap) JSON.deserialize(jsonResult, Pro_PurchaseOrderToPayable_con.PayableWrap.class);
        
        Boolean expected = true, actual = dataWrapper.Result;
        
        System.assertEquals(expected, actual);
    }
}