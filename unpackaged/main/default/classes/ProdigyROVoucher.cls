/*
Mahmoud Diab - 14 Dec 2023
Trigger Accounting Seed RO Voucher Action per Line via Line matching criteria
*/


public with sharing class ProdigyROVoucher {

    //Action Controller Method
    @InvocableMethod(label='Do RO Voucher [Prodigy]')
    public static List<OutputParameters> doRoVoucher(List<InputParameters> inputs){
        List<OutputParameters> outputs = new List <OutputParameters> ();
        
        for (InputParameters input: inputs){
            OutputParameters output = invoke(input);
            outputs.add(output);
        }
    
        return outputs;
    }

    //Action Main Method
    private static OutputParameters invoke(InputParameters input){
        //Init Output object
        OutputParameters output = new OutputParameters();
        try {
            //Build Debug Message - TODO Enable/Disable Debugging Message
            output.message = input.repairOrder.name + ':' + input.repairOrder.id;
            
            List<inscor.VoucherPostService.LineDetails> rolwrp = new List<inscor.VoucherPostService.LineDetails>();
            
            //Create RO Voucher Lines
            for (inscor__Repair_Order_Line__c repairOrderLine: input.repairOrderLines){
                
                //Verifiy Matched RO Line via following criteria, Match [RO, Partnumber, Status:Recived, Cost]
                String roLinesQuery = 'SELECT Id FROM inscor__Repair_Order_Line__c WHERE '
                + '( inscor__Status__c = \'Received\' AND  inscor__Repair_Order__c = \''+ input.repairOrder.id +'\' AND inscor__Original_Product__c =\''+repairOrderLine.inscor__Original_Product__c+'\' AND inscor__Final_Unit_Repair_Cost__c = '+repairOrderLine.inscor__Final_Unit_Repair_Cost__c+')';
                output.message = output.message + '@' + roLinesQuery + '@';
                List<inscor__Repair_Order_Line__c> sobjList = Database.query(roLinesQuery);
                output.message = output.message + sobjList.size();
                
                //Create if There is matches
                if (sobjList.size() > 0){
                     output.message = output.message + ':' + sobjList[0].Id;
                    inscor.VoucherPostService.LineDetails wrp = new inscor.VoucherPostService.LineDetails(sobjList[0].Id, repairOrderLine.inscor__Quantity_Received__c, null);
                    rolwrp.add(wrp);
                }
            }
            
            //No Match
            if(rolwrp.size() < 1){
                throw new ProdigyROVoucherException('No RO Lines Matches criteria');
            
            }    
        
            String invcDateString = input.invcDate.year()+ '-'+input.invcDate.month()+ '-'+input.invcDate.day();
            String dueDateString = input.dueDate.year()+ '-'+input.dueDate.month()+ '-'+input.dueDate.day();
             
            output.message = output.message + '&invcNumber='+input.invcNumber+ '&invcDate='+invcDateString+ '&invcDate='+dueDateString ;
            inscor.VoucherPostService.voucherROSelectedLine(input.repairOrder.Id, input.invcNumber, invcDateString , dueDateString , rolwrp, null);
            output.message = output.message + ' <br> (Done!)';
        }catch(Exception e){
            output.message = output.message +'-Error- *'+ e.getMessage()+'*';
            output.error = e.getMessage();
            output.isFailed = true;
            
        }
        
         return output;
    }
    
    //Input Subclass Defention
    public class InputParameters {
        
        @InvocableVariable(required=true)
        public inscor__Repair_Order__c repairOrder;
        
        @InvocableVariable(required=true)
        public List<inscor__Repair_Order_Line__c> repairOrderLines;
        
        @InvocableVariable(required=true)
        public String invcNumber;
        
        @InvocableVariable(required=true)
        public Date invcDate;
        
        @InvocableVariable(required=true)
        public Date dueDate;
        
    }
    
    //Output Subclass Defention
    public class OutputParameters {
        
        @InvocableVariable()
        public String message ;
        
        @InvocableVariable()
        public String error ;
        
        @InvocableVariable()
        public Boolean isFailed;
    
    }
    
    public class ProdigyROVoucherException extends Exception {}

}