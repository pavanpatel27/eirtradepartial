public without sharing class TransactionUpdatingBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT Id
                FROM AcctSeed__Transaction__c
        ]);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        AcctSeedTransactionHandler.states.add(AcctSeedTransactionHandler.State.REFILL_ADDITIONAL_FIELDS);
        update scope;
    }

    public void finish(Database.BatchableContext context) {}
}