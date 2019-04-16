/*************************************************************
 * The class acts as a controller for the Lightning Component
 * to display tags on a contact based on their selected values
 * History
 * ------------------------------------------------------------------------
 * VERSION     AUTHOR                    DATE         DETAIL
 * 1.0      ING Volunteering Team   5/12/2018    Initial implementation
 * 2.0      SFDO SPRINT AMSTERDAM   April 4, 2019    Adaption for NPSP
 *************************************************************/
public class SkillVisualisation {
  //This method is used to fetch the tags from metadata and prepare them to display in the component
    @AuraEnabled
    public static Tags  Get_Tags(String recID,String currentObject){
        String Queryfields = ''; 
        list<Visualiser_Tag__mdt> selectedfields = new list<Visualiser_Tag__mdt>();
        Map<string,list<string>> Tags2Display = new Map<string,list<string>>();
        map<string,list<Visualiser_Tag__mdt>> MAP_ObjTags = new map<string,list<Visualiser_Tag__mdt>>();
    map<string,Visualiser_Tag__mdt> MAP_MainTags = new map<string,Visualiser_Tag__mdt>();
        map<string,list<Visualiser_Tag__mdt>> MAP_SubTags = new map<string,list<Visualiser_Tag__mdt>>();
        Tags collectedtags = new Tags();
        
        //Iterating through all metadata recors of the object type from component
        for(Visualiser_Tag__mdt tag: [select Color_Code__c,Field_API_Name__c,Field_Type__c,SObject__c,Type__c,DeveloperName,MasterLabel,Related_tag__c from Visualiser_Tag__mdt where SObject__c=: currentObject]){
            //If its a main tag, preparing map of the tag and its developername(Duo Tag Name)
            if(tag.Type__c == 'Category'){
                MAP_MainTags.put(tag.DeveloperName,tag);
            }
            //If its a sub tag
            else if(tag.Type__c == 'Sub Category'){
                //If the field API name is available add it to the Query string
                if(tag.Field_API_Name__c != '' && tag.Field_API_Name__c!= null){
                    Queryfields += tag.Field_API_Name__c + ' , ';
                    selectedfields.add(tag);
                }
                //If the map already contains the main tag(Related tag)
                if(MAP_SubTags.containskey(tag.Related_tag__c)){
                    //the list of sub tags for the main tag is collected in a list
                    list<Visualiser_Tag__mdt> subtags = MAP_SubTags.get(tag.Related_tag__c);
                    //the current record is added in the list
                    subtags.add(tag);
                    //adding the new list to the map of the existing main tag
                    MAP_SubTags.put(tag.Related_tag__c,subtags);
                }
                //If the map doesnot have the main tag(Related tag) of the current record
                else{
                    MAP_SubTags.put(tag.Related_tag__c, new list<Visualiser_Tag__mdt>{ tag });
                }

            }
        }
        
        //if the fields to query are available
        if(Queryfields!=null && Queryfields!=''){
            //remove the last ',' from the query string of fields
            Queryfields = Queryfields.removeEnd(' , ');
            //preparing the query string
            String queryStr = 'Select ' + Queryfields +' from ' + currentObject + ' where ID= \'' + recID +'\'';

            List<MainTag> mtag_List = new List<MainTag>();
            //Queryng the record from dynamic soql
            SObject rec= Database.query(queryStr);
            //Iterarting through the main tags Names from the map keyset
            for(String Mtag: MAP_SubTags.keyset()){
                //Initiating variables as to flush them after every loop of Main Tag
                MainTag mtag_Rec = new MainTag();
                List<SubTag> stag_List = new List<SubTag>();
                //iterating through the subtags from the values of the map
                if(MAP_SubTags.get(Mtag)!=null){
                    for(Visualiser_Tag__mdt Stag: MAP_SubTags.get(Mtag)){
                      //Initiating the subtag variable after every assignment
                        SubTag stag_Rec = new SubTag();
                        //If the Sub tag is selected in the contact then assign the label
                        if((rec.get(Stag.Field_API_Name__c) == true || rec.get(Stag.Field_API_Name__c) <> null) && Stag.MasterLabel!=null){
                            if(stag.Field_Type__c == 'Multiselect Picklist')
                            {
                                
								String[] vals;                                
                                 //vals.addAll(rec.get(Stag.Field_API_Name__c).split(';'));
                            	//stag_List.addAll(rec.get(Stag.Field_API_Name__c));
                            	//stag_Rec.Label = (String)rec.get(Stag.Field_API_Name__c);                               

                            }
                            else if(stag.Field_Type__c == 'Picklist')
                            {
                            	stag_Rec.Label = (String)rec.get(Stag.Field_API_Name__c);                               
                            }else
                            {
                            	stag_Rec.Label = Stag.MasterLabel;
                            
                            }
                                //preparing list of sub tags
                            stag_List.add(stag_Rec);
                        }
                    }
                }
                system.debug(stag_List+'<<<<<<<<<<>>>>>>>>>'+MAP_MainTags);
                //If there are subtags avaialble for the Duo tag then the main tag is created with label and their list of sub tags
                if(stag_List.size()>0 && MAP_MainTags.get(Mtag).MasterLabel!=null && MAP_MainTags.get(Mtag).MasterLabel!=''){
                    mtag_Rec.Label = MAP_MainTags.get(Mtag).MasterLabel;
                    mtag_Rec.STagLst = stag_List;
                    //Preparing list of Main Tags
                    mtag_List.add(mtag_Rec);
                }
            }
            //Assigning the Main Tags to the Tags inner class to return to the component
            collectedtags.MTagLst = mtag_List;
        }
        return collectedtags;
    }
    
    
/**********Inner classes used to pass the values to component in Object structure Starts************/
    public class Tags{
        @AuraEnabled
        public list<MainTag> MTagLst{get;set;}
    }
    public class MainTag{
        @AuraEnabled
        public String Label{get;set;}
        @AuraEnabled
        public list<SubTag> STagLst{get;set;}
    }
    public class SubTag{
        @AuraEnabled
        public String Label{get;set;}
        //Commented as not currently used
        //@AuraEnabled
        //public String ColorCode{get;set;}
    }
/**********Inner classes used to pass the values to component in Object structure Ends************/
    

}