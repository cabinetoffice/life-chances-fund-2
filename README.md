# LCF-Web-App-2.0

This Salesforce VisualForce application enables organisations to apply for funding from the The Life Chances Fund (LCF) - a £80 million top-up fund, whose objective is to help those people in society who face the most significant barriers to leading happy and productive lives.

The application presents a number of forms to applicants, and manages complex question branching scenarios, in order to collect the necessary information from applicants to fully access their funding needs.

## Deployment to Scratch Org

* [Enable Dev Hub in your Salesforce org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_enable_devhub.htm)
* [Install sfdx-cli](https://developer.salesforce.com/tools/sfdxcli)
* Checkout this source and cd into directory
* Authenticate e.g. 'sfdx force:auth:web:login -d -a DevHub' (use Org with Dev Hub enabled e.g. Production)
* Create a new scratch org e.g. 'sfdx force:org:create -f config/project-scratch-def.json -a lcf2'
* Push the source into the scratch org e.g. 'sfdx force:source:push -u lcf2'
* Open the scratch org as an authenticated user e.g. 'sfdx force:org:open -u lcf2'
* Create a new 'Application__c' record and new 'Form_LCF_Full_App_1__c' set as a related object
* Hit '/apex/applications'

## Deployment to Sandbox

* Authenticate the sandbox, e.g. sfdx force:auth:web:login --setalias lcfdev --instanceurl https://test.salesforce.com
* Create a subdirectory in the source directory e.g mdapioutput
* Convert the source: sfdx force:source:convert -d mdapioutput
* Deploy the source: sfdx force:mdapi:deploy -d mdapioutput -u lcfdev -w 100

## Deployment Issues

* Any flows included in the deployment must first be deactivated and DELETED in the target org
* A Permission Set must be included for any new custom fields and added to users, otherwise Profiles must be updated manually
* If errors arise when "pulling" Profiles, try a dummy edit and save on the affected Profiles

## Contact

TBC

## License

TBC
