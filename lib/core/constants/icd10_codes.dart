/// Local ICD-10 lookup list used by the Problem List module.
///
/// The assignment requires a searchable ICD-9 or ICD-10 list or local lookup.
/// For this project, a small local ICD-10 dataset is used for demonstration.
///
/// Each item contains:
/// - ICD-10 code
/// - diagnosis/problem title
///
/// More ICD-10 codes can be added later without changing the UI logic.
const List<Map<String, String>> icd10Codes = [
  {
    'code': 'I10',
    'title': 'Essential hypertension',
  },
  {
    'code': 'E11',
    'title': 'Type 2 diabetes mellitus',
  },
  {
    'code': 'J45',
    'title': 'Asthma',
  },
  {
    'code': 'E78.5',
    'title': 'Hyperlipidemia',
  },
  {
    'code': 'F32',
    'title': 'Depressive episode',
  },
  {
    'code': 'I25.10',
    'title': 'Atherosclerotic heart disease',
  },
  {
    'code': 'N18.9',
    'title': 'Chronic kidney disease, unspecified',
  },
  {
    'code': 'K21.9',
    'title': 'Gastro-esophageal reflux disease without esophagitis',
  },
  {
    'code': 'M54.5',
    'title': 'Low back pain',
  },
  {
    'code': 'E66.9',
    'title': 'Obesity, unspecified',
  },
  {
    'code': 'J30.9',
    'title': 'Allergic rhinitis, unspecified',
  },
  {
    'code': 'G43.9',
    'title': 'Migraine, unspecified',
  },
  {
    'code': 'D50.9',
    'title': 'Iron deficiency anemia, unspecified',
  },
  {
    'code': 'F41.9',
    'title': 'Anxiety disorder, unspecified',
  },
  {
    'code': 'M81.0',
    'title': 'Age-related osteoporosis without current pathological fracture',
  },
];