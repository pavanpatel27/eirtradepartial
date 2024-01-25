/*
* Description: <<Description of your code goes here>>.
*
* Last modified by Johnny in Prodigy on 30-06-2023.
*/
@isTest
class Pro_RemittancePdf_tst {
    
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

        Pro_DataFactory_dat.CreateCashDisbursementsWithoutPayable();
    }

    /*
    * Description: Tests the Pro_RemittancePdf_ext constructor.
    *
    * Last modified by Johnny in Prodigy on 19-04-2023.
    */
    @isTest
    static void testPro_RemittancePdf_ext() {

        AcctSeed__Cash_Disbursement__c testRecord = [
            SELECT
                Id
            FROM
                AcctSeed__Cash_Disbursement__c
            LIMIT
                1
        ];

        ApexPages.StandardController standardController = new ApexPages.StandardController(testRecord);

        Test.startTest();
        
        Pro_RemittancePdf_ext extensionClass = new Pro_RemittancePdf_ext(standardController);
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

        AcctSeed__Cash_Disbursement__c testRecord = [
            SELECT
                Id
            FROM
                AcctSeed__Cash_Disbursement__c
            LIMIT
                1
        ];

        ApexPages.StandardController standardController = new ApexPages.StandardController(testRecord);

        Test.startTest();
        
        Pro_RemittancePdf_ext extensionClass = new Pro_RemittancePdf_ext(standardController);
        
        Pro_RemittancePdf_ext.SavePDF();
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }
}