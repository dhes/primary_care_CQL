// @author: Dan Heslinga
// Does this patient need an HbA1c to monitor prediabetes?
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
include FHIRCommon version '4.0.1' called FC

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
codesystem "LOINC": 'http://loinc.org'
// codesystem "ObservationCategory": 'http://terminology.hl7.org/CodeSystem/observation-category' // not sure if I need this; it's to get quantities

valueset "Inclusive Prediabetes Codes": 'http://example.org/fhir/ValueSet/inclusiveprediabetescodes'
valueset "Condition Clinical Status Active": 'http://example.org/fhir/ValueSet/conditionclinicalstatusactive'
valueset "Laboratory": 'http://example.org/fhir/ValueSet/laboratory'

// LOINC for A1c = 4548-4.
// Long common name Hemoglobin A1c/Hemoglobin.total in Blood
// Short name HbA1c MFr Bld
// Display name HbA1c (Bld) [Mass fraction]
// codesystem LOINC is in fhircommon
code "HbA1c": '4548-4' from "LOINC" display 'HbA1c (Bld) [Mass fraction]'

context Patient

define "Name":
[Patient] P return  P.name.given.first() + ' ' + P.name.family.first()

// define "Patient Name": [Patient] P.family + " " + P.given

define "Has prediabetes":
  [Condition: "Inclusive Prediabetes Codes"] C
  where C.clinicalStatus in "Condition Clinical Status Active"


define "HbA1c observations":
[Observation: category in "Laboratory"] O
  where O.status in { 'final', 'amended' , 'corrected', 'preliminary'}
    and O.value is Quantity
    and O.code ~ "HbA1c"
  sort by FHIRHelpers.ToDateTime(effective as dateTime) desc


/* define "HbA1c test in last year":
  [Observation: "HbA1c"] O
    where O.status  in { 'final', 'amended', 'corrected', 'preliminary' }
    and FC.ToInterval(O.effective) ends 1 year or less before Today() */

define "HbA1c test in last year":
  "HbA1c observations" O
    where O.status  in { 'final', 'amended', 'corrected', 'preliminary' }
      and FC.ToInterval(O.effective) ends 1 year or less before Today()

define "Had a HbA1c test in last year":
Exists("HbA1c test in last year")

define "Most Recent A1c test":
  First("HbA1c observations")

define "Most recent A1c value":
 "Most Recent A1c test" MR
 return Abs(MR.value as Quantity)

 define "Most recent A1c date":
  "Most Recent A1c test" MR
  return MR.effective.toString()

define "Has HbA1c test":  Exists("HbA1c observations")

define "Count HbA1c tests": Count("HbA1c observations")

define "Needs an A1c test to monitor prediabetes":
not Exists("HbA1c test in last year")
and Exists("Has prediabetes")
