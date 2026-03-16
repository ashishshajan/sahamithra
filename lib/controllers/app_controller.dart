import 'package:get/get.dart';

/// Global app state — user session, progress data, therapy activities.
class AppController extends GetxController {
  // ── Auth / User ────────────────────────────────────────────────────────────
  final Rx<Map<String, dynamic>?> userData = Rx(null);
  final RxString mobileNumber = ''.obs;
  final RxBool isLoggedIn = false.obs;

  // ── Progress Data ──────────────────────────────────────────────────────────
  final RxInt overallProgress = 68.obs;
  final RxInt streak          = 7.obs;
  final RxInt points          = 1250.obs;

  // ── Therapy Activities ─────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> therapyActivities = <Map<String, dynamic>>[
    {'name': 'Speech Exercise', 'completed': true,  'duration': '20 min'},
    {'name': 'Fine Motor Skills', 'completed': true, 'duration': '15 min'},
    {'name': 'Cognitive Play', 'completed': false,  'duration': '25 min'},
    {'name': 'Sensory Activity', 'completed': false, 'duration': '20 min'},
    {'name': 'Social Interaction', 'completed': false,'duration': '30 min'},
  ].obs;

  int get completedActivities =>
      therapyActivities.where((a) => a['completed'] == true).length;

  // ── Assessment Navigation State ───────────────────────────────────────────
  final RxString lastAssessmentSource = 'assessment-menu'.obs;

  // ── Methods ───────────────────────────────────────────────────────────────
  void setUserData(Map<String, dynamic> data) {
    userData.value = data;
    mobileNumber.value = data['mobileNumber'] ?? '';
    isLoggedIn.value = true;
  }

  void logout() {
    userData.value = null;
    mobileNumber.value = '';
    isLoggedIn.value = false;
  }

  void toggleActivity(int index) {
    final list = List<Map<String, dynamic>>.from(therapyActivities);
    list[index] = {
      ...list[index],
      'completed': !(list[index]['completed'] as bool),
    };
    therapyActivities.value = list;
    if (list[index]['completed'] == true) {
      points.value += 50;
    }
  }
}
