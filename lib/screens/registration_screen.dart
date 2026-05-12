import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/gradient_button.dart';
import '../widgets/standard_footer.dart';
import '../widgets/standard_header.dart';
import '../routes/app_routes.dart';
import '../providers/language_provider.dart';

/// Mirrors /components/RegistrationScreen.tsx
/// Two-tab form: Basic Info | Additional Details
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _activeTab = 0; // 0=basic, 1=detailed
  bool _isLoading = false;

  final _childNameCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _birthOrderCtrl = TextEditingController();
  final _mothersAgeCtrl = TextEditingController();

  String _childGender = '';
  String _consanguinity = '';
  String _familyHistory = '';

  Map<String, String> _errors = {};
  String? _mobileNumber;
  int? _childId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _mobileNumber = args?['mobile'] as String?;
    if (_mobileNumber != null) {
      _phoneCtrl.text = _mobileNumber!;
    }
  }

  @override
  void dispose() {
    _childNameCtrl.dispose();
    _parentNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _birthOrderCtrl.dispose();
    _mothersAgeCtrl.dispose();
    super.dispose();
  }

  bool get _isBasicValid =>
      _childNameCtrl.text.isNotEmpty &&
      _parentNameCtrl.text.isNotEmpty &&
      _addressCtrl.text.isNotEmpty &&
      _phoneCtrl.text.length == 10;

  Map<String, String> _validateBasic() {
    final errors = <String, String>{};
    if (_childNameCtrl.text.isEmpty) {
      errors['childName'] = 'validationChildNameRequired';
    }
    if (_parentNameCtrl.text.isEmpty) {
      errors['parentName'] = 'validationParentNameRequired';
    }
    if (_addressCtrl.text.isEmpty) {
      errors['address'] = 'validationAddressRequired';
    }
    if (_phoneCtrl.text.length != 10) {
      errors['phone'] = 'validationPhoneRequired';
    }
    return errors;
  }

  void _handleSaveBasic() async {
    final errors = _validateBasic();
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      _showSnack(
          LanguageProvider.to.t('registrationFillRequired'), isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await NetworkHelper().registerStep1(
      childName: _childNameCtrl.text,
      parentsName: _parentNameCtrl.text,
      address: _addressCtrl.text,
      phoneNumber: _phoneCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      _childId = result['data']?['child_id'];
      _showSnack(
          LanguageProvider.to.t('registrationBasicSaved'), isError: false);
      setState(() {
        _errors = {};
        _activeTab = 1;
      });
    } else {
      _showSnack(
          result['message'] ??
              LanguageProvider.to.t('registrationSaveFailed'),
          isError: true);
    }
  }

  void _handleSubmit() async {
    final errors = _validateBasic();
    if (errors.isNotEmpty) {
      _showSnack(
          LanguageProvider.to.t('registrationFillRequired'), isError: true);
      return;
    }
    if (_childId == null) {
      _showSnack(
          LanguageProvider.to.t('registrationSaveBasicFirst'), isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await NetworkHelper().registerStep2(
      childId: _childId!.toString(),
      dob: _dobForApi(_dobCtrl.text),
      gender: _childGender,
      birthOrder: _birthOrderCtrl.text,
      mothersAgeAtBirth: _mothersAgeCtrl.text,
      bloodRelationship: _consanguinity,
      familyHistory: _familyHistory,
    );

    if (!mounted) return;

    if (result['success']) {
      await _persistRegistrationSession(result['data']);
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack(LanguageProvider.to.t('registrationCompletedSuccess'),
          isError: false);
      Get.offAllNamed(AppRoutes.dashboard, arguments: {
        'childName': _childNameCtrl.text,
        'mobile': _phoneCtrl.text,
      });
    } else {
      setState(() => _isLoading = false);
      _showSnack(
          result['message'] ?? LanguageProvider.to.t('registrationFailed'),
          isError: true);
    }
  }

  /// Saves session data from the `register2` response, mirroring the login flow:
  /// tokens + phone + child details, then fetches `/get-init` for the full
  /// user payload (same as OTP verification path).
  Future<void> _persistRegistrationSession(dynamic data) async {
    if (data is! Map) return;
    final utils = GlobalUtils();

    final accessToken = data['access_token'];
    final refreshToken = data['refresh_token'];
    final child = data['child'];

    await utils.setGuestUser(false);

    final phone = _phoneCtrl.text.trim();
    if (phone.isNotEmpty) {
      await utils.setPhoneNumber(phone);
    }

    if (accessToken is String && accessToken.isNotEmpty) {
      await utils.setToken(accessToken);
    }
    if (refreshToken is String && refreshToken.isNotEmpty) {
      await utils.setRefreshToken(refreshToken);
    }
    await utils.setLoggedIn(true);

    if (child is Map) {
      await utils.persistChildFromMap(Map<String, dynamic>.from(child));
    }

    try {
      final initResult = await NetworkHelper().getInit();
      if (initResult['success'] == true) {
        final initData = initResult['data'];
        if (initData is Map<String, dynamic>) {
          await utils.setInitUserAndFirstChild(initData);
        } else if (initData is Map) {
          await utils.setUserData(initData.cast<String, dynamic>());
        }
      }
    } catch (_) {
    }
  }

  /// Converts the displayed DOB (`dd-MM-yyyy`) to the API format (`yyyy-MM-dd`).
  /// Returns the original string if it can't be parsed.
  String _dobForApi(String displayed) {
    final s = displayed.trim();
    if (s.isEmpty) return s;
    try {
      final parsed = DateFormat('dd-MM-yyyy').parseStrict(s);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return s;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Obx(
              () => StandardHeader(
                onBack: () => Get.offAllNamed(AppRoutes.login),
                title: LanguageProvider.to.t('completeProfile'),
                subtitle: LanguageProvider.to.t('registrationSubtitle'),
              ),
            ),

            // Content
            Expanded(
              child: Obx(
                () {
                  final lang = LanguageProvider.to;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.base.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(lang),
                        SizedBox(height: AppSpacing.xl.h),
                        _buildTabBar(lang),
                        SizedBox(height: AppSpacing.xl.h),
                        if (_activeTab == 0) _buildBasicForm(lang),
                        if (_activeTab == 1) _buildDetailedForm(lang),
                      ],
                    ),
                  );
                },
              ),
            ),

            const StandardFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(LanguageProvider lang) {
    return Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            gradient: _activeTab == 0
                ? const LinearGradient(
                    colors: [AppColors.purple, AppColors.pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF2563EB), AppColors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _activeTab == 0
                ? Icons.person_rounded
                : Icons.description_rounded,
            size: 20.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _activeTab == 0
                    ? lang.t('registrationBasicInfo')
                    : lang.t('registrationAdditionalDetails'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _activeTab == 0
                    ? lang.t('registrationBasicInfoDesc')
                    : lang.t('registrationAdditionalDesc'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(LanguageProvider lang) {
    return Row(
      children: [
        Expanded(
          child: _FormTab(
            label: lang.t('registrationTabBasic'),
            active: _activeTab == 0,
            onTap: () => setState(() => _activeTab = 0),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _FormTab(
            label: lang.t('registrationTabAdditional'),
            active: _activeTab == 1,
            onTap: () {
              if (_isBasicValid) setState(() => _activeTab = 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBasicForm(LanguageProvider lang) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _FormField(
            label: lang.t('childNameLabel'),
            required: true,
            controller: _childNameCtrl,
            placeholder: lang.t('childNamePlaceholder'),
            error: _errors['childName'] != null
                ? lang.t(_errors['childName']!)
                : null,
            onChanged: (_) => setState(() => _errors.remove('childName')),
          ),
          SizedBox(height: AppSpacing.lg.h),
          _FormField(
            label: lang.t('parentName'),
            required: true,
            controller: _parentNameCtrl,
            placeholder: lang.t('parentNamePlaceholder'),
            error: _errors['parentName'] != null
                ? lang.t(_errors['parentName']!)
                : null,
            onChanged: (_) => setState(() => _errors.remove('parentName')),
          ),
          SizedBox(height: AppSpacing.lg.h),
          _FormField(
            label: lang.t('accountAddress'),
            required: true,
            controller: _addressCtrl,
            placeholder: lang.t('registrationAddressPlaceholder'),
            error: _errors['address'] != null
                ? lang.t(_errors['address']!)
                : null,
            onChanged: (_) => setState(() => _errors.remove('address')),
          ),
          SizedBox(height: AppSpacing.lg.h),
          _FormField(
            label: lang.t('registrationPhoneLabel'),
            required: true,
            controller: _phoneCtrl,
            placeholder: lang.t('enterAadhaar'),
            error: _errors['phone'] != null
                ? lang.t(_errors['phone']!)
                : null,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            enabled: _mobileNumber == null,
            helperText: _mobileNumber != null
                ? lang.t('registrationVerifiedMobile')
                : 'registrationPhoneDigits'
                    .trParams({'n': '${_phoneCtrl.text.length}'}),
            onChanged: (_) => setState(() => _errors.remove('phone')),
          ),
          SizedBox(height: AppSpacing.xl2.h),
          GradientButton(
            onPressed: (_isBasicValid && !_isLoading) ? _handleSaveBasic : null,
            height: 48.h,
            disabled: !_isBasicValid || _isLoading,
            isLoading: _isLoading,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text(lang.t('save'), style: AppTextStyles.button),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedForm(LanguageProvider lang) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date of birth
          _FormField(
            label: lang.t('accountChildDob'),
            required: true,
            controller: _dobCtrl,
            placeholder: lang.t('registrationDobPlaceholder'),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Gender dropdown
          _DropdownField(
            label: lang.t('accountChildGender'),
            required: true,
            value: _childGender,
            items: [
              DropdownMenuItem(
                  value: '',
                  child: Text(lang.t('selectGenderPrompt'))),
              DropdownMenuItem(value: 'Male', child: Text(lang.t('male'))),
              DropdownMenuItem(value: 'Female', child: Text(lang.t('female'))),
              DropdownMenuItem(value: 'Other', child: Text(lang.t('other'))),
            ],
            onChanged: (v) => setState(() => _childGender = v ?? ''),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Birth order
          _FormField(
            label: lang.t('registrationBirthOrderLabel'),
            controller: _birthOrderCtrl,
            placeholder: lang.t('registrationBirthOrderPlaceholder'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Mothers age
          _FormField(
            label: lang.t('registrationMotherAgeAtBirth'),
            controller: _mothersAgeCtrl,
            placeholder: lang.t('registrationMotherAgePlaceholder'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Consanguinity
          _DropdownField(
            label: lang.t('registrationBloodRelationship'),
            value: _consanguinity,
            items: [
              DropdownMenuItem(
                  value: '', child: Text(lang.t('selectPrompt'))),
              DropdownMenuItem(value: 'yes', child: Text(lang.t('yes'))),
              DropdownMenuItem(value: 'no', child: Text(lang.t('no'))),
            ],
            onChanged: (v) => setState(() => _consanguinity = v ?? ''),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Family history
          _DropdownField(
            label: lang.t('registrationFamilyHistoryDev'),
            value: _familyHistory,
            items: [
              DropdownMenuItem(
                  value: '', child: Text(lang.t('selectPrompt'))),
              DropdownMenuItem(value: 'yes', child: Text(lang.t('yes'))),
              DropdownMenuItem(value: 'no', child: Text(lang.t('no'))),
            ],
            onChanged: (v) => setState(() => _familyHistory = v ?? ''),
          ),

          SizedBox(height: AppSpacing.xl2.h),

          GradientButton(
            onPressed: (!_isBasicValid || _isLoading) ? null : _handleSubmit,
            height: 48.h,
            disabled: !_isBasicValid || _isLoading,
            isLoading: _isLoading,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text(lang.t('completeRegistration'),
                    style: AppTextStyles.button),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────

class _FormTab extends StatelessWidget {
  const _FormTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          color: active ? null : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.required = false,
    this.placeholder = '',
    this.error,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.enabled = true,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final bool required;
  final String placeholder;
  final String? error;
  final String? helperText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: label),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          enabled: enabled,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: placeholder,
            errorText: error,
            filled: true,
            fillColor: enabled ? Colors.white : AppColors.neutral100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: const BorderSide(color: AppColors.neutral200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: BorderSide(
                color: error != null ? AppColors.error : AppColors.neutral200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: const BorderSide(color: AppColors.purple, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
        if (helperText != null && error == null)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              helperText!,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.required = false,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: label),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
