/*
 * Created by Prodigy on 13-04-2023.
 *
 * Description: Data factory used by testing classes.
 *
 * Last modified by Finbar in Prodigy on 26/10/2023.
*/
@isTest
public class Pro_DataFactory_dat {
    
    /*
    * Description: Creates accounts for testing purposes.
    *
    * Last modified by Johnny in Prodigy on 24-05-2023.
    */
    public static void CreateAccounts() {

        Account testingAccount1 = new Account(
            Name = 'Test Supplier Account',
            AcctSeed__Accounting_Active__c = true,
            AcctSeed__Credit_Card_Vendor__c = false,
            AcctSeed__X1099_Vendor__c = false,
            BillingStreet = 'Cavan Digital Hub',
            BillingCity = 'Cavan',
            BillingPostalCode = 'H12 YE04',
            BillingState = 'Cavan',
            BillingCountry = 'Ireland',
            ShippingStreet = 'Cavan Digital Hub',
            ShippingCity = 'Cavan',
            ShippingPostalCode = 'H12 YE04',
            ShippingState = 'Cavan',
            ShippingCountry = 'Ireland',
            pro_Email__c = 'johnny.bredenkamp@weareprodigy.com',
            pro_Remittance_CC_Email__c = 'johnny.bredenkamp@weareprodigy.com',
            pro_Purchase_Order_Email__c = 'johnny.bredenkamp@weareprodigy.com',
            pro_Purchase_Order_CC_Email__c = 'johnny.bredenkamp@weareprodigy.com',
            pro_Invoice_Email__c = 'johnny.bredenkamp@weareprodigy.com',
            pro_Statement_Email_Address__c = 'johnny.bredenkamp@weareprodigy.com'
        );

        insert testingAccount1;

        Account testingAccount2 = new Account(
            Name = 'Test Account',
            AcctSeed__Accounting_Active__c = true,
            AcctSeed__Credit_Card_Vendor__c = false,
            AcctSeed__X1099_Vendor__c = false,
            BillingStreet = 'Cavan Digital Hub',
            BillingCity = 'Cavan',
            BillingPostalCode = 'H12 YE04',
            BillingState = 'Cavan',
            BillingCountry = 'Ireland',
            ShippingStreet = 'Cavan Digital Hub',
            ShippingCity = 'Cavan',
            ShippingPostalCode = 'H12 YE04',
            ShippingState = 'Cavan',
            ShippingCountry = 'Ireland',
            pro_Email__c = 'johnny.bredenkamp@weareprodigy.com',
            pro_Remittance_CC_Email__c = 'johnny.bredenkamp@weareprodigy.com',
            pro_Purchase_Order_Email__c = 'johnny.bredenkamp@weareprodigy.com',
            pro_Purchase_Order_CC_Email__c = 'johnny.bredenkamp@weareprodigy.com',
            pro_Invoice_Email__c = 'johnny.bredenkamp@weareprodigy.com',
            pro_Statement_Email_Address__c = 'johnny.bredenkamp@weareprodigy.com'
        );

        insert testingAccount2;
    }

    /*
    * Description: Creates Contacts for testing purposes. Requires an Account(s)
    *
    * Last modified by Johnny in Prodigy on 22-05-2023.
    */
    public static void CreateContacts() {

        List<Account> testAccounts = [
            SELECT
                Id
            FROM
                Account
        ];

        List<Contact> contactList = new List<Contact>();
        Integer counterVar = 1;

        for (Account currentAccount : testAccounts) {
            
            Contact currentContact = new Contact(
                FirstName = 'Billing',
                LastName = 'Contact ' + String.valueOf(counterVar),
                Phone = '012 345 6789',
                Email = 'test' + String.valueOf(counterVar) + '@gmail.com',
                inscor__Contact_Options__c = 'Receive Invoice',
                AccountId = currentAccount.Id
            );

            contactList.add(currentContact);

            counterVar++;
        }

        insert contactList;
    }

    /*
    * Description: Method used to create Product(s) for testing purposes.
    *
    * Last modified by Johnny in Prodigy on 13-04-2023.
    */
    public static void CreateProducts() {

        AcctSeed__GL_Account__c expenseGL = [
            SELECT
                Id
            FROM
                AcctSeed__GL_Account__c
            WHERE   
                Name = '123456 - Testing Expense Account'
        ];

        AcctSeed__GL_Account__c revenueGL = [
            SELECT
                Id
            FROM
                AcctSeed__GL_Account__c
            WHERE
                Name = '30301 - Other Income'
        ];

        Product2 testProduct1 = new Product2(
            Name = 'Test Product 1',
            AcctSeed__Expense_GL_Account__c = expenseGL.Id,
            AcctSeed__Revenue_GL_Account__c = revenueGL.Id,
            inscor__Keyword__c = 'Test Product'
        );

        insert testProduct1;

        Product2 testProduct2 = new Product2(
            Name = 'Test Product 2',
            AcctSeed__Expense_GL_Account__c = expenseGL.Id,
            AcctSeed__Revenue_GL_Account__c = revenueGL.Id,
            inscor__Keyword__c = 'Test Product'
        );

        insert testProduct2;

        Pricebook2 testPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId()
        );

        update testPricebook;

        insert new PricebookEntry(
            UnitPrice = 0,
            IsActive = true,
            Product2Id = testProduct1.Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );

        insert new PricebookEntry(
            UnitPrice = 0,
            IsActive = true,
            Product2Id = testProduct2.Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );
    }

    /*
    * Description: Method used to create the required Accounting Seed record(s) for testing.
    *
    * Last modified by Johnny in Prodigy on 25-05-2023.
    */
    public static void CreateAcctSeedRecords() {

        //
        // -- SECTION: Billing Formats
        //

        AcctSeed__Billing_Format__c activityStatement = new AcctSeed__Billing_Format__c(
            Name = 'AS Format',
            AcctSeed__Type__c = 'Activity Statement',
            AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF'
        );

        insert activityStatement;

        AcctSeed__Billing_Format__c outstandingStatement = new AcctSeed__Billing_Format__c(
            Name = 'OS Format',
            AcctSeed__Type__c = 'Outstanding Statement',
            AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF'
        );

        insert outstandingStatement;

        AcctSeed__Billing_Format__c billingFormat = new AcctSeed__Billing_Format__c(
            Name = 'Billing Format',
            AcctSeed__Type__c = 'Billing',
            AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF'
        );

        insert billingFormat;

        AcctSeed__Billing_Format__c packingSlip = new AcctSeed__Billing_Format__c(
            Name = 'PS Format',
            AcctSeed__Type__c = 'Packing Slip',
            AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF'
        );

        insert packingSlip;

        AcctSeed__Billing_Format__c purchaseOrder = new AcctSeed__Billing_Format__c(
            Name = 'PO Format',
            AcctSeed__Type__c = 'Purchase Order',
            AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStmtModernPDF',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Image__c = '<p><img src="https://prod-avs-eirtrade--prodigydev.sandbox.file.force.com/servlet/rtaImage?eid=a2N77000000LAAC&amp;feoid=00N5f000005nM35&amp;refid=0EM77000000H0TN" alt="rtaImage.jpg"></img></p>'
        );

        insert purchaseOrder;

        AcctSeed__Billing_Format__c remittanceFormat = new AcctSeed__Billing_Format__c(
            Name = 'Remittance Format',
            AcctSeed__Type__c = 'Activity Statement',
            AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
            AcctSeed__Visualforce_PDF_Page__c = 'Pro_RemittancePDF',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Image__c = '<p><img src="https://prod-avs-eirtrade--prodigydev.sandbox.file.force.com/servlet/rtaImage?eid=a2N77000000LAAC&amp;feoid=00N5f000005nM35&amp;refid=0EM77000000H0TN" alt="rtaImage.jpg"></img></p>'
        );

        insert remittanceFormat;

        //
        // -- General Ledger Accounts
        //

        AcctSeed__GL_Account__c ledgerBankAccount = new AcctSeed__GL_Account__c(
            Name = '10711 - USD AIB Current Account 25125904',
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true,
            AcctSeed__Bank__c = true,
            AcctSeed__Mileage_Account__c = false,
            AcctSeed__Used_in_Expense_Reports__c = false
        );

        insert ledgerBankAccount;

        AcctSeed__GL_Account__c currencyGainLossAccount = new AcctSeed__GL_Account__c(
            AcctSeed__Bank__c = false,
            Name = '51801 - Exchange Rate',
            AcctSeed__Type__c = 'Expense',
            AcctSeed__Sub_Type_2__c = 'SG&A',
            AcctSeed__Sub_Type_1__c = 'Currency Exchange',
            AcctSeed__Active__c = true,
            CurrencyIsoCode = UserInfo.getDefaultCurrency()
        );

        insert currencyGainLossAccount;

        AcctSeed__GL_Account__c currentYearEarning = new AcctSeed__GL_Account__c(
            AcctSeed__Bank__c = false,
            Name = '20901 - Current Year Earnings',
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Owners Equity',
            AcctSeed__Sub_Type_2__c = 'Equity',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert currentYearEarning;

        AcctSeed__GL_Account__c retainedYearEarning = new AcctSeed__GL_Account__c(
            AcctSeed__Bank__c = false,
            Name = '20801 - Retained Earings',
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Owners Equity',
            AcctSeed__Sub_Type_2__c = 'Equity',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert retainedYearEarning;

        AcctSeed__GL_Account__c arControl = new AcctSeed__GL_Account__c(
            AcctSeed__Bank__c = false,
            Name = '10401 - Debtors: General',
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert arControl;

        AcctSeed__GL_Account__c expenseGL = new AcctSeed__GL_Account__c(
            Name = '123456 - Testing Expense Account',
            AcctSeed__Type__c = 'Expense',
            AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
            AcctSeed__Sub_Type_2__c = 'Other Expense',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert expenseGL;

        AcctSeed__GL_Account__c debitGL = new AcctSeed__GL_Account__c(
            Name = '78910 - Testing Debit Account',
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert debitGL;

        AcctSeed__GL_Account__c defaultRevenue = new AcctSeed__GL_Account__c(
            AcctSeed__Bank__c = false,
            Name = '30101 - Consignment Income',
            AcctSeed__Type__c = 'Revenue',
            AcctSeed__Sub_Type_1__c = 'Operating Revenue',
            AcctSeed__Sub_Type_2__c = 'Consignment Income',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert defaultRevenue;

        AcctSeed__GL_Account__c arUnapplied = new AcctSeed__GL_Account__c(
            AcctSeed__Bank__c = false,
            Name = '10911 - Unapplied Cash',
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert arUnapplied;

        AcctSeed__GL_Account__c apControl = new AcctSeed__GL_Account__c(
            AcctSeed__Bank__c = false,
            Name = '20101 - Creditors: General',
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Liabilities',
            AcctSeed__Sub_Type_2__c = 'Current Liabilities',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert apControl;

        AcctSeed__GL_Account__c prepaidExpense = new AcctSeed__GL_Account__c(
            AcctSeed__Bank__c = false,
            Name = '10507 - Prepayment: Cash Disbursements',
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Current Assets',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert prepaidExpense;

        AcctSeed__GL_Account__c otherIncome = new AcctSeed__GL_Account__c(
            AcctSeed__Bank__c = false,
            Name = '30301 - Other Income',
            AcctSeed__Type__c = 'Revenue',
            AcctSeed__Sub_Type_1__c = 'Operating Revenue',
            AcctSeed__Sub_Type_2__c = 'Other Income',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert otherIncome;

        AcctSeed__GL_Account__c otherExpense = new AcctSeed__GL_Account__c(
            AcctSeed__Bank__c = false,
            Name = '40303 - Other Expense',
            AcctSeed__Type__c = 'Expense',
            AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
            AcctSeed__Sub_Type_2__c = 'Other Expense',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Active__c = true
        );

        insert otherExpense;

        //
        // -- SECTION: Ledgers
        //

        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
            Name = 'IRL EirTrade Aviation',
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            AcctSeed__Type__c = 'Transactional',
            AcctSeed__Billing_Activity_Statement_Format__c = activityStatement.Id,
            AcctSeed__Default_Bank_Account__c = ledgerBankAccount.Id,
            AcctSeed__Default_Billing_Format__c = billingFormat.Id,
            AcctSeed__Default_Packing_Slip_Format__c = packingSlip.Id,
            AcctSeed__Default_Purchase_Order_Format__c = purchaseOrder.Id,
            AcctSeed__Billing_Outstanding_Statement_Format__c = outstandingStatement.Id,
            pro_Default_Remittance_PDF__c = remittanceFormat.Id
        );

        insert ledger;

        //
        // -- SECTION: Accounting Period
        //

        Date tempDate = Date.today();

        String tempstring = tempDate.year() + '-' + tempDate.month();
        if(tempString.length() == 6) {

            tempstring = tempDate.year() + '-0' + tempDate.month();
        }

        AcctSeed__Accounting_Period__c accountingPeriod = new AcctSeed__Accounting_Period__c(

            Name = tempstring,
            AcctSeed__Status__c = 'Open',
            AcctSeed__Start_Date__c = tempDate,
            AcctSeed__End_Date__c = tempDate.addMonths(1)
        );

        insert accountingPeriod;

        //
        // -- SECTION: Accounting Settings
        //

        AcctSeed__Accounting_Settings__c accountSettings = new AcctSeed__Accounting_Settings__c(
            AcctSeed__Enable_AP_Period_Sensitive_Aging__c = true,
            AcctSeed__Enable_Billing_Period_Sensitive_Aging__c = true,
            AcctSeed__Currency_Gain_Loss_GL_Account__c = currencyGainLossAccount.Id,
            AcctSeed__Current_Year_Earnings_GL_Account__c = currentYearEarning.Id,
            AcctSeed__Retained_Earnings_GL_Account__c = retainedYearEarning.Id,
            AcctSeed__AR_Control_GL_Account__c = arControl.Id,
            AcctSeed__Revenue_GL_Account__c = defaultRevenue.Id,
            AcctSeed__Unapplied_Cash_GL_Account__c = arUnapplied.Id,
            AcctSeed__AP_Control_GL_Account__c = apControl.Id,
            AcctSeed__Prepaid_Expense_GL_Account__c = prepaidExpense.Id,
            AcctSeed__Default_Credit_GL_Account_Revenue__c = defaultRevenue.Id,
            AcctSeed__Default_Ledger__c = ledger.Id
        );

        insert accountSettings;

        //
        // -- SECTION: Custom Settings
        //

        pro_PCS__c customSetting = new pro_PCS__c(
            pro_Purchase_Order_PDF__c = 'pro_Eirtrade_Purchase_Order',
            pro_Purchase_Order_Visualforce_Page__c = 'Pro_PurchaseOrderPDF',
            pro_Remittance_PDF__c = 'pro_Eirtrade_Remittance',
            pro_Remittance_Visualforce_Page__c = 'Pro_RemittancePDF'
        );

        insert customSetting;
    }

    /*
    * Description: Method used to create Purchase Orders and Line Items for testing purposes. Requires: Account, Ledger, GL Account and Product
    *
    * Last modified by Johnny in Prodigy on 14-04-2023.
    */
    public static void CreatePurchaseOrder() {
        
        Account supplierAccount = [
            SELECT
                Id
            FROM
                Account
            LIMIT
                1
        ];

        AcctSeed__Ledger__c testLedger = [
            SELECT
                Id
            FROM
                AcctSeed__Ledger__c
            LIMIT
                1
        ];

        Product2 testProduct = [
            SELECT
                Id
            FROM
                Product2
            LIMIT
                1
        ];

        pro_Purchase_Order__c testOrder = new pro_Purchase_Order__c(
            pro_Purchase_Order_Date__c = System.today(),
            pro_Supplier_Account__c = supplierAccount.Id,
            pro_Supplier_Email_Address__c = 'Test@email.com',
            pro_Ledger_Picklist__c = 'IRL EirTrade Aviation',
            pro_Status__c = 'Approved',
            pro_Ledger_Lookup__c = testLedger.Id
        );

        AcctSeed__GL_Account__c testGLAccount = [
            SELECT
                Id
            FROM
                AcctSeed__GL_Account__c
            WHERE
                Name = '123456 - Testing Expense Account'
            LIMIT
                1
        ];

        insert testOrder;

        List<pro_Purchase_Order_Line__c> testLines = new List<pro_Purchase_Order_Line__c>();

        for (Integer i = 1; i < 6; i++) {
            
            pro_Purchase_Order_Line__c currentLine = new pro_Purchase_Order_Line__c(
                pro_Purchase_Order__c = testOrder.Id,
                pro_Comment__c = 'Test Comment',
                pro_Product__c = testProduct.Id,
                pro_Expense_GL_Account__c = testGLAccount.Id,
                CurrencyIsoCode = UserInfo.getDefaultCurrency(),
                pro_Unit_Price__c = (100 * i),
                pro_Quantity__c = i 
            );

            testLines.add(currentLine);
        }

        insert testLines;
    }

    /*
    * Description: Creates Account Payable(s) for testing purposes. Requires: Account, Ledger, Product and Accounting Period
    *
    * Last modified by Johnny in Prodigy on 17-04-2023.
    */
    public static void CreateAccountPayables() {

        Account testAccount = [
            SELECT
                Id
            FROM
                Account
            LIMIT
                1
        ];

        AcctSeed__Ledger__c testLedger = [
            SELECT
                Id
            FROM
                AcctSeed__Ledger__c
            LIMIT
                1
        ];

        Product2 testProduct = [
            SELECT
                Id
            FROM
                Product2
            LIMIT
                1
        ];

        AcctSeed__GL_Account__c testGLAccount = [
            SELECT
                Id
            FROM
                AcctSeed__GL_Account__c
            WHERE
                Name = '123456 - Testing Expense Account'
            LIMIT
                1
        ];

        AcctSeed__Accounting_Period__c testPeriod = [
            SELECT
                Id
            FROM
                AcctSeed__Accounting_Period__c
            LIMIT
                1
        ];

        AcctSeed__Account_Payable__c testPayable = new AcctSeed__Account_Payable__c(
            AcctSeed__Vendor__c = testAccount.Id,
            AcctSeed__Ledger__c = testLedger.Id,
            AcctSeed__Accounting_Period__c = testPeriod.Id,
            AcctSeed__Payee_Reference__c = 'Test Payable',
            AcctSeed__Status__c = 'Approved',
            AcctSeed__Payment_Status__c = 'Unpaid',
            CurrencyIsoCode = UserInfo.getDefaultCurrency()
        );

        insert testPayable;

        List<AcctSeed__Account_Payable_Line__c> testLines = new List<AcctSeed__Account_Payable_Line__c>();

        for (Integer i = 1; i < 4; i++) {
            
            testLines.add(new AcctSeed__Account_Payable_Line__c(
                AcctSeed__Account_Payable__c = testPayable.Id,
                AcctSeed__Product__c = testProduct.Id,
                AcctSeed__Quantity__c = i,
                AcctSeed__Unit_Cost__c = (100 * i),
                AcctSeed__Expense_GL_Account__c = testGLAccount.Id
            ));
        }

        insert testLines;
    }

    /*
    * Description: Creates Cash Disbursement Batch(es) and Cash Disbursements for testing. Requires: Accounting Seed Records, Account Payables
    *
    * Last modified by Johnny in Prodigy on 18-04-2023.
    */
    public static void CreateCashDisbursements() {

        AcctSeed__GL_Account__c testBankAccount = [
            SELECT
                Id
            FROM
                AcctSeed__GL_Account__c
            WHERE
                AcctSeed__Bank__c = TRUE
            LIMIT
                1
        ];

        AcctSeed__GL_Account__c testDebitAccount = [
            SELECT
                Id
            FROM
                AcctSeed__GL_Account__c
            WHERE
                Name = '78910 - Testing Debit Account'
            LIMIT
                1
        ];

        AcctSeed__Accounting_Period__c testPeriod = [
            SELECT
                Id
            FROM
                AcctSeed__Accounting_Period__c
            LIMIT
                1
        ];

        AcctSeed__Account_Payable__c testPayable = [
            SELECT
                Id,
                AcctSeed__Balance__c,
                AcctSeed__Ledger__c,
                AcctSeed__Vendor__c
            FROM
                AcctSeed__Account_Payable__c
            LIMIT
                1
        ];

        Date todaysDate = System.today();
        String batchName = Datetime.newInstance(todaysDate, Time.newInstance(0, 0, 0, 0)).format('dd-MM-yyyy'),
            disbursementType = 'Electronic',
            disbursementStatus = 'In Process',
            disbursementPaymentStatus = 'Paid',
            disbursementReference = 'Test Disbursement',
            disbursementSource = 'Manual',
            currencyCode = UserInfo.getDefaultCurrency();

        AcctSeed__Cash_Disbursement_Batch__c disbursementBatch = new AcctSeed__Cash_Disbursement_Batch__c(
            Name = 'Test Batch' + '@' + batchName + '@' + UserInfo.getDefaultCurrency(),
            CurrencyIsoCode = UserInfo.getDefaultCurrency()
        );

        insert disbursementBatch;

        AcctSeed__Cash_Disbursement__c testDisbursement = new AcctSeed__Cash_Disbursement__c(
            AcctSeed__Ledger__c = testPayable.AcctSeed__Ledger__c,
            AcctSeed__Vendor__c = testPayable.AcctSeed__Vendor__c,
            AcctSeed__Cash_Disbursement_Batch__c = disbursementBatch.Id,
            AcctSeed__Amount__c = testPayable.AcctSeed__Balance__c,
            AcctSeed__Disbursement_Date__c = todaysDate,
            AcctSeed__Bank_Account__c = testBankAccount.Id,
            AcctSeed__Type__c = disbursementType,
            AcctSeed__Status__c = disbursementStatus,
            AcctSeed__Payment_Status__c = disbursementPaymentStatus,
            AcctSeed__Reference__c = disbursementReference,
            AcctSeed__Debit_GL_Account__c = testDebitAccount.Id,
            CurrencyIsoCode = currencyCode,
            AcctSeed__Accounting_Period__c = testPeriod.Id,
            AcctSeed__Source__c = disbursementSource
        );

        insert testDisbursement;
    }

    /*
    * Description: Creates Cash Disbursement Batch(es) and Cash Disbursements for testing. Requires: Accounting Seed Records
    *
    * Last modified by Johnny in Prodigy on 23-06-2023.
    */
    public static void CreateCashDisbursementsWithoutPayable() {

        AcctSeed__GL_Account__c testBankAccount = [
            SELECT
                Id
            FROM
                AcctSeed__GL_Account__c
            WHERE
                AcctSeed__Bank__c = TRUE
            LIMIT
                1
        ];

        AcctSeed__GL_Account__c testDebitAccount = [
            SELECT
                Id
            FROM
                AcctSeed__GL_Account__c
            WHERE
                Name = '78910 - Testing Debit Account'
            LIMIT
                1
        ];

        AcctSeed__Accounting_Period__c testPeriod = [
            SELECT
                Id
            FROM
                AcctSeed__Accounting_Period__c
            LIMIT
                1
        ];

        AcctSeed__Ledger__c testLedger = [
            SELECT
                Id
            FROM
                AcctSeed__Ledger__c
            LIMIT
                1
        ];

        Account testAccount = [
            SELECT
                Id
            FROM
                Account
            LIMIT
                1
        ];

        Date todaysDate = System.today();
        String batchName = Datetime.newInstance(todaysDate, Time.newInstance(0, 0, 0, 0)).format('dd-MM-yyyy'),
            disbursementType = 'Electronic',
            disbursementStatus = 'In Process',
            disbursementPaymentStatus = 'Paid',
            disbursementReference = 'Test Disbursement',
            disbursementSource = 'Manual',
            currencyCode = UserInfo.getDefaultCurrency();

        AcctSeed__Cash_Disbursement_Batch__c disbursementBatch = new AcctSeed__Cash_Disbursement_Batch__c(
            Name = 'Test Batch' + '@' + batchName + '@' + UserInfo.getDefaultCurrency(),
            CurrencyIsoCode = UserInfo.getDefaultCurrency()
        );

        insert disbursementBatch;

        AcctSeed__Cash_Disbursement__c testDisbursement = new AcctSeed__Cash_Disbursement__c(
            AcctSeed__Ledger__c = testLedger.Id,
            AcctSeed__Vendor__c = testAccount.Id,
            AcctSeed__Cash_Disbursement_Batch__c = disbursementBatch.Id,
            AcctSeed__Amount__c = 1000,
            AcctSeed__Disbursement_Date__c = todaysDate,
            AcctSeed__Bank_Account__c = testBankAccount.Id,
            AcctSeed__Type__c = disbursementType,
            AcctSeed__Status__c = disbursementStatus,
            AcctSeed__Payment_Status__c = disbursementPaymentStatus,
            AcctSeed__Reference__c = disbursementReference,
            AcctSeed__Debit_GL_Account__c = testDebitAccount.Id,
            CurrencyIsoCode = currencyCode,
            AcctSeed__Accounting_Period__c = testPeriod.Id,
            AcctSeed__Source__c = disbursementSource
        );

        insert testDisbursement;
    }

    /*
    * Description: Creates Billings and Billing Lines for testing purposes. Requires: Account, GL Account and Ledger
    *
    * Last modified by Johnny in Prodigy on 27-04-2023.
    */
    public static void CreateBillings() {

        Account testAccount1 = [
            SELECT
                Id
            FROM  
                Account
            WHERE
                Name = 'Test Supplier Account'
            LIMIT
                1
        ];

        Account testAccount2 = [
            SELECT
                Id
            FROM
                Account
            WHERE
                Name = 'Test Account'
            LIMIT
                1
        ];

        AcctSeed__Ledger__c testLedger = [
            SELECT
                Id
            FROM
                AcctSeed__Ledger__c
            LIMIT
                1
        ];

        AcctSeed__Accounting_Period__c testPeriod = [
            SELECT
                Id
            FROM
                AcctSeed__Accounting_Period__c
            LIMIT
                1
        ];

        AcctSeed__Billing_Format__c testFormat = [
            SELECT
                Id
            FROM
                AcctSeed__Billing_Format__c
            WHERE
                AcctSeed__Type__c = 'Billing'
            LIMIT
                1
        ];

        AcctSeed__GL_Account__c testGLAccount = [
            SELECT
                Id
            FROM
                AcctSeed__GL_Account__c
            WHERE
                Name = '30101 - Consignment Income'
            LIMIT
                1
        ];

        AcctSeed__Billing__c testBilling = new AcctSeed__Billing__c(
            AcctSeed__Customer__c = testAccount1.Id,
            AcctSeed__Ledger__c = testLedger.Id,
            AcctSeed__Accounting_Period__c = testPeriod.Id,
            AcctSeed__Billing_Format__c = testFormat.Id
        );

        insert testBilling;

        List<AcctSeed__Billing_Line__c> testLines = new List<AcctSeed__Billing_Line__c>();

        for (Integer i = 1; i < 3; i++) {
            
            AcctSeed__Billing_Line__c testLine = new AcctSeed__Billing_Line__c(
                AcctSeed__Billing__c = testBilling.Id,
                AcctSeed__Date__c = System.today(),
                AcctSeed__Hours_Units__c = 1,
                AcctSeed__Rate__c = i * 100,
                AcctSeed__Revenue_GL_Account__c = testGLAccount.Id
            );

            testLines.add(testLine);
        }

        insert testLines;

        AcctSeed__Billing__c testBilling2 = new AcctSeed__Billing__c(
            AcctSeed__Customer__c = testAccount2.Id,
            AcctSeed__Ledger__c = testLedger.Id,
            AcctSeed__Accounting_Period__c = testPeriod.Id,
            AcctSeed__Billing_Format__c = testFormat.Id
        );

        insert testBilling2;

        List<AcctSeed__Billing_Line__c> testLines2 = new List<AcctSeed__Billing_Line__c>();

        for (Integer i = 1; i < 3; i++) {
            
            AcctSeed__Billing_Line__c testLine = new AcctSeed__Billing_Line__c(
                AcctSeed__Billing__c = testBilling.Id,
                AcctSeed__Date__c = System.today(),
                AcctSeed__Hours_Units__c = 1,
                AcctSeed__Rate__c = i * 100,
                AcctSeed__Revenue_GL_Account__c = testGLAccount.Id
            );

            testLines2.add(testLine);
        }

        insert testLines2;
    }

    /*
    * Description: Creates the AvSight Company record required for testing purposes.
    *
    * Last modified by Johnny in Prodigy on 30-05-2023.
    */
    public static void CreateAvSightCompany() {

        inscor__Company__c testCompany = new inscor__Company__c(
            inscor__Company_Name__c = 'CID-1',
            inscor__Address_1__c = 'Cavan Digital Hub',
            inscor__City__c = 'Cavan',
            inscor__State__c = 'CN',
            inscor__Zip_Code__c = 'H12 YE04',
            inscor__Country__c = 'Ireland',
            inscor__Phone_Number__c = '+353 49 489 1238',
            inscor__Website__c = 'https://weareprodigy.com',
            inscor__Cert_Status__c = 'Surplus Parts Supplier',
            inscor__VAT_Tax_ID__c = 'IE 1234567J',
            inscor__CQ_Tax__c = true,
            inscor__SO_Tax__c = true,
            inscor__SO_Tracking_Default_Enabled__c = true,
            inscor__Show_Receiving_Barcode_Feature__c = true,
            inscor__Receiving_TechData_Fields__c = 'inscor__Time_Limit__c,inscor__Cycle_Limit__c,inscor__Time_Remaining__c,inscor__Cycles_Remaining__c,inscor__Tag_Agency__c,inscor__Tag_Date__c,inscor__Tag_Reference__c,inscor__Tag_Agency_2__c,inscor__Tag_Date_2__c,inscor__Trace__c,inscor__Source__c,inscor__Source_2__c,inscor__Sub_Location__c,inscor__Batch_LOT__c,inscor__Manufacture_Date__c,inscor__Tags__c,inscor__Protected_Reason__c,inscor__Protected__c,inscor__Comments__c,inscor__ESN_Text__c,inscor__Expiration_Date__c,inscor__Purchase_Order__c,inscor__Repair_Order__c,inscor__RMA__c,inscor__MFR_Code__c,inscor__Country_of_Origin__c,MSN__c,inscor__TSN__c,inscor__CSN__c,Moment_Weight__c,inscor__Warehouse__c,inscor__Location__c',
            inscor__Use_Conversion_Tag_Agency_on_Certs__c = true,
            inscor__Admin_Email__c = 'sfadmin@weareprodigy.com',
            inscor__Show_PN_Comments_on_PR__c = true,
            inscor__Include_Secondary_in_PR_Summary__c = true,
            inscor__Invoice_Auto_Send_Time__c = Time.newInstance(13, 45, 0, 0),
            inscor__Nightly_Data_Load__c = 'ILS_Automatic',
            inscor__ILS_Client_ID__c = 'BUK7',
            inscor__ILS_Include_Alternates__c = true,
            inscor__ILS_RFQ_Pull_Schedule__c = 'Every 15 Min',
            inscor__Load_Open_POs__c = true,
            inscor__ILS_Schedule__c = 'Nightly',
            inscor__Price_Held_Firm_Time__c = 10,
            inscor__Account_Default_CQ_Approved__c = true,
            inscor__Account_Default_RFQ_Approved__c = true,
            inscor__Exchange_Part_Writedown__c = 0.00
        );

        insert testCompany;
    }

    /*
    * Description: Creates the AvSight Manufacturer record(s) for testing purposes.
    *
    * Last modified by Johnny in Prodigy on 30-05-2023.
    */
    public static void CreateAvSightManufacturerCode() {

        inscor__Manufacturer_Code__c testManufacturerCode = new inscor__Manufacturer_Code__c(
            Name = 'Test Manufacturer Code',
            inscor__CAGE_Code__c = 'TMC',
            CurrencyIsoCode = UserInfo.getDefaultCurrency()
        );

        insert testManufacturerCode;

        inscor__Manufacturer_Code__c naManufacturerCode = new inscor__Manufacturer_Code__c(
            Name = 'N/A',
            CurrencyIsoCode = UserInfo.getDefaultCurrency()
        );

        insert naManufacturerCode;
    }

    /*
    * Description: Creates an AvSight Sales Order required for testing purposes. Requires: Account, Contact, Account Terms, Ship Method, Company, Product, Condition code
    *
    * Last modified by Johnny in Prodigy on 30-05-2023.
    */
    public static void CreateAvSightSalesOrder() {

        Account testAccount = [
            SELECT
                Id
            FROM
                Account
            LIMIT
                1
        ];

        inscor__Account_Terms__c testTerms = [
            SELECT
                Id
            FROM
                inscor__Account_Terms__c
            LIMIT
                1
        ];

        Contact testContact = [
            SELECT
                Id
            FROM
                Contact
            WHERE
                AccountId =: testAccount.Id
        ];

        inscor__Ship_Method__c testShipMethod = [
            SELECT
                Id
            FROM
                inscor__Ship_Method__c
            LIMIT   
                1
        ];

        inscor__Company__c testCompany = [
            SELECT
                Id
            FROM
                inscor__Company__c
            WHERE
                Name = 'CID-1'
        ];

        Product2 testProduct = [
            SELECT
                Id
            FROM
                Product2
            LIMIT
                1
        ];

        inscor__Condition_Code__c testConditionCode = [
            SELECT
                Id
            FROM
                inscor__Condition_Code__c
            LIMIT
                1
        ];

        inscor__Sales_Order__c testSalesOrder = new inscor__Sales_Order__c(
            inscor__Customer__c = testAccount.Id,
            inscor__Urgency__c = 'Routine',
            inscor__Customer_PO_Number__c = 'PO-0123456789',
            inscor__Account_Terms__c = testTerms.Id,
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            inscor__Status__c = 'New',
            inscor__Contact__c = testContact.Id,
            inscor__Create_Date__c = System.now(),
            inscor__Ship_Method__c = testShipMethod.Id,
            inscor__Contact_Phone__c = '012 345 6789',
            inscor__Billing_Street__c = 'Cavan Digital Hub',
            inscor__Billing_City__c = 'Cavan',
            inscor__Billing_State__c = 'Cavan',
            inscor__Billing_Postal_Code__c = 'H12 YE04',
            inscor__Billing_Country__c = 'Ireland',
            inscor__Shipping_Street__c = 'Cavan Digital Hub',
            inscor__Shipping_City__c = 'Cavan',
            inscor__Shipping_State__c = 'Cavan',
            inscor__Shipping_Postal_Code__c = 'H12 YE04',
            inscor__Shipping_Country__c = 'Ireland',
            inscor__Company__c = testCompany.Id
        );

        insert testSalesOrder;

        inscor__Sales_Order_Line__c testSalesOrderLine = new inscor__Sales_Order_Line__c(
            inscor__Order_Type__c = 'Outright',
            inscor__Status__c = 'Open',
            inscor__Product__c = testProduct.Id,
            inscor__Condition_Code__c = testConditionCode.Id,
            inscor__Quantity_Ordered__c = 5.0,
            inscor__Price__c = 100.00,
            inscor__Promised_Date__c = System.today().addDays(1),
            inscor__Order__c = testSalesOrder.Id
        );

        insert testSalesOrderLine;
    }

    /*
    * Description: Creates an AvSight Release for testing purposes.
    *
    * Last modified by Johnny in Prodigy on 30-05-2023.
    */
    public static void CreateAvSightRelease() {

        Contact testContact = [
            SELECT
                Id
            FROM
                Contact
            LIMIT
                1
        ];

        inscor__Account_Terms__c testTerms = [
            SELECT
                Id
            FROM
                inscor__Account_Terms__c
            LIMIT   
                1
        ];

        inscor__Ship_Method__c testShipMethod = [
            SELECT
                Id
            FROM
                inscor__Ship_Method__c
            LIMIT
                1
        ];

        inscor__Release__c testRelease = new inscor__Release__c(
            inscor__Release_Type__c = 'Sales Order',
            inscor__Release_Date__c = System.today(),
            inscor__Release_Value__c = 100.00,
            inscor__Account_Terms__c = testTerms.Id,
            inscor__Billing_Contact__c = testContact.Id,
            CurrencyIsoCode = UserInfo.getDefaultCurrency(),
            SO_Contact_Email__c = UserInfo.getUserEmail(),
            Salesperson__c = UserInfo.getUserEmail(),
            inscor__Status__c = 'Released',
            inscor__Requested_Ship_Date__c = System.today().addDays(3),
            inscor__Credit_Status__c = 'On Hold',
            inscor__Ship_Method__c = testShipMethod.Id
        );
    }

    /*
    * Description: Creates an AvSight Company Location for testing purposes. Requires - Resource
    *
    * Last modified by Johnny in Prodigy on 31-05-2023.
    */
    public static void CreateAvSightCompanyLocation() {

        inscor__Company__c testCompany = [
            SELECT
                Id
            FROM
                inscor__Company__c
            LIMIT
                1
        ];

        inscor__Company_Location__c testCompanyLocation = new inscor__Company_Location__c(
            Name = 'Company Location',
            inscor__Shipping_Street_1__c = 'Cavan Digital Hub',
            inscor__Shipping_City__c = 'Cavan',
            inscor__Shipping_Country__c = 'Ireland',
            inscor__Shipping_Zip_Code__c = 'H12 YE04',
            inscor__Company__c = testCompany.Id,
            CurrencyIsoCode = UserInfo.getDefaultCurrency()
        );

        insert testCompanyLocation;
    }

    /*
    * Description: Creates Remote Work Request.
    *
    * Last modified by Finbar in Prodigy on 26/10/2023.
    */
    public static void CreateResource() {
        GlicW__Resource__c resource = new GlicW__Resource__c(
            Name = 'Test User',
            pro_Employee_ID__c = '122345'
        );

        insert resource;
    }

    /*
    * Description: Creates Remote Work Request.
    *
    * Last modified by Finbar in Prodigy on 23/10/2023.
    */
    public static void CreateRemoteWorkRequest() {
        GlicW__Resource__c resource = [
            SELECT
                Id
            FROM
                GlicW__Resource__c
            LIMIT 1
        ];

        Remote_Work_Request__c rwr = new Remote_Work_Request__c(
            pro_Start_Date__c = Date.today(),
            pro_End_Date__c = Date.today().addDays(2),
            pro_Comment__c = 'This is a test comment',
            pro_Status__c = 'Approved',
            pro_Employee_Remote_Request__c = resource.Id
        );

        insert rwr;
    }

    /*
    * Description: Creates Rebate & Rebate Rates. - Requires Account
    *
    * Last modified by Finbar in Prodigy on 12/12/2023.
    */
    public static void CreateRebate() {
        Account account = [
            SELECT
                Id
            FROM
                Account
            LIMIT 1
        ];

        pro_Rebate__c rebate = new pro_Rebate__c(
            pro_Account__c = account.Id,    
            pro_Start_Date__c = Date.today(),
            pro_End_Date__c = Date.today().addDays(364)
        );
        insert rebate;

        pro_Rebate_Rate__c rebateRate = new pro_Rebate_Rate__c(
            pro_Rebate__c = rebate.Id,
            pro_Range_Start__c = 0,
            pro_Range_End__c = 10000,
            pro_Rebate_Percent__c = 5

        );
        insert rebateRate;
    }
}