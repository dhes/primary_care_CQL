// Prediabetes - annual A1c Related observations: A1c
// "Patients with prediabetes should have an A1c blood test once a year."

// Basis:

/*
NOTE: This example is for instructional purposes only and is derived from work in progress.
It should in no way be considered a final specification or recommendation for guidance.
*/

library PrediabetesAnnualA1c

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers
// include cqf.fhir.common.FHIRCommon // uncomment as needed

// urn - uniform resource name https://en.wikipedia.org/wiki/Uniform_Resource_Name
// oid - organization id

valueset "Prediabetes" 'https://cts.nlm.nih.gov/fhir/r4/ValueSet/2.16.840.1.113762.1.4.1222.419'

context Patient

define "Has prediabetes": [Observation: Condition] C where C.code in "Prediabetes"
