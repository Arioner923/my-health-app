/// Model class for storing patient demographic information.
///
/// This class represents the basic demographic data required by the project:
/// - name
/// - age
/// - gender
/// - race
/// - ethnicity
/// - birthday
/// - city
/// - country
///
/// The model includes toMap() and fromMap() methods so it can be easily
/// saved and loaded from local storage.
class PatientModel {
  final String name;
  final String age;
  final String gender;
  final String race;
  final String ethnicity;
  final String birthday;
  final String city;
  final String country;

  const PatientModel({
    required this.name,
    required this.age,
    required this.gender,
    required this.race,
    required this.ethnicity,
    required this.birthday,
    required this.city,
    required this.country,
  });

  /// Converts the PatientModel object into a Map.
  ///
  /// This is useful when saving the object as JSON in local storage.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'race': race,
      'ethnicity': ethnicity,
      'birthday': birthday,
      'city': city,
      'country': country,
    };
  }

  /// Creates a PatientModel object from a Map.
  ///
  /// This is useful when reading saved JSON data from local storage.
  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      gender: map['gender'] ?? '',
      race: map['race'] ?? '',
      ethnicity: map['ethnicity'] ?? '',
      birthday: map['birthday'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
    );
  }
}