import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Already fully implemented screens
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/public_dashboard_screen.dart';
import '../screens/gamification_screen.dart';
import '../screens/progress_tracking_screen.dart';

// Manually added/continued screens
import '../screens/assessment_menu_screen.dart';
import '../screens/tdsc_assessment_screen.dart';
import '../screens/lest_assessment_screen.dart';

// Newly added complete screens
import '../screens/parental_stress_screen.dart';
import '../screens/parental_stress_screen_new.dart';
import '../screens/risk_factor_screen.dart';
import '../screens/results_screen.dart';
import '../screens/weekly_therapy_schedule_screen.dart';
import '../screens/therapy_videos_screen.dart';
import '../screens/institution_finder_screen.dart';
import '../screens/cdmc_services_screen.dart';
import '../screens/team_collaboration_screen.dart';
import '../screens/appointment_booking_screen.dart';
import '../screens/appointment_history_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/feedback_submission_screen.dart';
import '../screens/data_privacy_screen.dart';
import '../screens/therapist_dashboard_screen.dart';
import '../screens/activity_library_screen.dart';
import '../screens/account_screen.dart';
import '../screens/video_player_screen.dart';

import 'app_routes.dart';

/// All GetX page definitions — every route now has a real screen implementation.
class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    // ── Core flow ──────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OTPVerificationScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.registration,
      page: () => const RegistrationScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.account,
      page: () => const AccountScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.publicDashboard,
      page: () => const PublicDashboardScreen(),
      transition: Transition.cupertino,
    ),

    // ── Gamification & Progress ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.gamification,
      page: () => const GamificationScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.progressTracking,
      page: () => const ProgressTrackingScreen(),
      transition: Transition.cupertino,
    ),

    // ── Assessments ────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.assessmentMenu,
      page: () => const AssessmentMenuScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.tdsc,
      page: () => const TDSCAssessmentScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.lest,
      page: () => const LESTAssessmentScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.stress,
      page: () => const ParentalStressScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.stressNew,
      page: () => const ParentalStressScreenNew(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.risk,
      page: () => const RiskFactorScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.results,
      page: () => const ResultsScreen(),
      transition: Transition.cupertino,
    ),

    // ── Therapy & Schedule ─────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.weeklySchedule,
      page: () => const WeeklyTherapyScheduleScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.videos,
      page: () => const TherapyVideosScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.videoPlayerScreen,
      page: () => const VideoPlayerScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.activityLibrary,
      page: () => const ActivityLibraryScreen(),
      transition: Transition.cupertino,
    ),

    // ── Services & Community ───────────────────────────────────────────────
    GetPage(
      name: AppRoutes.institutions,
      page: () => const InstitutionFinderScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.cdmcServices,
      page: () => const CDMCServicesScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.teamCollaboration,
      page: () => const TeamCollaborationScreen(),
      transition: Transition.cupertino,
    ),

    // ── Appointments, Reports, Reminders ──────────────────────────────────
    GetPage(
      name: AppRoutes.appointments,
      page: () => const AppointmentBookingScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.appointmentHistory,
      page: () => const AppointmentHistoryScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.reminders,
      page: () => const RemindersScreen(),
      transition: Transition.cupertino,
    ),

    // ── Feedback & Privacy ─────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackSubmissionScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.dataPrivacy,
      page: () => const DataPrivacyScreen(),
      transition: Transition.cupertino,
    ),

    // ── Therapist Portal ───────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.therapistDashboard,
      page: () => const TherapistDashboardScreen(),
      transition: Transition.cupertino,
    ),
  ];
}