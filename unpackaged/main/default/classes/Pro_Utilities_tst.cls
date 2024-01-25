/*
 * Created by Prodigy Ltd on 13-04-2023.
 *
 * Description: Test class for Pro_Utilities.
 *
 * Last modified by Johnny in Prodigy on 13-04-2023.
*/
@IsTest
class Pro_Utilities_tst {
    /*
    * Description: Tests the GetRecords Method.
    *
    * Last modified by Johnny in Prodigy on 13-04-2023.
    */
    @isTest
    static void testGetRecords() {
        pro_Error_Log__c err = new pro_Error_Log__c();
        insert err;
        
        String objectApiName = 'pro_Error_Log__c', searchField = '', extraFields = '';
        
        List<String> recordIds = new List<String>();
        
        Test.startTest();
        
        List<pro_Error_Log__c> errors = Pro_Utilities.GetRecords(objectApiName, recordIds, searchField, extraFields);
        
        Test.stopTest();
        
        Integer expected = 1, actual = errors.size();
        
        System.assertEquals(expected, actual);
    }
    
    /*
    * Description: Tests the GetObjectFields Method.
    *
    * Last modified by Johnny in Prodigy on 13-04-2023.
    */
    @isTest
    static void testGetObjectFields() {
        String objectApiName = 'pro_Error_Log__c';
        
        Test.startTest();
        
        List<String> result = Pro_Utilities.GetObjectFields(objectApiName);
        
        Test.stopTest();
        
        Boolean expected = false, actual = result.isEmpty();
        
        System.assertEquals(expected, actual);
    }
    
    /*
    * Description: Tests the DeleteRecords Method.
    *
    * Last modified by Johnny in Prodigy on 13-04-2023.
    */
    @isTest
    static void testDeleteRecords() {
        pro_Error_Log__c err = new pro_Error_Log__c();
        insert err;

        Savepoint savePoint = Database.setSavePoint();
        
        Test.startTest();
        
        Pro_Utilities.ResultWrap result = Pro_Utilities.DeleteRecords(new List<SObject>{ err }, savePoint);
        
        Test.stopTest();
        
        Boolean expected = true, actual = result.Result;
        
        System.assertEquals(expected, actual);
    }
    
    /*
    * Description: Tests the DeleteRecords Method.
    *
    * Last modified by Johnny in Prodigy on 13-04-2023.
    */
    @isTest
    static void testDeleteRecords_fail() {
        pro_Error_Log__c err = new pro_Error_Log__c();

        Savepoint savePoint = Database.setSavePoint();
        
        Test.startTest();
        
        Pro_Utilities.ResultWrap result = Pro_Utilities.DeleteRecords(new List<SObject>{ err }, savePoint);
        
        Test.stopTest();
        
        Boolean expected = false, actual = result.Result;
        
        System.assertEquals(expected, actual);
    }
    
    /*
    * Description: Tests the UpdateRecords Method.
    *
    * Last modified by Johnny in Prodigy on 13-04-2023.
    */
    @isTest
    static void testUpdateRecords() {
        pro_Error_Log__c err = new pro_Error_Log__c();
        insert err;
        
        Savepoint savePoint = Database.setSavePoint();

        Test.startTest();
        
        Pro_Utilities.ResultWrap result = Pro_Utilities.UpdateRecords(new List<SObject>{ err }, savePoint);
        
        Test.stopTest();
        
        Boolean expected = true, actual = result.Result;
        
        System.assertEquals(expected, actual);
    }
    
    /*
    * Description: Tests the UpdateRecords Method.
    *
    * Last modified by Johnny in Prodigy on 13-04-2023.
    */
    @isTest
    static void testUpdateRecords_fail() {
        pro_Error_Log__c err = new pro_Error_Log__c();
        
        Savepoint savePoint = Database.setSavePoint();

        Test.startTest();
        
        Pro_Utilities.ResultWrap result = Pro_Utilities.UpdateRecords(new List<SObject>{ err }, savePoint);
        
        Test.stopTest();
        
        Boolean expected = false, actual = result.Result;
        
        System.assertEquals(expected, actual);
    }
    
    /*
    * Description: Tests the InsertRecords Method.
    *
    * Last modified by Johnny in Prodigy on 13-04-2023.
    */
    @isTest
    static void testInsertRecords() {
        pro_Error_Log__c err = new pro_Error_Log__c();
        
        Savepoint savePoint = Database.setSavePoint();

        Test.startTest();
        
        Pro_Utilities.ResultWrap result = Pro_Utilities.InsertRecords(new List<SObject>{ err }, savePoint);
        
        Test.stopTest();
        
        Boolean expected = true, actual = result.Result;
        
        System.assertEquals(expected, actual);
    }
    
    /*
    * Description: Tests the InsertRecords Method.
    *
    * Last modified by Johnny in Prodigy on 13-04-2023.
    */
    @isTest
    static void testInsertRecords_fail() {
        pro_Error_Log__c err = new pro_Error_Log__c();
        insert err;
        
        Savepoint savePoint = Database.setSavePoint();

        Test.startTest();
        
        Pro_Utilities.ResultWrap result = Pro_Utilities.InsertRecords(new List<SObject>{ err }, savePoint);
        
        Test.stopTest();
        
        Boolean expected = false, actual = result.Result;
        
        System.assertEquals(expected, actual);
    }
    
    /*
    * Description: Tests the ResultWrap Method.
    *
    * Last modified by Johnny in Prodigy on 13-04-2023.
    */
    @isTest
    static void testResultWrap() {
        Test.startTest();
        
        Pro_Utilities.ResultWrap rw = new Pro_Utilities.ResultWrap();
        rw.Result = false;
        
        rw.Type = '';
        rw.ErrorTitle = '';
        rw.ErrorMessage = '';
        
        Test.stopTest();
        
        Integer expected = 1, actual = 1;
        
        System.assertEquals(expected, actual);
    }
}