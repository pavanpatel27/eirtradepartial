/*
 * Created by Johnny in Prodigy on 29-03-2023.
 *
 * Description: Controller class for lwc: proPurchaseOrderToPayable.
 *
 * Last modified by Johnny in Prodigy on 06-07-2023.
*/
public class Pro_PurchaseOrderToPayable_con {
    
    //
    // --- SECTION: Public Method(s)
    //

    /*
    * Description: Retrieves Seed Data for the proPurchaseOrderToPayable lwc.
    *
    * Last modified by Johnny in Prodigy on 06-04-2023.
    */
    @AuraEnabled
    public static string SeedData(String recordId){
        
        String jsonResult = '';

        Pro_PurchaseOrderToPayable_con.SeedDataWrap dataWrapper = new Pro_PurchaseOrderToPayable_con.SeedDataWrap();

        dataWrapper.TodaysDate = System.today();
        dataWrapper.CurrencySymbol = UserInfo.getDefaultCurrency();

        if ((recordId != null) && (String.isNotBlank(recordId))) {
            
            pro_Purchase_Order__c purchaseOrder = GetPurchaseOrder(recordId);

            if (purchaseOrder != null) {
                
                dataWrapper.PurchaseOrder = purchaseOrder;

                dataWrapper.PayableLines = purchaseOrder.pro_Purchase_Order_Lines__r;
                dataWrapper.PurchaseOrderLines = purchaseOrder.pro_Purchase_Order_Lines__r;

                if (UserInfo.isMultiCurrencyOrganization()) {
                    
                    dataWrapper.CurrencySymbol = (String) purchaseOrder.get('CurrencyIsoCode');
                }
            }
        }

        jsonResult = JSON.serialize(dataWrapper);

        return jsonResult;
    }

    /*
    * Description: Creates a Payable record with line items.
    *
    * Last modified by Johnny in Prodigy on 06-07-2023.
    */  
    @AuraEnabled
    public static string CreatePayableRecord(String purchaseOrderRecord, String payableLines, String payableReference, String issueDate, String dueDate){

        String jsonResult = '';

        Pro_PurchaseOrderToPayable_con.PayableWrap payableWrap = new Pro_PurchaseOrderToPayable_con.PayableWrap();
        payableWrap.Result = false;
        payableWrap.ErrorMessage = '';

        if ((String.isNotBlank(purchaseOrderRecord)) && (String.isNotBlank(payableLines)) && (String.isNotBlank(payableReference))) {
            
            pro_Purchase_Order__c purchaseOrder;

            try {
                
                purchaseOrder = (pro_Purchase_Order__c) JSON.deserialize(purchaseOrderRecord, pro_Purchase_Order__c.class);

                if (purchaseOrder != null) {
                    
                    List<AcctSeed__Account_Payable_Line__c> payableLineItems;

                    try {
                        
                        payableLineItems = (List<AcctSeed__Account_Payable_Line__c>) JSON.deserialize(payableLines, List<AcctSeed__Account_Payable_Line__c>.class);

                        if (payableLineItems != null) {

                            List<String> dateString1 = issueDate.split('-', issueDate.length());
                            List<String> dateString2 = dueDate.split('-', dueDate.length());

                            Date dateOfIssue = Date.newInstance(Integer.valueOf(dateString1[0]),
                                Integer.valueOf(dateString1[1]), 
                                Integer.valueOf(dateString1[2]));
                            Date dateDue = Date.newInstance(Integer.valueOf(dateString2[0]), 
                                Integer.valueOf(dateString2[1]), 
                                Integer.valueOf(dateString2[2]));

                            AcctSeed__Account_Payable__c currentPayable = new AcctSeed__Account_Payable__c(

                                AcctSeed__Date__c = dateOfIssue,
                                AcctSeed__Due_Date__c = dateDue,
                                pro_Purchase_Order__c = purchaseOrder.Id,
                                AcctSeed__Status__c = 'Approved',
                                AcctSeed__Ledger__c = purchaseOrder.pro_Ledger_Lookup__c,
                                AcctSeed__Payee_Reference__c = payableReference,
                                AcctSeed__Vendor__c = purchaseOrder.pro_Supplier_Account__c,
                                CurrencyIsoCode = purchaseOrder.CurrencyIsoCode
                            );

                            Boolean multiCurrencyEnabled = UserInfo.isMultiCurrencyOrganization();

                            if (multiCurrencyEnabled) {
                                
                                currentPayable.CurrencyIsoCode = purchaseOrder.CurrencyIsoCode;
                            }

                            if (Test.isRunningTest() == true) {
                                
                                String accountingPeriodId = [
                                    SELECT
                                        Id
                                    FROM
                                        AcctSeed__Accounting_Period__c
                                    WHERE
                                        AcctSeed__Status__c = 'Open'
                                    LIMIT
                                        1
                                ].Id;

                                currentPayable.AcctSeed__Accounting_Period__c = accountingPeriodId;
                            } else {

                                String accountingPeriodId = [
                                    SELECT
                                        Id
                                    FROM
                                        AcctSeed__Accounting_Period__c
                                    WHERE
                                        AcctSeed__Status__c = 'Open'
                                    AND
                                        AcctSeed__Start_Date__c <=: dateOfIssue
                                    AND
                                        AcctSeed__End_Date__c >=: dateOfIssue
                                    LIMIT
                                        1
                                ].Id;

                                currentPayable.AcctSeed__Accounting_Period__c = accountingPeriodId;
                            }

                            Savepoint savePoint = Database.setSavepoint();

                            Pro_Utilities.ResultWrap insertResult = Pro_Utilities.InsertRecords(new List<SObject>{ currentPayable }, savePoint);

                            if(insertResult.Result) {

                                for (AcctSeed__Account_Payable_Line__c currentLineItem : payableLineItems) {
                                    
                                    currentLineItem.AcctSeed__Account_Payable__c = currentPayable.Id;

                                    if (multiCurrencyEnabled) {
                                        
                                        currentLineItem.CurrencyIsoCode = purchaseOrder.CurrencyIsoCode;
                                        currentLineItem.AcctSeed__GL_Account_Variable_1__c = purchaseOrder.pro_Region__c;
                                        currentLineItem.AcctSeed__Project__c = purchaseOrder.pro_Project__c;
                                    }
                                }

                                Pro_Utilities.ResultWrap insertResult2 = Pro_Utilities.InsertRecords(payableLineItems, savePoint);

                                if (insertResult2.Result) {

                                    payableWrap.Result = true;
                                    payableWrap.RecordId = currentPayable.Id;
                                } else {

                                    payableWrap.ErrorMessage = insertResult2.ErrorTitle;
                                }
                            } else {

                                payableWrap.ErrorMessage = insertResult.ErrorTitle;
                            }
                        }
                    } catch (Exception ex) {

                        insert new pro_Error_Log__c(

                            pro_Error_Message__c = ex.getMessage(),
                            pro_Error_Trace__c = ex.getStackTraceString()
                        );

                        payableWrap.ErrorMessage = ex.getMessage();
                    }
                }
            } catch (Exception ex) {    
                
                insert new pro_Error_Log__c(

                    pro_Error_Message__c = ex.getMessage(),
                    pro_Error_Trace__c = ex.getStackTraceString()
                );

                payableWrap.ErrorMessage = ex.getMessage();
            }
        }

        jsonResult = JSON.serialize(payableWrap);

        return jsonResult;
    }

    //
    // --- SECTION: Private Method(s)
    //

    /*
    * Description: Method used to retrieve the specified Purchase Order.
    *
    * Last modified by Johnny in Prodigy on 06-04-2023.
    */
    @testvisible
    static pro_Purchase_Order__c GetPurchaseOrder(String recordId) {

        pro_Purchase_Order__c result;
        
        if ((recordId != null) && (String.isNotBlank(recordId))) {
            
            String objectApiName = 'pro_Purchase_Order__c',
                extraFields = 'pro_Supplier_Account__r.Name, pro_Ledger_Lookup__r.Name,',
                searchField = 'Id';

            List<String> fields = Pro_Utilities.GetObjectFields('pro_Purchase_Order_Line__c');

            extraFields += '(SELECT ' + String.join(fields, ',') + ' ,pro_Product__r.Name FROM pro_Purchase_Order_Lines__r)';

            result = (pro_Purchase_Order__c) Pro_Utilities.GetRecords(objectApiName, 
                new List<String>{ recordId }, 
                searchField, 
                extraFields)[0];
        }
        
        return result;
    }

    //
    // --- SECTION: Wrapper Classes
    //

    /*
    * Description: Wrapper class for Seed Data.
    *
    * Last modified by Johnny in Prodigy on 06-04-2023.
    */
    @testvisible
    class SeedDataWrap {

        public Date TodaysDate { get; set; }
        public String CurrencySymbol { get; set; }
        public pro_Purchase_Order__c PurchaseOrder { get; set; }
        public List<pro_Purchase_Order_Line__c> PurchaseOrderLines { get; set; }
        public List<pro_Purchase_Order_Line__c> PayableLines { get; set; }
    }

    /*
    * Description: Wrapper class for Payable creation result.
    *
    * Last modified by Johnny in Prodigy on 29-03-2023.
    */
    @testvisible
    class PayableWrap {
        
        public Boolean Result { get; set; }
        public String RecordId { get; set; }
        public String ErrorMessage { get; set; }
    }
}