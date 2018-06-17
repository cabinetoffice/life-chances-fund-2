/**
 * COF_Router
 * Cabinet Office Forms 1.0
 *
 * This class determines the next page (e.g. the route) from any given page. This is evaluated
 * based the JSON definition (COF_QuestionSet) and the state of the target object (e.g. whether
 * constraints defined are valid).
 *
 * History:
 * M.Witchalls Apr 2018:  Constraint checking correction; constraints attribute on questions and fields
 */
public class COF_Router {
	public static final String EQUALS = 'equals';
	public static final String GREATER = 'greater';
	public static final String CONTAINS = 'contains';

	public SObject targetObject {get;set;}
	public COF_QuestionSet questionSet {get;set;}

	/**
	* Returns the next page given the current page
	*/
	public COF_Page nextFromPage(COF_Page currentPage) {
		if (currentPage.routes != null) {
            // Loop through the routes from this page
            for (COF_QuestionSet.COF_Route route : currentPage.routes) {
                // Determine if constraints apply
                if (route.constraints != null) {
                    for (COF_QuestionSet.COF_Constraint constraint : route.constraints) {
                        // Need to ensure we've included this field in the object fetch prior to this call
                        //if (this.targetObject.get(constraint.field) == constraint.value) {
                        
                        // M.Witchalls Apr 2018
                        if (validConstraint(constraint, this.targetObject.get(constraint.field))) {
                            // Valid constraint, so this is the next page
                            return this.questionSet.getPage(route.target_page);
                        }
                    }
                } else {
                    // No constraints so this is the next page
                    return this.questionSet.getPage(route.target_page);
                }
            }
        }

        // No subsequent page was found
        return null;
	}
    
    public Boolean validConstraint(COF_QuestionSet.COF_Constraint constraint, Object compareValue) {
    	system.debug('@@@@compareValue: '+compareValue);
    	if (constraint.operator != EQUALS && compareValue == null) return false;
        if (constraint.operator == EQUALS) {
        	if ((String.isBlank(String.valueOf(compareValue)) && String.isBlank(String.valueOf(constraint.value)))
            	|| (String.valueOf(compareValue) == String.valueOf(constraint.value))) {
                // Valid constraint 
                return true;
            }
        } else if (constraint.operator == GREATER) {
            if (Double.valueOf(compareValue) > Double.valueOf(constraint.value)) {
                // Valid constraint 
                return true;
            }
        } else if (constraint.operator == CONTAINS) {
            if (String.valueOf(compareValue).contains(constraint.value) == true) {
                // Valid constraint 
                return true;
            }
        }   
        return false;	
    }
}