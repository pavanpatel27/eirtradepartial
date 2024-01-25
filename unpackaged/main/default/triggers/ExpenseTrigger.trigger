trigger ExpenseTrigger on salestrip__Expense__c (after insert, after update) {
    new ExpenseTriggerHandler().Run();
}