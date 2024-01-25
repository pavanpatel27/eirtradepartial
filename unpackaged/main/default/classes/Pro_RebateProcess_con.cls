/*
 * Created by Prodigy Ltd on 28/11/2023.
 *
 * Description: Controller class for the proRebateProcess LWC.
 *
 * Last modified by Finbar in Prodigy on 11/12/2023.
*/
public class Pro_RebateProcess_con {
    /*
    * Description: Method used to seed component with Data.
    *
    * Last modified by Finbar in Prodigy on 29/11/2023.
    */
    @AuraEnabled
    public static string SeedData(String recordId){
        String result = '';

        Pro_RebateProcess_con.SeedDataWrap sdw = new Pro_RebateProcess_con.SeedDataWrap();
        sdw.Rebate = GetRebate(recordId);
        sdw.RebateRates = GetRebateRates(sdw.Rebate);

        result =  JSON.serialize(sdw);

        return result;
    }

    /*
    * Description: Updates end range on Line items.
    *
    * Last modified by Finbar in Prodigy on 11/12/2023.
    */
    @AuraEnabled
    public static String UpdateEndRange(String recordId, Decimal range){
        Savepoint savePoint = Database.setSavepoint();

        pro_Rebate_Rate__c rebateRate = new pro_Rebate_Rate__c(
            Id = recordId,
            pro_Range_End__c = range
        );

        Pro_Utilities.ResultWrap res  = Pro_Utilities.UpdateRecords(new List<pro_Rebate_Rate__c>{ rebateRate }, savePoint);
        
        String result = JSON.serialize( res );

        return result;
    }

    /*
    * Description: Updates Benefit on Line items.
    *
    * Last modified by Finbar in Prodigy on 11/12/2023.
    */
    @AuraEnabled
    public static String UpdateBenefit(String recordId, Decimal percentage){
        Savepoint savePoint = Database.setSavepoint();

        pro_Rebate_Rate__c rebateRate = new pro_Rebate_Rate__c(
            Id = recordId,
            pro_Rebate_Percent__c = percentage
        );

        Pro_Utilities.ResultWrap res  = Pro_Utilities.UpdateRecords(new List<pro_Rebate_Rate__c>{ rebateRate }, savePoint);
        
        String result = JSON.serialize( res );

        return result;
    }

    /*
    * Description: Updates Line items.
    *
    * Last modified by Finbar in Prodigy on 04/12/2023.
    */
    @AuraEnabled
    public static String CreateRecord(pro_Rebate_Rate__c record){
        Savepoint savePoint = Database.setSavepoint();

        Pro_Utilities.ResultWrap res  = Pro_Utilities.InsertRecords(new List<pro_Rebate_Rate__c>{ record }, savePoint);

        if (res.Result) {
            res.ErrorTitle = record.Id;
        }

        String result = JSON.serialize( res );
        
        return result;
    }

    /*
    * Description: Deletes Rebate Line.
    *
    * Last modified by Finbar in Prodigy on 11/12/2023.
    */
    @AuraEnabled
    public static String DeleteRecord(Id recordId){

        Savepoint savePoint = Database.setSavepoint();

        pro_Rebate_Rate__c rebateRate = new pro_Rebate_Rate__c(
            Id = recordId
        );
 

        Pro_Utilities.ResultWrap res = Pro_Utilities.DeleteRecords(new List<pro_Rebate_Rate__c>{ rebateRate }, savePoint);
        
        String result = JSON.serialize( res );
        
        return result;
    }

    /*
    * Description: Returns the rebate record.
    *
    * Last modified by Finbar in Prodigy on 05/12/2023.
    */
    @testvisible
    static pro_Rebate__c GetRebate(String recordId){
        pro_Rebate__c rebate = new pro_Rebate__c();

        List<pro_Rebate__c> rebates = Pro_Utilities.GetRecords('pro_Rebate__c', new List<String> { recordId } , 'Id', '');
        
        if (!rebates.isEmpty()) {
            rebate = rebates[0];
        }

        return rebate;
    }

    /*
    * Description: Returns the rebate record.
    *
    * Last modified by Finbar in Prodigy on 04/12/2023.
    */
    @testvisible
    static List<pro_Rebate_Rate__c> GetRebateRates(pro_Rebate__c rebate){

        List<pro_Rebate_Rate__c> rates =[
            SELECT
                Id,
                Name,
                pro_Rebate__c,
                pro_Range_End__c,
                pro_Range_Start__c,
                pro_Rebate_Percent__c,
                pro_Vouchered_Amount__c,
                pro_Rebate_Calculation__c,
                pro_Rebate_Calculation_Currency__c
            FROM
                pro_Rebate_Rate__c
            WHERE
                pro_Rebate__c =: rebate.Id
            ORDER BY
                pro_Range_Start__c ASC
        ];

        return rates;
    }

    /*
    * Description: Updates end range on Line items.
    *
    * Last modified by Finbar in Prodigy on 06/12/2023.
    */
    @testvisible
    public static Pro_Utilities.ResultWrap UpdateStartRange(Id rebate, Decimal startRange, Decimal endRange){
        Savepoint savePoint = Database.setSavepoint();
        Pro_Utilities.ResultWrap res = new Pro_Utilities.ResultWrap(); 
        res.Result = false;

        List<pro_Rebate_Rate__c> rebateRates = [
            SELECT
                Id,
                pro_Rebate__c,
                pro_Range_Start__c,
                pro_Range_End__c
            FROM
                pro_Rebate_Rate__c
            WHERE
                pro_Rebate__c =: rebate
            AND 
                pro_Range_Start__c =:  endRange
            LIMIT 1
        ];

        if (! rebateRates.isEmpty()) {
            rebateRates[0].pro_Range_Start__c = startRange;

            res  = Pro_Utilities.UpdateRecords(rebateRates, savePoint);
        }

        return res;
    }

    //
    // --- SECTION START: Wrapper classes
    //

    /*
    * Description: Wrapper class for Seed Data.
    *
    * Last modified by Finbar in Prodigy on 29/11/202.
    */
    @testvisible
    class SeedDataWrap{

        public pro_Rebate__c Rebate { get; set; }
        public List<pro_Rebate_Rate__c> RebateRates { get; set; }
    }
}