@IsTest
private class ExpenseServiceTest {

    @IsTest
    static void testJEANDLine() {
        AcctSeed__Billing_Format__c pdfFormat = new AcctSeed__Billing_Format__c();
        pdfFormat.Name = 'Default Billing Service';
        pdfFormat.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
		pdfFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceIrisPdfHLP';
        insert pdfFormat;
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        gl.Name = '10010 - Fifth Third - Checking';
        gl.AcctSeed__Type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Assets';
        insert gl;
        
        AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
        gl1.Name = '20202 - Reimbursable Expenses -Employees';
        gl1.AcctSeed__Type__c = 'Balance Sheet';
        gl1.AcctSeed__Sub_Type_1__c = 'Assets';
        gl1.AcctSeed__Bank__c = true;
        insert gl1;
        
        AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
        gl2.Name = '20201 - Credit Cards IRL';
        gl2.AcctSeed__Type__c = 'Balance Sheet';
        gl2.AcctSeed__Sub_Type_1__c = 'Assets';
        gl2.AcctSeed__Bank__c = true;
        insert gl2;
        
        AcctSeed__Ledger__c led = new AcctSeed__Ledger__c();
        led.Name = 'IRL EirTrade Aviation';
        led.AcctSeed__Type__c = 'Transactional';
        led.AcctSeed__Billing_Activity_Statement_Format__c = pdfFormat.Id;
        led.AcctSeed__Billing_Outstanding_Statement_Format__c = pdfFormat.Id;
        led.AcctSeed__Default_Bank_Account__c = gl1.Id;
        led.AcctSeed__Default_Billing_Format__c = pdfFormat.Id;
        insert led;
        
        AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
        accPeriod.Name = '2022-10';
        accPeriod.AcctSeed__Start_Date__c = System.today()-10;
        accPeriod.AcctSeed__End_Date__c = System.today();
        insert accPeriod;
        
        AcctSeed__Accounting_Variable__c accV = new AcctSeed__Accounting_Variable__c();
        accV.AcctSeed__Type__c = 'GL Account Variable 1';
        accV.Name = 'Core';
        insert accV;
        
        AcctSeed__GL_Account_Mapping__c accGL = new AcctSeed__GL_Account_Mapping__c();
        accGL.AcctSeed__Account_Name__c = 'Questline Inc - xxxx1234';
        accGL.AcctSeed__GL_Account__c = gl.Id;    
        accGL.AcctSeed__External_Id__c = '124';
        insert accGL;
        
		Salestrip__PaymentMethod__c pm = new Salestrip__PaymentMethod__c();
        pm.Name = 'Test';
        pm.Salestrip__Street__c = 'Street';
        pm.Salestrip__CardLast4Digits__c = '1234';
        insert pm;
        
        salestrip__ExportRecord__c er = new salestrip__ExportRecord__c();
        insert er;
        
        User u = new User();
        u.Alias = 'alacato';
        u.Email = 'exampletestuser@alacato.com';
        u.EmailEncodingKey = 'UTF-8';
        u.FirstName = 'Testing';
        u.LastName = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.TimeZoneSidKey = 'Europe/London';
        u.LocaleSidKey = 'en_US';
        u.UserName = 'exampletestuser' + getUniqueNumber() + '@alacato.com';
        u.Street = 'Test Account';
        u.Region__c = 'Core';
        u.PostalCode = 'Test Account';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id;
        insert u;
        
        salestrip__Expense__c exp = new salestrip__Expense__c();
        exp.Salestrip__Amount__c = 100;
        exp.Salestrip__Date__c = system.today();
        exp.Salestrip__Type__c = 'Fuel';
        exp.Salestrip__PaymentMethod__c = pm.Id;
        exp.salestrip__Date__c = System.today();
        exp.salestrip__Description__c = 'Des';
        exp.OwnerId = u.Id;
        insert exp;
        
        system.runAs(u) {
            Test.startTest();
                exp.salestrip__ExportRecord__c = er.Id;
                update exp;
            Test.stopTest();
        }
    }
    
     @IsTest
    static void testExpenseReport() {
         AcctSeed__Billing_Format__c pdfFormat = new AcctSeed__Billing_Format__c();
        pdfFormat.Name = 'Default Billing Service';
        pdfFormat.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
		pdfFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceIrisPdfHLP';
        insert pdfFormat;
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        gl.Name = '10010 - Fifth Third - Checking';
        gl.AcctSeed__Type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Assets';
        insert gl;
        
        AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
        gl1.Name = '20202 - Reimbursable Expenses -Employees';
        gl1.AcctSeed__Type__c = 'Balance Sheet';
        gl1.AcctSeed__Sub_Type_1__c = 'Assets';
        gl1.AcctSeed__Bank__c = true;
        insert gl1;
        
        AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
        gl2.Name = '20201 - Credit Cards IRL';
        gl2.AcctSeed__Type__c = 'Balance Sheet';
        gl2.AcctSeed__Sub_Type_1__c = 'Assets';
        gl2.AcctSeed__Bank__c = true;
        insert gl2;
        
        AcctSeed__Ledger__c led = new AcctSeed__Ledger__c();
        led.Name = 'IRL EirTrade Aviation';
        led.AcctSeed__Type__c = 'Transactional';
        led.AcctSeed__Billing_Activity_Statement_Format__c = pdfFormat.Id;
        led.AcctSeed__Billing_Outstanding_Statement_Format__c = pdfFormat.Id;
        led.AcctSeed__Default_Bank_Account__c = gl1.Id;
        led.AcctSeed__Default_Billing_Format__c = pdfFormat.Id;
        insert led;
        
        AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
        accPeriod.Name = '2022-10';
        accPeriod.AcctSeed__Start_Date__c = System.today()-10;
        accPeriod.AcctSeed__End_Date__c = System.today();
        insert accPeriod;
        
        AcctSeed__Accounting_Variable__c accV = new AcctSeed__Accounting_Variable__c();
        accV.AcctSeed__Type__c = 'GL Account Variable 1';
        accV.Name = 'Core';
        insert accV;
        
        AcctSeed__GL_Account_Mapping__c accGL = new AcctSeed__GL_Account_Mapping__c();
        accGL.AcctSeed__Account_Name__c = 'Questline Inc - xxxx1234';
        accGL.AcctSeed__GL_Account__c = gl.Id;    
        accGL.AcctSeed__External_Id__c = '124';
        insert accGL;
        
		Salestrip__PaymentMethod__c pm = new Salestrip__PaymentMethod__c();
        pm.Name = 'Test';
        pm.Salestrip__Street__c = 'Street';
        pm.Salestrip__CardLast4Digits__c = '1234';
        insert pm;
        
        salestrip__ExportRecord__c er = new salestrip__ExportRecord__c();
        insert er;
        
        User u = new User();
        u.Alias = 'alacato';
        u.Email = 'exampletestuser@alacato.com';
        u.EmailEncodingKey = 'UTF-8';
        u.FirstName = 'Testing';
        u.LastName = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.TimeZoneSidKey = 'Europe/London';
        u.LocaleSidKey = 'en_US';
        u.UserName = 'exampletestuser' + getUniqueNumber() + '@alacato.com';
        u.Street = 'Test Account';
        u.Region__c = 'Core';
        u.PostalCode = 'Test Account';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id;
        insert u;
        
        salestrip__ExpenseReport__c errp = new salestrip__ExpenseReport__c();
        	errp.Name = 'Test';
        insert errp;
        
        salestrip__Expense__c exp = new salestrip__Expense__c();
        exp.salestrip__ExpenseReport__c = errp.Id;
        exp.Salestrip__Amount__c = 100;
        exp.Salestrip__Date__c = system.today();
        exp.Salestrip__Type__c = 'Fuel';
        exp.Salestrip__PaymentMethod__c = pm.Id;
        exp.salestrip__Date__c = System.today();
        exp.salestrip__Description__c = 'Des';
        exp.OwnerId = u.Id;
        insert exp;
    	
        Test.startTest();
			errp.salestrip__Status__c = 'Pending Approval';
        	update errp;
        Test.stopTest();
        
    }
    
    @IsTest
    static void testER() {
        AcctSeed__Billing_Format__c pdfFormat = new AcctSeed__Billing_Format__c();
        pdfFormat.Name = 'Default Billing Service';
        pdfFormat.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
		pdfFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceIrisPdfHLP';
        insert pdfFormat;
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        gl.Name = '10010 - Fifth Third - Checking';
        gl.AcctSeed__Type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Assets';
        insert gl;
        
        AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
        gl1.Name = '20202 - Reimbursable Expenses -Employees';
        gl1.AcctSeed__Type__c = 'Balance Sheet';
        gl1.AcctSeed__Sub_Type_1__c = 'Assets';
        gl1.AcctSeed__Bank__c = true;
        insert gl1;
        
        AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
        gl2.Name = '20201 - Credit Cards IRL';
        gl2.AcctSeed__Type__c = 'Balance Sheet';
        gl2.AcctSeed__Sub_Type_1__c = 'Assets';
        gl2.AcctSeed__Bank__c = true;
        insert gl2;
        
        AcctSeed__Ledger__c led = new AcctSeed__Ledger__c();
        led.Name = 'IRL EirTrade Aviation';
        led.AcctSeed__Type__c = 'Transactional';
        led.AcctSeed__Billing_Activity_Statement_Format__c = pdfFormat.Id;
        led.AcctSeed__Billing_Outstanding_Statement_Format__c = pdfFormat.Id;
        led.AcctSeed__Default_Bank_Account__c = gl1.Id;
        led.AcctSeed__Default_Billing_Format__c = pdfFormat.Id;
        insert led;
        
        AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
        accPeriod.Name = '2022-10';
        accPeriod.AcctSeed__Start_Date__c = System.today()-10;
        accPeriod.AcctSeed__End_Date__c = System.today();
        insert accPeriod;
        
        AcctSeed__Accounting_Variable__c accV = new AcctSeed__Accounting_Variable__c();
        accV.AcctSeed__Type__c = 'GL Account Variable 1';
        accV.Name = 'Core';
        insert accV;
        
        AcctSeed__GL_Account_Mapping__c accGL = new AcctSeed__GL_Account_Mapping__c();
        accGL.AcctSeed__Account_Name__c = 'Questline Inc - xxxx1234';
        accGL.AcctSeed__GL_Account__c = gl.Id;    
        accGL.AcctSeed__External_Id__c = '124';
        insert accGL;
        
		Salestrip__PaymentMethod__c pm = new Salestrip__PaymentMethod__c();
        pm.Name = 'Test';
        pm.Salestrip__Street__c = 'Street';
        pm.Salestrip__CardLast4Digits__c = '1234';
        insert pm;
        
        salestrip__ExpenseReport__c er = new salestrip__ExpenseReport__c();
        er.Name = 'New Report';
        er.Salestrip__Status__c = 'Draft';
        insert er;
        
    	salestrip__Expense__c exp = new salestrip__Expense__c();
        exp.Salestrip__Amount__c = 100;
        exp.Salestrip__Date__c = system.today();
        exp.Salestrip__Type__c = 'Fuel';
        exp.Salestrip__PaymentMethod__c = pm.Id;
        exp.salestrip__ExpenseReport__c = er.Id;
        exp.salestrip__Date__c = System.today();
        exp.salestrip__Description__c = 'Des';
        insert exp;
        
        salestrip__ExportRecord__c err = new salestrip__ExportRecord__c();
        insert err;
        
        User u = new User();
        u.Alias = 'alacato';
        u.Email = 'exampletestuser@alacato.com';
        u.EmailEncodingKey = 'UTF-8';
        u.FirstName = 'Testing';
        u.LastName = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.TimeZoneSidKey = 'Europe/London';
        u.LocaleSidKey = 'en_US';
        u.UserName = 'exampletestuser' + getUniqueNumber() + '@alacato.com';
        u.Street = 'Test Account';
        u.Region__c = 'Core';
        u.PostalCode = 'Test Account';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id;
        insert u;
        system.runAs(u) {
            Test.startTest();
                er.salestrip__Status__c = 'Pending Approval';
                update er;
            Test.stopTest();
        }
    }
    
    private static Integer UNIQUENESS_ITERATOR = 0;
    private static Integer getUniqueNumber() {
        return UNIQUENESS_ITERATOR++;
    }
}