// Current smoker - lung cancer screening Related observations: chest CT
// "Order a screening chest CT once a year in current smokers age 55 to 80 with a 30 or greater pack-year history."
// This incorporated the current smoker and past smoker CDS rules #8 and #61 in my heroku app

// Basis:

/*
NOTE: This example is for instructional purposes only and is derived from work in progress.
It should in no way be considered a final specification or recommendation for guidance.
*/

library lung-cancer-screening

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers
// include cqf.fhir.common.FHIRCommon // uncomment as needed
