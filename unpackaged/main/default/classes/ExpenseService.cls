public with sharing class ExpenseService {
    public void InsertAccountingExpense(List<salestrip__Expense__c> listOfExpense) {
        set<Id> setOfOwnerId = new set<Id>();
        set<String> setOfGLId = new set<String>();
        list<sObjectWrapper> listOfsObjectWrapper = new list<sObjectWrapper>();
        map<String , AcctSeed__GL_Account__c> mapOfGLAcc = new map<String , AcctSeed__GL_Account__c>();
        map<String , list<salestrip__Expense__c>> mapOfExpense = new map<String , list<salestrip__Expense__c>>();
        map<Id , salestrip__ExportRecord__c> mapOfExpenseReport = new map<Id , salestrip__ExportRecord__c>();
        map<Id , Decimal> mapOfExpenseReportIdTotalAmount = new map<Id , Decimal>();
        set<String> setOfMonthYear = new set<String>(); 
        map<String , AcctSeed__Accounting_Period__c> mapOfAP = new map<String , AcctSeed__Accounting_Period__c>();
        
        for(salestrip__Expense__c exp : listOfExpense) {
            if(mapOfExpense.containsKey(exp.salestrip__ExportRecord__c)) {
                mapOfExpense.get(exp.salestrip__ExportRecord__c).add(exp);
            } else {
                mapOfExpense.put(exp.salestrip__ExportRecord__c , new list<salestrip__Expense__c>{exp});
            }
            setOfMonthYear.add(exp.Year_Month__c);   
        }
        
        for(salestrip__ExportRecord__c er : [Select salestrip__ExpenseExport__c,salestrip__ExpenseExport__r.Name,Name,OwnerId,Id,salestrip__Amount__c,CurrencyIsoCode,salestrip__Contact__c,salestrip__UserName__c From salestrip__ExportRecord__c Where Id IN : mapOfExpense.Keyset()]) {
            mapOfExpenseReport.put(er.Id,er);
        } 
        
        for(AcctSeed__GL_Account__c er : [Select Name From AcctSeed__GL_Account__c]) {
            mapOfGLAcc.put(er.Id,er);    
        }
        
        for(AcctSeed__Accounting_Period__c ap : [SELECT Name FROM AcctSeed__Accounting_Period__c WHERE Name IN : setOfMonthYear AND AcctSeed__Status__c=:'Open']) {
            mapOfAP.put(ap.Name,ap);	
        }
        
        Map<String, Decimal> MapOfCurrencyRates  =  new Map <String, Decimal>();
        for(SObject curr : Database.query('select IsCorporate, IsoCode, DecimalPlaces, ConversionRate from CurrencyType where IsActive = TRUE')) {
            MapOfCurrencyRates.put((String)curr.get('IsoCode'),(Decimal)curr.get('ConversionRate'));
        }
        
        User u = [Select Region__c From User Where Id =:listOfExpense[0].OwnerId];
        AcctSeed__Accounting_Variable__c av = [Select Name From AcctSeed__Accounting_Variable__c Where Name =:u.Region__c];
        AcctSeed__Ledger__c led = [SELECT Name FROM AcctSeed__Ledger__c WHERE Name =:'IRL EirTrade Aviation'][0];
        for(Id erId : mapOfExpenseReport.Keyset()) {
            Decimal tempValue= 0;
            for(salestrip__Expense__c exp : mapOfExpense.get(erId)) {
                tempValue = tempValue + exp.Salestrip__Amount__c;
                mapOfExpenseReportIdTotalAmount.put(erId,tempValue);
            } 
        }
        
        set<String> SetOfNames = new set<String>();
        SetOfNames.add('20201 - Credit Cards IRL');
        SetOfNames.add('20102 - Creditors: Sundry');
        SetOfNames.add('11102 - Purchases VAT');
        map<String , AcctSeed__GL_Account__c> mapOfGLA = new map<String , AcctSeed__GL_Account__c>();
        for(AcctSeed__GL_Account__c er : [Select Name From AcctSeed__GL_Account__c WHERE Name IN : SetOfNames]) {
            if(er.Name != null){
                mapOfGLA.put(er.Name,er);    
            }
        }
        
        for(Id erId : mapOfExpenseReport.Keyset()) {
            sObjectWrapper objWrapper = new sObjectWrapper();
            salestrip__Expense__c tempExp = mapOfExpense.get(erId)[0];
            Decimal ConvertionRate = (MapOfCurrencyRates.ContainsKey(tempExp.currencyISOCode) && 
                                      tempExp.currencyISOCode != UserInFo.getDefaultCurrency() ? MapOfCurrencyRates.get(tempExp.currencyISOCode) : 1);  
            AcctSeed__Journal_Entry__c jlnew = new AcctSeed__Journal_Entry__c();
            jlnew.Name = mapOfExpenseReport.get(erId).salestrip__ExpenseExport__r.Name +' '+tempExp.OwnerName__c;
            jlnew.AcctSeed__Journal_Date__c = system.today();
            jlnew.AcctSeed__Ledger__c = led.Id;
            if(!Test.isRunningTest() && mapOfAP.ContainsKey(tempExp.year_Month__c)) {
                jlnew.AcctSeed__Accounting_Period__c = mapOfAP.get(tempExp.year_Month__c).Id;
            }
            jlnew.currencyISOCode = tempExp.currencyISOCode;
            jlnew.ExportRecord__c = erId;
            objWrapper.JL = jlnew;
            objWrapper.listOfjLines = new list<AcctSeed__Journal_Entry_Line__c>();
          	
            for(salestrip__Expense__c exp : mapOfExpense.get(erId)) {
                Decimal tempAmount = 0.00;
                if(exp.Salestrip__TransactionTaxAmount__c != null) {
                    tempAmount = exp.Salestrip__Amount__c - exp.Salestrip__TransactionTaxAmount__c;
                    AcctSeed__Journal_Entry_Line__c pseexp0 = new AcctSeed__Journal_Entry_Line__c();
                    pseexp0.Expense__c = exp.Id;
                    pseexp0.AcctSeed__Debit__c = exp.Salestrip__TransactionTaxAmount__c;
                    pseexp0.AcctSeed__Date__c = exp.salestrip__Date__c;
                    pseexp0.AcctSeed__GL_Account_Variable_1__c = av.Id;
                    pseexp0.AcctSeed__Reference__c  = exp.salestrip__Description__c;
                    pseexp0.AcctSeed__Employee__c = exp.OwnerId;
                    pseexp0.currencyISOCode = exp.currencyISOCode;
                    pseexp0.AcctSeed__Project__c = exp.project__c;
                    if(mapOfGLA.containsKey('11102 - Purchases VAT')) {
                        pseexp0.AcctSeed__GL_Account__c = mapOfGLA.get('11102 - Purchases VAT').Id;
                    }
                    objWrapper.listOfjLines.add(pseexp0);
                } else {
                    tempAmount = exp.Salestrip__Amount__c;
                }
                
                AcctSeed__Journal_Entry_Line__c pseexp1 = new AcctSeed__Journal_Entry_Line__c();
                pseexp1.Expense__c = exp.Id;
                pseexp1.AcctSeed__Debit__c = tempAmount;
                pseexp1.AcctSeed__Date__c = exp.salestrip__Date__c;
                pseexp1.AcctSeed__GL_Account_Variable_1__c = av.Id;
                pseexp1.AcctSeed__Reference__c  = exp.salestrip__Description__c;
                pseexp1.AcctSeed__Employee__c = exp.OwnerId;
                pseexp1.currencyISOCode = exp.currencyISOCode;
                pseexp1.AcctSeed__Project__c = exp.project__c;
                if(mapOfGLAcc.containsKey(exp.GL_Account__c)) {
                    pseexp1.AcctSeed__GL_Account__c = mapOfGLAcc.get(exp.GL_Account__c).Id;
                }
                objWrapper.listOfjLines.add(pseexp1);
            }
            
            AcctSeed__Journal_Entry_Line__c pseexp2 = new AcctSeed__Journal_Entry_Line__c();
            pseexp2.AcctSeed__Credit__c = mapOfExpenseReportIdTotalAmount.get(erId);
            pseexp2.AcctSeed__GL_Account_Variable_1__c = av.Id;
            if(String.isNotBlank(tempExp.PaymentMethodType__c)) {
                if(tempExp.PaymentMethodType__c.Contains('Corporate Card')) {
                    pseexp2.AcctSeed__GL_Account__c = mapOfGLA.get('20201 - Credit Cards IRL').Id;
                } else {
                    pseexp2.AcctSeed__GL_Account__c = mapOfGLA.get('20102 - Creditors: Sundry').Id;
                }
            }
            pseexp2.currencyISOCode = tempExp.currencyISOCode;
            objWrapper.listOfjLines.add(pseexp2);
            listOfsObjectWrapper.add(objWrapper);
        }
        processDML(listOfsObjectWrapper);
    }
    
    public void processDML(list<sObjectWrapper> listOfsObjectWrapper) {
        Integer iCounter = 0;
        Integer iCounter1 = 0;
        
        list<AcctSeed__Journal_Entry__c> listOfER = new list<AcctSeed__Journal_Entry__c>();   
        list<AcctSeed__Journal_Entry_Line__c> listOfExp = new list<AcctSeed__Journal_Entry_Line__c>();   
        list<ExpenseExportException__c> listOfException = new list<ExpenseExportException__c>(); 
        set<Id> setOfExpIds = new set<Id>();
        set<Id> setOfExpRecordIds = new set<Id>();
        
        for(sObjectWrapper sObjwrap : listOfsObjectWrapper) {
            setOfExpRecordIds.add(sObjwrap.JL.ExportRecord__c);
            if (String.isBlank(sObjwrap.JL.Id)) {
                listOfER.add(sObjwrap.JL);
            }
        }
        
        for(sObjectWrapper sObjwrap : listOfsObjectWrapper) {
            for(AcctSeed__Journal_Entry_Line__c exp : sObjwrap.listOfjLines) {
                setOfExpIds.add(exp.Expense__c);
            }
        }
        
        map<Id,salestrip__ExportRecord__c> mapOfExpenseRecord = new map<Id,salestrip__ExportRecord__c>([SELECT Name,salestrip__ExpenseExport__c FROM 
                                                                                                        salestrip__ExportRecord__c WHERE Id IN:setOfExpRecordIds]);
        
        map<Id,salestrip__Expense__c> mapOfExpense = new map<Id,salestrip__Expense__c>([SELECT Name,salestrip__ExportRecord__c,salestrip__ExportRecord__r.salestrip__ExpenseExport__c FROM 
                                                                                        salestrip__Expense__c WHERE Id IN:setOfExpIds]);
        
        List<Database.UpsertResult> upsertResultsExpenseReport = Database.upsert(listOfER, false);
        
        for(Integer i=0 ; i < upsertResultsExpenseReport.size(); i++) {
            if (!upsertResultsExpenseReport.get(i).isSuccess())
            {
                if (!upsertResultsExpenseReport.get(i).getErrors().isEmpty())
                {
                    for(Database.Error error : upsertResultsExpenseReport.get(i).getErrors()) {
                        ExpenseExportException__c cusLogError = new ExpenseExportException__c();
                        cusLogError.ErrorMessage__c = (mapOfExpenseRecord.ContainsKey(listOfER.get(iCounter1).ExportRecord__c) ? mapOfExpenseRecord.get(listOfER.get(iCounter1).ExportRecord__c).Name +' - '+ error.getMessage() : error.getMessage());
                        cusLogError.ExportRecord__c = listOfER.get(iCounter1).ExportRecord__c;
                        listOfException.add(cusLogError);
                    }
                }
            }
            iCounter1++;
        }
        
        for(sObjectWrapper sObjwrap : listOfsObjectWrapper) {
            for(AcctSeed__Journal_Entry_Line__c exp : sObjwrap.listOfjLines) {
                if(exp.AcctSeed__Journal_Entry__c == null) {
                	exp.AcctSeed__Journal_Entry__c = sObjwrap.JL.Id;
                	listOfExp.add(exp);     
                }
            }
        }
        
        List<Database.UpsertResult> upsertResults = Database.upsert(listOfExp, false);
        set<Id> setOfEXPIdsToUpdate = new set<Id>();
        List<salestrip__Expense__c> listOfExpense = new List<salestrip__Expense__c>();
        
        for(Integer i=0 ; i < upsertResults.size(); i++){
            if (!upsertResults.get(i).isSuccess())
            {
                if (!upsertResults.get(i).getErrors().isEmpty())
                {
                    for(Database.Error error : upsertResults.get(i).getErrors()) {
                        ExpenseExportException__c cusLogError = new ExpenseExportException__c();
                        cusLogError.ErrorMessage__c = (mapOfExpense.ContainsKey(listOfExp.get(iCounter).Expense__c) ? mapOfExpense.get(listOfExp.get(iCounter).Expense__c).Name +' - '+ error.getMessage() : error.getMessage());
                        if(listOfExp.get(iCounter).Expense__c != null) {
                        	cusLogError.ExportRecord__c = mapOfExpense.get(listOfExp.get(iCounter).Expense__c).salestrip__ExportRecord__c;    
                        }
                        listOfException.add(cusLogError);
                        setOfEXPIdsToUpdate.add(listOfExp.get(iCounter).Expense__c);
                    }
                }
            }
            iCounter++;
        }
        
        if (NULL != listOfException && !listOfException.IsEmpty()) { 
            insert listOfException;
        }
        
        if (NULL != setOfEXPIdsToUpdate && !setOfEXPIdsToUpdate.IsEmpty()) { 
            for(Id expId : setOfEXPIdsToUpdate){
                if(expId != null){
                	listOfExpense.add(new salestrip__Expense__c(Id = expId,salestrip__ExportRecord__c = null,salestrip__Status__c = 'Pending Reimbursement'));    
                }
            }
            
            if (NULL != listOfExpense && !listOfExpense.IsEmpty()) { 
                update listOfExpense;
            }
        }
    }
    
    public class sObjectWrapper {
        Public AcctSeed__Journal_Entry__c JL;
        Public list<AcctSeed__Journal_Entry_Line__c > listOfjLines;    
    }
}