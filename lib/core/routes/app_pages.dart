import 'package:get/get.dart';
import 'app_routes.dart';
import '../../screens/splash_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/otp_verification_screen.dart';
import '../../screens/registration_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/public_dashboard_screen.dart';
import '../../screens/assessment_menu_screen.dart';
import '../../screens/tdsc_assessment_screen.dart';
import '../../screens/lest_assessment_screen.dart';
import '../../screens/results_screen.dart';
import '../../screens/parental_stress_screen.dart';
import '../../screens/risk_factor_screen.dart';
import '../../screens/institution_finder_screen.dart';
import '../../screens/therapy_videos_screen.dart';
import '../../screens/therapist_dashboard_screen.dart';
import '../../screens/activity_library_screen.dart';
import '../../screens/progress_tracking_screen.dart';
import '../../screens/gamification_screen.dart';
import '../../screens/appointment_booking_screen.dart';
import '../../screens/team_collaboration_screen.dart';
import '../../screens/cdmc_services_screen.dart';
import '../../screens/weekly_therapy_schedule_screen.dart';
import '../../screens/reminders_screen.dart';
import '../../screens/feedback_submission_screen.dart';
import '../../screens/data_privacy_screen.dart';
import '../../screens/reports_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: AppRoutes.publicDashboard,
      page: () => const PublicDashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.assessmentMenu,
      page: () => const AssessmentMenuScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OTPVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.registration,
      page: () => const RegistrationScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.tdsc,
      page: () => const TDSCAssessmentScreen(),
    ),
    GetPage(
      name: AppRoutes.lest,
      page: () => const LESTAssessmentScreen(),
    ),
    GetPage(
      name: AppRoutes.results,
      page: () => const ResultsScreen(),
    ),
    GetPage(
      name: AppRoutes.stress,
      page: () => const ParentalStressScreen(),
    ),
    GetPage(
      name: AppRoutes.risk,
      page: () => const RiskFactorScreen(),
    ),
    GetPage(
      name: AppRoutes.institutions,
      page: () => const InstitutionFinderScreen(),
    ),
    GetPage(
      name: AppRoutes.videos,
      page: () => const TherapyVideosScreen(),
    ),
    GetPage(
      name: AppRoutes.therapistDashboard,
      page: () => const TherapistDashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.activityLibrary,
      page: () => const ActivityLibraryScreen(),
    ),
    GetPage(
      name: AppRoutes.progressTracking,
      page: () => const ProgressTrackingScreen(),
    ),
    GetPage(
      name: AppRoutes.gamification,
      page: () => const GamificationScreen(),
    ),
    GetPage(
      name: AppRoutes.appointmentBooking,
      page: () => const AppointmentBookingScreen(),
    ),
    GetPage(
      name: AppRoutes.teamCollaboration,
      page: () => const TeamCollaborationScreen(),
    ),
    GetPage(
      name: AppRoutes.cdmcServices,
      page: () => const CDMCServicesScreen(),
    ),
    GetPage(
      name: AppRoutes.weeklySchedule,
      page: () => const WeeklyTherapyScheduleScreen(),
    ),
    GetPage(
      name: AppRoutes.reminders,
      page: () => const RemindersScreen(),
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackSubmissionScreen(),
    ),
    GetPage(
      name: AppRoutes.dataPrivacy,
      page: () => const DataPrivacyScreen(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsScreen(),
    ),
  ];
}
