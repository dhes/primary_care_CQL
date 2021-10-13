library NextColonoscopy

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
//include FHIRCommon version '4.0.1' called FC

codesystem "SNOMED": 'http://snomed.info/sct'
codesystem "LOINC": 'http://loinc.org'

valueset "Colonoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "Polyp of Large Intestine": 'http://example.com/bcd6931c-f88c-4df8-aeea-1ee5cc4cf70b'

//code "Polyp size": '33756-8' from "LOINC" display 'Polyp size greatest dimension'
//code "Polyp path": '34574-4' from "LOINC" display 'Pathology report final diagnosis'
code "Colonoscopic polypectomy": '311774002' from "SNOMED"

context Patient

//define "Had Colonoscopy":
//  [Procedure: "Colonoscopy"] P

//define "First colonoscopy in the list":
//"Had Colonoscopy"[0]

//define "Found polyps":
//  [Observation] O
//    where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
//      and (O.value as CodeableConcept) in "Polyp of Large Intestine"

//define "Polyp length":
//  [Observation] O
//  where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
//    and O.code ~ "Polyp size"
//    return O.id.value

//define "Polyp report":
//  [Observation] O
//  where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
//    and O.code ~ "Polyp path"

// In this data model there are two layers of pathology observations.
// The top is the coded gross pathology e.g. 'cecum polyp'.
// This serves to define the anatomic location of lesion as well
// as its polyp appearance.
// Within this, as .hasMember elements, are the reference sto observations
// of length and microscopic pathology of the specimen.
// In this patients chart the only observations that have members are
// Gross path reports.
define "Gross pathology":
  [Observation] O
  where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
  and exists O.hasMember

define "Polyp size":
  from [Observation] O,
  "Gross pathology" GrossPathology
    where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
    and Last(Split(O.id,':')) = Last(Split(GrossPathology.hasMember.reference[0],'/'))
     /*as a simplifying convention, when polyp sizes are reported
     as a range in the colonoscopy procedure report (e.g. "6-8 mm"),
     only the HIGHER value is recorded*/
  /*return {ID: Last(Split(O.id,':')),
    Location: (GrossPathology.value as CodeableConcept).text,
    Size: ((O.value as Quantity).value.value).toString() + ' ' +
    (O.value as Quantity).unit
     }*/

define "Polyp pathology":
  from [Observation] O,
  "Gross pathology" GrossPathology
    where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
    and Last(Split(O.id,':')) = Last(Split(GrossPathology.hasMember.reference[1],'/'))
 /*return {ID: Last(Split(O.id,':')),
   Location: (GrossPathology.value as CodeableConcept).text,
   Pathology: (O.value as CodeableConcept).text}*/

define "Full report":
  from
    "Polyp size" PS,
    "Polyp pathology" PP
      where PS.GrossPathology = PP.GrossPathology
    return {ID: PS.GrossPathology.id,
            Specimen: (PS.GrossPathology.value as CodeableConcept).text,
            Size: ((PS.O.value as Quantity).value.value).toString() + ' ' +
                  (PS.O.value as Quantity).unit,
            "Microscopic Pathology": (PP.O.value as CodeableConcept).text}

define "Diagnostic Report":
  [DiagnosticReport] D
  return D.result.reference.value

define "Observations of interest":
  [Observation] O
    // only observations with references..
    where exists(O.partOf.reference)
    // ...to a colonoscopy with polypectomy
    return singleton from O.partOf.reference.value
