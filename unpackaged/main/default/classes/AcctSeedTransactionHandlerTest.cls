@IsTest
private class AcctSeedTransactionHandlerTest {
    @IsTest
    static void testBehavior() {
        AcctSeed.TestService.setupTestData(true, true, true);

        List<AcctSeed__Accounting_Period__c> accountingPeriods = [
                SELECT Id, AcctSeed__Start_Date__c, AcctSeed__End_Date__c
                FROM AcctSeed__Accounting_Period__c
                LIMIT 1
        ];

        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];

        List<AcctSeed__Billing_Format__c> billingFormats = [SELECT Id FROM AcctSeed__Billing_Format__c LIMIT 1];

        List<AcctSeed__Billing__c> billings = new List<AcctSeed__Billing__c>{
                new AcctSeed__Billing__c(
                        AcctSeed__Billing_Cycle_Start_Date__c = accountingPeriods[0].AcctSeed__Start_Date__c,
                        AcctSeed__Billing_Cycle_End_Date__c = accountingPeriods[0].AcctSeed__End_Date__c + 3,
                        AcctSeed__Date__c = accountingPeriods[0].AcctSeed__Start_Date__c,
                        AcctSeed__Customer__c = accounts[0].Id,
                        AcctSeed__Status__c = 'Approved',
                        AcctSeed__Accounting_Period__c = accountingPeriods[0].Id,
                        AcctSeed__Billing_Format__c = billingFormats[0].Id,
                        AcctSeed__Due_Date2__c = System.today() + 30,
                        AcctSeed__Billing_Street__c = '999 Billing Street',
                        AcctSeed__Billing_City__c = 'BillingCity',
                        AcctSeed__Billing_State__c = 'CA',
                        AcctSeed__Billing_Country__c = 'US',
                        AcctSeed__Billing_PostalCode__c = '94104',
                        AcctSeed__Shipping_Street__c = '888 Shipping Street',
                        AcctSeed__Shipping_City__c = 'ShippingCity',
                        AcctSeed__Shipping_State__c = 'CA',
                        AcctSeed__Shipping_Country__c = 'US',
                        AcctSeed__Shipping_PostalCode__c = '90100',
                        Owner_Code_Project__c = 'test'
                )
        };
        insert billings;

        List<AcctSeed__GL_Account__c> revenueGlAccounts = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Name = '4000-Product Revenue'];

        List<AcctSeed__Billing_Line__c> billingLines = new List<AcctSeed__Billing_Line__c>{
                new AcctSeed__Billing_Line__c(
                        AcctSeed__Billing__c = billings[0].Id,
                        AcctSeed__Date__c = accountingPeriods[0].AcctSeed__Start_Date__c,
                        AcctSeed__Hours_Units__c = 20,
                        AcctSeed__Rate__c = 10,
                        AcctSeed__Revenue_GL_Account__c = revenueGlAccounts[0].Id
                ),
                new AcctSeed__Billing_Line__c(
                        AcctSeed__Billing__c = billings[0].Id,
                        AcctSeed__Date__c = accountingPeriods[0].AcctSeed__Start_Date__c,
                        AcctSeed__Hours_Units__c = 25,
                        AcctSeed__Rate__c = 10,
                        AcctSeed__Revenue_GL_Account__c = revenueGlAccounts[0].Id
                )
        };
        insert billingLines;

        Test.startTest();
        AcctSeed.BillingPostService.postBillings(billings);
        Test.stopTest();

        List<AcctSeed__Transaction__c> transactions = [
                SELECT Id, Owner_Code_Project__c
                FROM AcctSeed__Transaction__c
                WHERE AcctSeed__Billing__c =: billings[0].Id
        ];
        System.assert(transactions[0].Owner_Code_Project__c == billings[0].Owner_Code_Project__c);

        transactions[0].Owner_Code_Project__c = null;
        update transactions;

        transactions = [
                SELECT Id, Owner_Code_Project__c
                FROM AcctSeed__Transaction__c
                WHERE AcctSeed__Billing__c =: billings[0].Id
        ];
        System.assert(transactions[0].Owner_Code_Project__c != billings[0].Owner_Code_Project__c);

        AcctSeedTransactionHandler.states.add(AcctSeedTransactionHandler.State.REFILL_ADDITIONAL_FIELDS);
        update transactions;

        transactions = [
                SELECT Id, Owner_Code_Project__c
                FROM AcctSeed__Transaction__c
                WHERE AcctSeed__Billing__c =: billings[0].Id
        ];
        System.assert(transactions[0].Owner_Code_Project__c == billings[0].Owner_Code_Project__c);
    }

    @IsTest
    static void testBehavior2() {
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

        Test.startTest();
        AcctSeed.JournalEntryPostService.postJournalEntries(journalEntries);
        Test.stopTest();

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
    }
}