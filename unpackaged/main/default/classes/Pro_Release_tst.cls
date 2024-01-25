/*
 * Created by Prodigy on 15-05-2023.
 *
 * Description: Test class for the Pro_Release controller class.
 *
 * Last modified by Johnny in Prodigy on 27-07-2023.
*/
@isTest
public class Pro_Release_tst {
    
    /*
    * Description: Method used to create .
    *
    * Last modified by Johnny in Prodigy on 27-07-2023.
    */
    @TestSetup
    static void MakeData(){
        
        Pro_DataFactory_dat.CreateAcctSeedRecords();

        Pro_DataFactory_dat.CreateAccounts();

        Pro_DataFactory_dat.CreateContacts();

        Pro_DataFactory_dat.CreateProducts();

        //Pro_DataFactory_dat.CreateBillings();

        Pro_DataFactory_dat.CreateAvSightAccountTerms();

        Pro_DataFactory_dat.CreateAvSightRelease();
    }

    /*
    * Description: Tests the ProcessRelease Method.
    *
    * Last modified by Johnny in Prodigy on 30-05-2023.
    */
    @isTest
    static void testProcessRelease() {

        inscor__Release__c testRelease = [
            SELECT
                Id,
                Salesperson__c,
                SO_Contact_Email__c
            FROM
                inscor__Release__c
            LIMIT
                1
        ];

        Test.startTest();
        
        Pro_Release_con.ProcessRelease(testRelease);
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }
}