library NextColonoscopy

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
// code "Tubular adenoma": '444408007' from "SNOMED"
// code "Adenoma with high-grade dysplasia":  Severe dysplasiaID

define function "GetId:"(uri String):
  Last(Split(uri, ':'))

define function "GetId/"(uri String ):
    Last(Split(uri, '/'))

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

// not currently referred to
// define "ID from Colonoscopy with polypectomy":
//  [Procedure] P
//    //where singleton from P.code.coding.code.value='311774002'
//    where P.code as CodeableConcept ~ "Colonoscopic polypectomy"
//    return "GetId:"(P.id)

// not currently referred to
// define "Observations that are part of Colonoscopy with polypectomy":
// AKA colon polyp observations
//  [Observation] O
    // only observations with references..
    //where exists(O.partOf.reference)
    // ...to a colonoscopy with polypectomy (in progress)
    //and O.partOf.reference
//      where "ID from Colonoscopy with polypectomy" contains "GetId/"(O.partOf.first().reference.value)
    //return {ID: Last(Split(O.id,'/')),
    //  Description: (O.value as CodeableConcept).coding.display.value}

// not currently referred to
// define "Full report with details":
//  "Observations that are part of Colonoscopy with polypectomy" O
//    return all {ID: "GetId:"(O.id.value),
//                Specimen: singleton from (O.value as CodeableConcept).coding.display,
//                Size: ((O.contained[0] as Observation).value as Quantity).value.toString() +
//                  ' ' + ((O.contained[0] as Observation).value as Quantity).unit.value,
//                "Microscopic Pathology": ((O.contained[1] as Observation).value as CodeableConcept).text }

// not currently referred to
// define "Full report":
//  "Observations that are part of Colonoscopy with polypectomy" O
//    return all {ID: "GetId:"(O.id.value),
//                Specimen: O.value as CodeableConcept,
//                Size: (O.contained[0] as Observation).value as Quantity,
//                "Microscopic Pathology": (O.contained[1] as Observation).value as CodeableConcept}

define "Specimen date and IDs from Colonoscopic polypectomy diagnosticReport":
   from [Procedure] P, [DiagnosticReport] DR
      where P.code ~ "Colonoscopic polypectomy"
      and P.report[0].reference.value=DR.id.value  //assumes only one report
      return {Date: P.performed.end,
              /* "P.report[0].reference": P.report[0].reference,
              "DR.id":DR.id, */
              Specimens: DR.specimen.reference}

define "Specimen IDs from Colonoscopic polypectomy":
  from [Specimen] S,
  "Specimen date and IDs from Colonoscopic polypectomy diagnosticReport" SFP // Specimen From Polypectomy
    where S.id in SFP.Specimens
  return {"Report date": SFP.Date,
          Specimen: S}

define "a":
  "Specimen IDs from Colonoscopic polypectomy".Specimen.id.value

define "Polyp length":
  from [Specimen] S, "Specimen IDs from Colonoscopic polypectomy" SFCP
    where S.id in ("Specimen IDs from Colonoscopic polypectomy".Specimen.id.value)
    return {ID: S.id,
            Date: SFCP."Report date",
            Site: S.collection.bodySite.text.value,
//            Size: S.collection.quantity.value.toString() + ' ' + S.collection.quantity.unit.value}  // for a literal readout
            Size: S.collection.quantity} // for the reminder calculation

// this one works but takes three minutes
// define "Polyp path":
//  from [Specimen] S, [Observation] O1, [Observation] O2, [Observation] O3
//    where (Last(Split(O1.specimen.reference, '/')) = Last(Split(S.id, ':')))
//    and (Last(Split(O2.specimen.reference, '/')) = Last(Split(S.id, ':')))
//    and (Last(Split(O3.specimen.reference, '/')) = Last(Split(S.id, ':')))
//    and singleton from O1.code.coding.code.value~'34574-4' // Pathology report final diagnosis
//    and singleton from O2.code.coding.code.value~'787139004'  // Piecemeal excision
//    and singleton from O3.code.coding.code.value~'55237006' // Severe dysplasia
//    return {Description: singleton from S.note.text,
//            "Body Site": S.collection.bodySite.text.value,
//            Length: S.collection.quantity.value.toString() + ' ' + S.collection.quantity.unit.value,
//            Pathology: singleton from (O1.value as CodeableConcept).coding.display.value,
//            "Piecemeal?": O2.value.value,
//            "High-grade dysplasia?": O3.value.value}

// break up "Polyp path" and then lace it back together using the specimen id
define "Pathology":
  from [Specimen] S, [Observation] O
    where O.specimen.reference=S.id
    and singleton from O.code.coding.code.value~'34574-4' // Pathology report final diagnosis
    return {ID: S.id.value,
            Pathology: O.value as CodeableConcept} // used in reminder calculation

define "Piecemeal?":
  from [Specimen] S, [Observation] O
    where O.specimen.reference = S.id
    and singleton from O.code.coding.code.value~'787139004' // Piecemeal resection?
    return {ID: S.id.value,
            "Piecemeal?": (O.value as boolean).value}

define "Severe dysplasia?":
  from [Specimen] S, [Observation] O
    where O.specimen.reference = S.id
    and singleton from O.code.coding.code.value~'55237006' // severe (high-grade) dysplasia?
    return {ID: S.id.value,
            "Severe Dysplasia": (O.value as boolean).value}

define "Polyp full report":
  from  "Polyp length" L,
        "Pathology" P,
        "Piecemeal?" PM,
        "Severe dysplasia?" SD
  where L.ID=P.ID and L.ID=PM.ID and L.ID = SD.ID
        and P.ID=PM.ID and P.ID=SD.ID
        and PM.ID=SD.ID
  return all {"Specimen ID": L.ID,
          Date: L.Date.value,
          Site: L.Site,
          Size: L.Size,
          Pathology: P.Pathology,
          "Piecemeal?": PM."Piecemeal?",
          "Severe dysplasia?": SD."Severe Dysplasia"}

 define "? tubular adenoma and < 10 mm":
  "Polyp full report" R
    where R.Size < 10 'mm'
    and R."Pathology"~"Tubular adenoma of colon"

define "1-2 tubular adenomas <10 mm":
  Count("? tubular adenoma and < 10 mm") <= 2

define "3-4 tubular adenomas <10 mm":
  3 <= Count("? tubular adenoma and < 10 mm") and Count("? tubular adenoma and < 10 mm") <=4

define "5-10 tubular adenomas <10 mm":
  5 <= Count("? tubular adenoma and < 10 mm") and Count("? tubular adenoma and < 10 mm") <=10

define "Any adenoma >= 10 mm":
Count("Polyp full report" R
  where R.Size >= 10 'mm'
  and R.Pathology in "Adenoma") > 0

define "Any adenoma with tubulovillous or villous histology":
Count("Polyp full report" R
  where R."Pathology" in "Adenoma with tubulovillous or villous histology") > 0

define "Adenoma with high-grade dysplasia":
  Count("Polyp full report" R
    where R."Severe dysplasia?"=true) >0

define ">10 adenomas on single examination":
Count("Polyp full report" R
  where R."Pathology" in "Adenoma") > 10

define "Piecemeal resection of adenoma >20 mm":
  Count("Polyp full report" R
    where R."Piecemeal?"=true) > 0

define "Next colonoscopy interval":
  case
    when "Piecemeal resection of adenoma >20 mm" then Interval[0.5 year, 0.5 year] //-or- point from Interval[0.5, 0.5]
    when ">10 adenomas on single examination" then Interval[1.0 year, 1.0 year]
    when "Adenoma with high-grade dysplasia" then Interval[3.0 years, 3.0 years]
    when "Any adenoma with tubulovillous or villous histology" then Interval[3.0 years, 3.0 years]
    when "Any adenoma >= 10 mm" then Interval[3.0 years, 3.0 years]
    when "5-10 tubular adenomas <10 mm" then Interval[3.0 years, 3.0 years]
    when "3-4 tubular adenomas <10 mm" then Interval[3.0 years, 5.0 years]
    when "1-2 tubular adenomas <10 mm" then Interval[7.0 years, 10.0 years]
    else Interval[10 years, 10.0 years]
  end

define "This colonoscopy date":
  [Procedure] P
    where P.code ~ "Colonoscopic polypectomy"  // this will need to be narrowed where there is more that one colonoscopy polypectomy on file
    return P.performed.end.value

define "Surveillance colonoscopy date low":
  [Procedure] P
    where P.code ~ "Colonoscopic polypectomy"
    return P.performed.end.value + "Next colonoscopy interval".low

define "Surveillance colonoscopy date high":
  [Procedure] P
    where P.code ~ "Colonoscopic polypectomy"
    return P.performed.end.value + "Next colonoscopy interval".high

define "Surveillance colonoscopy date range tuple":
  [Procedure] P
    where P.code ~ "Colonoscopic polypectomy"
    return {"From": ToDate(P.performed.end.value + "Next colonoscopy interval".low),
            "To":   ToDate(P.performed.end.value + "Next colonoscopy interval".high)}

define "Colonoscopic polypectomy diagnosticReport id":
   [Procedure] P
    where P.code ~ "Colonoscopic polypectomy"
    return P.report.reference.value
