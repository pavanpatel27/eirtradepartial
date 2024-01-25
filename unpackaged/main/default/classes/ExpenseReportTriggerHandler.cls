public with sharing class ExpenseReportTriggerHandler extends TriggerHandlerSalestrip{
	public class MyException extends Exception {} 
    public override void beforeUpdate() {
        set<Id> setOfExpRepIds = new set<Id>();
        Map<Id, salestrip__ExpenseReport__c> oldMap = (Map<Id, salestrip__ExpenseReport__c>) Trigger.oldMap;
        
        for(salestrip__ExpenseReport__c exp : (List<salestrip__ExpenseReport__c>) Trigger.new) {
            salestrip__ExpenseReport__c oldexp = oldMap.get(exp.id);
            
            if(String.isNotBlank(exp.salestrip__Status__c) && exp.salestrip__Status__c == 'Pending Approval') {
                setOfExpRepIds.add(exp.Id);
            }
        } 
        
        if(setOfExpRepIds != NULL && !setOfExpRepIds.IsEmpty()) {
            map<Id,salestrip__Expense__c> mapofExpense = new map<Id,salestrip__Expense__c>([SELECT Id,Name FROM salestrip__Expense__c WHERE salestrip__ExpenseReport__c IN :setOfExpRepIds]);
            map<Id,ContentDocumentLink> mapOfFiles = new map<Id,ContentDocumentLink>();
            
            for(ContentDocumentLink con :[
                SELECT Id, LinkedEntityId,ContentDocumentId, ShareType
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :mapofExpense.KeySet()]) {
                    mapOfFiles.put(con.LinkedEntityId,con);
                }
            String str = '';
            for(Id expId : mapofExpense.KeySet()) {
                salestrip__Expense__c exp = mapofExpense.get(expId);
                If(!mapOfFiles.ContainsKey(expId)) {
       				str = str + 'Attach the Recipents for expense : '+ exp.Name +',';
                }
            }
            
            if(String.isNotBlank(str)) {
                if(!Test.isRunningTest()) { 
            		//throw new MyException(str);              
                }
            }
        }
    }
}