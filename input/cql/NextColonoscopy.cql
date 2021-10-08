library NextColonoscopy

// I am using LungCancerScreening as a template for NextColonoscopy
// This is a stub

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
//include FHIRCommon version '4.0.1' called FC

codesystem "SNOMED": 'http://snomed.info/sct'
// codesystem "UTAH_EDU": 'http://utah.edu/epic/proc_code'
codesystem "LOINC": 'http://loinc.org'

valueset "Colonoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "Polyp of Large Intestine": 'http://example.com/bcd6931c-f88c-4df8-aeea-1ee5cc4cf70b'
// code runs with or without the next line
//valueset "Gross Pathology": 'http://example.com/81523557-8a25-45b0-a880-f864b939a75e'
//valueset "PolypOfLargeIntestine": 'http://example.com/768d1418-20b6-4b3a-b0ba-da6c7d576fb7'
//valueset "Colonoscopy": 'http://example.org/fhir/ValueSet/colonoscopy-from-dbcg-cql-evaluator'
// valueset "Lung Cancer":  'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1116.89'
// valueset "Smoking Status": 'http://hl7.org/fhir/us/core/ValueSet/us-core-observation-smokingstatus'
// find at http://build.fhir.org/ig/cqframework/lcs-cds/ValueSet-currentsmoker.json.html
// valueset "Current Smoker": 'http://fhir.org/guides/utah-edu/lcs-cds/ValueSet/currentsmoker'
// valueset "Chest CT": 'http://fhir.org/guides/utah-edu/lcs-cds/ValueSet/chest-ct-proc-code'
// valueset "Condition Clinical Status": 'http://fhir.org/guides/utah-edu/lcs-cds/ValueSet/conditionclinical'

// code "Tobacco Smoking Status": '72166-2' from "LOINC"
// code "Former Smoker": '8517006' from "SNOMED"
// code "PACKS A DAY": '8663-7' from "LOINC" display 'packs per day'

code "Polyp size": '33756-8' from "LOINC" display 'Polyp size greatest dimension'
code "Polyp path": '34574-4' from "LOINC" display 'Pathology report final diagnosis'

context Patient

// Data Elements
/* define "Patient age in years based on date of birth":
  AgeInYears() */

// When a tobacco smoking status is more than 10 years old, should that be a "warning" surfaced to the clinician in some way?
/*define "Smoking status observation":
  [Observation: "Tobacco Smoking Status"] O
    where O.status in { 'final', 'amended' }
      //and FHIRHelpers.ToDateTime(O.issued) 10 years or less before Today()

define "Lung cancer diagnosis":
  [Condition: "Lung Cancer"] C
    where C.clinicalStatus in "Condition Clinical Status"

define "Chest CT procedure":
  [Procedure: "Chest CT"] P
    where P.status = 'completed'

// Intermediate Data Elements
define "55 through 80":
  AgeInYears() >= 55 and AgeInYears() <= 80

define "Most recent smoking status observation":
  Last("Smoking status observation" O
    sort by (FHIRHelpers.ToDateTime(issued))
  )

define "Current smoker observation":
  "Most recent smoking status observation" O
    where (O.value as CodeableConcept) in "Current Smoker"

define "Former smoker observation":
  "Most recent smoking status observation" O
    where (O.value as CodeableConcept) ~ "Former Smoker"

define "Is current smoker":
  "Current smoker observation" is not null

define "Is former smoker who quit within past 15 years":
  ("Former smoker observation" O
    where O.effective ends 15 years or less before Today()
  ) is not null

define "Pack-years":
  "Most recent smoking status observation" O
    let PacksPerDay: singleton from (O.component C where C.code ~ "PACKS A DAY").value,
    DurationInDays: duration in days of O.effective
    return System.Quantity { value: Round((PacksPerDay * (DurationInDays / 365.25)).value), unit: '{Pack-years}' }

define "Has 30 pack-year smoking history":
  "Pack-years" >= 30 '{Pack-years}'

define "Has lung cancer":
  exists ("Lung cancer diagnosis")

define "Had chest CT in past year":
  exists ("Chest CT procedure" P
    where FC.ToInterval(P.performed) ends 1 year or less before Today()
  )

// Inclusion Criteria
define "Inclusion Criteria":
  "55 through 80"
    and ("Is current smoker" or "Is former smoker who quit within past 15 years")
    and "Has 30 pack-year smoking history"
    and not "Has lung cancer"
    and not "Had chest CT in past year"

define "Is Eligible Detail":
  if "Inclusion Criteria"
    then 'Potential eligible patient: ' + First(Patient.name).text +
      ': Born ' + ToString(Patient.birthDate) +
      ' (Age: ' + ToString(AgeInYears()) +
      '), Gender: ' + Patient.gender
  else null

define "Is Eligible Summary":
  if "Inclusion Criteria"
    then 'Recommend shared decision making for lung cancer screening'
  else null

define "Is Eligible Indicator":
  if "Inclusion Criteria"
    then 'info'
  else null

// Exclusion Criteria
define "Exclusion Criteria":
  (
    not ("Is current smoker" or "Is former smoker who quit within past 15 years")
      or "Has lung cancer"
  )

define "Exclusion Detail":
  if "Exclusion Criteria"
    then First(Patient.name).text +
      ': Born ' + ToString(Patient.birthDate) +
      ' (Age: ' + ToString(AgeInYears()) +
      '), Gender: ' + Patient.gender
    else null

define "Exclusion Summary":
  if "Exclusion Criteria"
    then 'Patient is not currently recommended for lung cancer screening'
  else null

define "Exclusion Indicator":
  if "Exclusion Criteria"
    then 'info'
  else null*/

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

  define "Polyp pathology":
    [Observation] O
    where O.status in { 'final', 'amended', 'corrected', 'preliminary' }
      and O.code ~ "Polyp path"

  define "Observation with member":
    [Observation] O
    //let a: Substring(O.hasMember.reference.value,6)
    where exists O.hasMember
    //return O.hasMember.reference

  define "First hasMember reference":
  First("Observation with member")

  //define "id":
  //"First hasMember reference"[0]

  //define "id1":
  //"id" is string

  define "Observation with Observation":
     [Observation] OM
       with [Observation] OO
         such that OM.id.value ~ OO.hasMember.reference[0].id

  define "Union function test":
    (Patient.name.given.value | Patient.name.family.value)
   //.substring(0,4)
  //identifier.where(use = 'official')

  define "Official contact phone":
  Patient.telecom.where(use = 'official')
  //.union(Patient.contact.telecom.where(use = 'official')).exists().not()

  define "Patient full name":
    Patient.name.given.first() + ' ' + Patient.name.family.first()

  define "Observation":
    from [Observation] O,
    "Observation with member" OM
    where Last(Split(O.id,':')) = Last(Split(OM.hasMember.reference[0],'/'))
//    where O.id = resolve(OM.hasMember.reference)
//    return {O: Last(Split(O.id,':')), OM: Last(Split(OM.hasMember.reference[0],'/'))}
    return {O: ((O.value as Quantity).value.value).toString() + ' ' +
      (O.value as Quantity).unit,
      OM: (OM.value as CodeableConcept).text }




//      where C.clinicalStatus in "Condition Clinical Status Active"

/*  define "Has prediabetes":
    Exists("Prediabetes conditions") */
