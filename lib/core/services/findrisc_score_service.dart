/// Service responsible for FINDRISC score calculation.
///
/// The FINDRISC score is calculated by adding points from eight risk factors:
/// - age
/// - BMI
/// - waist circumference
/// - physical activity
/// - fruit/vegetable intake
/// - blood pressure medication
/// - history of high blood glucose
/// - family history of diabetes
///
/// This calculator is implemented for educational/university project purposes.
class FindriscScoreService {
  /// Calculates the total FINDRISC score.
  static int calculateTotalScore({
    required int ageScore,
    required int bmiScore,
    required int waistScore,
    required int activityScore,
    required int dietScore,
    required int bpMedicationScore,
    required int glucoseScore,
    required int familyHistoryScore,
  }) {
    return ageScore +
        bmiScore +
        waistScore +
        activityScore +
        dietScore +
        bpMedicationScore +
        glucoseScore +
        familyHistoryScore;
  }

  /// Returns the FINDRISC risk category based on total score.
  ///
  /// Common FINDRISC interpretation:
  /// - less than 7: low risk
  /// - 7 to 11: slightly elevated risk
  /// - 12 to 14: moderate risk
  /// - 15 to 20: high risk
  /// - over 20: very high risk
  static String getRiskCategory({
    required int totalScore,
    required String lowRiskLabel,
    required String slightlyElevatedRiskLabel,
    required String moderateRiskLabel,
    required String highRiskLabel,
    required String veryHighRiskLabel,
  }) {
    if (totalScore < 7) {
      return lowRiskLabel;
    }

    if (totalScore <= 11) {
      return slightlyElevatedRiskLabel;
    }

    if (totalScore <= 14) {
      return moderateRiskLabel;
    }

    if (totalScore <= 20) {
      return highRiskLabel;
    }

    return veryHighRiskLabel;
  }
}