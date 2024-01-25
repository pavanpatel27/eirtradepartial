public with sharing class ProdigyTestApexClass {
    public ProdigyTestApexClass() {

    }

    public String ProdigyTestApexClass() {
        return 'My Test';
    }

    //Action Controller Method
    @InvocableMethod(label='Prodigy Test Apex Method')
    public static List<OutputParameters> prodigyTestApexMethod(List<InputParameters> inputs){
        List<OutputParameters> outputs = new List <OutputParameters> ();
        
        for (InputParameters input: inputs){
            OutputParameters output = invoke(input);
            outputs.add(output);
        }
    
        return outputs;
    }

    private static OutputParameters invoke(InputParameters input){
         //Init Output object
         OutputParameters output = new OutputParameters();

         output.message = 'Got it !!';

        return  output;
    }

    //Input Subclass Defention
    public class InputParameters {
        
        @InvocableVariable()
        public String text;
        
    }
    
    //Output Subclass Defention
    public class OutputParameters {
        
        @InvocableVariable()
        public String message ;
    }
    
    public class ProdigyTestApexException extends Exception {}
}