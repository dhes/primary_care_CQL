// Prediabetes - annual A1c Related observations: A1c
// "Patients with prediabetes should have an A1c blood test once a year."
// Rule #1 from web app

// Basis: https://care.diabetesjournals.org/content/44/Supplement_1/S34
// 'At least annual monitoring for the development of type 2 diabetes in those with prediabetes is suggested.'

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

// valueset "Prediabetes": 'https://cts.nlm.nih.gov/fhir/r4/ValueSet/2.16.840.1.113762.1.4.1222.419'
// the synthea generator uses a deprecated snomedct code of 15777000
// the current snomedct code is 714628002
// this value set references the current snomedct code 714628002 and three ICD-10-CM codes:
// see https://icd10cmtool.cdc.gov/?fy=FY2021
// valueset "Most Recent Prediabetes Codes": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1222.419'
// this custom value set includes the deprecated synthea code, all of the Prediabetes codes as well as corresponding ICD9 codes
// R73.01 = 790.21
// R73.02 = 790.22
// R73.03 = 790.29 (other abnormal glucose; no specific code for prediabetes)
// all resourcetype: Conditions are encounter-diagnosis; none are problem-list item.
valueset "Inclusive Prediabetes Codes": 'http://example.org/fhir/ValueSet/inclusiveprediabetescodes'
valueset "Condition Clinical Status Active": 'http://example.org/fhir/ValueSet/conditionclinicalstatusactive'

// LOINC for A1c = 4548-4
context Patient

define "Has prediabetes": [Condition: "Inclusive Prediabetes Codes"]
