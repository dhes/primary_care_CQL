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

define "Colonoscopy with polypectomy":
  [Procedure] P
    //where singleton from P.code.coding.code.value='311774002'
    where P.code as CodeableConcept ~ "Colonoscopic polypectomy"
    return Last(Split(P.id,':'))

define "Observations that are part of Colonoscopy with polypectomy":
// AKA colon polyp observations
  [Observation] O
    // only observations with references..
    //where exists(O.partOf.reference)
    // ...to a colonoscopy with polypectomy (in progress)
    //and O.partOf.reference
    where "Colonoscopy with polypectomy" contains Last(Split(O.partOf.first().reference.value,'/'))
    //return {ID: Last(Split(O.id,'/')),
    //  Description: (O.value as CodeableConcept).coding.display.value}

define "References of member Observations":
 "Observations that are part of Colonoscopy with polypectomy" O
 return {Reference: O.hasMember.reference.value}

//define "Lenth of polyps":
//"Observations that are part of Colonoscopy with polypectomy" O
//  O.

define "IDs of member Observations":
"References of member Observations" R
//can't get to the individual elements this way; can only choose one
return Last(Split(R.Reference.first(),'/'))

/*define "Bundle url":
[Bundle] B
return B.entry[0]*/

//Use a tuple to gather together the two detail observation members
define "References":
"Observations that are part of Colonoscopy with polypectomy" O
return {Length: Last(Split(O.hasMember.reference[0].value,'/')), Path: Last(Split(O.hasMember.reference[1].value,'/'))}

// Get the Details
// Sadly this doesn't return quite what I want
define "Details":
  from "References" R,
  [Observation] O
    let length: (O.where(O.id.value = ('urn:uuid:' + R.Length)).value as Quantity),
      path: (O.where(O.id.value = ('urn:uuid:' + R.Path))).value as CodeableConcept
      //let x: Last(Split(O.id.value, ':'))
  return all {Length: length, Path: path}
