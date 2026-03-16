/// All translations from /contexts/LanguageContext.tsx
/// Supports: English ('en') and Malayalam ('ml')
class AppLocalizations {
  AppLocalizations._();

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // App
      'appName': 'SAHAMITHRA',
      'appTagline': 'Child Development Assessment App',

      // Common
      'continue': 'Continue',
      'back': 'Back',
      'next': 'Next',
      'skip': 'Skip',
      'cancel': 'Cancel',
      'save': 'Save',
      'submit': 'Submit',
      'download': 'Download',
      'share': 'Share',
      'viewDetails': 'View Details',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
      'loading': 'Loading...',
      'retry': 'Retry',
      'error': 'Error',
      'success': 'Success',

      // Splash
      'welcomeTo': 'Welcome to',
      'childDevelopment': 'Child Development Assessment',

      // Onboarding
      'welcomeTitle': 'Welcome to SAHAMITHRA',
      'welcomeDesc':
          'Your trusted companion for child development assessment and therapy management',
      'assessmentsTitle': 'Comprehensive Assessments',
      'assessmentsDesc':
          'Evidence-based developmental screening tools for children 0-6 years',
      'therapyTitle': 'Therapy Support',
      'therapyDesc':
          'Access expert-guided therapy videos and connect with specialized institutions',
      'trackingTitle': 'Progress Tracking',
      'trackingDesc':
          'Monitor your child\'s development with detailed reports and gamified milestones',
      'getStarted': 'Get Started',

      // Login
      'parentLogin': 'Parent Login',
      'guestAccess': 'Guest Access',
      'therapistLogin': 'Therapist Login',
      'motherAadhaar': "Mother's Mobile Number",
      'enterAadhaar': 'Enter 10-digit mobile number',
      'enterOtp': 'Enter OTP',
      'enterOtpPlaceholder': 'Enter 6-digit OTP',
      'verifyLogin': 'Verify & Login',
      'resendOtp': 'Resend OTP',
      'didntReceiveOtp': "Didn't receive OTP?",
      'otpSent': 'OTP Sent',
      'sendingOtp': 'Sending OTP...',
      'verifying': 'Verifying...',
      'otpSentSuccess': 'OTP sent to your mobile number',
      'otpVerifiedSuccess': 'OTP verified successfully!',
      'otpResent': 'OTP resent to your mobile number',
      'enterValidMobile': 'Please enter a valid 10-digit mobile number',
      'enterValidOtp': 'Please enter a valid 6-digit OTP',
      'mobileStartWith': 'Mobile number must start with 6, 7, 8, or 9',
      'digits': 'digits',
      'complete': 'Complete',
      'otpSentTo': 'OTP sent to +91',
      'aboutSahamithra': 'About SAHAMITHRA',
      'aboutPoint1': 'Developmental screening for children 0-6 years',
      'aboutPoint2': 'Self-administrable assessment tools',
      'aboutPoint3': 'Connect with therapy institutions',
      'aboutPoint4': 'Access home-based therapy videos',
      'submittedBy': 'Submitted by CRC Kerala & NHM Kozhikode',
      'presentedBy': 'Presented by Dr. Roshan Bijlee, Director CRC Kerala',

      // Registration
      'completeProfile': 'Complete Your Profile',
      'childInformation': 'Child Information',
      'childNameLabel': "Child's Name",
      'childNamePlaceholder': "Enter child's full name",
      'dateOfBirth': 'Date of Birth',
      'selectDate': 'Select date',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
      'parentInformation': 'Parent Information',
      'parentName': "Parent's Name",
      'parentNamePlaceholder': 'Enter your full name',
      'relationshipToChild': 'Relationship to Child',
      'mother': 'Mother',
      'father': 'Father',
      'guardian': 'Guardian',
      'email': 'Email (Optional)',
      'emailPlaceholder': 'your.email@example.com',
      'district': 'District',
      'selectDistrict': 'Select district',
      'kozhikode': 'Kozhikode',
      'completeRegistration': 'Complete Registration',

      // Dashboard
      'welcome': 'Welcome',
      'childName': "Child's Name",
      'therapistPortal': 'Therapist Portal',
      'overallProgress': 'Overall Progress',
      'fromLastMonth': 'from last month',
      'achievementsUnlocked': 'Achievements Unlocked!',
      'dayStreak': 'day streak',
      'points': 'points',
      'thisWeeksTherapy': "This Week's Therapy",
      'activitiesCompleted': 'activities completed',

      // Sections
      'assessments': 'Assessments',
      'services': 'Services',
      'quickActions': 'Quick Actions',

      // Assessment cards
      'developmentalScreening': 'Developmental Screening',
      'tdscRange': 'TDSC (0-6 years)',
      'tdscDescription': 'Trivendrum Developmental Screening Chart',
      'lestDescription': 'Language Evaluation Scale Trivandrum',
      'parentalStressScale': 'Parental Stress Scale',
      'selfAssessment': 'Self-assessment (36 items)',
      'riskFactorChecklist': 'Risk Factor Checklist',
      'optionalAssessment': 'Optional assessment',

      // Services
      'cdmcServices': 'CDMC Services',
      'integratedCare': 'Integrated disability care',
      'findTherapyCenters': 'Find Therapy Centers',
      'gpsEnabled': 'GPS-enabled location finder',
      'homeTherapyVideos': 'Home Therapy Videos',
      'expertGuided': 'Expert-guided therapy modules',
      'careTeam': 'Care Team',
      'teamCollaboration': 'Multidisciplinary collaboration',

      // Quick Actions
      'bookAppointment': 'Book Appointment',
      'viewReports': 'View Reports',
      'reminders': 'Reminders',
      'giveFeedback': 'Give Feedback',
      'privacySecurity': 'Privacy & Security',

      // Public Dashboard
      'exploreFeatures': 'Explore Features',
      'tryAssessment': 'Try Assessment',
      'watchVideos': 'Watch Therapy Videos',
      'findInstitution': 'Find Institution',
      'loginForFull': 'Login for full access',

      // Assessment Menu
      'selectAssessment': 'Select Assessment',
      'tdsc': 'TDSC',
      'lest': 'LEST',
      'stress': 'Parental Stress',
      'risk': 'Risk Factors',

      // Results
      'assessmentResults': 'Assessment Results',
      'developmentalAge': 'Developmental Age',
      'chronologicalAge': 'Chronological Age',
      'months': 'months',
      'years': 'years',
      'developmentStatus': 'Development Status',
      'normal': 'Normal',
      'delayed': 'Delayed',
      'recommendations': 'Recommendations',
      'viewFullReport': 'View Full Report',
      'saveResults': 'Save Results',

      // Reports
      'reportsDocuments': 'Reports & Documents',
      'completeHealthRecords': 'Complete health records',
      'thisWeek': 'This Week',
      'thisMonth': 'This Month',
      'thisQuarter': 'This Quarter',
      'allTime': 'All Time',
      'assessmentReports': 'Assessment Reports',
      'progressReports': 'Progress Reports',
      'therapyReports': 'Therapy Session Reports',
      'medicalRecords': 'Medical Records',
      'reportGenerated': 'Report Generated',
      'downloadReport': 'Download Report',
      'shareReport': 'Share Report',

      // Therapy Schedule
      'therapySchedule': 'Therapy Schedule',
      'weekOf': 'Week of',
      'todaysGoals': "Today's Goals",
      'scheduledActivities': 'Scheduled Activities',
      'noActivitiesScheduled': 'No activities scheduled for this day',
      'restDay': 'Rest day - enjoy quality time together!',
      'weeklyProgress': 'Weekly Progress',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',

      // Therapy Videos
      'therapyVideoLibrary': 'Therapy Video Library',
      'searchVideos': 'Search videos...',
      'allCategories': 'All Categories',
      'speech': 'Speech Therapy',
      'occupational': 'Occupational Therapy',
      'physical': 'Physical Therapy',
      'behavioral': 'Behavioral Therapy',

      // Institution Finder
      'findNearbyInstitutions': 'Find Nearby Institutions',
      'searchLocation': 'Search location...',
      'useCurrentLocation': 'Use Current Location',
      'mapView': 'Map View',
      'listView': 'List View',
      'km': 'km',
      'away': 'away',
      'getDirections': 'Get Directions',
      'callNow': 'Call Now',

      // Gamification
      'yourProgress': 'Your Progress',
      'achievements': 'Achievements',
      'badges': 'Badges',
      'streak': 'Streak',
      'totalPoints': 'Total Points',
      'level': 'Level',
      'nextLevel': 'Next Level',

      // Appointments
      'appointmentBooking': 'Appointment Booking',
      'selectTime': 'Select Time',
      'selectInstitution': 'Select Institution',
      'appointmentType': 'Appointment Type',
      'consultation': 'Consultation',
      'therapy': 'Therapy Session',
      'followUp': 'Follow-up',
      'bookNow': 'Book Now',
      'upcomingAppointments': 'Upcoming Appointments',

      // Feedback
      'submitFeedback': 'Submit Feedback',
      'feedbackType': 'Feedback Type',
      'suggestion': 'Suggestion',
      'complaint': 'Complaint',
      'appreciation': 'Appreciation',
      'yourFeedback': 'Your Feedback',
      'enterFeedback': 'Enter your feedback here...',

      // Data Privacy
      'dataPrivacy': 'Data Privacy & Security',
      'yourDataSafe': 'Your data is safe with us',
      'encryptedData': 'End-to-end encryption',
      'secureStorage': 'Secure cloud storage',
      'gdprCompliant': 'GDPR compliant',
      'manageData': 'Manage Your Data',
      'exportData': 'Export Data',
      'deleteAccount': 'Delete Account',

      // Language
      'selectLanguage': 'Select Language',
      'english': 'English',
      'malayalam': 'മലയാളം',
      'changeLanguage': 'Change Language',

      // Footer nav
      'home': 'Home',
      'schedule': 'Schedule',
      'progress': 'Progress',
      'profile': 'Profile',

      'trackProgress': 'Track your child\'s progress',
    },
    'ml': {
      // App
      'appName': 'സഹമിത്ര',
      'appTagline': 'കുട്ടികളുടെ വികസന വിലയിരുത്തൽ ആപ്പ്',

      // Common
      'continue': 'തുടരുക',
      'back': 'തിരികെ',
      'next': 'അടുത്തത്',
      'skip': 'ഒഴിവാക്കുക',
      'cancel': 'റദ്ദാക്കുക',
      'save': 'സംരക്ഷിക്കുക',
      'submit': 'സമർപ്പിക്കുക',
      'download': 'ഡൗൺലോഡ് ചെയ്യുക',
      'share': 'പങ്കിടുക',
      'viewDetails': 'വിശദാംശങ്ങൾ കാണുക',
      'close': 'അടയ്ക്കുക',
      'yes': 'ഉവ്വ്',
      'no': 'ഇല്ല',
      'loading': 'ലോഡിംഗ്...',
      'retry': 'പുനരാവർത്തിക്കുക',
      'error': 'പിശക്',
      'success': 'വിജയകരം',

      // Splash
      'welcomeTo': 'സ്വാഗതം',
      'childDevelopment': 'കുട്ടികളുടെ വികസന വിലയിരുത്തൽ',

      // Onboarding
      'welcomeTitle': 'സഹമിത്രയിലേക്ക് സ്വാഗതം',
      'welcomeDesc':
          'കുട്ടികളുടെ വികസന വിലയിരുത്തൽ മാനജ്‌മെന്റിന്റെ നിർവ്വഹണ സഹായി',
      'assessmentsTitle': 'മുഴുവൻ വിലയിരുത്തലുകൾ',
      'assessmentsDesc':
          '0-6 വയസ്സ് വരെയുള്ള കുട്ടികൾക്കുള്ള പ്രമുഖ വികസന പരിശോധന ഉപകരണങ്ങൾ',
      'therapyTitle': 'തെറാപ്പി സഹായം',
      'therapyDesc':
          'വിദഗ്ദ്ധ നിർദ്ദേശിത തെറാപ്പി വീഡിയോകൾ ആക്സസ് ചെയ്യുക',
      'trackingTitle': 'പുരോഗതി പിന്തുണ',
      'trackingDesc':
          'വിശദമായ റിപ്പോർട്ടുകളും ഗെയ്‌മിഫൈഡ് മൈൽസ്‌റ്റോണുകളും ഉപയോഗിച്ച് കുട്ടിയുടെ വികസനം നിരീക്ഷിക്കുക',
      'getStarted': 'ആരംഭിക്കുക',

      // Login
      'parentLogin': 'രക്ഷിതാവിന്റെ പ്രവേശനം',
      'guestAccess': 'അതിഥി പ്രവേശനം',
      'therapistLogin': 'തെറാപ്പിസ്റ്റ് പ്രവേശനം',
      'motherAadhaar': 'അമ്മയുടെ മൊബൈൽ നമ്പർ',
      'enterAadhaar': '10 അക്ക മൊബൈൽ നമ്പർ നൽകുക',
      'enterOtp': 'OTP നൽകുക',
      'enterOtpPlaceholder': '6 അക്ക OTP നൽകുക',
      'verifyLogin': 'സ്ഥിരീകരിക്കുക & പ്രവേശിക്കുക',
      'resendOtp': 'OTP വീണ്ടും അയക്കുക',
      'didntReceiveOtp': 'OTP ലഭിച്ചില്ലേ?',
      'otpSent': 'OTP അയച്ചു',
      'sendingOtp': 'OTP അയക്കുന്നു...',
      'verifying': 'സ്ഥിരീകരിക്കുന്നു...',
      'otpSentSuccess': 'OTP മൊബൈൽ നമ്പറിലേക്ക് അയച്ചു',
      'otpVerifiedSuccess': 'OTP വിജയകരമായി സ്ഥിരീകരിച്ചു!',
      'otpResent': 'OTP വീണ്ടും അയച്ചു',
      'enterValidMobile': 'ദയവായി സാധുവായ 10 അക്ക മൊബൈൽ നമ്പർ നൽകുക',
      'enterValidOtp': 'ദയവായി സാധുവായ 6 അക്ക OTP നൽകുക',
      'mobileStartWith': 'മൊബൈൽ നമ്പർ 6, 7, അല്ലെങ്കിൽ 8 ൽ ആരംഭിക്കണം',
      'digits': 'അക്കങ്ങൾ',
      'complete': 'പൂർണ്ണം',
      'otpSentTo': 'OTP അയച്ചത് +91',
      'aboutSahamithra': 'സഹമിത്രയെ കുറിച്ച്',
      'aboutPoint1': '0-6 വയസ്സ് കുട്ടികൾക്ക് വികസന പരിശോധന',
      'aboutPoint2': 'സ്വയം നടത്താവുന്ന വിലയിരുത്തൽ ഉപകരണങ്ങൾ',
      'aboutPoint3': 'തെറാപ്പി സ്ഥാപനങ്ങളുമായി ബന്ധം',
      'aboutPoint4': 'ഗൃഹ തെറാപ്പി വീഡിയോകൾ ആക്സസ് ചെയ്യുക',
      'submittedBy': 'സമർപ്പിച്ചത്: CRC കേരള & NHM കോഴിക്കോട്',
      'presentedBy': 'അവതരിപ്പിച്ചത്: ഡോ. റോഷൻ ബിജ്ലി, ഡയറക്ടർ CRC കേരള',

      // Registration
      'completeProfile': 'പ്രൊഫൈൽ പൂർത്തിയാക്കുക',
      'childInformation': 'കുട്ടിയുടെ വിവരങ്ങൾ',
      'childNameLabel': 'കുട്ടിയുടെ പേര്',
      'childNamePlaceholder': 'കുട്ടിയുടെ പൂർണ്ണ പേര് നൽകുക',
      'dateOfBirth': 'ജനനതീയതി',
      'gender': 'ലിംഗം',
      'male': 'പുരുഷൻ',
      'female': 'സ്ത്രീ',
      'other': 'മറ്റുള്ളത്',
      'parentInformation': 'രക്ഷിതാവിന്റെ വിവരങ്ങൾ',
      'parentName': 'രക്ഷിതാവിന്റെ പേര്',
      'parentNamePlaceholder': 'നിങ്ങളുടെ പൂർണ്ണ പേര് നൽകുക',
      'relationshipToChild': 'കുട്ടിയുമായുള്ള ബന്ധം',
      'mother': 'അമ്മ',
      'father': 'അച്ഛൻ',
      'guardian': 'രക്ഷകൻ',
      'email': 'ഇമെയിൽ (ഓപ്ഷണൽ)',
      'emailPlaceholder': 'your.email@example.com',
      'district': 'ജില്ല',
      'selectDistrict': 'ജില്ല തിരഞ്ഞെടുക്കുക',
      'kozhikode': 'കോഴിക്കോട്',
      'completeRegistration': 'രജിസ്ട്രേഷൻ പൂർത്തിയാക്കുക',

      // Dashboard
      'welcome': 'സ്വാഗതം',
      'childName': 'കുട്ടിയുടെ പേര്',
      'therapistPortal': 'തെറാപ്പിസ്റ്റ് പോർട്ടൽ',
      'overallProgress': 'മൊത്തം പുരോഗതി',
      'fromLastMonth': 'കഴിഞ്ഞ മാസത്തെ അപേക്ഷിച്ച്',
      'achievementsUnlocked': 'നേട്ടങ്ങൾ അൺലോക്ക് ചെയ്തു!',
      'dayStreak': 'ദിവസ തുടർ',
      'points': 'പോയിന്റ്',
      'thisWeeksTherapy': 'ഈ ആഴ്ചത്തെ തെറാപ്പി',
      'activitiesCompleted': 'പ്രവർത്തനങ്ങൾ പൂർത്തിയാക്കി',

      // Sections
      'assessments': 'വിലയിരുത്തലുകൾ',
      'services': 'സേവനങ്ങൾ',
      'quickActions': 'വേഗ പ്രവർത്തനങ്ങൾ',

      // Assessment cards
      'developmentalScreening': 'വികസന പരിശോധന',
      'tdscRange': 'TDSC (0-6 വയസ്സ്)',
      'tdscDescription': 'തിരുവനന്തപുരം വികസന പരിശോധന ചാർട്ട്',
      'lestDescription': 'ഭാഷ മൂല്യനിർണ്ണയ സ്‌കെയിൽ',
      'parentalStressScale': 'രക്ഷാകർതൃ സ്ട്രെസ് സ്‌കെയിൽ',
      'selfAssessment': 'സ്വയം വിലയിരുത്തൽ (36 ഇനങ്ങൾ)',
      'riskFactorChecklist': 'റിസ്ക് ഫാക്ടർ ചെക്ക്ലിസ്റ്റ്',
      'optionalAssessment': 'ഓപ്ഷണൽ വിലയിരുത്തൽ',

      // Services
      'cdmcServices': 'CDMC സേവനങ്ങൾ',
      'integratedCare': 'സംയോജിത ഭിന്നശേഷി പരിചരണം',
      'findTherapyCenters': 'തെറാപ്പി സെന്ററുകൾ കണ്ടെത്തുക',
      'gpsEnabled': 'GPS ലൊക്കേഷൻ കണ്ടെത്തൽ',
      'homeTherapyVideos': 'ഗൃഹ തെറാപ്പി വീഡിയോകൾ',
      'expertGuided': 'വിദഗ്ദ്ധ നിർദ്ദേശിത മൊഡ്യൂളുകൾ',
      'careTeam': 'പരിചരണ സംഘം',
      'teamCollaboration': 'ബഹുവിഭാഗ സഹകരണം',

      // Quick Actions
      'bookAppointment': 'അപ്പോയ്ന്റ്മെന്റ് ബുക്ക് ചെയ്യുക',
      'viewReports': 'റിപ്പോർട്ടുകൾ കാണുക',
      'reminders': 'ഓർമ്മപ്പെടുത്തലുകൾ',
      'giveFeedback': 'ഫീഡ്ബാക്ക് നൽകുക',
      'privacySecurity': 'സ്വകാര്യത & സുരക്ഷ',

      // Public Dashboard
      'exploreFeatures': 'വിശേഷങ്ങൾ പര്യവേക്ഷണം ചെയ്യുക',
      'tryAssessment': 'വിലയിരുത്തൽ പരീക്ഷിക്കുക',
      'watchVideos': 'തെറാപ്പി വീഡിയോകൾ കാണുക',
      'findInstitution': 'സ്ഥാപനം കണ്ടെത്തുക',
      'loginForFull': 'പൂർണ്ണ ആക്സസിന് ലോഗിൻ ചെയ്യുക',

      // Assessment Menu
      'selectAssessment': 'വിലയിരുത്തൽ തിരഞ്ഞെടുക്കുക',
      'tdsc': 'TDSC',
      'lest': 'LEST',
      'stress': 'രക്ഷാകർതൃ സ്ട്രെസ്',
      'risk': 'റിസ്ക് ഫാക്ടറുകൾ',

      // Results
      'assessmentResults': 'വിലയിരുത്തൽ ഫലങ്ങൾ',
      'developmentalAge': 'വികസന പ്രായം',
      'chronologicalAge': 'കാലഗണനാ പ്രായം',
      'months': 'മാസം',
      'years': 'വർഷം',
      'developmentStatus': 'വികസന നില',
      'normal': 'സ്വാഭാവികം',
      'delayed': 'വൈകിയത്',
      'recommendations': 'ശുപാർശകൾ',
      'viewFullReport': 'പൂർണ്ണ റിപ്പോർട്ട് കാണുക',
      'saveResults': 'ഫലങ്ങൾ സംരക്ഷിക്കുക',

      // Reports
      'reportsDocuments': 'റിപ്പോർട്ടുകളും രേഖകളും',
      'completeHealthRecords': 'പൂർണ്ണ ആരോഗ്യ രേഖകൾ',
      'thisWeek': 'ഈ ആഴ്ച',
      'thisMonth': 'ഈ മാസം',
      'thisQuarter': 'ഈ പാദം',
      'allTime': 'എല്ലാ കാലവും',
      'assessmentReports': 'വിലയിരുത്തൽ റിപ്പോർട്ടുകൾ',
      'progressReports': 'പുരോഗതി റിപ്പോർട്ടുകൾ',
      'therapyReports': 'തെറാപ്പി സെഷൻ റിപ്പോർട്ടുകൾ',
      'medicalRecords': 'മെഡിക്കൽ രേഖകൾ',
      'reportGenerated': 'റിപ്പോർട്ട് സൃഷ്ടിച്ചു',
      'downloadReport': 'റിപ്പോർട്ട് ഡൗൺലോഡ് ചെയ്യുക',
      'shareReport': 'റിപ്പോർട്ട് പങ്കിടുക',

      // Therapy Schedule
      'therapySchedule': 'തെറാപ്പി ഷെഡ്യൂൾ',
      'weekOf': 'ആഴ്ച',
      'todaysGoals': 'ഇന്നത്തെ ലക്ഷ്യങ്ങൾ',
      'scheduledActivities': 'ഷെഡ്യൂൾ ചെയ്ത പ്രവർത്തനങ്ങൾ',
      'noActivitiesScheduled': 'ഈ ദിവസത്തേക്ക് പ്രവർത്തനങ്ങളൊന്നും ഷെഡ്യൂൾ ചെയ്തിട്ടില്ല',
      'restDay': 'വിശ്രമ ദിനം - ഒരുമിച്ച് ആസ്വദിക്കൂ!',
      'weeklyProgress': 'ആഴ്ചതോറുമുള്ള പുരോഗതി',
      'monday': 'തിങ്കൾ',
      'tuesday': 'ചൊവ്വ',
      'wednesday': 'ബുധൻ',
      'thursday': 'വ്യാഴം',
      'friday': 'വെള്ളി',
      'saturday': 'ശനി',
      'sunday': 'ഞായർ',

      // Therapy Videos
      'therapyVideoLibrary': 'തെറാപ്പി വീഡിയോ ലൈബ്രറി',
      'searchVideos': 'വീഡിയോകൾ തിരയുക...',
      'allCategories': 'എല്ലാ വിഭാഗങ്ങൾ',
      'speech': 'സ്പീച്ച് തെറാപ്പി',
      'occupational': 'ഒക്യൂപ്പേഷണൽ തെറാപ്പി',
      'physical': 'ഫിസിക്കൽ തെറാപ്പി',
      'behavioral': 'ബിഹേവിയറൽ തെറാപ്പി',

      // Institution Finder
      'findNearbyInstitutions': 'അടുത്തുള്ള സ്ഥാപനങ്ങൾ കണ്ടെത്തുക',
      'searchLocation': 'സ്ഥലം തിരയുക...',
      'useCurrentLocation': 'നിലവിലെ സ്ഥാനം ഉപയോഗിക്കുക',
      'mapView': 'മാപ്പ് കാഴ്ച',
      'listView': 'പട്ടിക കാഴ്ച',
      'km': 'കി.മീ',
      'away': 'അകലെ',
      'getDirections': 'ദിശകൾ നേടുക',
      'callNow': 'ഇപ്പോൾ വിളിക്കുക',

      // Gamification
      'yourProgress': 'നിങ്ങളുടെ പുരോഗതി',
      'achievements': 'നേട്ടങ്ങൾ',
      'badges': 'ബാഡ്ജുകൾ',
      'streak': 'തുടർ',
      'totalPoints': 'മൊത്തം പോയിന്റ്',
      'level': 'ലെവൽ',
      'nextLevel': 'അടുത്ത ലെവൽ',

      // Appointments
      'appointmentBooking': 'അപ്പോയ്ന്റ്മെന്റ് ബുക്കിംഗ്',
      'selectDate': 'തീയതി തിരഞ്ഞെടുക്കുക',
      'selectTime': 'സമയം തിരഞ്ഞെടുക്കുക',
      'selectInstitution': 'സ്ഥാപനം തിരഞ്ഞെടുക്കുക',
      'appointmentType': 'അപ്പോയ്ന്റ്മെന്റ് തരം',
      'consultation': 'കൺസൾട്ടേഷൻ',
      'therapy': 'തെറാപ്പി സെഷൻ',
      'followUp': 'ഫോളോ-അപ്',
      'bookNow': 'ഇപ്പോൾ ബുക്ക് ചെയ്യുക',
      'upcomingAppointments': 'വരാനിരിക്കുന്ന അപ്പോയ്ന്റ്മെന്റുകൾ',

      // Feedback
      'submitFeedback': 'ഫീഡ്ബാക്ക് സമർപ്പിക്കുക',
      'feedbackType': 'ഫീഡ്ബാക്ക് തരം',
      'suggestion': 'നിർദ്ദേശം',
      'complaint': 'പരാതി',
      'appreciation': 'പ്രശംസ',
      'yourFeedback': 'നിങ്ങളുടെ ഫീഡ്ബാക്ക്',
      'enterFeedback': 'ഇവിടെ ഫീഡ്ബാക്ക് നൽകുക...',

      // Data Privacy
      'dataPrivacy': 'ഡാറ്റ സ്വകാര്യത & സുരക്ഷ',
      'yourDataSafe': 'നിങ്ങളുടെ ഡാറ്റ സുരക്ഷിതമാണ്',
      'encryptedData': 'എൻഡ്-ടു-എൻഡ് എൻക്രിപ്ഷൻ',
      'secureStorage': 'സുരക്ഷിത ക്ലൗഡ് സ്റ്റോറേജ്',
      'gdprCompliant': 'GDPR അനുസൃതം',
      'manageData': 'ഡാറ്റ നിയന്ത്രിക്കുക',
      'exportData': 'ഡാറ്റ എക്സ്പോർട്ട് ചെയ്യുക',
      'deleteAccount': 'അക്കൗണ്ട് ഇല്ലാതാക്കുക',

      // Language
      'selectLanguage': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
      'english': 'English',
      'malayalam': 'മലയാളം',
      'changeLanguage': 'ഭാഷ മാറ്റുക',

      // Footer nav
      'home': 'ഹോം',
      'schedule': 'ഷെഡ്യൂൾ',
      'progress': 'പുരോഗതി',
      'profile': 'പ്രൊഫൈൽ',

      'trackProgress': 'കുട്ടിയുടെ പുരോഗതി ട്രാക്ക് ചെയ്യുക',
    },
  };

  static String translate(String lang, String key) {
    return _translations[lang]?[key] ?? _translations['en']?[key] ?? key;
  }
}
