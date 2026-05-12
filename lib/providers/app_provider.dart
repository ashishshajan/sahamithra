import 'package:get/get.dart';

/// Mirrors the React AppContext data structure.
class TherapyActivity {
  final String id;
  final String name;
  final String time;
  final int duration; // minutes
  bool completed;

  TherapyActivity({
    required this.id,
    required this.name,
    required this.time,
    required this.duration,
    this.completed = false,
  });
}

class ProgressData {
  final int overall;
  final int grossMotor;
  final int fineMotor;
  final int speech;
  final int cognitive;
  final int social;
  final int streak;
  final int points;
  final List<String> badges;

  const ProgressData({
    required this.overall,
    required this.grossMotor,
    required this.fineMotor,
    required this.speech,
    required this.cognitive,
    required this.social,
    required this.streak,
    required this.points,
    required this.badges,
  });
}

class AppProvider extends GetxController {
  static AppProvider get to => Get.find();

  // ─── Progress data (mirrors AppContext) ─────────────────────────────────────
  final Rx<ProgressData> progressData = const ProgressData(
    overall: 68,
    grossMotor: 75,
    fineMotor: 62,
    speech: 58,
    cognitive: 71,
    social: 80,
    streak: 7,
    points: 1250,
    badges: [
      'First Steps',
      'Goal Getter',
      'Champion',
      'Speed Star',
      'Award Winner',
      'Gift Master',
    ],
  ).obs;

  // ─── Therapy activities ──────────────────────────────────────────────────────
  final RxList<TherapyActivity> therapyActivities = <TherapyActivity>[
    TherapyActivity(
      id: '1',
      name: 'Ball Rolling Exercise',
      time: '9:30 AM',
      duration: 15,
      completed: true,
    ),
    TherapyActivity(
      id: '2',
      name: 'Picture Naming Game',
      time: '3:00 PM',
      duration: 12,
      completed: true,
    ),
    TherapyActivity(
      id: '3',
      name: 'Stacking Blocks',
      time: '5:00 PM',
      duration: 10,
      completed: false,
    ),
    TherapyActivity(
      id: '4',
      name: 'Singing & Clapping',
      time: '7:00 PM',
      duration: 8,
      completed: false,
    ),
    TherapyActivity(
      id: '5',
      name: 'Mirror Face Game',
      time: '10:00 AM',
      duration: 10,
      completed: false,
    ),
  ].obs;

  int get completedCount => therapyActivities.where((a) => a.completed).length;
  int get totalCount => therapyActivities.length;

  void toggleActivity(String id) {
    final idx = therapyActivities.indexWhere((a) => a.id == id);
    if (idx != -1) {
      therapyActivities[idx].completed = !therapyActivities[idx].completed;
      therapyActivities.refresh();
    }
  }

  // ─── User / session data ─────────────────────────────────────────────────────
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  void setUserData(Map<String, dynamic> data) {
    userData.assignAll(data);
  }
}
