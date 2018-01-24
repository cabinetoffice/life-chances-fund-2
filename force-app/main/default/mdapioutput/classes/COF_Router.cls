/**
 * COF_Router
 * Cabinet Office Forms 1.0
 *
 * This class determines the next page (e.g. the route) from any given page. This is evaluated
 * based the JSON definition (COF_QuestionSet) and the state of the target object (e.g. whether
 * constraints defined are valid).
 */
public class COF_Router {

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
                        if (this.targetObject.get(constraint.field) == constraint.value) {
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
}