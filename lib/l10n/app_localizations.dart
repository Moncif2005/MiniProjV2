import 'package:flutter/material.dart';
import 'app_en.dart';
import 'app_fr.dart';
import 'app_ar.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'fr':
        return {...frStrings, ...frStringsExtra, ...frStringsV5};
      case 'ar':
        return {...arStrings, ...arStringsExtra, ...arStringsV5};
      default:
        return {...enStrings, ...enStringsExtra, ...enStringsV5};
    }
  }

  String translate(String key) => _strings[key] ?? enStrings[key] ?? key;

  // ── General ──
  String get appName => translate('app_name');
  String get ok => translate('ok');
  String get back => translate('back');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get search => translate('search');
  String get loading => translate('loading');
  String get error => translate('error');
  String get noData => translate('no_data');
  String get seeAll => translate('see_all');
  String get orContinueWith => translate('or_continue_with');
  String get newToApp => translate('new_to_app');
  String get platformSubtitle => translate('platform_subtitle');

  // ── Auth ──
  String get signIn => translate('sign_in');
  String get signUp => translate('sign_up');
  String get logOut => translate('log_out');
  String get email => translate('email');
  String get emailAddress => translate('email_address');
  String get password => translate('password');
  String get forgotPassword => translate('forgot_password');
  String get createAccount => translate('create_account');
  String get createMyAccount => translate('create_my_account');
  String get welcomeBack => translate('welcome_back');
  String get dontHaveAccount => translate('dont_have_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get fullName => translate('full_name');
  String get phoneNumber => translate('phone_number');
  String get confirmPassword => translate('confirm_password');
  String get chooseRole => translate('choose_role');
  String get roleStudent => translate('role_student');
  String get roleRecruiter => translate('role_recruiter');
  String get roleTeacher => translate('role_teacher');
  String get oneLastStep => translate('one_last_step');
  String get personalizeExperience => translate('personalize_experience');
  String get getStarted => translate('get_started');
  String get studentSubtitle => translate('student_subtitle');
  String get teacherSubtitle => translate('teacher_subtitle');
  String get recruiterSubtitle => translate('recruiter_subtitle');
  String get signInFailed => translate('sign_in_failed');
  String get signUpFailed => translate('sign_up_failed');
  String get fixErrors => translate('fix_errors');
  String get correctErrors => translate('correct_errors');
  String get welcomeBackEmoji => translate('welcome_back_emoji');
  String get google => translate('google');
  String get passwordsMatch => translate('passwords_match');
  String get passwordsNoMatch => translate('passwords_no_match');
  String get signInLink => translate('sign_in_link');

  // ── Forgot Password ──
  String get forgotPasswordTitle => translate('forgot_password_title');
  String get forgotPasswordSubtitle => translate('forgot_password_subtitle');
  String get sendResetLink => translate('send_reset_link');
  String get backToSignIn => translate('back_to_sign_in');
  String get checkInbox => translate('check_inbox');
  String get resetLinkSent => translate('reset_link_sent');
  String get checkSpam => translate('check_spam');
  String get resendEmail => translate('resend_email');
  String get enterValidEmail => translate('enter_valid_email');

  // ── New Password ──
  String get setNewPassword => translate('set_new_password');
  String get newPasswordSubtitle => translate('new_password_subtitle');
  String get newPassword => translate('new_password');
  String get confirmNewPassword => translate('confirm_new_password');
  String get updatePassword => translate('update_password');
  String get passwordUpdated => translate('password_updated');
  String get passwordUpdatedSubtitle => translate('password_updated_subtitle');
  String get goToSignIn => translate('go_to_sign_in');
  String get passwordStrengthHint => translate('password_strength_hint');
  String get passwordsNotMatch => translate('passwords_not_match');
  String get invalidResetLink => translate('invalid_reset_link');

  // ── Navigation ──
  String get navHome => translate('nav_home');
  String get navJobs => translate('nav_jobs');
  String get navApplicants => translate('nav_applicants');
  String get navProfile => translate('nav_profile');
  String get navLearn => translate('nav_learn');
  String get navCourses => translate('nav_courses');
  String get navWork => translate('nav_work');

  // ── Profile ──
  String get myProfile => translate('my_profile');
  String get editProfile => translate('edit_profile');
  String get companyInfo => translate('company_info');
  String get company => translate('company');
  String get location => translate('location');
  String get companySize => translate('company_size');
  String get industry => translate('industry');
  String get overview => translate('overview');
  String get dashboard => translate('dashboard');
  String get myJobPosts => translate('my_job_posts');
  String get candidates => translate('candidates');
  String get parameters => translate('parameters');
  String get settings => translate('settings');
  String get hrManager => translate('hr_manager');
  String get recruiter => translate('recruiter');

  // ── Home Recruiter ──
  String get hello => translate('hello');
  String get findGreatHire => translate('find_great_hire');
  String get searchCandidates => translate('search_candidates');
  String get recruitmentHub => translate('recruitment_hub');
  String get noJobsYet => translate('no_jobs_yet');
  String get postNewJob => translate('post_new_job');
  String get postedJobs => translate('posted_jobs');

  // ── Home Student ──
  String get goodMorning => translate('good_morning');
  String get goodAfternoon => translate('good_afternoon');
  String get goodEvening => translate('good_evening');
  String get searchCoursesJobs => translate('search_courses_jobs');
  String get continueLearning => translate('continue_learning');
  String get noLearningProgress => translate('no_learning_progress');
  String get startLearning => translate('start_learning');
  String get featuredCourses => translate('featured_courses');
  String get noCoursesAvailable => translate('no_courses_available');
  String get latestJobs => translate('latest_jobs');
  String get noJobsAvailable => translate('no_jobs_available');
  String get exploreCourses => translate('explore_courses');
  String get exploreJobs => translate('explore_jobs');
  String get studentRole => translate('student_role');

  // ── Home Teacher ──
  String get myCourses => translate('my_courses');
  String get createCourse => translate('create_course');
  String get noCoursesYet => translate('no_courses_yet');
  String get teacherRole => translate('teacher_role');

  // ── Dashboard ──
  String get recruitmentOverview => translate('recruitment_overview');
  String get liveAnalytics => translate('live_analytics');
  String get totalJobs => translate('total_jobs');
  String get active => translate('active');
  String get applicants => translate('applicants');
  String get hired => translate('hired');
  String get quickStats => translate('quick_stats');
  String get totalViews => translate('total_views');
  String get conversion => translate('conversion');
  String get activeJobs => translate('active_jobs');
  String get closedJobs => translate('closed_jobs');
  String get recruitmentPipeline => translate('recruitment_pipeline');
  String get applications => translate('applications');
  String get total => translate('total');
  String get pending => translate('pending');
  String get reviewing => translate('reviewing');
  String get interview => translate('interview');
  String get rejected => translate('rejected');
  String get topJobs => translate('top_jobs');
  String get postJobsAnalytics => translate('post_jobs_analytics');
  String get recentApplications => translate('recent_applications');
  String get noApplications => translate('no_applications');

  // ── Notifications ──
  String get notificationsTitle => translate('notifications_title');
  String get markAllRead => translate('mark_all_read');
  String get allRead => translate('all_read');
  String get noNotifications => translate('no_notifications');
  String get allCaughtUp => translate('all_caught_up');
  String get allNotificationsRead => translate('all_notifications_read');

  // ── Settings ──
  String get appearance => translate('appearance');
  String get darkMode => translate('dark_mode');
  String get language => translate('language');
  String get selectLanguage => translate('select_language');
  String get langEnglish => translate('lang_english');
  String get langFrench => translate('lang_french');
  String get langArabic => translate('lang_arabic');
  String get notifications => translate('notifications');
  String get pushNotifications => translate('push_notifications');
  String get emailNotifications => translate('email_notifications');
  String get account => translate('account');
  String get changePassword => translate('change_password');
  String get privacyPolicy => translate('privacy_policy');
  String get termsOfService => translate('terms_of_service');
  String get about => translate('about');
  String get version => translate('version');

  // ── Helpers ──
  String activeJobPostLabel(int count) {
    if (count == 1) {
      return '$count ${translate('active_job_post')}';
    }
    return '$count ${translate('active_job_posts')}';
  }

  String get jobActive   => translate('job_active');
  String get jobClosed   => translate('job_closed');

  // ── Extra (remaining screens) ──
  String get actions          => translate('actions');
  String get apply            => translate('apply');
  String get applyForJob      => translate('apply_for_job');
  String get areYouSure       => translate('are_you_sure');
  String get browseCourses    => translate('browse_courses');
  String get changePhoto      => translate('change_photo');
  String get deactivate       => translate('deactivate');
  String get deactivateJob    => translate('deactivate_job');
  String get deactivateJobMsg => translate('deactivate_job_msg');
  String get deleteCourse     => translate('delete_course');
  String get deletePermanently => translate('delete_permanently');
  String get deleteJobMsg     => translate('delete_job_msg');
  String get description      => translate('description');
  String get editJob          => translate('edit_job');
  String get failedUpdateStatus => translate('failed_update_status');
  String get fillDetails      => translate('fill_details');
  String get inProgress       => translate('in_progress');
  String get jobDeleted       => translate('job_deleted');
  String get jobPosted        => translate('job_posted');
  String get jobSubmitted     => translate('job_submitted');
  String get jobTitleRequired => translate('job_title_required');
  String get jobUpdated       => translate('job_updated');
  String get keep             => translate('keep');
  String get manage           => translate('manage');
  String get manageCourse     => translate('manage_course');
  String get max200           => translate('max_200');
  String get myJobs           => translate('my_jobs');
  String get noApplicationsYet   => translate('no_applications_yet');
  String get noCoursesFound      => translate('no_courses_found');
  String get noCoursesInProgress => translate('no_courses_in_progress');
  String get noOffersFound    => translate('no_offers_found');
  String get newCourse        => translate('new_course');
  String get pleaseEnterJobTitle => translate('please_enter_job_title');
  String get pleaseSignIn     => translate('please_sign_in');
  String get pleaseSignInApply => translate('please_sign_in_apply');
  String get pleaseSignInPost  => translate('please_sign_in_post');
  String get postJobBtn       => translate('post_job_btn');
  String get preview          => translate('preview');
  String get publishJob       => translate('publish_job');
  String get statusUpdated    => translate('status_updated');
  String get updatePersonalInfo => translate('update_personal_info');
  String get view             => translate('view');
  String get withdrawApplication => translate('withdraw_application');
  String get noMatches        => translate('no_matches');
  String get complete         => translate('complete');
  String get lessons          => translate('lessons');
  String get units            => translate('units');
  String get startFirstCourse => translate('start_first_course');
  String get noPublishedCourses => translate('no_published_courses');
  String get certPrice        => translate('cert_price');

  String get statusPending    => translate('status_pending');
  String get statusReviewing  => translate('status_reviewing');
  String get statusInterview  => translate('status_interview');
  String get statusAccepted   => translate('status_accepted');
  String get statusRejected   => translate('status_rejected');

  // ── v5: Course details ──
  String get rateThisCourse     => translate('rate_this_course');
  String get howWasExperience   => translate('how_was_experience');
  String get submitRating       => translate('submit_rating');
  String get aboutThisCourse    => translate('about_this_course');
  String get courseContent      => translate('course_content');
  String get certificatePrice   => translate('certificate_price');
  String get noLessonsYet       => translate('no_lessons_yet');
  String get yourProgress       => translate('your_progress');
  String get byInstructor       => translate('by_instructor');

  // ── v5: Lesson player ──
  String get lessonCompleted    => translate('lesson_completed');
  String get aboutThisLesson    => translate('about_this_lesson');

  // ── v5: Course management ──
  String get pdfUploaded        => translate('pdf_uploaded');
  String get imageUploaded      => translate('image_uploaded');
  String get coursePublished    => translate('course_published');
  String get courseUpdated      => translate('course_updated');
  String get editCourse         => translate('edit_course');
  String get editLessonsNote    => translate('edit_lessons_note');
  String get video              => translate('video');
  String get pdf                => translate('pdf');
  String get createNewCourse    => translate('create_new_course');
  String get createFirstCourse  => translate('create_first_course');

  // ── v5: Home student extra ──
  String get recommendedForYou  => translate('recommended_for_you');
  String get newOpportunities   => translate('new_opportunities');
  String get noNewJobs          => translate('no_new_jobs');

  // ── v5: Profile menus ──
  String get myPortfolio        => translate('my_portfolio');
  String get learningHistory    => translate('learning_history');
  String get appliedJobs        => translate('applied_jobs');
  String get logOutMenu         => translate('log_out_menu');

  // ── v5: Portfolio ──
  String get deleteCv           => translate('delete_cv');
  String get deleteCvConfirm    => translate('delete_cv_confirm');
  String get deleteItem         => translate('delete_item');
  String get viewDocument       => translate('view_document');
  String get previewCv          => translate('preview_cv');
  String get projectLabel       => translate('project_label');
  String get certificateItem    => translate('certificate_item');
  String get failedLoadImage    => translate('failed_load_image');

  // ── v5: Public profiles ──
  String get viewCv             => translate('view_cv');
  String get documentViewer     => translate('document_viewer');
  String get teacherProfile     => translate('teacher_profile');
  String get userNotFound       => translate('user_not_found');
  String get coursesByTeacher   => translate('courses_by_teacher');
  String get noCoursesPublished => translate('no_courses_published');

  // ── v5: Recruiter applicants ──
  String get allCandidates         => translate('all_candidates');
  String get noApplicantsYet       => translate('no_applicants_yet');
  String get candidatesWillAppear  => translate('candidates_will_appear');
  String get appliedFor            => translate('applied_for');

  // ── v5: Manage offer ──
  String get editJobDetails     => translate('edit_job_details');
  String get updateJobSubtitle  => translate('update_job_subtitle');
  String get viewApplicants     => translate('view_applicants');
  String get hideJob            => translate('hide_job');

  // ── v5: Search hints ──
  String get searchCoursesTeachers => translate('search_courses_teachers');
  String get searchJobsCompanies   => translate('search_jobs_companies');
  String get searchJobKeyword      => translate('search_job_keyword');
  String get searchCourse          => translate('search_course');

  // ── v5: Form labels ──
  String get titleLabel         => translate('title_label');
  String get categoryLabel      => translate('category_label');

  // ── v5: Certificates ──
  String get addCertificate     => translate('add_certificate');
  String get addTraining        => translate('add_training');

  // ── v5: Misc ──
  String get appliedTo          => translate('applied_to');

  bool get isRtl => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
