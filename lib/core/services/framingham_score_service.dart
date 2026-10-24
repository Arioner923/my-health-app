/// Service responsible for Framingham-style risk score calculations.
///
/// This implementation uses a point-based educational approach based on
/// common Framingham risk score factors:
/// - age
/// - gender
/// - total cholesterol
/// - HDL cholesterol
/// - systolic blood pressure
/// - blood pressure treatment
/// - smoking
/// - diabetes
///
/// The result is an estimated 10-year cardiovascular risk percentage.
/// This calculator is for educational/university project purposes only.
class FraminghamScoreService {
  /// Calculates total Framingham-style risk points.
  static int calculateRiskPoints({
    required int age,
    required String gender,
    required int totalCholesterol,
    required int hdlCholesterol,
    required int systolicBp,
    required bool treatedBp,
    required bool smoker,
    required bool diabetes,
  }) {
    final bool isMale = gender == 'Male';

    int points = 0;

    points += _agePoints(age: age, isMale: isMale);
    points += _cholesterolPoints(
      age: age,
      isMale: isMale,
      totalCholesterol: totalCholesterol,
    );
    points += _hdlPoints(hdlCholesterol);
    points += _bloodPressurePoints(
      isMale: isMale,
      systolicBp: systolicBp,
      treatedBp: treatedBp,
    );

    if (smoker) {
      points += _smokerPoints(age: age, isMale: isMale);
    }

    /// Diabetes is included as an additional risk modifier
    /// for this educational project implementation.
    if (diabetes) {
      points += isMale ? 2 : 3;
    }

    return points;
  }

  /// Converts total points into an estimated risk percentage.
  static double calculateRiskPercentage({
    required int riskPoints,
    required String gender,
  }) {
    final bool isMale = gender == 'Male';

    if (isMale) {
      return _maleRiskPercentage(riskPoints);
    }

    return _femaleRiskPercentage(riskPoints);
  }

  /// Returns a risk category based on estimated 10-year risk.
  static String getRiskCategory({
    required double riskPercentage,
    required String lowRiskLabel,
    required String moderateRiskLabel,
    required String highRiskLabel,
  }) {
    if (riskPercentage < 10) {
      return lowRiskLabel;
    }

    if (riskPercentage < 20) {
      return moderateRiskLabel;
    }

    return highRiskLabel;
  }

  /// Age point table.
  static int _agePoints({
    required int age,
    required bool isMale,
  }) {
    if (isMale) {
      if (age <= 34) return -9;
      if (age <= 39) return -4;
      if (age <= 44) return 0;
      if (age <= 49) return 3;
      if (age <= 54) return 6;
      if (age <= 59) return 8;
      if (age <= 64) return 10;
      if (age <= 69) return 11;
      if (age <= 74) return 12;
      return 13;
    }

    if (age <= 34) return -7;
    if (age <= 39) return -3;
    if (age <= 44) return 0;
    if (age <= 49) return 3;
    if (age <= 54) return 6;
    if (age <= 59) return 8;
    if (age <= 64) return 10;
    if (age <= 69) return 12;
    if (age <= 74) return 14;
    return 16;
  }

  /// Total cholesterol point table.
  static int _cholesterolPoints({
    required int age,
    required bool isMale,
    required int totalCholesterol,
  }) {
    final int ageBand = _ageBand(age);
    final int cholesterolBand = _cholesterolBand(totalCholesterol);

    final List<List<int>> maleTable = [
      [0, 4, 7, 9, 11],
      [0, 3, 5, 6, 8],
      [0, 2, 3, 4, 5],
      [0, 1, 1, 2, 3],
      [0, 0, 0, 1, 1],
    ];

    final List<List<int>> femaleTable = [
      [0, 4, 8, 11, 13],
      [0, 3, 6, 8, 10],
      [0, 2, 4, 5, 7],
      [0, 1, 2, 3, 4],
      [0, 1, 1, 2, 2],
    ];

    return isMale
        ? maleTable[ageBand][cholesterolBand]
        : femaleTable[ageBand][cholesterolBand];
  }

  /// HDL cholesterol points.
  static int _hdlPoints(int hdlCholesterol) {
    if (hdlCholesterol >= 60) return -1;
    if (hdlCholesterol >= 50) return 0;
    if (hdlCholesterol >= 40) return 1;
    return 2;
  }

  /// Blood pressure point table.
  static int _bloodPressurePoints({
    required bool isMale,
    required int systolicBp,
    required bool treatedBp,
  }) {
    final int bpBand = _bloodPressureBand(systolicBp);

    final List<int> maleUntreated = [0, 0, 1, 1, 2];
    final List<int> maleTreated = [0, 1, 2, 2, 3];

    final List<int> femaleUntreated = [0, 1, 2, 3, 4];
    final List<int> femaleTreated = [0, 3, 4, 5, 6];

    if (isMale) {
      return treatedBp ? maleTreated[bpBand] : maleUntreated[bpBand];
    }

    return treatedBp ? femaleTreated[bpBand] : femaleUntreated[bpBand];
  }

  /// Smoking point table.
  static int _smokerPoints({
    required int age,
    required bool isMale,
  }) {
    final int ageBand = _ageBand(age);

    final List<int> maleTable = [8, 5, 3, 1, 1];
    final List<int> femaleTable = [9, 7, 4, 2, 1];

    return isMale ? maleTable[ageBand] : femaleTable[ageBand];
  }

  /// Converts age into an age band index.
  static int _ageBand(int age) {
    if (age <= 39) return 0;
    if (age <= 49) return 1;
    if (age <= 59) return 2;
    if (age <= 69) return 3;
    return 4;
  }

  /// Converts total cholesterol into a category index.
  static int _cholesterolBand(int totalCholesterol) {
    if (totalCholesterol < 160) return 0;
    if (totalCholesterol <= 199) return 1;
    if (totalCholesterol <= 239) return 2;
    if (totalCholesterol <= 279) return 3;
    return 4;
  }

  /// Converts systolic blood pressure into a category index.
  static int _bloodPressureBand(int systolicBp) {
    if (systolicBp < 120) return 0;
    if (systolicBp <= 129) return 1;
    if (systolicBp <= 139) return 2;
    if (systolicBp <= 159) return 3;
    return 4;
  }

  /// Male risk percentage lookup.
  static double _maleRiskPercentage(int points) {
    if (points <= 0) return 0.5;
    if (points <= 4) return 1;
    if (points <= 6) return 2;
    if (points == 7) return 3;
    if (points == 8) return 4;
    if (points == 9) return 5;
    if (points == 10) return 6;
    if (points == 11) return 8;
    if (points == 12) return 10;
    if (points == 13) return 12;
    if (points == 14) return 16;
    if (points == 15) return 20;
    if (points == 16) return 25;
    return 30;
  }

  /// Female risk percentage lookup.
  static double _femaleRiskPercentage(int points) {
    if (points < 9) return 0.5;
    if (points <= 12) return 1;
    if (points <= 14) return 2;
    if (points == 15) return 3;
    if (points == 16) return 4;
    if (points == 17) return 5;
    if (points == 18) return 6;
    if (points == 19) return 8;
    if (points == 20) return 11;
    if (points == 21) return 14;
    if (points == 22) return 17;
    if (points == 23) return 22;
    if (points == 24) return 27;
    return 30;
  }
}