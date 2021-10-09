library NextColonoscopy

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
//include FHIRCommon version '4.0.1' called FC

codesystem "SNOMED": 'http://snomed.info/sct'
codesystem "LOINC": 'http://loinc.org'

valueset "Colonoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "Polyp of Large Intestine": 'http://example.com/bcd6931c-f88c-4df8-aeea-1ee5cc4cf70b'

code "Polyp size": '33756-8' from "LOINC" display 'Polyp size greatest dimension'
code "Polyp path": '34574-4' from "LOINC" display 'Pathology report final diagnosis'

context Patient

define "Had Colonoscopy":
  [Procedure: "Colonoscopy"] P

define "First colonoscopy in the list":
"Had Colonoscopy"[0]

define "Found polyps":
  [Observation] O
    where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
      and (O.value as CodeableConcept) in "Polyp of Large Intestine"

define "Polyp length":
  [Observation] O
  where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
    and O.code ~ "Polyp size"
    return O.id.value

define "Polyp report":
  [Observation] O
  where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
    and O.code ~ "Polyp path"

define "Observation with member":
  [Observation] O
  where exists O.hasMember

define "First hasMember reference":
  First("Observation with member")

define "Observation with Observation":
   [Observation] OM
     with [Observation] OO
       such that OM.id.value ~ OO.hasMember.reference[0].id

define "Union function test":
  (Patient.name.given.value | Patient.name.family.value)

define "Official contact phone":
Patient.telecom.where(use = 'official')

define "Patient full name":
  Patient.name.given.first() + ' ' + Patient.name.family.first()

define "Polpy size":
  from [Observation] O,
  "Observation with member" OM
    where Last(Split(O.id,':')) = Last(Split(OM.hasMember.reference[0],'/'))
     /*as a simplifying convention, when polyp sizes are reported
     as a range in the colonoscopy procedure report (e.g. "6-8 mm"),
     only the HIGHER value is recorded*/
  /*return {ID: Last(Split(O.id,':')),
    Location: (OM.value as CodeableConcept).text,
    Size: ((O.value as Quantity).value.value).toString() + ' ' +
    (O.value as Quantity).unit
     }*/

define "Polyp pathology":
  from [Observation] O,
  "Observation with member" OM
    where Last(Split(O.id,':')) = Last(Split(OM.hasMember.reference[1],'/'))
 /*return {ID: Last(Split(O.id,':')),
   Location: (OM.value as CodeableConcept).text,
   Pathology: (O.value as CodeableConcept).text}*/

define "Full report":
  from
    "Polpy size" PS,
    "Polyp pathology" PP
      where PS.OM = PP.OM
    return {Location: (PS.OM.value as CodeableConcept).text,
            Size: ((PS.O.value as Quantity).value.value).toString() + ' ' +
                  (PS.O.value as Quantity).unit,
            Path: (PP.O.value as CodeableConcept).text}
