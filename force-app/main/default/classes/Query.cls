/* __________________________________________________________________________________________________________________
   Name:		Query.cls
   Description: Utility class for SOQL and DML
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   2017		    1.0    	Cabinet Office			Initial Release 
   Jan 2018		1.1		M.Witchalls, Westbrook	Additional versions of object methods (use of sets) + DML methods
__________________________________________________________________________________________________________________ */        
public class Query {

    // refactor to take a set of fields and remove duplication
    public static sObject object(String targetObject, Set<String> fields, String constraint) {
        List<String> fieldList = new List<String>(fields);
        return Query.object(targetObject, fieldList, constraint);
    }
    
    public static sObject object(String targetObject, String[] fields, String constraint) {
    	return Query.object(targetObject, fields, constraint, false, null);
    }

	public static sObject object(String targetObject, String[] fields, String constraint, Boolean createIfNotFound, String applicationId) {
		sObject queryresult;
		String fieldslist = Query.fieldListString(fields);
        // Construct the query string
        String soqlquery = 'SELECT ' + fieldslist + ' FROM ' + targetObject + ' ' + constraint + ' LIMIT 1';
        // Run the query
        System.debug('###'+soqlquery);
		try {
        	List<sObject> resultList = Database.query(soqlquery);
	        if (resultList.size() == 0) {
	        	if (createIfNotFound) {
	        		Query.createObject(targetObject, applicationId);
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
	
	public static Database.SaveResult createObject(String targetObject, String applicationId) {
		Database.SaveResult result;
		sObject newRecord = Schema.getGlobalDescribe().get(targetObject).newSObject();
		newRecord.put('application__c', applicationId);
		try {
			result = Database.insert(newRecord);
		} catch(Exception ex) {
		    throw new COF_Exception('Could not create new '+targetObject+': '+ex.getMessage()+'\n'+ex.getStackTraceString());
		}	
		return result;	
	}
	
	public static Database.SaveResult createObject(String targetObject, String applicationId, String parentFieldName, String parentId) {
		Database.SaveResult result;
		sObject newRecord = Schema.getGlobalDescribe().get(targetObject).newSObject();
		newRecord.put('application__c', applicationId);
        newRecord.put(parentFieldName, parentId);
		try {
			result = Database.insert(newRecord);
		} catch(Exception ex) {
		    throw new COF_Exception('Could not create new '+targetObject+': '+ex.getMessage()+'\n'+ex.getStackTraceString());
		}		
		return result;	
	}
	
	public static Database.SaveResult updateObject(SObject targetObject) {
		Database.SaveResult result;
		String targetObjectName = targetObject.getSObjectType().getDescribe().getName();
		try {
			system.debug('####update targetObject: '+targetObject);
			result = Database.update(targetObject);
		} catch(Exception ex) {
		    throw new COF_Exception('Could not update '+targetObjectName+': '+ex.getMessage()+'\n'+ex.getStackTraceString());
		}	
		return result;	
	}

    public static List<sObject> objects(String targetObject, String[] fields, String constraint)
    {
        List<sObject> queryresult;
        String fieldslist = Query.fieldListString(fields);
        // Construct the query string
        String soqlquery = 'SELECT ' + fieldslist + ' FROM ' + targetObject + ' ' + constraint;
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