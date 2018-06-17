/* __________________________________________________________________________________________________________________
   Name:		Query.cls
   Description: Utility class for SOQL and DML
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   2017		    1.0    	Cabinet Office			Initial Release 
   Jan 2018		1.1		M.Witchalls, Westbrook	Additional versions of object methods (use of sets) + DML methods
__________________________________________________________________________________________________________________ */        
public class Query {
    private static final String VALIDATION_EXCEPTION = 'There is an error on this page';
    private static final String DUPLICATE_EXCEPTION = 'duplicate value found:';
    private static final String APPLICATIONFIELD = 'application__c';
    private static final String GRANTFIELD ='lcf_grant__c';
    private static final String CONTACTFIELD = 'contact__c';

    // refactor to take a set of fields and remove duplication
    public static SObject object(String targetObject, Set<String> fields, String constraint) {
        List<String> fieldList = new List<String>(fields);
        return Query.object(targetObject, fieldList, constraint);
    }
    
    public static SObject object(String targetObject, String[] fields, String constraint) {
    	return Query.object(targetObject, fields, constraint, false, null);
    }

    public static SObject object(String targetObject, String[] fields, String constraint, Boolean createIfNotFound, String parentId) {
    	return Query.object(targetObject, fields, constraint, createIfNotFound, parentId, null, null);
    }
    
    public static SObject object(String targetObject, String[] fields, String constraint, Boolean createIfNotFound, String parentId, 
    	String parentFieldName, String parentFieldValue
    ) {
		SObject queryresult;
		String fieldslist = Query.fieldListString(fields);
        // Construct the query string
        String soqlquery = 'SELECT ' + fieldslist + ' FROM ' + targetObject + ' ' + constraint + ' LIMIT 1';
        // Run the query
        System.debug('###'+soqlquery);
		try {
        	List<SObject> resultList = Database.query(soqlquery);
	        if (resultList.size() == 0) {
	        	if (createIfNotFound) {
	        		Query.createObject(targetObject, parentId, parentFieldName, parentFieldValue);
	        		return Query.object(targetObject, fields, constraint);
	        	} else {
	        		throw new COF_Exception('No rows returned from SOQL query on '+targetObject);
	        		return null; 
	        	}
	        } else {
			    queryresult = resultList[0];
			    return queryresult;
	        } 
		} catch(Exception ex) {
		    throw new COF_Exception('Error in SOQL Query on '+targetObject+': '+ex.getMessage()+'\n'+ex.getStackTraceString());
		    return null;
		}		
	}

	/*
	 *	Purpose: Multiple versions of createObject method, allowing for population of parent and grandparent reference fields
	 *	History: 
	 *		Mar 2018: Michael Witchalls: Initial Release
	 *		Apr 2018: Grant Management versions
	 *
	 */	
	public static Database.SaveResult createObject(String targetObject, String parentId) {
		return createObject(targetObject, parentId, null);
	}
	
	public static Database.SaveResult createObject(String targetObject, String parentId, String objectId) {
		return createObject(targetObject, parentId, objectId, null, null);
	}
	
	public static Database.SaveResult createObject(String targetObject, String parentId, String objectFieldName, String objectFieldValue) {
		return createObject(targetObject, parentId, null, objectFieldName, objectFieldValue);
	}
	
	public static Database.SaveResult createObject(String targetObject, String parentId, String objectId, String objectFieldName, String objectFieldValue) {
		Database.SaveResult result;
		SObject newRecord = Schema.getGlobalDescribe().get(targetObject).newSObject();
		ID idValue = parentId;
		if (idValue.getSObjectType() == LCF_Grant__c.sObjectType) {
			newRecord.put(GRANTFIELD, parentId);
		} else {
			newRecord.put(APPLICATIONFIELD, parentId);
		}
		if (objectId != null) {
			idValue = objectId;
			if (idValue.getSObjectType() == Contact.sObjectType) {
				newRecord.put(CONTACTFIELD, objectId);
			} else if (idValue.getSObjectType() == LCF_Grant__c.sObjectType) {
				newRecord.put(GRANTFIELD, objectId);
			}
		}
		if (objectFieldName != null) {
			newRecord.put(objectFieldName, objectFieldValue);
		}
		try {
			result = Database.insert(newRecord);
		} catch(Exception ex) {
		    throw new COF_Exception('Could not create new '+targetObject+': '+ex.getMessage()+'\n'+ex.getStackTraceString());
		}	
		return result;	
	}
	
	public static Database.SaveResult createObject(String targetObject, String grandParentFieldName, String grandParentId, String parentFieldName, String parentId, String recordType) {
		Schema.SObjectType objectType = Schema.getGlobalDescribe().get(targetObject);
		SObject newRecord = objectType.newSObject();
		return createObject(newRecord, grandParentFieldName, grandParentId, parentFieldName, parentId, recordType, true);
	}
	
	public static Database.SaveResult createObject(SObject newRecord, String grandParentFieldName, String grandParentId, 
		String parentFieldName, String parentId, String recordType, Boolean allOrNone) 
	{
		Database.SaveResult result;
		Schema.SObjectType objectType = newRecord.getSObjectType();
		Schema.DescribeSObjectResult dr = objectType.getDescribe();
		if (grandParentFieldName == null) { 
			ID idValue = grandParentId;
			if (idValue.getSObjectType() == LCF_Grant__c.sObjectType) {
				grandParentFieldName = GRANTFIELD;
			} else {
				grandParentFieldName = APPLICATIONFIELD;
			}
		}
		newRecord.put('Id', null);
		newRecord.put(grandParentFieldName, grandParentId);
        newRecord.put(parentFieldName, parentId);
        if (recordType != null) {
        	newRecord.put('recordTypeId', dr.getRecordTypeInfosByName().get(recordType).getRecordTypeId());   
        }
		try {
			result = Database.insert(newRecord, allOrNone);
		} catch(Exception ex) {
		    throw new COF_Exception('Could not create new '+newRecord+': '+ex.getMessage()+'\n'+ex.getStackTraceString());
		}		
		return result;	
	}

	/*
	 *	Purpose: Create multiple records, allow errors on individual records - used to copy child records from a previous form: e.g. EOI Commissioners to Full Application
	 *	History: 
	 *		Apr 2018: Michael Witchalls: Initial Release
	 *
	 */
	public static createResult createObjects(List<SObject> targetObjects, String grandParentId, String parentFieldName, String parentId, String recordType) {
		return createObjects(targetObjects, null, grandParentId, parentFieldName, parentId, recordType);
	}	
	public static createResult createObjects(List<SObject> targetObjects, String grandParentFieldName, String grandParentId, String parentFieldName, String parentId, String recordType) {
		Database.SaveResult[] results = new List<Database.SaveResult>();
		Boolean isError = false;
		String errorMessage = null;
		for (SObject newRecord: targetObjects) {
			results.add(createObject(newRecord, grandParentFieldName, grandParentId, parentFieldName, parentId, recordType, false));
		}
		for (Database.SaveResult result: results) {		
			if (!result.isSuccess()) {
				for (Database.Error e: result.getErrors()) {
		            String msg = e.getMessage();
		            if (msg.contains(DUPLICATE_EXCEPTION) ) {
		                isError = true;
		                errorMessage = msg;
		            } else {
						Schema.SObjectType objectType = targetObjects[0].getSObjectType();
						Schema.DescribeSObjectResult dr = objectType.getDescribe();
		            	throw new COF_Exception('Could not create new '+dr.getName()+': '+e.getMessage());
		            }
				}     
			}
		}
        return new createResult(isError, errorMessage, results);
	}
	
	public class createResult {
		public Boolean isError {get; set;}
		public String message {get; set;}
		public Database.SaveResult[] results {get; set;}
		
		public createResult(Boolean ie, String msg, Database.SaveResult[] res) {
			this.isError = ie;
			this.message = msg;
			this.results = res;
		}
	}
	

	/*
	 *	Purpose: Update a record, returning messages for validation and duplicate errors
	 *	History: 
	 *		Mar 2018: Michael Witchalls: Initial Release
	 *
	 */
	public static Query.updateResult updateObject(SObject targetObject) {
		Database.SaveResult result;
		String targetObjectName = targetObject.getSObjectType().getDescribe().getName();
		try {
			system.debug('####update targetObject: '+targetObject);
			result = Database.update(targetObject, false);
		} catch(Exception ex) {
            throw new COF_Exception('Could not update '+targetObjectName+': '+ex.getMessage()+'\n'+ex.getStackTraceString());
		}	
		if (!result.isSuccess()) {
			for (Database.Error e: result.getErrors()) {
	            String msg = e.getMessage();
	            if (msg.contains(VALIDATION_EXCEPTION)) {
	                return new updateResult(true, msg, result);
	            } else if (msg.contains(DUPLICATE_EXCEPTION)) {
	            	return new updateResult(true, System.Label.SIB_Duplicate_Error, result);
	            } else {
	            	throw new COF_Exception('Could not update '+targetObjectName+': '+e.getMessage());
	            }
			}     
		} 
		return new updateResult(false, '', result);	
	}
	
	public class updateResult {
		public Boolean isError {get; set;}
		public String message {get; set;}
		public Database.SaveResult result {get; set;}
		
		public updateResult(Boolean ie, String msg, Database.SaveResult res) {
			this.isError = ie;
			this.message = msg;
			this.result = res;
		}
	}

    public static List<SObject> objects(String targetObject, Set<String> fields, String constraint) {
        List<String> fieldList = new List<String>(fields);
        return Query.objects(targetObject, fieldList, constraint);
    }

    public static List<SObject> objects(String targetObject, String[] fields, String constraint)
    { 
        List<SObject> queryresult;
        String fieldslist = Query.fieldListString(fields);
        // Construct the query string
        String soqlquery = 'SELECT ' + fieldslist + ' FROM ' + targetObject + ' ' + (constraint==null ? '' : constraint);
        // Run the query
        System.debug(soqlquery);
		try {
        	queryresult = Database.query(soqlquery);
	        //if (queryresult.size() == 0) {
        	//	throw new COF_Exception('No rows returned from SOQL query on '+targetObject);
        	//	return null; 
	        //} else {
			    return queryresult;
	        //} 
		} catch(Exception ex) {
		    throw new COF_Exception('Error in SOQL Query on '+targetObject+': '+ex.getMessage()+'\n'+ex.getStackTraceString());
		}		
        return queryresult;               
    }

	/*
	 *	Purpose: Query child of child records (e.g. LCF Grant Outcome Achievement) and if they don't exist 
	 *	create them from existing child records (e.g. LCF Grant Outcome)
	 *
	 *	History: 
	 *		May 2018: Michael Witchalls: Initial Release
	 *
	 */    
 	public static List<SObject> objects(String targetObject, String[] fields, String constraint, Boolean createIfNotFound, 
    	String grandParentFieldName, String grandParentId, String parentFieldName, String parentId, String refFieldName, List<String> refIdList) 
    {
        List<SObject> queryresult;
		String fieldslist = Query.fieldListString(fields);
        // Construct the query string
        String soqlquery = 'SELECT ' + fieldslist + ' FROM ' + targetObject + ' ' + constraint;
        // Run the query
        System.debug('@@@'+soqlquery);
		try {
        	queryresult = Database.query(soqlquery);
	        if (queryresult.size() == 0) {
	        	if (refFieldName != null && refIdList != null && createIfNotFound) {
	        		List<SObject> targetObjects = new List<SObject>();
	        		for (String refId: refIdList) {
	        			// Only about 3 records will be created here
						Schema.SObjectType objectType = Schema.getGlobalDescribe().get(targetObject);
						SObject newRecord = objectType.newSObject();
						newRecord.put(refFieldName, refId);
						Query.createObject(newRecord, grandParentFieldName, grandParentId, parentFieldName, parentId, null /*recordType*/, true /*allOrNone*/);
	        		}
	        		return Query.objects(targetObject, fields, constraint, false, 
	        			grandParentFieldName, grandParentId, parentFieldName, parentId, refFieldName, refIdList);
	        	} else {
	        		throw new COF_Exception('No rows returned from SOQL query on '+targetObject);
	        		return null; 
	        	}
	        } else {
			    return queryresult;
	        } 
		} catch(Exception ex) {
		    throw new COF_Exception('Error in SOQL Query on '+targetObject+': '+ex.getMessage()+'\n'+ex.getStackTraceString());
		    return null;
		}		
	}

    
    public static String fieldListString(String[] fields) {
        String fieldslist = '';
        // Generate the fieldslist from the string array 
        if (fields != NULL)
        {
            if(fields.size() > 0)
            {
                for (Integer i=0; i < fields.size(); i++)
                {
                    if( i <= (fields.size() - 2))
                        fieldslist = fieldslist+fields[i]+',';
                    else
                        fieldslist = fieldslist+fields[i];    
                }
            }
        } 
    	return fieldslist;
    }
}