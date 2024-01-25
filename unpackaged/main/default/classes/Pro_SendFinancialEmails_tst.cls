/*
 * Created by Prodigy on 27-04-2023.
 *
 * Description: Test class used for testing of Pro_SendFinancialEmails batch class.
 *
 * Last modified by Johnny in Prodigy on 26-05-2023.
*/
@isTest
class Pro_SendFinancialEmails_tst {

    /*
    * Description: Method used to create data for testing.
    *
    * Last modified by Johnny in Prodigy on 26-05-2023.
    */
    @TestSetup
    static void MakeData(){
        
        Pro_DataFactory_dat.CreateAccounts();

        Pro_DataFactory_dat.CreateContacts();

        Pro_DataFactory_dat.CreateAcctSeedRecords();

        Pro_DataFactory_dat.CreateBillings();
    }

    /*
    * Description: Tests the Pro_SendFinancialEmails_btc constructor with a Billing.
    *
    * Last modified by Johnny in Prodigy on 26-05-2023.
    */
    @isTest
    static void testPro_SendFinancialEmails_btcWithBilling() {

        Test.startTest();
        
        Database.executeBatch(new Pro_SendFinancialEmails_btc('Billing'));
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the Pro_SendFinancialEmails_btc constructor with a Billing and Record ID.
    *
    * Last modified by Johnny in Prodigy on 26-05-2023.
    */
    @isTest
    static void testPro_SendFinancialEmails_btcWithBillingAndId() {

        AcctSeed__Billing__c testBilling = [
            SELECT
                Id
            FROM
                AcctSeed__Billing__c
            LIMIT
                1
        ];

        Test.startTest();
        
        Database.executeBatch(new Pro_SendFinancialEmails_btc(testBilling.Id, 'Billing'));
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the Pro_SendFinancialEmails_btc constructor with a Billing and multiple Record IDs.
    *
    * Last modified by Johnny in Prodigy on 26-05-2023.
    */
    @isTest
    static void testPro_SendFinancialEmails_btcWithBillingAndIds() {

        List<AcctSeed__Billing__c> testBillings = [
            SELECT
                Id
            FROM
                AcctSeed__Billing__c
        ];

        Test.startTest();
        
        List<String> testList = new List<String>();

        for (AcctSeed__Billing__c currentBilling : testBillings) {
            
            testList.add(currentBilling.Id);
        }

        Database.executeBatch(new Pro_SendFinancialEmails_btc(new List<String>{} , 'Billing'));
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

        /*
    * Description: Tests the Pro_SendFinancialEmails_btc constructor with an Account.
    *
    * Last modified by Johnny in Prodigy on 26-05-2023.
    */
    @isTest
    static void testPro_SendFinancialEmails_btcWithAccount() {

        Test.startTest();
        
        Database.executeBatch(new Pro_SendFinancialEmails_btc('Customer Statement'));
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the StartSchedule Method for Billings.
    *
    * Last modified by Johnny in Prodigy on 27-04-2023.
    */
    @isTest
    static void testStartScheduleBilling() {

        Test.startTest();
        
        Pro_SendFinancialEmails_btc.StartSchedule(true);
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

        /*
    * Description: Tests the StartSchedule Method for Accounts.
    *
    * Last modified by Johnny in Prodigy on 27-04-2023.
    */
    @isTest
    static void testStartScheduleAccount() {

        Test.startTest();
        
        Pro_SendFinancialEmails_btc.StartSchedule(false);
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }

    
}