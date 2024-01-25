/*
 * Created by Johnny in Prodigy on 22-08-2023.
 *
 * Description: Test class for the Pro_PromisedPyment controller class.
 *
 * Last modified by Johnny in Prodigy on 22-08-2023.
*/
@isTest
public class Pro_PromisedPayment_tst {
    
    /*
    * Description: Method used to setup data for testing.
    *
    * Last modified by Johnny in Prodigy on 22-08-2023.
    */
    @TestSetup
    static void MakeData(){
        
        Pro_DataFactory_dat.CreateAcctSeedRecords();
        Pro_DataFactory_dat.CreateAccounts();
        Pro_DataFactory_dat.CreateBillings();
    }

    /*
    * Description: Tests the SeedData Method.
    *
    * Last modified by Johnny in Prodigy on 22-08-2023.
    */
    @isTest
    static void testSeedData() {

        Account testAccount = [
            SELECT
                Id
            FROM
                Account
            LIMIT
                1
        ];

        Test.startTest();
        
        String jsonResult = Pro_PromisedPayment_con.SeedData(testAccount.Id);
        
        Test.stopTest();
        
        Boolean expected = false, actual = String.isBlank(jsonResult);
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the <<Method Name>> Method.
    *
    * Last modified by Johnny in Prodigy on 22-08-2023.
    */
    @isTest
    static void testSaveBillings() {

        Account testAccount = [
            SELECT
                Id
            FROM
                Account
            LIMIT
                1
        ];

        List<AcctSeed__Billing__c> billingList = [
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
                AcctSeed__Customer__c =: testAccount.Id
            AND
                AcctSeed__Balance__c > 0
        ];

        for (AcctSeed__Billing__c currentBilling : billingList) {
            
            currentBilling.pro_PP_Amount__c = 500;
            currentBilling.pro_PP_Comment__c = 'Test';
            currentBilling.pro_PP_Date__c = Date.today();
        }

        Test.startTest();
        
        String jsonResult = Pro_PromisedPayment_con.SaveBillings(JSON.serialize(billingList));
        
        Test.stopTest();
        
        String expected = 'true', actual = jsonResult;
        
        System.assertEquals(expected, actual);
    }
}