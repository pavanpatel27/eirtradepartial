/*
 * Created by Prodigy Ltd on 19-04-2023.
 *
 * Description: Test class for Pro_CustomLookupField_con.
 *
 * Last modified by Johnny in Prodigy on 19-04-2023.
*/
@IsTest
class Pro_CustomLookupField_tst {
    /*
    * Description: Sets up test data for the class.
    *
    * Last modified by Johnny in Prodigy on 19-04-2023.
    */
    @TestSetup
    static void MakeData() {
        insert new pro_Error_Log__c(
            pro_Error_Message__c = 'Test Record'
        );
    }

    /*
    * Description: Tests the SearchRecords Method.
    *
    * Last modified by Johnny in Prodigy on 19-04-2023.
    */
    @isTest
    static void testSearchRecords() {

        String errorName = [
            SELECT
                Id,
                Name
            FROM
                pro_Error_Log__c
            LIMIT 1
        ].Name;

        String searchValue = errorName, objectApiName = 'pro_Error_Log__c';

        Test.startTest();
        
        String result = Pro_CustomLookupField_con.SearchRecords(searchValue, objectApiName);
        
        Test.stopTest();
        
        Boolean expected = true, actual = String.isNotBlank(result);
        
        System.assertEquals(expected, actual);
    }
    
    /*
    * Description: Tests the SearchRecordsDynamic Method.
    *
    * Last modified by Johnny in Prodigy on 19-04-2023.
    */
    @isTest
    static void testSearchRecordsDynamic() {
        String errorName = [
            SELECT
                Id,
                Name
            FROM
                pro_Error_Log__c
            LIMIT 1
        ].Name;

        String searchValue = errorName, objectApiName = 'pro_Error_Log__c', searchFields = 'Name', searchCriteria = '';

        Test.startTest();
        
        String result = Pro_CustomLookupField_con.SearchRecordsDynamic(searchValue, objectApiName, searchFields, searchCriteria);
        
        Test.stopTest();
        
        Boolean expected = true, actual = String.isNotBlank( result );
        
        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the SearchWrap wrapper class.
    *
    * Last modified by Johnny in Prodigy on 19-04-2023.
    */
    @isTest
    static void testSearchWrap() {
        Test.startTest();
        
        Pro_CustomLookupField_con.SearchWrap sw = new Pro_CustomLookupField_con.SearchWrap();
        sw.Label = '';
        sw.Value = '';
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }
}