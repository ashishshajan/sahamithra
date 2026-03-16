import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/app_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/standard_footer.dart';
import '../widgets/standard_header.dart';
import '../routes/app_routes.dart';

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
    if (_childNameCtrl.text.isEmpty) errors['childName'] = 'Child name is required';
    if (_parentNameCtrl.text.isEmpty) errors['parentName'] = 'Parent name is required';
    if (_addressCtrl.text.isEmpty) errors['address'] = 'Address is required';
    if (_phoneCtrl.text.length != 10) errors['phone'] = 'Valid 10-digit phone required';
    return errors;
  }

  void _handleSaveBasic() async {
    final errors = _validateBasic();
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      _showSnack('Please fill in all required fields', isError: true);
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
      _showSnack('Basic information saved!', isError: false);
      setState(() {
        _errors = {};
        _activeTab = 1;
      });
    } else {
      _showSnack(result['message'] ?? 'Failed to save information', isError: true);
    }
  }

  void _handleSubmit() async {
    final errors = _validateBasic();
    if (errors.isNotEmpty) {
      _showSnack('Please fill in all required fields', isError: true);
      return;
    }
    if (_childId == null) {
      _showSnack('Please save basic information first', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await NetworkHelper().registerStep2(
      childId: _childId!.toString(),
      dob: _dobCtrl.text,
      gender: _childGender,
      birthOrder: _birthOrderCtrl.text,
      mothersAgeAtBirth: _mothersAgeCtrl.text,
      bloodRelationship: _consanguinity,
      familyHistory: _familyHistory,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      final childData = result['data']?['child'];
      if (childData != null) {
        // ... (GlobalUtils saving logic can be added here if needed)
      }
      _showSnack('Registration completed successfully!', isError: false);
      Get.offAllNamed(AppRoutes.dashboard, arguments: {
        'childName': _childNameCtrl.text,
        'mobile': _phoneCtrl.text,
      });
    } else {
      _showSnack(result['message'] ?? 'Registration failed', isError: true);
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
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
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
            StandardHeader(
              onBack: () => Get.back(),
              title: 'Complete Your Profile',
              subtitle: 'Complete your profile to get started',
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.base.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    _buildSectionHeader(),
                    SizedBox(height: AppSpacing.xl.h),

                    // Tab switcher (pill style)
                    _buildTabBar(),
                    SizedBox(height: AppSpacing.xl.h),

                    // Form card
                    if (_activeTab == 0) _buildBasicForm(),
                    if (_activeTab == 1) _buildDetailedForm(),
                  ],
                ),
              ),
            ),

            const StandardFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _activeTab == 0 ? 'Basic Information' : 'Additional Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _activeTab == 0
                  ? 'Essential details about you and your child'
                  : 'More information for better care',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        _FormTab(
          label: 'Basic Info',
          active: _activeTab == 0,
          onTap: () => setState(() => _activeTab = 0),
        ),
        SizedBox(width: 8.w),
        _FormTab(
          label: 'Additional',
          active: _activeTab == 1,
          onTap: () {
            if (_isBasicValid) setState(() => _activeTab = 1);
          },
        ),
      ],
    );
  }

  Widget _buildBasicForm() {
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
            label: "Child's Name",
            required: true,
            controller: _childNameCtrl,
            placeholder: "Enter child's full name",
            error: _errors['childName'],
            onChanged: (_) => setState(() => _errors.remove('childName')),
          ),
          SizedBox(height: AppSpacing.lg.h),
          _FormField(
            label: "Parent's Name",
            required: true,
            controller: _parentNameCtrl,
            placeholder: "Enter parent's full name",
            error: _errors['parentName'],
            onChanged: (_) => setState(() => _errors.remove('parentName')),
          ),
          SizedBox(height: AppSpacing.lg.h),
          _FormField(
            label: 'Address',
            required: true,
            controller: _addressCtrl,
            placeholder: 'Enter residential address',
            error: _errors['address'],
            onChanged: (_) => setState(() => _errors.remove('address')),
          ),
          SizedBox(height: AppSpacing.lg.h),
          _FormField(
            label: 'Phone Number',
            required: true,
            controller: _phoneCtrl,
            placeholder: 'Enter 10-digit mobile number',
            error: _errors['phone'],
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            enabled: _mobileNumber == null,
            helperText: _mobileNumber != null
                ? 'Verified mobile number'
                : '${_phoneCtrl.text.length}/10 digits',
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
                Text('Save', style: AppTextStyles.button),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedForm() {
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
            label: "Child's Date of Birth",
            required: true,
            controller: _dobCtrl,
            placeholder: 'YYYY-MM-DD',
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Gender dropdown
          _DropdownField(
            label: "Child's Gender",
            required: true,
            value: _childGender,
            items: const [
              DropdownMenuItem(value: '', child: Text('Select gender')),
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _childGender = v ?? ''),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Birth order
          _FormField(
            label: 'Birth Order',
            controller: _birthOrderCtrl,
            placeholder: '1, 2, 3...',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Mothers age
          _FormField(
            label: "Mother's Age at Birth",
            controller: _mothersAgeCtrl,
            placeholder: 'Age in years',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Consanguinity
          _DropdownField(
            label: 'Blood Relationship',
            value: _consanguinity,
            items: const [
              DropdownMenuItem(value: '', child: Text('Select')),
              DropdownMenuItem(value: 'yes', child: Text('Yes')),
              DropdownMenuItem(value: 'no', child: Text('No')),
            ],
            onChanged: (v) => setState(() => _consanguinity = v ?? ''),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Family history
          _DropdownField(
            label: 'Family History of Developmental Issues',
            value: _familyHistory,
            items: const [
              DropdownMenuItem(value: '', child: Text('Select')),
              DropdownMenuItem(value: 'yes', child: Text('Yes')),
              DropdownMenuItem(value: 'no', child: Text('No')),
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
                Text('Complete Registration', style: AppTextStyles.button),
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : AppColors.textSecondary,
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
