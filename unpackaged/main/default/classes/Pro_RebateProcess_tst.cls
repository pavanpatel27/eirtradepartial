/*
 * Created by Prodigy Ltd on 05/12/2023.
 *
 * Description: Test class for Pro_RebateProcess_con
 *
 * Last modified by Finbar in Prodigy on 12/12/2023.
*/
@isTest
public class Pro_RebateProcess_tst {
    
    /*
    * Description: Method used to setup data for testing.
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    @TestSetup
    static void MakeData(){
        Pro_DataFactory_dat.CreateAccounts();
        Pro_DataFactory_dat.CreateRebate();
    }

    /*
    * Description: Tests the SeedData.
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    @isTest
    static void testSeedData(){
        pro_Rebate__c rebate = [
            SELECT
                Id
            FROM
                pro_Rebate__c
            LIMIT 1
        ];

        Test.startTest();
        
        Pro_RebateProcess_con.SeedData( rebate.Id );
        
        Test.stopTest();
    }

    /*
    * Description: Tests the UpdateEndRange.
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    @isTest
    static void testUpdateEndRange(){
        
        pro_Rebate_Rate__c rebateRate = [
            SELECT
                Id
            FROM
                pro_Rebate_Rate__c
            LIMIT 1
        ];

        Test.startTest();
        
        Pro_RebateProcess_con.UpdateEndRange(rebateRate.Id, 20000);
        
        Test.stopTest();
    }

    /*
    * Description: Tests the UpdateBenefit.
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    @isTest
    static void testUpdateBenefit(){
        
        pro_Rebate_Rate__c rebateRate = [
            SELECT
                Id
            FROM
                pro_Rebate_Rate__c
            LIMIT 1
        ];
        Test.startTest();
        
        Pro_RebateProcess_con.UpdateBenefit(rebateRate.Id, 20);
        
        Test.stopTest();
    }

    /*
    * Description: Tests the CreateRecord.
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    @isTest
    static void testCreateRecord(){
        pro_Rebate_Rate__c rebateRate = [
            SELECT
                Id
            FROM
                pro_Rebate_Rate__c
            LIMIT 1
        ];

        Test.startTest();
        
        Pro_RebateProcess_con.CreateRecord(rebateRate);
        
        Test.stopTest();
    }

    /*
    * Description: Tests the DeleteRecord.
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    @isTest
    static void testDeleteRecord(){
        Id rebateRateId = [
            SELECT
                Id
            FROM
                pro_Rebate_Rate__c
            LIMIT 1
        ].Id;

        Test.startTest();
        
        Pro_RebateProcess_con.DeleteRecord(rebateRateId);
        
        Test.stopTest();
    }

    /*
    * Description: Tests the GetRebate.
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    @isTest
    static void testGetRebate(){
        Id rebateId = [
            SELECT
                Id
            FROM
                pro_Rebate__c
            LIMIT 1
        ].Id;

        Test.startTest();
        
        Pro_RebateProcess_con.GetRebate(rebateId);
        
        Test.stopTest();
    }

    /*
    * Description: Tests the GetRebateRates.
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    @isTest
    static void testGetRebateRates(){
        pro_Rebate__c rebate = [
            SELECT
                Id
            FROM
                pro_Rebate__c
            LIMIT 1
        ];

        Test.startTest();
        
        Pro_RebateProcess_con.GetRebateRates(rebate);
        
        Test.stopTest();
    }
    
    /*
    * Description: Tests the UpdateStartRange.
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    @isTest
    static void testUpdateStartRange(){
        Id rebate = [
            SELECT
                Id
            FROM
                pro_Rebate__c
            LIMIT 1
        ].Id;

        Test.startTest();
        
        Pro_RebateProcess_con.UpdateStartRange(rebate, 5000, 10000);
        
        Test.stopTest();
    }
}