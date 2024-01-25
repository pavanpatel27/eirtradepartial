public with sharing class AcctSeedTransactionHandler {
    public static Set<State> states = new Set<State>();

    private static Map<SObjectType, Map<SObjectField, List<SObjectField>>> queueFieldsByTransactionFields = new Map<SObjectType, Map<SObjectField, List<SObjectField>>>{
            AcctSeed__Account_Payable_Line__c.SObjectType => new Map<SObjectField, List<SObjectField>>{
                    AcctSeed__Transaction__c.RO_Number__c => new List<SObjectField>{
                            AcctSeed__Account_Payable_Line__c.inscoras__Repair_Order_Line__c,
                            inscor__Repair_Order_Line__c.inscor__Repair_Order__c,
                            inscor__Repair_Order__c.Name
                    },
                    AcctSeed__Transaction__c.Original_Owner_Code__c => new List<SObjectField>{
                            AcctSeed__Account_Payable_Line__c.inscoras__Repair_Order_Line__c,
                            inscor__Repair_Order_Line__c.inscor__Original_Part_Owner__c
                    },
                    AcctSeed__Transaction__c.Repair_Order__c => new List<SObjectField>{
                            AcctSeed__Account_Payable_Line__c.AcctSeed__Account_Payable__c,
                            AcctSeed__Account_Payable__c.inscoras__Repair_Order__c
                    },
                    AcctSeed__Transaction__c.Owner_Code__c => new List<SObjectField>{
                            AcctSeed__Account_Payable_Line__c.AcctSeed__Account_Payable__c,
                            AcctSeed__Account_Payable__c.inscoras__Owner_Code__c
                    },
                    AcctSeed__Transaction__c.Purchase_Order__c => new List<SObjectField>{
                            AcctSeed__Account_Payable_Line__c.AcctSeed__Account_Payable__c,
                            AcctSeed__Account_Payable__c.inscoras__Purchase_Order__c
                    },
                    AcctSeed__Transaction__c.Transaction_Activity__c => new List<SObjectField>{
                            AcctSeed__Account_Payable_Line__c.AcctSeed__Account_Payable__c,
                            AcctSeed__Account_Payable__c.inscoras__Transaction_Activity__c
                    }
            },
            AcctSeed__Billing_Line__c.SObjectType => new Map<SObjectField, List<SObjectField>>{
                    AcctSeed__Transaction__c.Journal_Entry_Name__c => new List<SObjectField>{
                            AcctSeed__Billing_Line__c.inscoras__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.Name
                    },
                    AcctSeed__Transaction__c.Release_Line__c => new List<SObjectField>{
                            AcctSeed__Billing_Line__c.inscoras__Release_Line__c,
                            inscor__Release_Line__c.Id
                    },

                    AcctSeed__Transaction__c.Owner_Code_Project__c => new List<SObjectField>{
                            AcctSeed__Billing_Line__c.AcctSeed__Billing__c,
                            AcctSeed__Billing__c.Owner_Code_Project__c
                    },
                    AcctSeed__Transaction__c.Sales_Order__c => new List<SObjectField>{
                            AcctSeed__Billing_Line__c.AcctSeed__Billing__c,
                            AcctSeed__Billing__c.inscoras__Sales_Order__c
                    },
                    AcctSeed__Transaction__c.RMA__c => new List<SObjectField>{
                            AcctSeed__Billing_Line__c.AcctSeed__Billing__c,
                            AcctSeed__Billing__c.inscoras__RMA__c
                    },
                    AcctSeed__Transaction__c.Transaction_Activity__c => new List<SObjectField>{
                            AcctSeed__Billing_Line__c.AcctSeed__Billing__c,
                            AcctSeed__Billing__c.inscoras__Transaction_Activity__c
                    },
                    AcctSeed__Transaction__c.Release__c => new List<SObjectField>{
                            AcctSeed__Billing_Line__c.AcctSeed__Billing__c,
                            AcctSeed__Billing__c.inscoras__Release__c
                    },
                    AcctSeed__Transaction__c.Invoice__c => new List<SObjectField>{
                            AcctSeed__Billing_Line__c.AcctSeed__Billing__c,
                            AcctSeed__Billing__c.inscoras__Invoice__c
                    }
            },
            AcctSeed__Journal_Entry_Line__c.SObjectType => new Map<SObjectField, List<SObjectField>>{
                    AcctSeed__Transaction__c.Release__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Release__c
                    },
                    AcctSeed__Transaction__c.Transaction_Activity__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Transaction_Activity__c
                    },
                    AcctSeed__Transaction__c.Purchase_Order_Line__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Purchase_Order_Line__c
                    },
                    AcctSeed__Transaction__c.Repair_Order_Line__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Repair_Order_Line__c
                    },
                    AcctSeed__Transaction__c.Repair_Order__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Repair_Order_Line__c,
                            inscor__Repair_Order_Line__c.inscor__Repair_Order__c
                    },
                    AcctSeed__Transaction__c.Original_Owner_Code__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Repair_Order_Line__c,
                            inscor__Repair_Order_Line__c.inscor__Original_Part_Owner__c
                    },
                    AcctSeed__Transaction__c.Invoice__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Release__c,
                            inscor__Release__c.inscor__Invoice__c
                    },
                    AcctSeed__Transaction__c.INV_Sold_Owner_Code__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Inventory__c,
                            inscor__Inventory_Line__c.inscor__Owner_Code__c,
                            inscor__Owner_Code__c.Name
                    },
                    AcctSeed__Transaction__c.INV_Sold_RO_Number__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Inventory__c,
                            inscor__Inventory_Line__c.inscor__Repair_Order__c,
                            inscor__Repair_Order__c.Name
                    },
                    AcctSeed__Transaction__c.RMA_Line_Id__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__RMA_Line__c
                    },
                    AcctSeed__Transaction__c.RMA_Line_Name__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__RMA_Line__c,
                            inscor__RMA_Line__c.Name
                    },
                    AcctSeed__Transaction__c.Inventory_Id__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Inventory__c
                    },
                    AcctSeed__Transaction__c.Inventory_Name__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Inventory__c,
                            inscor__Inventory_Line__c.Name
                    },
                    AcctSeed__Transaction__c.Receipt_Id__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Receipt__c
                    },
                    AcctSeed__Transaction__c.Receipt_Name__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__Receipt__c,
                            inscor__Receipt__c.Name
                    },
                    AcctSeed__Transaction__c.RO_Issue_Id__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__RO_Issue__c
                    },
                    AcctSeed__Transaction__c.RO_Issue_Name__c => new List<SObjectField>{
                            AcctSeed__Journal_Entry_Line__c.AcctSeed__Journal_Entry__c,
                            AcctSeed__Journal_Entry__c.inscoras__RO_Issue__c,
                            inscor__RO_Issue__c.Name
                    }
            }
    };

    private static Map<SObjectType, Map<SObjectField, SObjectField>> transactionFieldsByFieldsBySObjectTypes = new Map<SObjectType, Map<SObjectField, SObjectField>>{
            AcctSeed__Account_Payable__c.SObjectType => new Map<SObjectField, SObjectField>{
                    AcctSeed__Account_Payable__c.inscoras__Repair_Order__c => AcctSeed__Transaction__c.Repair_Order__c,
                    AcctSeed__Account_Payable__c.inscoras__Owner_Code__c => AcctSeed__Transaction__c.Owner_Code__c,
                    AcctSeed__Account_Payable__c.inscoras__Purchase_Order__c => AcctSeed__Transaction__c.Purchase_Order__c,
                    AcctSeed__Account_Payable__c.inscoras__Transaction_Activity__c => AcctSeed__Transaction__c.Transaction_Activity__c
            },
            AcctSeed__Account_Payable_Line__c.SObjectType => new Map<SObjectField, SObjectField>{
                    AcctSeed__Transaction__c.RO_Number__c => AcctSeed__Transaction__c.RO_Number__c,
                    AcctSeed__Account_Payable_Line__c.inscoras__Repair_Order_Line__c => AcctSeed__Transaction__c.Repair_Order_Line__c,
                    AcctSeed__Transaction__c.Original_Owner_Code__c => AcctSeed__Transaction__c.Original_Owner_Code__c,
                    AcctSeed__Account_Payable_Line__c.inscoras__Purchase_Order_Line__c => AcctSeed__Transaction__c.Purchase_Order_Line__c,

                    AcctSeed__Transaction__c.Repair_Order__c => AcctSeed__Transaction__c.Repair_Order__c,
                    AcctSeed__Transaction__c.Owner_Code__c => AcctSeed__Transaction__c.Owner_Code__c,
                    AcctSeed__Transaction__c.Purchase_Order__c => AcctSeed__Transaction__c.Purchase_Order__c,
                    AcctSeed__Transaction__c.Transaction_Activity__c => AcctSeed__Transaction__c.Transaction_Activity__c
            },
            AcctSeed__Billing__c.SObjectType => new Map<SObjectField, SObjectField>{
                    AcctSeed__Billing__c.Owner_Code_Project__c => AcctSeed__Transaction__c.Owner_Code_Project__c,
                    AcctSeed__Billing__c.inscoras__Sales_Order__c => AcctSeed__Transaction__c.Sales_Order__c,
                    AcctSeed__Billing__c.inscoras__RMA__c => AcctSeed__Transaction__c.RMA__c,
                    AcctSeed__Billing__c.inscoras__Transaction_Activity__c => AcctSeed__Transaction__c.Transaction_Activity__c,
                    AcctSeed__Billing__c.inscoras__Release__c => AcctSeed__Transaction__c.Release__c,
                    AcctSeed__Billing__c.inscoras__Invoice__c => AcctSeed__Transaction__c.Invoice__c
            },
            AcctSeed__Billing_Line__c.SObjectType => new Map<SObjectField, SObjectField>{
                    AcctSeed__Billing_Line__c.inscoras__Order_Type__c => AcctSeed__Transaction__c.Order_Type__c,
                    AcctSeed__Billing_Line__c.inscoras__Condition_Code__c => AcctSeed__Transaction__c.Condition_Code__c,
                    AcctSeed__Billing_Line__c.inscoras__Warehouse__c => AcctSeed__Transaction__c.Warehouse__c,
                    AcctSeed__Billing_Line__c.inscoras__Transaction_Activity__c => AcctSeed__Transaction__c.Transaction_Activity__c,
                    AcctSeed__Billing_Line__c.inscoras__Serial_Number__c => AcctSeed__Transaction__c.Serial_Number__c,
                    AcctSeed__Billing_Line__c.inscoras__Owner_Code__c => AcctSeed__Transaction__c.Owner_Code__c,
                    AcctSeed__Transaction__c.Release_Line__c => AcctSeed__Transaction__c.Release_Line__c,

                    AcctSeed__Transaction__c.Owner_Code_Project__c => AcctSeed__Transaction__c.Owner_Code_Project__c,
                    AcctSeed__Transaction__c.Sales_Order__c => AcctSeed__Transaction__c.Sales_Order__c,
                    AcctSeed__Transaction__c.RMA__c => AcctSeed__Transaction__c.RMA__c,
                    AcctSeed__Transaction__c.Transaction_Activity__c => AcctSeed__Transaction__c.Transaction_Activity__c,
                    AcctSeed__Transaction__c.Release__c => AcctSeed__Transaction__c.Release__c,
                    AcctSeed__Transaction__c.Invoice__c => AcctSeed__Transaction__c.Invoice__c,

//                    Journal_Entry HYPERLINK
                    AcctSeed__Billing_Line__c.inscoras__Journal_Entry__c => AcctSeed__Transaction__c.Journal_Entry_Id__c,
                    AcctSeed__Transaction__c.Journal_Entry_Name__c => AcctSeed__Transaction__c.Journal_Entry_Name__c
            },
            AcctSeed__Journal_Entry_Line__c.SObjectType => new Map<SObjectField, SObjectField>{
                    AcctSeed__Transaction__c.Release__c => AcctSeed__Transaction__c.Release__c,
                    AcctSeed__Transaction__c.Transaction_Activity__c => AcctSeed__Transaction__c.Transaction_Activity__c,
                    AcctSeed__Transaction__c.Purchase_Order_Line__c => AcctSeed__Transaction__c.Purchase_Order_Line__c,

//                    RMA_LINE  HYPERLINK
                    AcctSeed__Transaction__c.RMA_Line_Id__c => AcctSeed__Transaction__c.RMA_Line_Id__c,
                    AcctSeed__Transaction__c.RMA_Line_Name__c => AcctSeed__Transaction__c.RMA_Line_Name__c,

//                    Inventory HYPERLINK
                    AcctSeed__Transaction__c.Inventory_Id__c => AcctSeed__Transaction__c.Inventory_Id__c,
                    AcctSeed__Transaction__c.Inventory_Name__c => AcctSeed__Transaction__c.Inventory_Name__c,

//                    Receipt HYPERLINK
                    AcctSeed__Transaction__c.Receipt_Id__c => AcctSeed__Transaction__c.Receipt_Id__c,
                    AcctSeed__Transaction__c.Receipt_Name__c => AcctSeed__Transaction__c.Receipt_Name__c,

                    AcctSeed__Transaction__c.Repair_Order_Line__c => AcctSeed__Transaction__c.Repair_Order_Line__c,

//                    RO Issue HYPERLINK
                    AcctSeed__Transaction__c.RO_Issue_Id__c => AcctSeed__Transaction__c.RO_Issue_Id__c,
                    AcctSeed__Transaction__c.RO_Issue_Name__c => AcctSeed__Transaction__c.RO_Issue_Name__c,

                    AcctSeed__Transaction__c.Repair_Order__c => AcctSeed__Transaction__c.Repair_Order__c,
                    AcctSeed__Transaction__c.Original_Owner_Code__c => AcctSeed__Transaction__c.Original_Owner_Code__c,
                    AcctSeed__Transaction__c.Invoice__c => AcctSeed__Transaction__c.Invoice__c,
                    AcctSeed__Transaction__c.INV_Sold_Owner_Code__c => AcctSeed__Transaction__c.INV_Sold_Owner_Code__c,
                    AcctSeed__Transaction__c.INV_Sold_RO_Number__c => AcctSeed__Transaction__c.INV_Sold_RO_Number__c
            }
    };

    private static Set<SObjectField> sourceFields = new Set<SObjectField>{
            AcctSeed__Transaction__c.AcctSeed__Account_Payable__c,
            AcctSeed__Transaction__c.AcctSeed__Account_Payable_Line__c,
            AcctSeed__Transaction__c.AcctSeed__Billing__c,
            AcctSeed__Transaction__c.AcctSeed__Billing_Line__c,
            AcctSeed__Transaction__c.AcctSeed__Journal_Entry_Line__c
    };

    public static void beforeInsert(List<AcctSeed__Transaction__c> transactions) {
        fillInAdditionalTransactionFields(transactions);
    }

    public static void beforeUpdate(List<AcctSeed__Transaction__c> transactions, Map<Id, AcctSeed__Transaction__c> oldTransactionsByIds) {
        if (states.contains(State.REFILL_ADDITIONAL_FIELDS)) {
            fillInAdditionalTransactionFields(transactions);
        }
    }

    private static void fillInAdditionalTransactionFields(List<AcctSeed__Transaction__c> transactions) {
        Set<SObjectType> sObjectTypes4Retrieve = new Set<SObjectType>();
        Set<Id> ids = new Set<Id>();
        for (AcctSeed__Transaction__c transactionItem : transactions) {
            for (SObjectField field : sourceFields) {
                Id refId = (Id)transactionItem.get(field);
                ids.add(refId);

                if (String.isNotBlank(refId)) {
                    sObjectTypes4Retrieve.add(refId.getSobjectType());
                }
            }
        }

        Map<SObjectType, Map<Id, SObject>> recordsBySObjectTypes = new Map<SObjectType, Map<Id, SObject>>();
        for (SObjectType sObjectTypeItem : sObjectTypes4Retrieve) { //the maximum number of iterations - 5
            recordsBySObjectTypes.put(sObjectTypeItem, SelectorUtils.retrieveRecords(ids, sObjectTypeItem));
        }

        for (AcctSeed__Transaction__c transactionItem : transactions) {
            for (SObjectField field : sourceFields) {
                Id refId = (Id)transactionItem.get(field);
                if (String.isNotBlank(refId)) {
                    transactionItem = prepareFields(
                            transactionItem,
                            recordsBySObjectTypes.get(refId.getSobjectType())?.get(refId),
                            refId.getSobjectType()
                    );
                }
            }
        }
    }

    private static AcctSeed__Transaction__c prepareFields(AcctSeed__Transaction__c transactionItem, SObject record, SObjectType sourceType) {
        Map<SObjectField, SObjectField> transactionFieldsByFields = transactionFieldsByFieldsBySObjectTypes.get(record.getSObjectType());
        if (transactionFieldsByFields != null) {
            for (SObjectField field : transactionFieldsByFields.keySet()) {
                SObjectField transactionField = transactionFieldsByFields.get(field);
                Object value = null;
                if (queueFieldsByTransactionFields.get(sourceType)?.get(field) != null) {
                    List<SObjectField> subFields = queueFieldsByTransactionFields.get(sourceType).get(field);
                    if (!subFields.isEmpty()) {
                        SObject subRecord = record.getSObject(subFields[0]);
                        for (Integer index = 1; index < subFields.size(); index++) {
                            SObjectField subField = subFields[index];
                            if (index < subFields.size() - 1) {
                                subRecord = subRecord?.getSObject(subField);
                            } else {
                                value = subRecord?.get(subField);
                            }
                        }
                    }
                } else {
                    value = record.get(field);
                }

                if (value != null) {
                    transactionItem.put(transactionField, value);
                }
            }
        }
        return transactionItem;
    }

    public enum State {
        REFILL_ADDITIONAL_FIELDS
    }
}