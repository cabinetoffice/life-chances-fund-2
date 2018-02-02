@isTest
public class DataFactory {
	private static final String APPRECORDTYPE = 'Expression of Interest';
	private static final String THEME1 = 'Children\'s services';
	
	public static Theme__c createTheme(String themeName){
		Theme__c themeToCreate = new Theme__c(
			Name = themeName
		);
		return themeToCreate;
	}

	public static Theme__c insertTheme(String themeName){
		Theme__c themeToInsert = createTheme(themeName);
		insert themeToInsert;
		return themeToInsert;
	}

	public static Application_Window__c createAW(Id themeId){
		Application_Window__c awToCreate = new Application_Window__c(
			Name = 'Test AW',
			Theme__c = themeId,
			Start_Date__c = Date.today().addDays(-10),
			End_Date__c = Date.today().addDays(10),
			Is_Live__c = true
		);
		return awToCreate;
	}

	public static Application_Window__c insertAW(Id themeId){
		Application_Window__c awToInsert = createAW(themeId);
		insert awToInsert;
		return awToInsert;
	}

	public static Application_Window_Template__c createAWT(Id awId){
		Application_Window_Template__c awtToCreate = new Application_Window_Template__c(
			Application_Window__c = awId
		);
		return awtToCreate;
	}

	public static Application_Window_Template__c insertAWT(Id awId){
		Application_Window_Template__c awtToInsert = createAWT(awId);
		insert awtToInsert;
		return awtToInsert;
	}

	public static Application_Form_Section__c createAFS(String name, String formToUseIn){
		Application_Form_Section__c afsToCreate = new Application_Form_Section__c(
			Name = name,
			Form_To_Use_In__c = formToUseIn
		);
		return afsToCreate;
	}

	public static Application_Form_Section__c insertAFS(String name, String formToUseIn){
		Application_Form_Section__c afsToInsert = createAFS(name, formToUseIn);
		insert afsToInsert;
		return afsToInsert;
	}

	public static Application_Question__c createAQ(
		String question, String questionType, String contactRecordField, String fieldToSetOnAnswer, String objectAPIName, String pageNumberToDisplayOn
	){
		Application_Question__c aq = new Application_Question__c(
			Name = question.left(80),
			Field_From_Contact_Record__c = contactRecordField,
			Field_To_Set_On_Answer__c = fieldToSetOnAnswer,
			Question__c = question,
			Question_Type__c = questionType,
			Picklist_Options__c = 'Test;Test2;Test3;',
			Checkboxes_Options__c = 'Test;Test2;Test3;',
			Page_Number_To_Display_On__c = String.isBlank(pageNumberToDisplayOn) ? 0 : Integer.valueOf(pageNumberToDisplayOn),
			Required__c = true, 
			Is_Branching_Question__c = false,
			Object_API_Name__c = objectAPIName
		);
		return aq;
	}

	public static Application_Question__c insertAQ(
		String question, String questionType, String contactRecordField, String fieldToSetOnAnswer, String objectAPIName, String pageNumberToDisplayOn
	){
		Application_Question__c aq = createAQ(question, questionType, contactRecordField, fieldToSetOnAnswer, objectAPIName, pageNumberToDisplayOn);
		insert aq;
		return aq;
	}

	public static Application_Question_Template__c createAQT(Id awId, Id aqId, Id afsId){
		Application_Question_Template__c aqtToCreate = new Application_Question_Template__c(
			Application_Question__c = aqId,
			Application_Window_Template__c = awId,
			Application_Form_Section__c = afsId
		);
		return aqtToCreate;
	}

	public static Application_Question_Template__c insertAQT(Id awId, Id aqId, Id afsId){
		Application_Question_Template__c aqtToInsert = createAQT(awId, aqId, afsId);
		insert aqtToInsert;
		return aqtToInsert;
	}

	public static Contact createContact(String contactEmail){
		Contact contactToCreate = new Contact(
			FirstName = 'Test',
			LastName = 'Test',
			Email = contactEmail
		);
		return contactToCreate;
	}

	public static Contact insertContact(String contactEmail){
		Contact contactToInsert = createContact(contactEmail);
		insert contactToInsert;
		return contactToInsert;
	}

	public static Application__c createApplication(Id awtId, Id contactId, String status){
		Application__c appToCreate = new Application__c(
			RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get(APPRECORDTYPE).getRecordTypeId(),
			Application_Window_Template__c = awtId,
			Contact__c = contactId,
			Status__c = status
		);
		return appToCreate;
	}

	public static Application__c insertApplication(Id awtId, Id contactId, String status){
		Application__c appToInsert = createApplication(awtId, contactId, status);
		insert appToInsert;
		return appToInsert;
	}

	public static Child_Record_Question__c createCRQ(Id aqId, String fieldAPIName, String questionNumber, String pageNumberToDisplayOn, String question, String objectAPIName){
		Child_Record_Question__c crqToCreate = new Child_Record_Question__c(
			Application_Question__c = aqId,
			Field_API_Name__c = fieldAPIName,
			Question_Number__c = Decimal.valueOf(questionNumber),
			Page_Number_To_Display_On__c = Integer.valueOf(pageNumberToDisplayOn),
			Question__c = question
            /*,
            Object_API_Name__c = (objectAPIName=='null'?null:objectAPIName)*/
		);
		return crqToCreate;
	}

	public static Child_Record_Question__c insertCRQ(Id aqId, String fieldAPIName, String questionNumber, String pageNumberToDisplayOn, String question, String objectAPIName){
		Child_Record_Question__c crqToInsert = createCRQ(aqId, fieldAPIName, questionNumber, pageNumberToDisplayOn, question, objectAPIName);
		insert crqToInsert;
		return crqToInsert;
	}

	public static Child_of_a_Child_Record_Question__c createCCRQ(Id aqId, String fieldAPIName, String questionNumber, String pageNumberToDisplayOn, String question){
		Child_of_a_Child_Record_Question__c crqToCreate = new Child_of_a_Child_Record_Question__c(
			Child_Record_Question__c = aqId,
			Field_API_Name__c = fieldAPIName,
			Question_Number__c = Decimal.valueOf(questionNumber),
			Page_Number_To_Display_On__c = Integer.valueOf(pageNumberToDisplayOn),
			Question__c = question
		);
		return crqToCreate;
	}

	public static Child_of_a_Child_Record_Question__c insertCCRQ(Id aqId, String fieldAPIName, String questionNumber, String pageNumberToDisplayOn, String question){
		Child_of_a_Child_Record_Question__c crqToInsert = createCCRQ(aqId, fieldAPIName, questionNumber, pageNumberToDisplayOn, question);
		insert crqToInsert;
		return crqToInsert;
	}    
    
	public static void setUpFullApplication(){
		Map<String, List<String>> formTypeToSectionNames = new Map<String, List<String>>{
			'Expression of Interest' => new List<String>{
				'1. Lead Contact',
				'2. Organisation',
				'3. Project Information',
				'4. Outcomes',
				'5. Research',
				'6. Commissioners',
				'7. Previous Applications',
				'8. Declaration'
			},
			'Development Form' => new List<String>{
				'1. My project',
				'2. Engagement',
				'3. Support'
			},
			'Full Application' => new List<String>{
				'1. Overview of your project',
				'5. Outcomes and payment triggers'
			}

        };
		//question, questionType, contactRecordField, fieldToSetOnAnswer, objectAPIName, pageNumberToDisplayOn
		Map<String, List<String>> formSectionToQuestionDetails = new Map<String, List<String>>{
			'1. Lead Contact' => new List<String>{
				'First Name;Short Text;FirstName;Short_Text_Answer__c;;1;',
				'What is the last name of the lead contact?;Short Text;LastName;Short_Text_Answer__c;;1;',
				'What is the position of the lead contact?;Short Text;;;;2;',
				'What is the email address of the lead contact?;Email;Email;Email_Answer__c;;3;',
				'What is the contact number of the lead contact?;Short Text;;;;4;'
			},
			'2. Organisation' => new List<String>{
				'What is the legal name of your organisation?;Short Text;;;;1;',
				'Choose the organisation type that best fits your organisation;Short Text;;;;2;',
				'What sector does your organisation fit into?;Radio Select;;;;3;',
				'How long has the organisation been operating?;Radio Select;;;;4',
				'When is the organisation’s account year ending?;Date;;;;5;',
				'Total income for the year;Currency;;;;6;',
				'Total expenditure for the year;Currency;;;;6;',
				'Surplus or deficit for the year;Currency;;;;6;',
				'Total savings or reserves at the year end;Currency;;;;6;'
			},
			'3. Project Information' => new List<String>{
				'What is the name of your project?;Short Text;;;;1',
				'Please provide a summary of your project and how it fits with the priorities for the Life Chances Fund.;Long Text;;;;2;',
				'Where will your project take place?;Radio Select;;;;3',
				'When will the project start (or when did it start)?;Date;;;;4',
				'When would you like your project to finish?;Date;;;;5;',
				'Apart from the theme selected, what other social issue would the project address? (Optional);Checkboxes;;;;6'
			},
			'4. Outcomes' => new List<String>{
				'What are the outcomes the project is looking to achieve?;;;;Outcome__c;1;',
				'Please outline the intervention(s), or provide examples of the sort of intervention(s) you intend to use to deliver the outcomes.;Long Text;;;;2;'
			},
			'5. Research' => new List<String>{
				'Please outline what you have done / will do to develop your service to ensure it best supports service users?;Long Text;;;;1;'
			},
			'6. Commissioners' => new List<String>{
				'Please provide details of commissioners who will be paying for outcomes;;;;Application_Commissioner__c;1;',
				'What are the estimated costs per year for the project\'s interventions (1)?;Currency;;;;2',
				'What are the estimated costs per year for the project\'s interventions (2)?;Currency;;;;2',
				'What are the estimated costs per year for the project\'s interventions (3)?;Currency;;;;2',
				'What are the estimated savings per year for the project\'s interventions (1)?;Currency;;;;3',
				'What are the estimated savings per year for the project\'s interventions (2)?;Currency;;;;3',
				'What are the estimated savings per year for the project\'s interventions (3)?;Currency;;;;3',
				'How much money is required from the Life Chances Fund for outcomes payments?;Currency;;;;4',
				'What percentage of the outcomes payments is going to be paid by the Life Chances Fund?;Percent;;;;5;'
			},
			'7. Previous Applications' => new List<String>{
				'Was it successful?Checkboxes;;;;;1',
				'Details of the projects that were previously submitted;;;;Previous_Application__c;2;'
			},
			'8. Declaration' => new List<String>{
				'I\'ve read and understood the declaration;Checkboxes;;;;0;'
			},
			'1. Overview of your project' => new List<String>{
				'What would you like to call your project?;Short Text;;;;1;',
				'What type of organisation is the lead applicant?;Radio Select;;;;2;',
				'Please provide the contact details of the intermediary?;Short Text;;;;3;',
				'Intermediary name?;Short Text;;;;3;',
				'Intermediary email?;Short Text;;;;3;'
			},
			'5. Outcomes and payment triggers' => new List<String>{
				'Please add the outcomes and payment triggers for your project?;Short Text;;;Primary_Outcome__c;1;',
				'How did you determine the payments per outcome?;Long Text;;;;2;',
				'How will you ensure outcomes are attributable to your project?;Long Text;;;;3;'
			}                
		};
            
		//String fieldAPIName, Decimal questionNumber, Integer pageNumberToDisplayOn, String question, String objectAPIName
		Map<String, List<String>> questionToChildRecordQuestions = new Map<String, List<String>>{
			'What are the outcomes the project is looking to achieve?' => new List<String>{
				'Name;1.00;1;Name of the outcome;null;',
				'Outcome_Summary__c;2.00;1;Please provide a summary of what the outcome is and what the key changes would be for the service users;null;',
				'Measure__c;3.00;2;How will the outcome be measured?;null;'
			},
			'Please provide details of commissioners who will be paying for outcomes' => new List<String>{
				'Organisation_Name__c;1.00;1;Name of the commissioners organisation;null;',
				'First_Name__c;2.00;1;First name of the lead contact for the commissioner;null;',
				'Last_Name__c;3.00;1;Last name of the lead contact for the commissioner;null;',
				'Email__c;4.00;2;Email address;null;',
				'Phone_Number__c;5.00;2;Phone number;null;',
				'Organisation_Region__c;6.00;3;What region is the commissioner in?;null;'
			},
			'Details of the projects that were previously submitted' => new List<String>{
				'Was_It_Successful__c;1.00;1;Was it successful;null;',
				'Not_Successful_Reasons__c;2.00;1;Reasons it was not successful?;null;'
			},
			'Please add the outcomes and payment triggers for your project?' => new List<String>{
                'Outcome_Summary__c;1.00;1;	Please provide a summary of the outcome;null;',
				';2.00;1;Add the payment triggers for the outcome;Outcome_Payment_Trigger__c;'
            }
		};
		Theme__c theme = insertTheme(THEME1);
		Application_Window__c aw = insertAW(theme.Id);
		Application_Window_Template__c awt = insertAWT(aw.Id);

		//Create Form Sections
		List<Application_Form_Section__c> afsToInsert = new List<Application_Form_Section__c>();
		for(String formType : formTypeToSectionNames.keySet()){
			for(String sectionName : formTypeToSectionNames.get(formType)){
				afsToInsert.add(
					createAFS(sectionName, formType)
				);
			}
		}
		insert afsToInsert;
		Map<String, Id> formSectionNameToId = new Map<String, Id>();
		for(Application_Form_Section__c af : afsToInsert){
			formSectionNameToId.put(af.Name, af.Id);
		}

		//Create application questions
		List<Application_Question__c> aqsToInsert = new List<Application_Question__c>();
		Map<String, String> questionNameToFormSection = new Map<String, String>();
		for(String formType : formSectionToQuestionDetails.keySet()){
			for(String question : formSectionToQuestionDetails.get(formType)){
				List<String> valuesToSet = question.split(';');
				aqsToInsert.add(createAQ(valuesToSet[0], valuesToSet[1], valuesToSet[2], valuesToSet[3], valuesToSet[4], valuesToSet[5]));
				questionNameToFormSection.put(valuesToSet[0], formType);
			}
		}
        System.debug('aqsToInsert:'+aqsToInsert.size()+'----->'+aqsToInsert);
		insert aqsToInsert;

		//Create application question templates
		Map<String, Id> questionNameToId = new Map<String, Id>();
		List<Application_Question_Template__c> aqtsToInsert = new List<Application_Question_Template__c>();
		for(Application_Question__c aq : aqsToInsert){
			aqtsToInsert.add(createAQT(awt.Id, aq.Id, formSectionNameToId.get(questionNameToFormSection.get(aq.Question__c))));
			questionNameToId.put(aq.Question__c, aq.Id);
		}
        
        System.debug('questionNameToId:'+questionNameToId.size()+'---->'+questionNameToId);
		insert aqtsToInsert;

		//Create child record question
		List<Child_Record_Question__c> crqsToInsert = new List<Child_Record_Question__c>();
		for(String question : questionToChildRecordQuestions.keySet()){
			Id aqId = questionNameToId.get(question);
			for (String childQuestion : questionToChildRecordQuestions.get(question)){
				List<String> valuesToSet = childQuestion.split(';');
				crqsToInsert.add(createCRQ(aqId, valuesToSet[0], valuesToSet[1], valuesToSet[2], valuesToSet[3], valuesToSet[4]));
			}
		}
        System.debug('crqsToInsert:'+crqsToInsert);
		insert crqsToInsert;
        
        //Create Child of Child record question
        List<Child_Of_a_Child_Record_Question__c> ccrqsToInsert = new List<Child_Of_a_Child_Record_Question__c>();
        
        
		Contact applicant = insertContact(UserInfo.getUserEmail());
		Application__c app = insertApplication(awt.Id, applicant.Id, 'Draft');
	}
}