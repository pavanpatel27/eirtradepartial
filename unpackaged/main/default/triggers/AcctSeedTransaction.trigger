trigger AcctSeedTransaction on AcctSeed__Transaction__c (before insert, before update) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            AcctSeedTransactionHandler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            AcctSeedTransactionHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}