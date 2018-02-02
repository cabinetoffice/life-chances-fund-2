public with sharing class SIB_ApplicationFormExtension {
    public Application__c currApp{get;set;}
    public Map<String, SectionWrapper> sectionWrappers{get;set;}
    public Boolean hasNext{get;set;}
    public Boolean hasPrevious{get;set;}
    public String formSection{get;set;}
    public SObject sObjectToCreate{get;set;}     // Child
    public SObject cOfChildSObjectToCreate{get;set;}     // Child of child
    public Boolean displayQuestionHelpText{get;set;}
    public String additionalSectionToShow{get;set;}
    public Map<Id, String> branchQuestionMap{get;set;}
    public Boolean disable{get;set;}
    public String statusField{get;set;}
    public Integer subPageNumber{get;set;} // Child
    public Integer cOfChildSubPageNumber{get;set;} // Child    
    public Integer pageNumber{get;set;}
    public List<CheckboxWrapper> regionWrapper{get;set;}
    public String formDisplayName{get;set;}
    public Map<String, String> objectNameToFieldQuery{get;set;}
    public Map<String, String> ccObjectNameToFieldQuery{get;set;}
    public Map<Id, List<String>> attachmentMap{get;set;}
    public Integer filecount{get;set;}
    public String uploadSuccess{get;set;}
    public List<String> attachedFiles{get;set;}
    private final Map<String, String> formTypeToStatusField = new Map<String, String>{
        'Expression Of Interest' => 'Status__c',
        'Development Form' => 'Development_Form_Status__c',
        'Financial health and fraud prevention' => 'Identity_Check_Status__c',
        'Full Application' => 'Full_Application_Status__c'
    };
    private final Map<String, String> formTypeToDisplayName = new Map<String, String>{
        'Expression Of Interest' => 'Expression of interest application',
        'Development Form' => 'Development grant',
        'Financial health and fraud prevention' => 'Financial health and fraud prevention',
        'Full Application' => 'Full application'
    };
    public Map<String, List<SObject>> objectNameToRecords {get;set;} // Child
    public Map<String, List<SObject>> cOfChildObjectNameToRecords {get;set;} // Child of child    
    public Map<Id, List<Child_Record_Question__c>> aqtIdToChildQuestions{get;set;}
    public Map<Id, List<Child_of_a_Child_Record_Question__c>> aqtIdToChildOfChildQuestions{get;set;}
    public List<ApplicationQuestionHolder> questionHolders{get;set;}
    // private Integer childOfChildSequence{get;set;}
    private Map<Id, Integer> childofchildSequenceMap{get;set;}
    private Integer primarySequence{get;set;}
    private Integer secondarySequence{get;set;}
    private Id currentChildId{get;set;}
    
    // public Integer var_i{get;set;}

    public SIB_ApplicationFormExtension() {      
       
    }

    public SIB_ApplicationFormExtension(ApexPages.StandardController controller) {
        if(!System.Test.isRunningTest()){
        	controller.addFields(new String[]{'Full_Application_Status__c','Status__c','Contact__c','Application_Window_Template__c','Identity_Check_Status__c','Development_Form_Status__c'});  
        }
        this.currApp = (Application__c)controller.getRecord();
        System.debug('currApp:'+currApp);

    }
    
    public PageReference initialiseData(){
        //Checking first if the user is not logged in, should return to homepage
        SIB_Utilities.checkLoggedInStatus();
        String formType = getParam('formType');
        System.debug('****formType:'+formType);
        //If there is no form type in the URL, we dont know which sections/questions are to display and therefore we can't display anything!
        if(String.isBlank(formType)){
            returnHomePage();
        }
        questionHolders = new List<ApplicationQuestionHolder>();
        objectNameToRecords = new Map<String, List<SObject>>();
        cOfChildObjectNameToRecords = new Map<String, List<SObject>>();
        objectNameToFieldQuery = new Map<String, String>();
        ccObjectNameToFieldQuery = new Map<String, String>();
        aqtIdToChildQuestions = new Map<Id, List<Child_Record_Question__c>>();
        aqtIdToChildOfChildQuestions = new Map<Id, List<Child_Of_a_Child_Record_Question__c>>();
        Map<Id, Application_Answer__c> previouslyAnsweredQuestions = new Map<Id,Application_Answer__c>();
        pageNumber = null;
        subPageNumber = null;
        additionalSectionToShow = '';
        hasNext = false;
        hasPrevious = false;
        displayQuestionHelpText = false;
        // childOfChildSequence = 0;
        clearFormSection();
        currApp = [SELECT Id, Contact__c, Application_Window_Template__c, Application_Window_Template__r.Application_Window__r.End_Date__c, Status__c, Identity_Check_Status__c, Development_Form_Status__c, Full_Application_Status__c FROM Application__c WHERE Id = :getParam('Id')];
        
        formDisplayName = formTypeToDisplayName.get(formType);
        List<Contact> contactRecords = Database.query('SELECT ' + SIB_Utilities.generateDefaultFields(currApp.Application_Window_Template__c) + ' FROM Contact WHERE Id = \'' + currApp.Contact__c + '\'');
        Contact contactToUse = contactRecords[0];
        previouslyAnsweredQuestions = getPreviousAnswers(currApp.Id);
        generateQuestionsAndSections(contactToUse);
        getCurrentApplication();
        // Child
        for(String objectName : objectNameToRecords.keySet()){
            String childObjectName = objectName.replace('__c', 's__r');
            List<SObject> sObjectsToPutInMap = (List<SObject>)currApp.getSObjects(childObjectName);
            objectNameToRecords.put(objectName, sObjectsToPutInMap == null ? new List<SObject>() : sObjectsToPutInMap);
        }
        // Child of child
        for(String cobjectName : cOfChildObjectNameToRecords.keySet()){
            String childObjectName = cobjectName.replace('__c', 's__r');
            List<SObject> sObjectsToPutInMap = (List<SObject>)currApp.getSObjects(childObjectName);
            cOfChildObjectNameToRecords.put(cobjectName, sObjectsToPutInMap == null ? new List<SObject>() : sObjectsToPutInMap);
        }
        
        System.debug('****formType:'+formType);
        System.debug('****objectNameToRecords:'+objectNameToRecords.values());
        System.debug('****cOfChildObjectNameToRecords:'+cOfChildObjectNameToRecords.values());
        
        statusField = formTypeToStatusField.get(formType);
        System.debug('statusField:'+statusField);
        disable = currApp.get(statusField) != 'Draft' && currApp.get(statusField) != '' && currApp.get(statusField) != null; 
        setBranchingMap();
        // Get the sequence numbers for Child of Child records
        childofchildSequenceMap = new Map<Id, Integer>();
        for(List<sObject> sList: cOfChildObjectNameToRecords.values() ){
            for(sObject s: sList){
                Id parentId = (Id)s.get('Primary_Outcome__c');
                if(childofchildSequenceMap.containsKey(parentId)){
                    Integer seq = childofchildSequenceMap.get(parentId);
                    childofchildSequenceMap.put(parentId, seq+1);
                } else{
                    childofchildSequenceMap.put(parentId, 1);
                }
            }
        }
        
        // Get the sequence numbers for primary and secondary outcomes
        if(!System.Test.isRunningTest()){
        primarySequence = 0;
        secondarySequence = 0;
        Boolean isRequired;
        try{
            String s = String.ValueOf(sObjectToCreate.get('IsPrimary__c'));
            isRequired = true;
        }
        catch(exception e){
            isRequired = false;
        }
        if(isRequired){        
            List<SObject> primaryOutcomesList= objectNameToRecords.get('Primary_Outcome__c');
                for(sObject s: primaryOutcomesList){
                    Boolean primary = (Boolean)s.get('IsPrimary__c');
                    if(primary){
                        primarySequence = 1;
                    }
                    else{
                        secondarySequence = secondarySequence +1;
                    }                       
                }
        } 
      }
            
        return null;
    }

    /*
        Method used when on the section summary page. It allows you to go to a specific question (or subpage number).
        It always expects to receive "pageNumber", then if should receive all or none of the following: sObjectNumber, sObjectName & subPageNumber
        These three params allow us to select the right sObject Type, sobject in the list and the correct subpagenumber.
    */

    public void setPageNumber(){
        if(ApexPages.getMessages().size() != 0){
            return;
        }
        setAdditionalSectionToShow('');
        pageNumber = Integer.valueOf(getParam('pageNumber'));
        String sObjectNumber = getParam('sObjectNumber');
        String sObjectName = getParam('sObjectName');
        System.debug('getParam:'+getParam('subPageNumber'));
        // subPageNumber = getParam('subPageNumber')==null||getParam('subPageNumber')==''?0:Integer.valueOf(getParam('subPageNumber'));
        
        System.debug('pageNumber:'+pageNumber);
        System.debug('sObjectNumber:'+sObjectNumber);
        System.debug('sObjectName:'+sObjectName);
        system.debug('objectNameToRecords:'+objectNameToRecords.values());
        if(String.isNotBlank(sObjectName) && String.isNotBlank(sObjectNumber)){
            sObjectToCreate = objectNameToRecords.get(getParam('sObjectName'))[Integer.valueOf(sObjectNumber)];
            subPageNumber = Integer.valueOf(getParam('subPageNumber'));
            System.debug('sObjectToCreate:'+sObjectToCreate);
            // System.debug('subPageNumber:'+subPageNumber);
        }
    }

    public void setSubPageNumber(){
        if(ApexPages.getMessages().size() != 0&&!System.Test.isRunningTest()){
            return;
        }
        setAdditionalSectionToShow('');
        pageNumber = Integer.valueOf(getParam('pageNumber'));
        String sObjectNumber = getParam('sObjectNumber');
        String sObjectName = getParam('sObjectName');
        System.debug('getParam:'+getParam('subPageNumber'));
        // subPageNumber = getParam('subPageNumber')==null||getParam('subPageNumber')==''?0:Integer.valueOf(getParam('subPageNumber'));
        String subSObjectNumber = getParam('subSObjectNumber');
        String subSObjectName = getParam('subSObjectName');
        System.debug('subSObjectNumber:'+getParam('subSObjectNumber'));
        System.debug('subSObjectName:'+getParam('subSObjectName'));
        
        System.debug('pageNumber:'+pageNumber);
        System.debug('sObjectNumber:'+sObjectNumber);
        System.debug('sObjectName:'+sObjectName);
        system.debug('objectNameToRecords:'+objectNameToRecords.values());
        System.debug('cOfChildObjectNameToRecords:'+cOfChildObjectNameToRecords);
        System.debug('cOfChildObjectNameToRecords.values():'+cOfChildObjectNameToRecords.values());
        if(String.isNotBlank(sObjectName) && String.isNotBlank(sObjectNumber)){
            sObjectToCreate = objectNameToRecords.get(getParam('sObjectName'))[Integer.valueOf(sObjectNumber)];
            subPageNumber = Integer.valueOf(getParam('subPageNumber'));
            System.debug('sObjectToCreate:'+sObjectToCreate);
            if(String.isNotBlank(subSObjectName) && String.isNotBlank(subSObjectNumber)){
                cOfChildSObjectToCreate = cOfChildObjectNameToRecords.get(getParam('subSObjectName'))[Integer.valueOf(subSObjectNumber)]; 
                System.debug('cOfChildSObjectToCreate:'+cOfChildSObjectToCreate);
                cOfChildSubPageNumber = 1;          
            }
            System.debug('subPageNumber:'+subPageNumber);
        }
    }

    /*
        Method which is run when a new formSection is selected. This limits the effort done in the back end as these
        questions will not change until the formSection is changed/cleared.
    */
    public List<ApplicationQuestionHolder> getqws(){
        questionHolders = 
            String.isNotBlank(formSection) && sectionWrappers.containsKey(formSection) ? 
            sectionWrappers.get(formSection).aqhMap.values() : 
            new List<ApplicationQuestionHolder>();
        if(questionHolders.size() == 0){
            hasNext = false;
            hasPrevious = false;
            return null;
        }
        hasNext = getHighestPageNumber() > pageNumber;
        hasPrevious = pageNumber > 0;
        return questionHolders;
    }

    /*
        This method returns the highest page number in this section. This is used to display the correct buttons in the VF page.
        Questions are queried from page number low to high, so the last question in the list will always be the highest page number.
    */
    public Integer getHighestPageNumber(){
        Integer size = 
            questionHolders.size() == 0 ? 
            0 : 
            Integer.valueOf(questionHolders[questionHolders.size() - 1].aqt.Application_Question__r.Page_Number_To_Display_On__c);
        return size;
    }

    /*
        This sets the form section to the default "ALL_QUESTIONS" (which overrides and shows all sections).
        It also clears the page number and sets additional section to show as "Section Summary" (which displays the section summary page surprisingly!)
    */
    public void viewAllAnswers(){
        System.debug('In viewAllAnswers');
        formSection = 'ALL_QUESTIONS';
        additionalSectionToShow = 'Section Summary';
        clearPageNumber();
        System.debug('Out of viewAllAnswers');
    }

    /*
        This method is used to toggle the help text. It shows the "Help_Text__c" field for relevant question.
    */
    public void toggleDisplayQuestionHelpText(){
        displayQuestionHelpText = !displayQuestionHelpText;
    }

    /*
        This was one of the hardest methods but has been simplified greatly by the implementation of "Child_Record_Question__c" object.
        It is the method behind the "Back" button on the page. Comments will be added to each branch to explain.
    */
    public PageReference previous(){
        // We need to hide the question help text
        displayQuestionHelpText = false;
        //If on section summary page of "View all answers", clear form section and stop section summary showing
        if(formSection == 'ALL_QUESTIONS'){
            clearFormSection();
            setAdditionalSectionToShow('');
        //On section summary at the end of a section, so stop showing section summary and display last question on list
        } else if(String.isNotBlank(additionalSectionToShow)){
            pageNumber = getHighestPageNumber();
            setAdditionalSectionToShow('');
        //We are in one of the "add another" patterns
        } else if(subPageNumber != null){
            //Go back to previous question if we are after question 1
            if(subPageNumber > 1){
                updateSubPageNumber(-1);
            // Else we are on the first page and the sobject has been created, so go back to the overview page
            } else if(sObjectToCreate != null){
                sObjectToCreate = null;
                subPageNumber = null;
            }
        //If we are not on an "add another pattern", but are in the questions
        }else if(pageNumber != null){
            // If past page 1, then just go to previous number
            if(pageNumber > 1){
                updatePageNumber(-1);
            // else if on first page, clear out page number, which will take you back to the help page for the section
            } else{
                clearPageNumber();
            }
        //We are on the section help page.
        }else if(pageNumber == null){
            clearFormSection();
        }
        return null;
    }

    public class SectionWrapper{
        public String helpText{get;set;}
        public String status{get;set;}
        public Map<Id, ApplicationQuestionHolder> aqhMap{get;set;}
        public SectionWrapper(String helpText, String status){
            this.helpText = helpText;
            this.status = status;
            this.aqhMap = new Map<Id, ApplicationQuestionHolder>();
        }

        public void generateStatus(Application_Answer__c appAnswer){
            status = appAnswer.Marked_as_Complete__c == true ? 'COMPLETED' : (String.isNotBlank(appAnswer.Id) ? 'IN PROGRESS' : status);
        }
    }

    public class ApplicationQuestionHolder{
        public Application_Question_Template__c aqt{get;private set;}
        public Application_Answer__c applicationAnswer{get;set;}
        public Application__c application{get; private set;}
        public String answerSubmitted{get;private set;}
        public Id applicationQuestionId{get;private set;}
        public List<SelectOption> selectOptions{get; private set;}
        public List<String> options{get;private set;}
        public List<CheckboxWrapper> cbws{get;set;}
        public ApplicationQuestionHolder(Application_Question_Template__c aqt, Application_Answer__c applicationAnswer, Application__c application){
            this.aqt = aqt;
            this.application = application;
            this.applicationAnswer = applicationAnswer;
            this.answerSubmitted = applicationAnswer.Response__c;
            this.applicationQuestionId = aqt.Application_Question__c;
            this.selectOptions = doSelectOptions();
            this.options = setUpOptions(this.selectOptions);
            this.cbws = populateCheckboxWrapper();
        }

        public List<SelectOption> doSelectOptions(){
            Map<String, SelectOption> selectOptionsMap = new Map<String, SelectOption>();
            // SIB-135
            if(String.isNotBlank(aqt.Application_Question__r.Picklist_Options__c)){
                for(String picklistOption : aqt.Application_Question__r.Picklist_Options__c.split(';')){
                    if(!selectOptionsMap.containsKey(picklistOption)){
                        selectOptionsMap.put(picklistOption, new SelectOption(picklistOption, picklistOption));
                    }
                }
            }  
            
            if(applicationAnswer != null && String.isNotBlank(applicationAnswer.Picklist_Answer__c)){
                selectOptionsMap.put(applicationAnswer.Picklist_Answer__c, new SelectOption(applicationAnswer.Picklist_Answer__c, applicationAnswer.Picklist_Answer__c));
            }    
            return selectOptionsMap.values();
        }

        public String getFieldsToDisplay(){
            List<String> fieldTypes = new List<String>{
                'Short Text',
                'Long Text',
                'Date',
                'Single Picklist',
                'Multi-Select Picklist',
                'Checkboxes',
                'Email',
                'Phone',
                'Number',
                'Currency',
                'Percent',
                'Radio Select',
                'Single Checkbox',
                'Attachment'
            };
            String returnValues = '';
            if(String.isBlank(aqt.Application_Question__r.Question_Type__c)){
                return returnValues;
            }
            for(String fieldToDisplay : fieldTypes){
                if(aqt.Application_Question__r.Question_Type__c.contains(fieldToDisplay) &&
                (aqt.Application_Question__r.Field_to_Conditionally_Render__c == null || 
                !aqt.Application_Question__r.Field_to_Conditionally_Render__c.contains(fieldToDisplay) ||
                aqt.Application_Question__r.Field_to_Conditionally_Render__c.contains(fieldToDisplay) && applicationAnswer.get(aqt.Application_Question__r.Field_to_Check_for_Rendering__c) == aqt.Application_Question__r.Answer_To_Rerender_On__c)){
                    returnValues += ';' + fieldToDisplay;
                }
            }
            return returnValues;
        }

        public List<String> setUpOptions(List<SelectOption> selectOptions){
            List<String> returnValue = new List<String>();
            for(SelectOption selectOption : selectOptions){
                if(selectOption.getLabel() != ''){
                    returnValue.add(selectOption.getLabel());
                }
            }
            return returnValue;
        }

        public List<CheckBoxWrapper> populateCheckboxWrapper(){
            List<CheckBoxWrapper> checkboxWrappers = new List<CheckBoxWrapper>();
            if(String.isNotBlank(aqt.Application_Question__r.Checkboxes_Options__c)){
                for(String checkboxOption : aqt.Application_Question__r.Checkboxes_Options__c.split(';')){
                    Boolean isPreviouslySelected = 
                        applicationAnswer != null && 
                        String.isNotBlank(applicationAnswer.Checkboxes_Answer__c) &&
                        applicationAnswer.Checkboxes_Answer__c.contains(checkboxOption);
                    checkboxWrappers.add(
                        new CheckboxWrapper(checkboxOption,isPreviouslySelected)
                    );
                }
            }
            return checkboxWrappers;
        }

        public void setAnswerSubmitted(){
            Set<String> answerFields = new Set<String>{
                'Radio_Answer__c', 
                'Checkbox_Answer__c',
                'Text_Answer__c',
                'Picklist_Answer__c',
                'Checkboxes_Answer__c',
                'Short_Text_Answer__c',
                'Multi_Picklist_Answers__c',
                'Date_Answer__c',
                'Email_Answer__c',
                'Percent_Answer__c',
                'Date_Day_Answer__c',
                'Date_Month_Answer__c',
                'Date_Year_Answer__c',
                'Currency_Answer__c',
                'Attachment_Answer__c'
            };
            answerSubmitted = '';
            for(String answerField : answerFields){
                if(String.valueOf(applicationAnswer.get(answerField)) == null || String.valueOf(applicationAnswer.get(answerField)) == '' || String.valueOf(applicationAnswer.get(answerField)) == 'false' || String.valueOf(applicationAnswer.get(answerField)) == 'null'){
                    continue;
                }
                String answerToAdd = String.valueOf(applicationAnswer.get(answerField));
                answerToAdd = answerField == 'Currency_Answer__c' ? ('£' + answerToAdd) : (answerField == 'Date_Day_Answer__c' || answerField == 'Date_Month_Answer__c' ? (answerToAdd + '/') : answerToAdd);
                answerSubmitted += answerField == 'Text_Answer__c' ? '' : ' ' + answerToAdd;
            }
        }
    }

    public class CheckBoxWrapper{
        public String checkBoxName{get;set;}
        public Boolean isSelected{get;set;}

        public CheckBoxWrapper(String checkBoxName, Boolean isSelected){
            this.checkBoxName = checkBoxName;
            this.isSelected = isSelected;
        }
    }

    public String getParam(String paramName){
        String param = ApexPages.currentPage().getParameters().get(paramName);
        return String.isBlank(param) ? '' : EncodingUtil.urlDecode(param, 'UTF-8');
    }

    public void addMesssageToPage(ApexPages.Severity severity, String errorToAdd){
        ApexPages.addMessage(new ApexPages.Message(severity, errorToAdd));
    }

    public void setFormSection(){
        clearPageNumber();
        formSection = getParam('formSectionHeader');
        if(formSection == null || formSection == ''){
            setAdditionalSectionToShow('');
            sObjectToCreate = null;
        } else{
            getqws();
        }
    }

    public void clearPageNumber(){
        pageNumber = null;
    }

    public void clearFormSection(){
        formSection = '';
    }

    private void setBranchingMap(){
        branchQuestionMap = new Map<Id, String>();
        for(Application_Branching_Question__c abq : [
            SELECT Answer__c, Application_Question__c
            FROM Application_Branching_Question__c
            WHERE Template__c = : currApp.Application_Window_Template__c
        ]){
            branchQuestionMap.put(abq.Application_Question__c, abq.Answer__c);
        }
        System.debug('******branchQuestionMap:'+branchQuestionMap.values());
    }

    private void generateQuestionsAndSections(Contact contactToUse){
        aqtIdToChildQuestions = new Map<Id, List<Child_Record_Question__c>>();
        aqtIdToChildOfChildQuestions = new Map<Id, List<Child_Of_a_Child_Record_Question__c>>();
        sectionWrappers = new Map<String, SectionWrapper>();
        Map<Id, Application_Answer__c> previouslyAnsweredQuestions = new Map<Id,Application_Answer__c>();
        previouslyAnsweredQuestions = getPreviousAnswers(currApp.Id);
        System.debug('previouslyAnsweredQuestions:'+previouslyAnsweredQuestions);
        Set<Id> idsWithChildRecordQuestions = new Set<Id>();
        for(Application_Question_Template__c aqt : returnCurrentApplicationQuestionTemplate()){
            System.debug('aqt.Application_Window_Template__r.Id:'+aqt.Application_Window_Template__r.Id);
            Application_Answer__c applicationAnswer;
            String sectionName = aqt.Application_Form_Section__r.Name;
            SectionWrapper sectionWrapper = generateSectionWrapper(sectionName, aqt.Application_Form_Section__r.Help_Text__c);
            
            if(previouslyAnsweredQuestions.containsKey(aqt.Application_Question__r.Id)){
                applicationAnswer = previouslyAnsweredQuestions.get(aqt.Application_Question__r.Id);
            }
            else{
                applicationAnswer = new Application_Answer__c(
                    Application_Question__c = aqt.Application_Question__c,
                    Application__c = currApp.Id,
                    Application_Question_Template__c = aqt.Id
                );
            }
            if(contactToUse != null){
                if(String.isNotBlank(aqt.Application_Question__r.Field_From_Contact_Record__c) && (applicationAnswer.get(aqt.Application_Question__r.Field_To_Set_On_Answer__c) == null)){
                    String fieldName = aqt.Application_Question__r.Field_From_Contact_Record__c;
                    applicationAnswer.put(aqt.Application_Question__r.Field_To_Set_On_Answer__c, contactToUse.get(fieldName));
                }
            }
            ApplicationQuestionHolder aqh = new ApplicationQuestionHolder(aqt, applicationAnswer, currApp);
            System.debug('aqt.Application_Question__r.Id:'+aqt.Application_Question__r.Id);
            System.debug('aqt.Application_Question__r.Object_API_Name__c:'+aqt.Application_Question__r.Object_API_Name__c);
            if(String.isNotBlank(aqt.Application_Question__r.Object_API_Name__c)){
                idsWithChildRecordQuestions.add(aqt.Application_Question__c);
                objectNameToRecords.put(aqt.Application_Question__r.Object_API_Name__c, new List<SObject>{});
            }
            aqh.setAnswerSubmitted();
            sectionWrapper.aqhMap.put(aqt.Id, aqh);
            sectionWrapper.generateStatus(applicationAnswer);
            sectionWrappers.put(sectionName, sectionWrapper);
        }
        System.debug('idsWithChildRecordQuestions:'+idsWithChildRecordQuestions);
        if(!idsWithChildRecordQuestions.isEmpty()){
            for(Child_Record_Question__c crq : [
                SELECT Id, Name, Field_API_Name__c, Question_Number__c, Page_Number_To_Display_On__c, 
                Application_Question__r.Object_API_Name__c, Question__c, Help_Text__c, Application_Question__c,
                Object_API_Name__c, Do_Not_Display_Question__c, Summary_Question_Label__c, Application_Question__r.Child_Header_Question__c,
                Character_Word_Assistance__c, Pages_for_Add_Another__c, Subtext__c, Question_Type__c,
                (Select Child_Record_Question__r.Object_API_Name__c, Child_Record_Question__c, Field_API_Name__c, Help_Text__c, Page_Number_To_Display_On__c, Question__c, Question_Number__c from Child_of_a_Child_Record_Questions__r)
                FROM Child_Record_Question__c
                WHERE Application_Question__c IN : idsWithChildRecordQuestions
                ORDER BY Question_Number__c ASC
            ]){
                if(String.isNotBlank(crq.Object_API_Name__c)){
                    cOfChildObjectNameToRecords.put(crq.Object_API_Name__c, new List<SObject>{});
                }                
                String fieldsToQuery = 
                    objectNameToFieldQuery.containsKey(crq.Application_Question__r.Object_API_Name__c) ? 
                    objectNameToFieldQuery.get(crq.Application_Question__r.Object_API_Name__c) :
                    '';
                String addition = String.isBlank(fieldsToQuery) ? '' : ',' ;
                if(String.IsNotBlank(crq.Field_API_Name__c)){
                	fieldsToQuery += addition + crq.Field_API_Name__c;
                	objectNameToFieldQuery.put(crq.Application_Question__r.Object_API_Name__c, fieldsToQuery);
                }
                List<Child_Record_Question__c> crqs = 
                    aqtIdToChildQuestions.containsKey(crq.Application_Question__c) ?
                    aqtIdToChildQuestions.get(crq.Application_Question__c)
                    : new List<Child_Record_Question__c>();
                crqs.add(crq);
                aqtIdToChildQuestions.put(crq.Application_Question__c, crqs);
                System.debug('aqtIdToChildQuestions:'+aqtIdToChildQuestions);
                
                // Child of a child functionality                
               if(crq.Child_of_a_Child_Record_Questions__r.size()>0){  
            		System.debug('Child of child question:'+crq.Child_of_a_Child_Record_Questions__r[0]);
                    String ccFieldsToQuery = 
                        ccObjectNameToFieldQuery.containsKey(crq.Object_API_Name__c) ? 
                        ccObjectNameToFieldQuery.get(crq.Object_API_Name__c) :
                    '';                    
                    for(Child_Of_a_Child_Record_Question__c ccrq:crq.Child_of_a_Child_Record_Questions__r){

                        String ccAddition = String.isBlank(ccFieldsToQuery) ? '' : ',' ;
                        ccFieldsToQuery += ccAddition + ccrq.Field_API_Name__c;                        
                    }

                	ccObjectNameToFieldQuery.put(crq.Object_API_Name__c, ccFieldsToQuery);                    
                    List<Child_Of_a_Child_Record_Question__c> ccrqs = 
                        aqtIdToChildOfChildQuestions.containsKey(crq.Id) ?
                        aqtIdToChildOfChildQuestions.get(crq.Id)
                        : new List<Child_Of_a_Child_Record_Question__c>();
                    ccrqs.addAll(crq.Child_of_a_Child_Record_Questions__r);
                    aqtIdToChildOfChildQuestions.put(crq.Id, ccrqs);  
                   System.debug('Initialise aqtIdToChildOfChildQuestions:'+aqtIdToChildOfChildQuestions);
                   System.debug('Initialise aqtIdToChildOfChildQuestions values:'+aqtIdToChildOfChildQuestions.values());
                }

                
            }
            System.debug('aqtIdToChildOfChildQuestions:'+aqtIdToChildOfChildQuestions);
            // for(List<Child_Of_a_Child_Record_Question__c> a: aqtIdToChildOfChildQuestions.values()){
            //    aqtIdToChildOfChildQuestionsList.addAll(a);
            // }
        }
    }
    
    public List<ApplicationQuestionHolder> saveCurrentSection(){
        return saveMethod(new Set<String>{formSection});
    }

    public List<ApplicationQuestionHolder> saveMethod(Set<String> formSectionsToSave){
        if(disable){
            addMesssageToPage(ApexPages.Severity.Warning, 'Your application has already been submitted, you cannot edit it now.');
            return new List<ApplicationQuestionHolder>();
        }
        List<ApplicationQuestionHolder> applicationQuestionHolderErrors = new List<ApplicationQuestionHolder>();
        List<Application_Answer__c> applicationAnswersToUpsert = new List<Application_Answer__c>();
        for(String formSectionToSave : formSectionsToSave){
            for(ApplicationQuestionHolder singleApplicationQuestionHolder : sectionWrappers.get(formSectionToSave).aqhMap.values()){
                applicationAnswersToUpsert.add(singleApplicationQuestionHolder.applicationAnswer);
                singleApplicationQuestionHolder.setAnswerSubmitted();
                if(( singleApplicationQuestionHolder.aqt.Application_Question__r.Required__c||singleApplicationQuestionHolder.aqt.Application_Question__r.Is_Branching_Question__c )&& 
                    (String.isBlank(singleApplicationQuestionHolder.answerSubmitted) && String.isBlank(singleApplicationQuestionHolder.applicationAnswer.Text_Answer__c))
                ){
                    applicationQuestionHolderErrors.add(singleApplicationQuestionHolder);
                }
            }
        }
        if(!applicationAnswersToUpsert.isEmpty()){
            upsert applicationAnswersToUpsert;
        }
        System.debug('applicationQuestionHolderErrors:'+applicationQuestionHolderErrors);
        return applicationQuestionHolderErrors;
    }

    public PageReference saveAndSubmit(){
        List<ApplicationQuestionHolder> errorQuestions = saveMethod(sectionWrappers.keySet());
        if(!errorQuestions.isEmpty()){
            for(ApplicationQuestionHolder errorQuestion : errorQuestions){
                addMesssageToPage(ApexPages.Severity.Warning, Label.SIB_Mandatory_Questions_Not_Filled);
                
            }
        }
        System.debug('ApexPages.getMessages():'+ApexPages.getMessages());
        if(ApexPages.getMessages().size() != 0&&!System.Test.isRunningTest()){
            return null;
        }
        System.debug('End Date:'+currApp.Application_Window_Template__r.Application_Window__r.End_Date__c);
        if(currApp.Application_Window_Template__r.Application_Window__r.End_Date__c < System.now()){
            addMesssageToPage(ApexPages.Severity.Warning, 'Application has been saved, but application window has now closed.');
            return null;
        }
        
        // SIB-266
        String currentApplicationStage = getParam('formType');
        if(currentApplicationStage=='Expression Of Interest'||currentApplicationStage=='Full Application'){
            if(currApp.Identity_Check_Status__c != 'Submitted'&&currApp.Identity_Check_Status__c != 'Successful'){
	            addMesssageToPage(ApexPages.Severity.Warning, 'You cannot submit this application form yet because Financial health and fraud prevention form has not been submitted.');    
                return null;
            }
        }
        else if(currentApplicationStage=='Development Form'){
            if(currApp.Status__c != 'Submitted'&&currApp.Status__c != 'Successful'){
	            addMesssageToPage(ApexPages.Severity.Warning, 'You cannot submit this application form yet because Expression of Interest form has not been submitted.'); 
                return null;
            }
            
        }
        // End of SIB-266
        if(currApp.Application_Window_Template__r.Application_Window__r.Is_Live__c){
            currApp.put(statusField, 'Submitted');
            update currApp;
            String message = getParam('formType') == 'Expression of interest' ? 'Application' : 'Development Form';
            addMesssageToPage(ApexPages.Severity.Confirm, message + ' Has Been Submitted');
            disable = true;
            return new PageReference(Page.SIB_ApplicationConfirm.getUrl() + '?formType=' + getParam('formType'));
        } else if(!currApp.Application_Window_Template__r.Application_Window__r.Is_Live__c){
            addMesssageToPage(ApexPages.Severity.Warning, 'You cannot submit this application form yet because the theme to which you are applying has not gone live. Please come back after the theme has gone live and try submitting again.');
        } else if(currApp.Application_Window_Template__r.Application_Window__r.End_Date__c > System.now()){
            addMesssageToPage(ApexPages.Severity.Warning, 'Application has been saved, but cannot be submitted yet as the window is inactive');
        }
        return null;
    }

    public void markSectionAsComplete(){
        List<Application_Answer__c> applicationAnswersToUpsert = new List<Application_Answer__c>();
        List<ApplicationQuestionHolder> errorQuestions = saveCurrentSection();
        if(!errorQuestions.isEmpty()){
            for(ApplicationQuestionHolder errorQuestion : errorQuestions){
                addMesssageToPage(ApexPages.Severity.Warning, 'Please fill out answer for : ' + errorQuestion.aqt.Application_Form_Section__r.Name + ' - ' + errorQuestion.aqt.Application_Question__r.Question__c);        
            }
            return;
        }
        for(ApplicationQuestionHolder singleApplicationQuestionHolder : questionHolders){
            Application_Answer__c appAnswer = singleApplicationQuestionHolder.applicationAnswer;
            appAnswer.Marked_as_Complete__c = true;
            applicationAnswersToUpsert.add(appAnswer);
        }
        upsert applicationAnswersToUpsert;
        sectionWrappers.get(formSection).status = 'COMPLETED';
        clearFormSection();
        clearPageNumber();
        setAdditionalSectionToShow('');
        initialiseData();
    }

    public void saveAndContinue(){
        System.debug('disable:'+disable);
        if(!disable){
            upsertAnswer();
        }
        System.debug('hasNext:'+hasNext);
        if(!hasNext){
            saveAndGoToSummarySection();
            displayQuestionHelpText = false;
        } else{
            sObjectToCreate = null;
            setAdditionalSectionToShow('');
            updatePageNumber(1);
        }
        return;
    }

    public void saveAndGoToSummarySection(){
        hasNext = false;
        setAdditionalSectionToShow('Section Summary');
        clearPageNumber();
    }

    public void saveAndContinueLater(){
        if(cOfChildSObjectToCreate!=null){
            savecOfchildSObject();
        }
        if(!disable){
            upsertAnswer();
        }
        clearPageNumber();
        sObjectToCreate = null;
        clearFormSection();
        setAdditionalSectionToShow('');
        subPageNumber = null;
        cOfChildSubPageNumber = null;
        cOfChildSObjectToCreate = null;
    }

    public void upsertAnswer(){
        if(disable){
            addMesssageToPage(ApexPages.Severity.Warning, 'Your application has already been submitted, you cannot edit it now.');
            return;
        }
        System.debug('upsertAnswer-------------> objectNameToRecords:'+objectNameToRecords.values());
        System.debug('upsertAnswer-------------> branchQuestionMap:'+branchQuestionMap);
        if(branchQuestionMap==null||branchQuestionMap.size()==0){
            setBranchingMap();
        }
        System.debug('branchQuestionMap:------------- '+branchQuestionMap.values());
        SectionWrapper sw = sectionWrappers.get(formSection);
        sw.status = 'IN PROGRESS';
        List<Application_Answer__c> answersToUpsert = new List<Application_Answer__c>();
        Map<Id, ApplicationQuestionHolder> questionHolderMap = sectionWrappers.get(formSection).aqhMap;
        Id branchingQuestionId = null;
        Boolean updateIDCheck = false;
        for(ApplicationQuestionHolder aqh : sectionWrappers.get(formSection).aqhMap.values()){
            if(aqh.aqt.Application_Question__r.Page_Number_To_Display_On__c == pageNumber){
                Id questionId = aqh.aqt.Application_Question__r.Id;
                if(branchQuestionMap.containsKey(questionId)){
                    if(!branchQuestionMap.get(questionId).contains(aqh.answerSubmitted)){
                        branchingQuestionId = questionId;
                    }
                }
                Application_Answer__c answerToUpsert = aqh.applicationAnswer;
                If(aqh.aqt.Application_Question__r.Question__c == Label.SIB_ID_Check_Question){
                   if(answerToUpsert.Radio_Answer__c=='no'){
                       updateIDCheck = true;
                   } 
                   System.debug('aqh.aqt.Application_Question__r.Question__:'+aqh.aqt.Application_Question__r.Question__c);
                }
                String checkBoxesAnswer = '';
                for(CheckBoxWrapper cbw : aqh.cbws){
                    if(cbw.isSelected){
                        checkBoxesAnswer += checkBoxesAnswer == '' ? cbw.checkBoxName : ',' + cbw.checkBoxName;
                    }
                }

                answerToUpsert.Checkboxes_Answer__c = checkBoxesAnswer.replace(',',';');
                if(String.isNotBlank(answerToUpsert.Text_Answer__c) && answerToUpsert.Text_Answer__c.length() > 32768){
                    addMesssageToPage(ApexPages.Severity.Warning, 'You have exceeded the maximum character limit (32,768 char) for this question. Please shorten your answer.');
                    return;
                }
                aqh.setAnswerSubmitted();
                // Validating the email address prior to the upsert
                if(String.isNotBlank(answerToUpsert.Email_Answer__c)&&!SIB_Utilities.isValidEmail(answerToUpsert.Email_Answer__c)){
                    addMesssageToPage(ApexPages.Severity.Warning, 'Please enter valid email address');
                    return;
                }
                answersToUpsert.add(answerToUpsert);
            }
        }
        try{
            upsert answersToUpsert;
            if(updateIDCheck){
                Application__c app = new Application__c(Id=currApp.Id);
                app.Identity_Check_Status__c = 'Draft';
                update app;
            }
        } catch(Exception ex){
            addMesssageToPage(ApexPages.Severity.Warning, ex.getMessage());
        }
        if(currApp.get(statusField) != 'Draft'){
            currApp.put(statusField, 'Draft');
            update currApp;
        }
        System.debug('branchingQuestionId:'+branchingQuestionId);
        
        if(String.isBlank(branchingQuestionId)){
            return;
        }
		
        System.debug('after branchingQuestionId:'+branchingQuestionId);
        System.debug('currApp.Application_Window_Template__r.Application_Window__c:'+currApp.Application_Window_Template__r.Application_Window__c);
        System.debug('currApp.Application_Window_Template__c:'+currApp.Application_Window_Template__c);
        Id awtToUse = null;
        branchQuestionMap = new Map<Id, String>();
        Set<Id> awtsToExclude = new Set<Id>();
        for(Application_Window_Template__c awt : [
            SELECT Id, (
                SELECT Id, Answer__c, Application_Question__c
                FROM Application_Branching_Questions__r
            )
            FROM Application_Window_Template__c
            WHERE Application_Window__c = :currApp.Application_Window_Template__r.Application_Window__c
            // AND Id != :currApp.Application_Window_Template__c
        ]){
            System.debug('awtToUse:'+awtToUse);
            if(awtToUse != null){
                break;
            }
            for (Application_Branching_Question__c abq : awt.Application_Branching_Questions__r){
                String answer = getAnswerFromAQId(abq.Application_Question__c);
                answer = answer.trim();
                System.debug('answer: ' + answer);
                if(!abq.Answer__c.contains(answer) || awtsToExclude.contains(awt.Id)){
                    System.debug('No Matches');
                    awtToUse = null;
                    branchQuestionMap = new Map<Id, String>();
                    awtsToExclude.add(awt.Id);
                } else{
                    awtToUse = awt.Id;
                    branchQuestionMap.put(abq.Application_Question__c, abq.Answer__c);
                }
            }
        }
        if(awtToUse == null){
            return;
        }
        System.debug('update awtToUse:'+awtToUse);
        if(awtToUse!=currApp.Application_Window_Template__c){
            System.debug('In update AWT curr:'+currApp.Application_Window_Template__c);
        	currApp.Application_Window_Template__c = awtToUse;
        	update currApp;
        // generateQuestionsAndSections(null);

            List<Contact> contactRecords = Database.query('SELECT ' + SIB_Utilities.generateDefaultFields(currApp.Application_Window_Template__c) + ' FROM Contact WHERE Id = \'' + currApp.Contact__c + '\'');
            Contact contactToUse = contactRecords[0];
            generateQuestionsAndSections(contactToUse);
        }
            
         
        System.debug('upsertAnswer out-------------> objectNameToRecords:'+objectNameToRecords.values());
    }

    public SectionWrapper generateSectionWrapper(String sectionName, String helpText){
        SectionWrapper sectionWrapper = sectionWrappers.containsKey(sectionName) ? sectionWrappers.get(sectionName): new SectionWrapper(helpText,'');
        return sectionWrapper;
    }

    public String getAnswerFromAQId(Id aqId){
        String answerToReturn = '';
        for(ApplicationQuestionHolder aqh : sectionWrappers.get(formSection).aqhMap.values()){
            if(aqh.aqt.Application_Question__r.Id == aqId){
                answerToReturn = aqh.answerSubmitted;
            }
        }
        return answerToReturn;
    }   

    /*////////////////////////////////////////////////////////////////////////////////////

                                    Query Methods

    ///////////////////////////////////////////////////////////////////////////////////*/

    private void getCurrentApplication(){
        System.debug('objectNameToFieldQuery:'+objectNameToFieldQuery);
        System.debug('objectNameToFieldQuery:'+objectNameToFieldQuery);
        System.debug('ccObjectNameToFieldQuery:'+ccObjectNameToFieldQuery);

        String queryString = 
            'SELECT Id, Application_Window_Template__c, Contact__c, Application_Window_Template__r.Application_Window__r.Is_Live__c, Is_Submitted__c,' + 
            'Last_Answered_Question__c, Application_Window_Template__r.Application_Window__r.Start_Date__c, Development_Form_Status__c, ' + 
            'Application_Window_Template__r.Application_Window__c, Application_Window_Template__r.Application_Window__r.End_Date__c,' + 
            'Dev_Form_External_Status__c, EOI_External_Status__c, Status__c, Identity_Check_Status__c, Full_Application_Status__c'; 
            for(String childObjectName : objectNameToFieldQuery.keySet()){
                String childObjectString = objectNameToFieldQuery.get(childObjectName);
                if(childObjectString==null||childObjectString==''){
                  childObjectString = ' Name';
                }else if(!childObjectString.contains('Name')){
                    childObjectString = childObjectString+', Name';
                }
                System.debug('childObjectString:'+childObjectString);
                queryString += ',(SELECT Id, ' + childObjectString + ' FROM ' + childObjectName.replace('__c', 's__r') + ')';
            }
            for(String ccChildObjectName : ccObjectNameToFieldQuery.keySet()){
                queryString += ',(SELECT Id, ' + ccObjectNameToFieldQuery.get(ccChildObjectName) + ', Name, Primary_Outcome__c FROM ' + ccChildObjectName.replace('__c', 's__r') + ')';
            }        
            queryString += ' FROM Application__c WHERE Id = \'' + getParam('Id') + '\'';
        System.debug('queryString:'+queryString);
        currApp = Database.query(queryString);
        return;
    }

    private Map<Id, Application_Answer__c> getPreviousAnswers(Id applicationId){
        Map<Id, Application_Answer__c> previouslyAnsweredQuestions = new Map<Id,Application_Answer__c>();
        attachmentMap = new Map<Id, List<String>>();
        for(Application_Answer__c singleApplicationAnswer : [
            SELECT Id, Checkbox_Answer__c, Text_Answer__c, Picklist_Answer__c, Application_Question__c, Checkboxes_Answer__c, Short_Text_Answer__c, Multi_Picklist_Answers__c,
            Date_Answer__c, Email_Answer__c, Percent_Answer__c, Response__c, Currency_Answer__c, Marked_as_Complete__c, 
            Date_Day_Answer__c, Date_Month_Answer__c, Date_Year_Answer__c, Radio_Answer__c, Attachment_Answer__c
            FROM Application_Answer__c
            WHERE Application__c = :applicationId
            ORDER BY Application_Question__r.Page_Number_To_Display_On__c ASC
        ]){
            previouslyAnsweredQuestions.put(singleApplicationAnswer.Application_Question__c, singleApplicationAnswer);
            if(!String.isBlank(singleApplicationAnswer.Attachment_Answer__c)){
                    List<String> fileSplit= singleApplicationAnswer.Attachment_Answer__c.split(';\\s*');
                    attachmentMap.put(singleApplicationAnswer.Id, fileSplit);
            }
        }
        return previouslyAnsweredQuestions;
    }

    private List<Application_Question_Template__c> returnCurrentApplicationQuestionTemplate(){
        String queryString = 
            'SELECT Application_Question__r.Id, Application_Question__r.Question_Type__c, Application_Question__r.Required__c,' + 
            ' Application_Question__r.Field_From_Contact_Record__c, Application_Question__r.Field_To_Set_On_Answer__c, Application_Question__r.Help_Text__c,' +
            ' Application_Question__r.Question__c, Application_Question__r.Picklist_Options__c, Application_Question__r.Checkboxes_Options__c,' +
            ' Application_Form_Section__r.Name, Application_Form_Section__r.Help_Text__c, Application_Question__r.Character_Word_Assistance__c,' + 
            ' Application_Question__r.Is_Branching_Question__c, Application_Question__r.Field_to_Check_for_Rendering__c, ' +
            ' Application_Question__r.Field_to_Conditionally_Render__c, Application_Question__r.Answer_To_Rerender_On__c, ' +
            ' Application_Question__r.Subtext__c, Application_Question__r.Object_API_Name__c, Application_Question__r.Pages_for_Add_Another__c, Application_Question__r.Has_Child_Of_Child__c,' + 
            ' Application_Question__r.Page_Number_To_Display_On__c, Application_Question__r.Child_Header_Question__c, Application_Window_Template__r.Id' + 
            ' FROM Application_Question_Template__c' + 
            ' WHERE Application_Window_Template__r.Id = \'' + currApp.Application_Window_Template__c + '\'' + 
            ' AND Application_Form_Section__r.Form_To_Use_In__c = \'' + getParam('formType') + '\'' +  
            ' ORDER BY Application_Question__r.Question_Number__c, Application_Question__r.Page_Number_To_Display_On__c ASC';
        return Database.query(queryString);
    }


    public PageReference returnHomePage(){
        return Page.SIB_ApplicationList;
    }

    public void nextSubPage(){
        Integer pagesToAdd = ApexPages.getMessages().size() != 0 ? 0 : 1;
        updateSubPageNumber(pagesToAdd);
    }

    private void updateSubPageNumber(Integer toAdd){
        subPageNumber = subPageNumber + toAdd;
    }

    private void updatePageNumber(Integer toAdd){
        pageNumber = pageNumber + toAdd;
    }

    private void setAdditionalSectionToShow(String additionalSection){
        additionalSectionToShow = additionalSectionToShow == additionalSection ? '' : additionalSection;
    }

    public List<CheckboxWrapper> generateRegionCBW(){
        List<CheckBoxWrapper> cbwList = new List<CheckBoxWrapper>();
        for(Schema.PicklistEntry picklistOption : Application_Commissioner__c.Organisation_Region__c.getDescribe().getPicklistValues()){
            cbwList.add(new CheckBoxWrapper(picklistOption.getLabel(), false));
        }
        return cbwList;
    }

    /*
        Method to return the AQH to display on the section answer summary page. 
        NOTE: Hardcoded "ALL_QUESTIONS" to force it to add all sections.
    */
    public Map<String, List<ApplicationQuestionHolder>> getSWAnswers(){
        Map<String, List<ApplicationQuestionHolder>> returnValue = new Map<String, List<ApplicationQuestionHolder>>();
        for(String sectionWrapperKey : sectionWrappers.keySet()){
            if(formSection == 'ALL_QUESTIONS' || formSection == sectionWrapperKey){
                returnValue.put(sectionWrapperKey, sectionWrappers.get(sectionWrapperKey).aqhMap.values());
            }
        }
        return returnValue;
    }

    /*
        Method to "setAnswer" - this is used for checkboxes and radio selects, where we need specific styling which cannot be achieved
        using standard Salesforce functionality. We pass through the answer, field to set and the question and do a "put" before upserting
    */
    public void setAnswer(){
        String answerType = getParam('answerType');
        String answerToSet = getParam('answerToSet');
        Id aqtId = getParam('aqtId');
        SectionWrapper sw = sectionWrappers.get(formSection);
        Map<Id, ApplicationQuestionHolder> aqhMap = sw.aqhMap;
        ApplicationQuestionHolder aqh = aqhMap.get(aqtId);
        aqh.applicationAnswer.put(answerType, answerToSet);
        aqh.answerSubmitted = answerToSet;
        upsertAnswer();
    }

    /*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                                                    "SubObject" methods

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/ 
    public void generateSObject(){
        sObjectToCreate = Schema.getGlobalDescribe().get(getParam('sObjectType')).newSObject();
        sObjectToCreate.put('Application__c', currApp.Id);
        subPageNumber = 1;
        cOfChildSubPageNumber=null;
        cOfChildSObjectToCreate = null;        
    }

    public void saveSObject(){
        Boolean isNewRecord = String.isBlank(String.valueOf(sObjectToCreate.get('Id')));
        if(isNewRecord&&!System.Test.isRunningTest()){
            Boolean isRequired;
            try{
                String s = String.ValueOf(sObjectToCreate.get('IsPrimary__c'));
                isRequired = true;
            }
            catch(exception e){
                isRequired = false;
            }
            if(isRequired){
                if(primarySequence==0){
 					sObjectToCreate.put('Name', 'Primary Outcome');      
                    sObjectToCreate.put('IsPrimary__c', true); 
                    primarySequence=1;
                }
                else{
                    secondarySequence = secondarySequence+1;
 					sObjectToCreate.put('Name', 'Secondary Outcome '+secondarySequence);                                        
                }
                    
            }
        }
        upsert sObjectToCreate;
        currentChildId = (Id)sObjectToCreate.get('Id');
        ApplicationQuestionHolder aqhWithChildRecord = returnAQHWithChildRecord();
        if(aqhWithChildRecord != null && isNewRecord == true){
            List<SObject> sObjects = objectNameToRecords.get(aqhWithChildRecord.aqt.Application_Question__r.Object_API_Name__c);
            sObjects.add(sObjectToCreate);
            objectNameToRecords.put(aqhWithChildRecord.aqt.Application_Question__r.Object_API_Name__c, sObjects);
        }
        sObjectToCreate = null;
        subPageNumber = null;
        System.debug('-------------> objectNameToRecords:'+objectNameToRecords.values());
    }

    public Integer getSObjectSize(){
        ApplicationQuestionHolder aqhWithChildRecord = returnAQHWithChildRecord();
        return aqhWithChildRecord == null ? 0 : objectNameToRecords.get(aqhWithChildRecord.aqt.Application_Question__r.Object_API_Name__c).size();
    }

    public String getSObjectLabel(){
        ApplicationQuestionHolder aqhWithChildRecord = returnAQHWithChildRecord();
        return aqhWithChildRecord==null?'':(Schema.describeSObjects(new List<String>{aqhWithChildRecord.aqt.Application_Question__r.Object_API_Name__c})[0].getLabel()).toLowerCase();
    }
    
    public Boolean getHasChild(){
        ApplicationQuestionHolder aqhWithChildRecord = returnAQHWithChildRecord();
        if(aqhWithChildRecord!=null){
            return true;
        }else{
            return false;
        }
    }

    /*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     										Child of child methods
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
    public void generatecOfChildSObject(){

        System.debug('generatecOfChildSObject:');
        cOfChildSObjectToCreate = Schema.getGlobalDescribe().get(getParam('childSObjectType')).newSObject(); // Generate a new SObject type
        System.debug('cOfChildSObjectToCreate:'+cOfChildSObjectToCreate);
        cOfChildSObjectToCreate.put('Application__c', currApp.Id);
        cOfChildSubPageNumber = 1;   
        if(getParam('parentId')!=null||getParam('parentId')!=''){
            cOfChildSObjectToCreate.put('Primary_Outcome__c', getParam('parentiId'));
            String sObjectNumber = (getParam('sObjectNumber')==null||getParam('sObjectNumber')=='')?'0':getParam('sObjectNumber');
    
            System.debug('sObjectNumber:'+sObjectNumber);
            System.debug('sObjectName:'+getParam('sObjectName'));
            String sObjectName = getParam('sObjectName');
            if(!String.isBlank(sObjectName)){
 				sObjectToCreate = objectNameToRecords.get(sObjectName)[Integer.valueOf(sObjectNumber)];
            }
            String subPageNumber1 = getParam('subPageNumber');
            if(!String.isBlank(subPageNumber1)){
            	subPageNumber = Integer.valueOf(subPageNumber1);
            }
        }   
        
    }

    public void savecOfchildSObject(){
        saveSObject();
        Boolean isNewRecord = String.isBlank(String.valueOf(cOfChildSObjectToCreate.get('Id')));
        System.debug('isNewRecord:'+isNewRecord);
        System.debug('cOfChildSObjectToCreate:'+cOfChildSObjectToCreate);
        System.debug('cOfChildObjectNameToRecords:'+cOfChildObjectNameToRecords);
        if(isNewRecord){
            cOfChildSObjectToCreate.put('Primary_Outcome__c', currentChildId);
            Integer cSeq = childofchildSequenceMap.containsKey(currentChildId)?childofchildSequenceMap.get(currentChildId)+1:1;
            childofchildSequenceMap.put((Id)cOfChildSObjectToCreate.get('Primary_Outcome__c'), cSeq);
            System.debug('childofchildSequenceMap:'+childofchildSequenceMap);
            System.debug('childofchildSequenceMap.values():'+childofchildSequenceMap.values());

            //childOfChildSequence = childOfChildSequence+1;
            cOfChildSObjectToCreate.put('Name', getcOfchildSObjectLabel()+' '+String.ValueOf(cSeq));

        }
        upsert cOfChildSObjectToCreate;
        ApplicationQuestionHolder aqhWithChildRecord = returnAQHWithChildRecord();
        if(aqhWithChildRecord != null && isNewRecord){
            String childObjectName;
            for(Child_Record_Question__c c: aqtIdToChildQuestions.get(aqhWithChildRecord.aqt.Application_Question__c)){
                if(c.Object_API_Name__c!=null){
                    childObjectName = c.Object_API_Name__c;
                }
            }
            if(childObjectName!=null&&cOfChildObjectNameToRecords!=null){
                List<SObject> sObjects = cOfChildObjectNameToRecords.get(childObjectName);
                sObjects.add(cOfChildSObjectToCreate);
                cOfChildObjectNameToRecords.put(childObjectName, sObjects);
            }
        }
        cOfChildSObjectToCreate = null;
        cOfChildSubPageNumber = null;
        System.debug('**** objectNameToRecords:'+objectNameToRecords.values());
        System.debug('**** aqtIdToChildQuestions:'+aqtIdToChildQuestions);
        System.debug('**** aqtIdToChildOfChildQuestions:'+aqtIdToChildOfChildQuestions);
    }
    
    public Integer getcOfChildSObjectSize(){
        ApplicationQuestionHolder aqhWithChildRecord = returnAQHWithChildRecord();
        if(aqhWithChildRecord==null){
            return 0;
        }
        String childObjectName;
        System.debug('aqtIdToChildQuestions.get(aqhWithChildRecord.aqt.Application_Question__c):'+aqtIdToChildQuestions.get(aqhWithChildRecord.aqt.Application_Question__c));
        for(Child_Record_Question__c c: aqtIdToChildQuestions.get(aqhWithChildRecord.aqt.Application_Question__c)){
            if(c.Object_API_Name__c!=null){
                childObjectName = c.Object_API_Name__c;
            }
        }
        System.debug('childObjectName:'+childObjectName);
        System.debug('cOfChildObjectNameToRecords:'+cOfChildObjectNameToRecords);
        // return aqhWithChildRecord == null ? 0 : cOfChildObjectNameToRecords.get(childObjectName).size();
        // 
        Integer sizeOfChildSObject = 0;
        if(cOfChildObjectNameToRecords!=null&&childObjectName!=null){
            for(sObject s:cOfChildObjectNameToRecords.get(childObjectName)){
                if(cOfChildSObjectToCreate!=null){
                    if(s.get('Primary_Outcome__c')==cOfChildSObjectToCreate.get('Primary_Outcome__c')){
                        sizeOfChildSObject=sizeOfChildSObject+1;
                    }
                }
            }
    	}
        // cOfChildSObjectToCreate.get('Primary_Outcome__c')
        // return (childObjectName==null||cOfChildObjectNameToRecords.size()==0)? 0 : cOfChildObjectNameToRecords.get(childObjectName).size();
        return (childObjectName==null||cOfChildObjectNameToRecords.size()==0)? 0 : sizeOfChildSObject;
    }

    public String getcOfchildSObjectLabel(){
        ApplicationQuestionHolder aqhWithChildRecord = returnAQHWithChildRecord();
        String childObjectName;
        for(Child_Record_Question__c c: aqtIdToChildQuestions.get(aqhWithChildRecord.aqt.Application_Question__c)){
            if(c.Object_API_Name__c!=null){
                childObjectName = c.Object_API_Name__c;
            }
        }        
        // return childObjectName; 
        /* getcOfChildSObjectSize()>0?(Schema.describeSObjects(new List<String>{childObjectName})[0].getLabel()).toLowerCase():''; */
        return childObjectName==null?'':(Schema.describeSObjects(new List<String>{childObjectName})[0].getLabel()).toLowerCase();
    } 
    
    /******************************** End of Child of child methods /////////////////////////////////////////////////////////////////////*/
    public ApplicationQuestionHolder returnAQHWithChildRecord(){
        for(ApplicationQuestionHolder aqh : questionHolders){
            if(String.isNotBlank(aqh.aqt.Application_Question__r.Object_API_Name__c)){
                return aqh;
            }
        }
        return null;
    }
    
    public pageReference showMessage(){
        uploadSuccess = ApexPages.currentPage().getParameters().get('uploadSuccess');
        String attachName = ApexPages.currentPage().getParameters().get('attachName');
        List<String> fileSplit= attachName.split(';\\s*');
        attachedFiles = new List<String>();
        attachedFiles.addAll(fileSplit);
        System.debug('uploadSuccess:'+uploadSuccess);
        return null;
    }
    
    public pageReference updAttachment(){
        Id ansId = (Id)ApexPages.currentPage().getParameters().get('ansId');
        String attachName = ApexPages.currentPage().getParameters().get('attachName');
        System.debug('ansId:'+ansId);
        System.debug(''+attachName);
        Application_Answer__c a = [ Select Id, Attachment_Answer__c from Application_Answer__c where Id = :ansId];
        a.Attachment_Answer__c = attachName;
        update a;  
        uploadSuccess = 'true';
        List<String> fileSplit= attachName.split(';\\s*');
        attachedFiles = new List<String>();
        attachedFiles.addAll(fileSplit);
        System.debug('attachedFiles:'+attachedFiles);
        
        //List<String> fileSplit= attachName.split(';\\s*');
        //System.debug('fileSplit:'+fileSplit);
        //attachmentMap = new Map<Id, List<String>>();
        //attachmentMap.put(ansId, fileSplit);   
        // Map<Id, Application_Answer__c> previouslyAnsweredQuestions = new Map<Id, Application_Answer__c>();
        // previouslyAnsweredQuestions = getPreviousAnswers(currApp.Id);
        // system.debug('attachmentMap:'+attachmentMap.values());
        return null;
    }
   
}