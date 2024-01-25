trigger ExpenseReportTrigger on salestrip__ExpenseReport__c (before insert,after insert,before update) {
	new ExpenseReportTriggerHandler().run();
}