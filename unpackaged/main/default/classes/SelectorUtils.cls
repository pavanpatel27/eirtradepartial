public without sharing class SelectorUtils {
    public static Map<Id, SObject> retrieveRecords(Set<Id> ids, SObjectType sObjectTypeItem) {
        List<SObject> records = new List<SObject>();
        if (sObjectTypeItem == AcctSeed__Account_Payable__c.SObjectType) { records = [SELECT Id, inscoras__Repair_Order__c, inscoras__Owner_Code__c, inscoras__Purchase_Order__c, inscoras__Transaction_Activity__c FROM AcctSeed__Account_Payable__c WHERE Id =: ids]; }
        if (sObjectTypeItem == AcctSeed__Account_Payable_Line__c.SObjectType) { records = [SELECT Id, inscoras__Repair_Order_Line__r.inscor__Repair_Order__r.Name, inscoras__Repair_Order_Line__c, inscoras__Repair_Order_Line__r.inscor__Original_Part_Owner__c, inscoras__Purchase_Order_Line__c, AcctSeed__Account_Payable__r.inscoras__Repair_Order__c, AcctSeed__Account_Payable__r.inscoras__Owner_Code__c, AcctSeed__Account_Payable__r.inscoras__Purchase_Order__c, AcctSeed__Account_Payable__r.inscoras__Transaction_Activity__c FROM AcctSeed__Account_Payable_Line__c WHERE Id =: ids]; }
        if (sObjectTypeItem == AcctSeed__Billing__c.SObjectType) {
            records = [
                    SELECT Id, Owner_Code_Project__c, inscoras__Sales_Order__c, inscoras__RMA__c,
                            inscoras__Transaction_Activity__c, inscoras__Release__c, inscoras__Invoice__c
                    FROM AcctSeed__Billing__c
                    WHERE Id =: ids
            ];
        }
        if (sObjectTypeItem == AcctSeed__Billing_Line__c.SObjectType) { records = [SELECT Id, inscoras__Order_Type__c, inscoras__Condition_Code__c, inscoras__Warehouse__c, inscoras__Transaction_Activity__c, inscoras__Serial_Number__c, inscoras__Owner_Code__c, inscoras__Release_Line__r.Id, inscoras__Journal_Entry__c, inscoras__Journal_Entry__r.Name, AcctSeed__Billing__r.Owner_Code_Project__c, AcctSeed__Billing__r.inscoras__Sales_Order__c, AcctSeed__Billing__r.inscoras__RMA__c, AcctSeed__Billing__r.inscoras__Transaction_Activity__c, AcctSeed__Billing__r.inscoras__Release__c, AcctSeed__Billing__r.inscoras__Invoice__c FROM AcctSeed__Billing_Line__c WHERE Id =: ids]; }
        if (sObjectTypeItem == AcctSeed__Journal_Entry_Line__c.SObjectType) {
            records = [
                    SELECT Id, AcctSeed__Journal_Entry__r.inscoras__Release__c, AcctSeed__Journal_Entry__r.inscoras__Transaction_Activity__c,
                            AcctSeed__Journal_Entry__r.inscoras__Purchase_Order_Line__c, AcctSeed__Journal_Entry__r.inscoras__Repair_Order_Line__c,
                            AcctSeed__Journal_Entry__r.inscoras__Repair_Order_Line__r.inscor__Repair_Order__c,
                            AcctSeed__Journal_Entry__r.inscoras__Repair_Order_Line__r.inscor__Original_Part_Owner__c,
                            AcctSeed__Journal_Entry__r.inscoras__Release__r.inscor__Invoice__c,
                            AcctSeed__Journal_Entry__r.inscoras__Inventory__c,
                            AcctSeed__Journal_Entry__r.inscoras__Inventory__r.Name,
                            AcctSeed__Journal_Entry__r.inscoras__Inventory__r.inscor__Owner_Code__r.Name,
                            AcctSeed__Journal_Entry__r.inscoras__Inventory__r.inscor__Repair_Order__r.Name,
                            AcctSeed__Journal_Entry__r.inscoras__RMA_Line__c, AcctSeed__Journal_Entry__r.inscoras__RMA_Line__r.Name,
                            AcctSeed__Journal_Entry__r.inscoras__Receipt__c, AcctSeed__Journal_Entry__r.inscoras__Receipt__r.Name,
                            AcctSeed__Journal_Entry__r.inscoras__RO_Issue__c, AcctSeed__Journal_Entry__r.inscoras__RO_Issue__r.Name
                    FROM AcctSeed__Journal_Entry_Line__c
                    WHERE Id =: ids
            ];
        }
        return new Map<Id, SObject>(records);
    }
}