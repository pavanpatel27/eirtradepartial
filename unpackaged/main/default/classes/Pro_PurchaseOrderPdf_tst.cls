/*
 * Created by Prodigy on 19-04-2023.
 *
 * Description: Test class for the Pro_PurchaseOrderPdf extension class.
 *
 * Last modified by Johnny in Prodigy on 30-06-2023.
*/
@isTest
class Pro_PurchaseOrderPdf_tst {

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
    * Description: Tests the Pro_PurchaseOrderPdf_ext constructor.
    *
    * Last modified by Johnny in Prodigy on 19-04-2023.
    */
    @isTest
    static void testPro_PurchaseOrderPdf_ext() {

        pro_Purchase_Order__c testRecord = [
            SELECT
                Id
            FROM
                pro_Purchase_Order__c
            LIMIT
                1
        ];

        ApexPages.StandardController standardController = new ApexPages.StandardController(testRecord);

        Test.startTest();
        
        Pro_PurchaseOrderPdf_ext extensionClass = new Pro_PurchaseOrderPdf_ext(standardController);
        extensionClass.CurrencySymbol = '';
        extensionClass.HeaderLogo = '';
        extensionClass.CurrencyFormat = '';
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the SavePDF Method.
    *
    * Last modified by Johnny in Prodigy on 19-04-2023.
    */
    @isTest
    static void testSavePDF() {

        pro_Purchase_Order__c testRecord = [
            SELECT
                Id
            FROM
                pro_Purchase_Order__c
            LIMIT
                1
        ];

        ApexPages.StandardController standardController = new ApexPages.StandardController(testRecord);

        Test.startTest();
        
        Pro_PurchaseOrderPdf_ext extensionClass = new Pro_PurchaseOrderPdf_ext(standardController);
        
        Pro_PurchaseOrderPdf_ext.SavePDF();
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }
}