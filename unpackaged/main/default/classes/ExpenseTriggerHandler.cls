public with sharing class ExpenseTriggerHandler extends TriggerHandlerSalestrip {
    public override void afterUpdate() {
        List<salestrip__Expense__c> listOfExp = new List<salestrip__Expense__c>();
        
        Map<Id, salestrip__Expense__c> oldMap = (Map<Id, salestrip__Expense__c>) Trigger.oldMap;
        
        for(salestrip__Expense__c exp : (List<salestrip__Expense__c>) Trigger.new) {
            salestrip__Expense__c oldexp = oldMap.get(exp.id);
            
            if(String.isNotBlank(exp.salestrip__ExportRecord__c) && oldexp.salestrip__ExportRecord__c == null && (exp.salestrip__ExportRecord__c != oldexp.salestrip__ExportRecord__c)) {
                listOfExp.add(exp);
            }
        } 
        
        if(listOfExp != NULL && !listOfExp.IsEmpty()) {
            new ExpenseService().InsertAccountingExpense(listOfExp);
        }
    }
}