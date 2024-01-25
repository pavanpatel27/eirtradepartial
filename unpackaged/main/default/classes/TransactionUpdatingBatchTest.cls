@IsTest
private class TransactionUpdatingBatchTest {
    @IsTest
    static void testBehavior() {
        AcctSeed.TestService.setupTestData(true, true, true);

        List<AcctSeed__Accounting_Period__c> accountingPeriods = [
                SELECT Id, AcctSeed__Start_Date__c, AcctSeed__End_Date__c
                FROM AcctSeed__Accounting_Period__c
                LIMIT 1
        ];

        List<inscor__RO_Issue__c> roIssues = new List<inscor__RO_Issue__c>{
                new inscor__RO_Issue__c()
        };
        insert roIssues;

        List<AcctSeed__Journal_Entry__c> journalEntries = new List<AcctSeed__Journal_Entry__c>{
                new AcctSeed__Journal_Entry__c(
                        Name = 'testJournal 1',
                        AcctSeed__Accounting_Period__c = accountingPeriods[0].Id,
                        AcctSeed__Journal_Date__c = System.today(),
                        AcctSeed__Status__c = 'Approved',
                        inscoras__RO_Issue__c = roIssues[0].Id
                )
        };
        insert journalEntries;

        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Name = '1000-Cash'];

        List<AcctSeed__Journal_Entry_Line__c> journalEntryLines = new List<AcctSeed__Journal_Entry_Line__c>{
                new AcctSeed__Journal_Entry_Line__c(
                        AcctSeed__Journal_Entry__c = journalEntries[0].Id,
                        AcctSeed__Credit__c = 100,
                        AcctSeed__GL_Account__c = glAccounts[0].Id,
                        AcctSeed__Units__c = 10,
                        AcctSeed__Reference__c = 'the reference 1',
                        AcctSeed__Description__c = 'the description 1'
                ),
                new AcctSeed__Journal_Entry_Line__c(
                        AcctSeed__Journal_Entry__c = journalEntries[0].Id,
                        AcctSeed__Debit__c = 100,
                        AcctSeed__GL_Account__c = glAccounts[0].Id,
                        AcctSeed__Units__c = 10,
                        AcctSeed__Reference__c = 'the reference 2',
                        AcctSeed__Description__c = 'the description 2'
                )
        };
        insert journalEntryLines;

        AcctSeed.JournalEntryPostService.postJournalEntries(journalEntries);

        List<AcctSeed__Transaction__c> transactions = [
                SELECT Id, RO_Issue_Id__c, RO_Issue_Name__c, RO_Issue__c
                FROM AcctSeed__Transaction__c
                WHERE AcctSeed__Journal_Entry_Line__r.AcctSeed__Journal_Entry__c =: journalEntries[0].Id
        ];
        inscor__RO_Issue__c zeroRoIssue = [SELECT Id, Name FROM inscor__RO_Issue__c WHERE Id =: roIssues[0].Id];

        System.assert(String.isNotBlank(zeroRoIssue.Id));
        System.assert(String.isNotBlank(zeroRoIssue.Name));
        System.assert(transactions[0].RO_Issue_Id__c == zeroRoIssue.Id);
        System.assert(transactions[0].RO_Issue_Name__c == zeroRoIssue.Name);

        transactions[0].RO_Issue_Id__c = null;
        transactions[0].RO_Issue_Name__c = null;
        update transactions[0];

        transactions = [
                SELECT Id, RO_Issue_Id__c, RO_Issue_Name__c, RO_Issue__c
                FROM AcctSeed__Transaction__c
                WHERE AcctSeed__Journal_Entry_Line__r.AcctSeed__Journal_Entry__c =: journalEntries[0].Id
        ];
        System.assert(String.isBlank(transactions[0].RO_Issue_Id__c));
        System.assert(String.isBlank(transactions[0].RO_Issue_Name__c));

        Test.startTest();
        Database.executeBatch(new TransactionUpdatingBatch());
        Test.stopTest();

        transactions = [
                SELECT Id, RO_Issue_Id__c, RO_Issue_Name__c, RO_Issue__c
                FROM AcctSeed__Transaction__c
                WHERE AcctSeed__Journal_Entry_Line__r.AcctSeed__Journal_Entry__c =: journalEntries[0].Id
        ];
        System.assert(transactions[0].RO_Issue_Id__c == zeroRoIssue.Id);
        System.assert(transactions[0].RO_Issue_Name__c == zeroRoIssue.Name);
    }
}