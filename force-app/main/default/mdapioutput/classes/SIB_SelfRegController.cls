public class SIB_SelfRegController {
	public String firstName {get; set;}
	public String lastName {get; set;}
	public String email {get; set;}
	public String organisationName{get; set;}
	public String orgTypeOther{get;set;}
	public String typeSelected{get;set;}
	public Integer pageNumber{get;set;}
	public Map<String, List<CheckboxWrapper>> nameToCBW{get;set;}
	public Map<String, String> orgTypeMap{get;set;}

	/*
		Page load methods:
			pageNumber being set to 1 to allow start page to be shown
			Generating the checkbox wrappers 
	*/
	public SIB_SelfRegController() {
		orgTypeMap = new Map<String, String>();
		pageNumber = 1;
		nameToCBW = new Map<String, List<CheckboxWrapper>>{
			'regions' => generateRegionCBW(),
			'themes' => generateThemeCBW()
		};
	}

	/*
		Method used to create user.
		Returns a page reference (null if there is any errors, else SelfRegConfirm)
	*/
	public PageReference registerUser() {
		if(usersWithNickname().size() != 0){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This email has already been used to register on the community.'));
			return null;
		}
		//These should at some point be updated to the correct Ids, as we are hardcoding the owner :|
		String profileId = [SELECT Id FROM Profile WHERE Name = 'SIB Applicant'].Id;
		String ownerId = [SELECT Id FROM User WHERE Name = 'Westbrook Admin'].Id;
		String accountId = '';

		String regionSelected = '';
		for(CheckboxWrapper region : nameToCBW.get('regions')){
			regionSelected += region.isSelected ? (region.checkBoxName + ';') : '';
		}
		Account accountToCreate = new Account(
			Name = organisationName,
			Type = typeSelected,
			Organisation_Region__c = regionSelected,
			Organisation_Type_Details__c = orgTypeOther,
			OwnerId = ownerId
		);
		//Fix to null "Ending position out of bounds" on email addresses less than 40 characters
		Integer subStringToGet = email.length() < 40 ? email.length() : 39;
		// SIB-222
		String commNickName = email.substring(0,subStringToGet);
		User u = new User(
			Username = email,
			Email = email,
			FirstName = firstName,
			LastName = lastName,
			CommunityNickname = commNickName, // SIB-222 - Was previously email
			ProfileId = profileId
		);
		String userId;
		Savepoint rollBackPoint = Database.setSavepoint();
		try{
			insert accountToCreate;
			accountId = accountToCreate.Id;
		} catch(DmlException dmlException){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmlException.getMessage()));
			Database.rollback(rollBackPoint);
			return null;
		}
		List<Theme_Interest__c> themeInterestsToInsert = new List<Theme_Interest__c>();

		for(CheckBoxWrapper theme : nameToCBW.get('themes')){
			if(theme.isSelected){
				themeInterestsToInsert.add(
					new Theme_Interest__c(
						Theme__c = theme.checkBoxId,
						Organisation__c = accountId
					)
				);
			}
		}
		if(!themeInterestsToInsert.isEmpty()){
			try {
				insert themeInterestsToInsert;
			} catch(DmlException insertException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error inserting theme interests'));
				Database.rollback(rollBackPoint);
				return null;
			}
		}
		/*
			Try catch on standard "Site.createExternalUser" method as per best practices. 
		*/
		try {
			userId = Site.createExternalUser(u, accountId);
		} catch(Site.ExternalUserCreateException ex) {
			List<String> errors = ex.getDisplayMessages();
			for (String error : errors)  {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			}
			Database.rollback(rollBackPoint);
			return null;
		}
		PageReference page = System.Page.SIB_SelfRegConfirm;
		page.setRedirect(true);
		return page;
	}

	public List<String> types{
		get{
			List<String> options = new List<String>();
			orgTypeMap = new Map<String, String>();
			for(Schema.PicklistEntry picklistOption : Account.Type.getDescribe().getPicklistValues()){
				String label = picklistOption.getLabel();
				orgTypeMap.put(label, label.replace('\'', '\\\''));
				options.add(label);
			}
			return options;
		}
	}

	private static List<CheckboxWrapper> generateRegionCBW(){
		List<CheckBoxWrapper> cbwList = new List<CheckBoxWrapper>();
		for(Schema.PicklistEntry picklistOption : Account.Organisation_Region__c.getDescribe().getPicklistValues()){
			cbwList.add(new CheckBoxWrapper(picklistOption.getLabel(), null));
		}
		return cbwList;
	}

	private static List<CheckboxWrapper> generateThemeCBW(){
		List<CheckBoxWrapper> cbwList = new List<CheckBoxWrapper>();
		for(Theme__c theme : [
			SELECT Name, Id
			FROM Theme__c
			ORDER BY CreatedDate
		]){
			cbwList.add(new CheckBoxWrapper(theme.Name, theme.Id));
		}
		return cbwList;
	}

	private List<User> usersWithNickname(){
		return [
			SELECT Id
			FROM User
			WHERE email = :email // SIB-222 - previously matching on the field nickname on the user object
		];
	}

	public void nextPage(){
		 // SIB-226
		if(pageNumber==1){  
			if(String.isBlank(email)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add email'));
				return;
			}              
			if(!SIB_Utilities.isValidEmail(email)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid email address'));
				return;
			}
			// SIB-236
			if (String.isBlank(organisationName)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add Organisation Name'));
				return;
			}
		}
		if(pageNumber==2){
			if(typeSelected == 'Other' && String.isBlank(orgTypeOther)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out \'If you chose other, please explain\' if you selected \'Other\' for organisation type'));
				return;
			}
		}
		updatePageNumber(1);
	}

	public void previousPage(){
		updatePageNumber(-1);
	}

	private void updatePageNumber(Integer toUpdate){
		pageNumber = pageNumber + toUpdate;
	}

	public class CheckBoxWrapper{
		public String checkBoxName{get;set;}
		public Id checkBoxId{get;set;}
		public Boolean isSelected{get;set;}

		public CheckBoxWrapper(String checkBoxName, Id checkBoxId){
			this.checkBoxName = checkBoxName;
			this.checkBoxId = checkBoxId;
			this.isSelected = false;
		}
	}

	public void setRadioAnswer(){
		typeSelected = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('selectedType'), 'UTF-8');
	}
}