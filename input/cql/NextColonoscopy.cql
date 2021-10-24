library NextColonoscopy

// TODO: add hasMember for 787139004 | Piecemeal excision (procedure) | Boolean
//       and 55237006 | Severe dysplasia (morphologic abnormality) |severe dysplasia | Boolean

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
//include FHIRCommon version '4.0.1' called FC

codesystem "SNOMED": 'http://snomed.info/sct'
codesystem "LOINC": 'http://loinc.org'

valueset "Colonoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "Polyp of Large Intestine": 'http://example.com/bcd6931c-f88c-4df8-aeea-1ee5cc4cf70b'
valueset "Adenoma": 'http://example.com/97428d86-47dc-4874-9e9d-b15843c4a3ad'
                    /* should contain:
                    Tubular adenoma of colon | 444898006 -or-
                      Benign tubular adenoma (morphologic abnormality) | 1156654007
                    Villous adenoma of colon (disorder) | 309084001 -or-
                      Villous adenoma (morphologic abnormality) | 128859003
                    Tubulovillous adenoma (morphologic abnormality) | 61722000
                    Right now I favor the morphologic abnormality*
                       (morphologic abnormality) | 55237006 - is in a different category  */
valueset "Adenoma with tubulovillous or villous histology": 'http://example.com/d4912e4f-62fe-434e-8501-a9320ce285c6'


//code "Polyp size": '33756-8' from "LOINC" display 'Polyp size greatest dimension'
//code "Polyp path": '34574-4' from "LOINC" display 'Pathology report final diagnosis'
code "Colonoscopic polypectomy": '311774002' from "SNOMED"
code "Hyperlastic polyp of large intestine": '721691004' from "SNOMED"
code "Tubular adenoma of colon": '444898006' from "SNOMED"
// next three for testing:
code "Benign tubular adenoma (morphologic abnormality)": '444898006' from "SNOMED"
code "Villous adenoma (morphologic abnormality)": '128859003' from "SNOMED"
code  "Tubulovillous adenoma (morphologic abnormality)": '61722000' from "SNOMED"
//code "Tubular adenoma": '444408007' from "SNOMED"
// code "Adenoma with high-grade dysplasia":  Severe dysplasia


// there is a certain ambuguity/overlap between colon and large intestine
// technically large intestine = cecum + colon + rectum
// There is a snomed code for polyp of the large Intestine
// ... but not for tubular adenoma of the large intestine, only
// ... tubular adenomas of the colon, which I will use in its place. .
// 399432003 | Adenoma of large intestine (disorder) |
// There are snomed codes for cecum polyp, asc colon polyp, desc colon polyp, sigmoid polyp and rectal polyp
// ... as well as a code for polyp of the large intestine.
// I'm using Tubular Adenoma of Colon but "Tubular adenoma" would probably be more correct.

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
/*define "Gross pathology":
  [Observation] O
  where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
  and exists O.hasMember*/

/*define "Polyp size":
  from [Observation] O,
  "Gross pathology" GrossPathology
    where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
    and Last(Split(O.id,':')) = Last(Split(GrossPathology.hasMember.reference[0],'/'))*/
     /*as a simplifying convention, when polyp sizes are reported
     as a range in the colonoscopy procedure report (e.g. "6-8 mm"),
     only the HIGHER value is recorded*/
  /*return {ID: Last(Split(O.id,':')),
    Location: (GrossPathology.value as CodeableConcept).text,
    Size: ((O.value as Quantity).value.value).toString() + ' ' +
    (O.value as Quantity).unit
     }*/

/*define "Polyp pathology":
  from [Observation] O,
  "Gross pathology" GrossPathology
    where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
    and Last(Split(O.id,':')) = Last(Split(GrossPathology.hasMember.reference[1],'/'))*/
 /*return {ID: Last(Split(O.id,':')),
   Location: (GrossPathology.value as CodeableConcept).text,
   Pathology: (O.value as CodeableConcept).text}*/

/*define "Old Full report text output":
  from
    "Polyp size" PS,
    "Polyp pathology" PP
      where PS.GrossPathology = PP.GrossPathology
    return {ID: PS.GrossPathology.id,
            Specimen: (PS.GrossPathology.value as CodeableConcept).text,
            Size: ((PS.O.value as Quantity).value).toString() + ' ' +
                  (PS.O.value as Quantity).unit,
            "Microscopic Pathology": (PP.O.value as CodeableConcept).text}*/

/*define "Old Full report":
  from
    "Polyp size" PS,
    "Polyp pathology" PP
      where PS.GrossPathology = PP.GrossPathology
    return {ID: PS.GrossPathology,
            Specimen: PS.GrossPathology.value as CodeableConcept,
            Size: PS.O.value as Quantity,
            "Microscopic Pathology": PP.O.value as CodeableConcept}*/

/*define "Diagnostic Report":
  [DiagnosticReport] D
  return D.result.reference.value*/

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

/*define "References of member Observations":
 "Observations that are part of Colonoscopy with polypectomy" O
 return {Reference: O.hasMember.reference.value}*/

//define "Lenth of polyps":
//"Observations that are part of Colonoscopy with polypectomy" O
//  O.

/*define "IDs of member Observations":
"References of member Observations" R
//can't get to the individual elements this way; can only choose one
return Last(Split(R.Reference.first(),'/'))*/

/*define "Bundle url":
[Bundle] B
return B.entry[0]*/

//Use a tuple to gather together the two detail observation members
/*define "References":
"Observations that are part of Colonoscopy with polypectomy" O
return {Length: Last(Split(O.hasMember.reference[0].value,'/')),
        Path: Last(Split(O.hasMember.reference[1].value,'/'))}*/

/*define "References with ID":
"Observations that are part of Colonoscopy with polypectomy" O
return {"ID and Length": {"Gross ID": Last(Split(O.id,':')),
                 Length: Last(Split(O.hasMember.reference[0].value,'/'))},
        "ID and Path":   {"Gross ID": Last(Split(O.id, ':')),
                 Path: Last(Split(O.hasMember.reference[1].value,'/'))}}*/

/*define "Length References":
"Observations that are part of Colonoscopy with polypectomy" O
return {ID: O.id,
        Length: Last(Split(O.hasMember.reference[0].value,'/'))}*/

/*define "Path References":
"Observations that are part of Colonoscopy with polypectomy" O
return {ID: O.id,
        Path: Last(Split(O.hasMember.reference[1].value,'/'))}*/

// Get the Details
// Sadly this doesn't return quite what I want
/*define "Details":
  from "References" R,
  [Observation] O
    let length: (O.where(O.id.value = ('urn:uuid:' + R.Length)).value as Quantity).value.value.toString(),
      path:   (O.where(O.id.value = ('urn:uuid:' + R.Path)).value as CodeableConcept).coding.display
  return {Length: length, Path: path} //.where(length != null)*/

/*define "Details with ID":
  from "References" R,
  [Observation] O
    let length: (O.where(O.id.value = ('urn:uuid:' + R.Length)).value as Quantity).value.value.toString(),
      path:   (O.where(O.id.value = ('urn:uuid:' + R.Path)).value as CodeableConcept).coding.display
  //where
  return {Length: length, Path: path}*/ //.where(length != null)

/*define "? polyp greater than 7 mm":
  from
    "Polyp size" PS,
    "Polyp pathology" PP
      where PS.GrossPathology = PP.GrossPathology
    return {ID: PS.GrossPathology.id,
            Specimen: (PS.GrossPathology.value as CodeableConcept).text,
//            Size: ((PS.O.value as Quantity).value.value).toString() + ' ' +
                  //(PS.O.value as Quantity).unit,
                  "Size > 7 mm?": (PS.O.value as Quantity) > 7 'mm',
            "Microscopic Pathology": (PP.O.value as CodeableConcept).text}*/

/*define "? tubular adenoma":
  from
    "Polyp size" PS,
    "Polyp pathology" PP
      where PS.GrossPathology = PP.GrossPathology
    return {ID: PS.GrossPathology.id,
            Specimen: (PS.GrossPathology.value as CodeableConcept).text,
            Size: ((PS.O.value as Quantity).value).toString() + ' ' +
                  (PS.O.value as Quantity).unit,
            "? tubular adenoma": (PP.O.value as CodeableConcept)~"Tubular adenoma of colon"}*/

define "? tubular adenoma and < 10 mm":
  "Full report" R
    where R.Size < 10 'mm'
    and R."Microscopic Pathology"~"Tubular adenoma of colon"
    return all {ID: R.ID,
            Specimen: R.Specimen.text,
            Size: (R.Size).value,
            Path: R."Microscopic Pathology".text
          }

define "1-2 tubular adenomas <10 mm":
  Count("? tubular adenoma and < 10 mm") <= 2

define "3-4 tubular adenomas <10 mm":
  3 <= Count("? tubular adenoma and < 10 mm") and Count("? tubular adenoma and < 10 mm") <=4

define "5-10 tubular adenomas <10 mm":
  5 <= Count("? tubular adenoma and < 10 mm") and Count("? tubular adenoma and < 10 mm") <=10

//define "Adenoma >= 10 mm":
/*define "Adenoma valueset test":
  //"Benign tubular adenoma (morphologic abnormality)" in "Adenoma" //t rue
  //"Villous adenoma (morphologic abnormality)"  in "Adenoma"       // true
  //"Tubulovillous adenoma (morphologic abnormality)" in "Adenoma"  // true
  "Colonoscopic polypectomy" in "Adenoma"      */                     // false

define "Any adenoma >= 10 mm":
Count("Full report" R
  where R.Size >= 10 'mm'
  and R."Microscopic Pathology" in "Adenoma"
  return all {ID: R.ID,
          Specimen: R.Specimen.text,
          Size: (R.Size).value.toString() + ' ' + (R.Size).unit,
          Path: R."Microscopic Pathology".text
        }) > 0

//define "Adenomas with tubulovillous or villous histology test":
//"Colonoscopic polypectomy" in "Adenoma with tubulovillous or villous histology"

define "Any adenomas with tubulovillous or villous histology":
Count("Full report" R
//  where R.Size >= 10 'mm'
  where R."Microscopic Pathology" in "Adenoma with tubulovillous or villous histology"
  return all {ID: R.ID,
          Specimen: R.Specimen.text,
          Size: (R.Size).value.toString() + ' ' + (R.Size).unit,
          Path: R."Microscopic Pathology".text
        }) > 0

define ">10 adenomas on single examination":
Count("Full report" R
  //where R.Size >= 10 'mm'
  //where R."Microscopic Pathology" in "Adenoma with tubulovillous or villous histology"
  where R."Microscopic Pathology" in "Adenoma"
  return all {ID: R.ID,
          Specimen: R.Specimen.text,
          Size: (R.Size).value.toString() + ' ' + (R.Size).unit,
          Path: R."Microscopic Pathology".text
        }) > 10

/* define "EOB":
  [ExplanationOfBenefit] E
    //where exists E.contained // all of them
    return all {"Service Request Status": (E.contained[0] as ServiceRequest).status.value,
                "Coverage Type":          (E.contained[1] as Coverage).type.text,
                "O":                      ((E.contained[2] as Observation).value as CodeableConcept).text} */

define "Full report with details":
  "Observations that are part of Colonoscopy with polypectomy" O
    return all {ID: Last(Split(O.id.value,':')),
                Specimen: singleton from (O.value as CodeableConcept).coding.display,
                Size: ((O.contained[0] as Observation).value as Quantity).value.toString() + ' ' + ((O.contained[0] as Observation).value as Quantity).unit.value,
                "Microscopic Pathology": ((O.contained[1] as Observation).value as CodeableConcept).text }

define "Full report":
  "Observations that are part of Colonoscopy with polypectomy" O
    return all {ID: Last(Split(O.id.value,':')),
                Specimen: O.value as CodeableConcept,
                Size: (O.contained[0] as Observation).value as Quantity,
                "Microscopic Pathology": (O.contained[1] as Observation).value as CodeableConcept}

define "Polpy length":
  [Specimen] S
    return {Site: S.collection.bodySite.text.value,
            Size: S.collection.quantity.value.toString() + ' ' + S.collection.quantity.unit.value}

define "Polyp path":
  from [Specimen] S, [Observation] O
    where (Last(Split(O.specimen.reference, '/')) = Last(Split(S.id, ':')))
    return {Description: singleton from S.note.text,
            "Body Site": S.collection.bodySite.text.value,
            Length: S.collection.quantity.value.toString() + ' ' + S.collection.quantity.unit.value,
            Pathology: singleton from (O.value as CodeableConcept).coding.display.value}
