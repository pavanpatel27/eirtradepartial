public with sharing class CustomBillingOutstandingStmntCtrl {
    public String AccountId {get; set;}
    public List<BillingStatementWrapper> Billings{get;set;}
    public Account billingAccount{get;set;}
    public String totalAmount{get;set;}
    public String currentDate{get;set;}
    public String billCurrencyISOCode{get;set;}
    public AcctSeed__Billing_Format__c statementFormat {get;set;}
    public CustomBillingOutstandingStmntCtrl() {
        Billings= new List<BillingStatementWrapper>();
        AccountId=ApexPages.currentPage().getParameters().get('Id'); 
        billCurrencyISOCode = ApexPages.currentPage().getParameters().get('currencyIsoCode'); 
        statementFormat=new AcctSeed__Billing_Format__c();
       
        Decimal totalAmountToCalculate=0;
        billingAccount=new Account();

        statementFormat = [select   AcctSeed__Image__c,
                                    AcctSeed__Company_Name__c,
                                    AcctSeed__Company_Street2__c, 
                                    AcctSeed__Company_City__c,
                                    AcctSeed__Company_State__c,
                                    AcctSeed__Company_PostalCode__c,
                                    AcctSeed__Company_Country__c,
                                    AcctSeed__Custom_Footer_Content__c
                                    from AcctSeed__Billing_Format__c where id=:ApexPages.currentPage().getParameters().get('formatId')];
        currentDate=   DateTime.newInstance(System.Today().year(), System.Today().month(), System.Today().day()).format('MM/dd/yyyy');
        billingAccount=[Select Name,
                               AcctSeed__Alternate_Payee_Name__c,
                               AcctSeed__Billing_Contact__c,
                               Account.AcctSeed__Billing_Contact__r.Name,
                               BillingStreet,
                               BillingCity,
                               BillingState,
                               BillingPostalCode,
                               BillingCountry
                               from Account 
                               where id=:AccountId
                               ];
        for(AcctSeed__Billing__c  billing :[Select 
                                        id,
                                        AcctSeed__Date__c,
                                        AcctSeed__Proprietary_Billing_Number__c,
                                        AcctSeed__Due_Date2__c,
                                        AcctSeed__Total__c,
                                        AcctSeed__Balance__c,
                                        CurrencyIsoCode,
                                        (select 
                                            Id,
                                            AcctSeed__Product__r.Name,
                                            inscoras__Serial_Number__c,
                                            AcctSeed__Hours_Units__c,
                                            AcctSeed__Rate__c,
                                            AcctSeed__Total__c,
                                            Name from AcctSeed__Project_Billing_Lines__r where AcctSeed__Total__c>0) 
                                from AcctSeed__Billing__c  
                                where AcctSeed__Customer__c=:AccountId and AcctSeed__Balance__c >0 and AcctSeed__Balance__c !=null]){
                List<BillingLinesWrapper> billingLineslst= new List<BillingLinesWrapper>();
            for(AcctSeed__Billing_Line__c line : billing.AcctSeed__Project_Billing_Lines__r){
                billingLineslst.add(new BillingLinesWrapper(
                                        line.AcctSeed__Product__r.Name,
                                        line.inscoras__Serial_Number__c,
                                        line.AcctSeed__Hours_Units__c,
                                        line.AcctSeed__Rate__c,
                                        line.AcctSeed__Total__c,
                                        billCurrencyISOCode
                ));
            }
            totalAmountToCalculate = billing.AcctSeed__Total__c + totalAmountToCalculate;
            Billings.add(new BillingStatementWrapper(
                                DateTime.newInstance(billing.AcctSeed__Date__c.year(), billing.AcctSeed__Date__c.month(), billing.AcctSeed__Date__c.day()).format('MM/dd/yyyy'), 
                                billing.AcctSeed__Proprietary_Billing_Number__c, 
                                DateTime.newInstance(billing.AcctSeed__Due_Date2__c.year(), billing.AcctSeed__Due_Date2__c.month(), billing.AcctSeed__Due_Date2__c.day()).format('MM/dd/yyyy'), 
                                billing.AcctSeed__Total__c, 
                                billing.AcctSeed__Balance__c ,
                                billingLineslst,
                                billCurrencyISOCode
            ));
        }
        Util util= new Util();
        if(Billings.size() > 0){
            totalAmount=billCurrencyISOCode + ' '+ Util.formatCurr(totalAmountToCalculate);
        }else{
            totalAmount=billCurrencyISOCode + ' 0.00';
        }
          
    }

    class BillingStatementWrapper  {
        public string billingDate {get;set;}
        public string invoiceNumber{get;set;} 
        public string dueDate{get;set;}
        public String total{get;set;}
        public String balance{get;set;}
        public String billCurrencyISOCode{get;set;}
        public List<BillingLinesWrapper> billingLines{get;set;}
        public BillingStatementWrapper(string billingDate,string invoiceNumber,string dueDate,Decimal total,Decimal balance,List<BillingLinesWrapper> billingLines,String billCurrencyISOCode){
            Util util= new Util();
            this.billingDate=billingDate;
            this.invoiceNumber=invoiceNumber;
            this.dueDate=dueDate;
            this.total=billCurrencyISOCode +' '+ total;
            this.balance=billCurrencyISOCode +' '+balance;
            this.billingLines=billingLines;
            this.billCurrencyISOCode=billCurrencyISOCode;

        }

    }

    class BillingLinesWrapper {
      
        public string productName{get;set;} 
        public string serialNumber{get;set;} 
        public Decimal quantity{get;set;}
        public String unitPrice{get;set;}
        public String total{get;set;}
        public BillingLinesWrapper(string productName,string serialNumber,Decimal quantity,Decimal unitPrice,Decimal total,String billCurrencyISOCode){
            Util util= new Util();
            this.productName=productName;
            this.serialNumber=serialNumber;
            this.quantity=quantity.setScale(2);
            this.unitPrice=billCurrencyISOCode +' '+ unitPrice.setScale(2);
            this.total=billCurrencyISOCode +' '+ total.setScale(2);
        }
    }
    class Util{
        public string formatCurr(Decimal yourInteger)
        {
            string regex = '(\\d)(?=(\\d{3})+(?!\\d))';
            Pattern objPt = Pattern.compile('(\\d)(?=(\\d{3})+(?!\\d))');
            Matcher regexMatcher = objPt.matcher(String.valueOf(yourInteger));
            String formattedCur;
            if(regexMatcher.find()) {
                formattedCur = String.valueOf(yourInteger).replaceAll(regex, '$1,');
            }
            return formattedCur;

        }
    }
}