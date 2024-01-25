/*
 * Created by Prodigy Ltd on 30-03-2023.
 *
 * Description: Controller class for proCustomLookupFields LWC.
 *
 * Last modified by Johnny in Prodigy on 30-03-2023.
*/
public class Pro_CustomLookupField_con {
    /*
    * Description: Retrieves Name and Id of record based onject name and search parameters.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    @AuraEnabled
    public static String SearchRecords(String name, String objectApiName){
        string result = '';

        string query = 'SELECT Id, Name FROM ' + objectApiName + ' WHERE Name LIKE \'%' + name + '%\' LIMIT 5';

        List<SObject> objects = Database.query(query);

        if(! objects.isEmpty() ){
            List<Pro_CustomLookupField_con.SearchWrap> wraps = new List<Pro_CustomLookupField_con.SearchWrap>();

            for( SObject o : objects ){
                Pro_CustomLookupField_con.SearchWrap wr = new Pro_CustomLookupField_con.SearchWrap();
                wr.Label = (String)o.get('Name');
                wr.Value = o.Id;

                wraps.add( wr );
            }

            result = JSON.serialize(wraps);
        }

        return result;
    }

    /*
    * Description: Searchs for records with dynamic criteria and search fields for LWC.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    @AuraEnabled
    public static String SearchRecordsDynamic(String searchValue, String objectApiName, String searchFields, String searchCriteria){
        String result = '';

        String query = 'SELECT Id, Name';

        query += ' FROM ' + objectApiName + ' WHERE ';

        String[] fieldsSearched = searchFields.split(',');

        Integer counter = 1;

        if( fieldsSearched.size() > 1 ){ query += '('; }

        for( String s : fieldsSearched ){ 

            if( counter == 1 ){ query += ' (' + s + ' LIKE \'%' + searchValue +'%\')'; }
             

            if( counter > 1 ){ query += ' OR (' + s + ' LIKE \'%' + searchValue +'%\')'; }

            counter++;
        }

        if( fieldsSearched.size() > 1 ){ query += ')'; }

        if( (searchCriteria != null) && (searchCriteria != '') ){ query +=  + ' AND (' + searchCriteria + ')' ; }

        query += ' LIMIT 5';

        List<SObject> objects = Database.query(query);

        if(! objects.isEmpty() ){
            List<Pro_CustomLookupField_con.SearchWrap> wraps = new List<Pro_CustomLookupField_con.SearchWrap>();

            for( SObject o : objects ){
                Pro_CustomLookupField_con.SearchWrap wr = new Pro_CustomLookupField_con.SearchWrap();
                wr.Label = (String)o.get('Name');
                wr.Value = o.Id;

                wraps.add( wr );
            }

            result = JSON.serialize(wraps);
        }

        return result;
    }

    /*
    * Description: Wrapper class for returning Id and Name of records searched.
    *
    * Last modified by Johnny in Prodigy on 30-03-2023.
    */
    @testvisible
    class SearchWrap{
        public String Value { get; set; }
        public String Label { get; set; }
    }
}