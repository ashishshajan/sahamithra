import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sahamitra1_0/widgets/gradient_button.dart';

import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../routes/app_routes.dart';
import '../widgets/language_switcher.dart';

/// Account / profile — layout derived from design export (gradient header,
/// white content, profile details and quick links).
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const LinearGradient _headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xff9e1df4),
      Color(0xfff5339b),
      Color(0xff447eff),
    ],
  );

  Future<void> _logout() async {
    try {
      await NetworkHelper().logout();
    } catch (_) {
      // Session clear + navigation still run below.
    }
    await GlobalUtils().logout();
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.login);
  }

  List<Map<String, dynamic>> _childrenForPicker(GlobalUtils utils) {
    final user = utils.userData?['user'];
    final raw = user is Map ? user['children'] : null;
    if (raw is List && raw.isNotEmpty) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (utils.childName != null && utils.childName!.isNotEmpty) {
      return [
        {
          'id': utils.childId ?? 0,
          'name': utils.childName,
          'gender': utils.childGender ?? '',
          'dob': utils.childDob ?? '',
        },
      ];
    }
    return [
      {
        'id': 1,
        'name': 'Meera Prasad',
        'gender': 'Female',
        'dob': '03-03-2023',
      },
      {
        'id': 2,
        'name': 'Arjun Prasad',
        'gender': 'Male',
        'dob': '01-01-2022',
      },
    ];
  }

  int _selectedChildIndex(
      List<Map<String, dynamic>> children, GlobalUtils utils) {
    final id = utils.childId;
    if (id == null) return 0;
    final i = children.indexWhere((c) {
      final cid = c['id'];
      if (cid is int) return cid == id;
      return int.tryParse(cid?.toString() ?? '') == id;
    });
    return i >= 0 ? i : 0;
  }

  String _initialsFromName(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first.toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  Future<void> _showChooseChildSheet() async {
    final utils = GlobalUtils();
    final children = _childrenForPicker(utils);
    var selectedIndex = _selectedChildIndex(children, utils);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl.w,
                      12.h,
                      AppSpacing.xl.w,
                      16.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 44.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: const Color(0xffdedede),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Choose child',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ...List.generate(children.length, (i) {
                          final c = children[i];
                          final name = (c['name'] ?? '').toString();
                          final sel = i == selectedIndex;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: InkWell(
                              onTap: () =>
                                  setModalState(() => selectedIndex = i),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 51.r,
                                      height: 50.r,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: _headerGradient,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _initialsFromName(name),
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Container(
                                      width: 10.r,
                                      height: 10.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: sel
                                            ? const Color(0xff0a7aff)
                                            : const Color(0xff8e8e93),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 16.h),
                        Center(
                          child: GradientButton(
                            width: double.infinity,
                            height: 52.h,
                            gradient: _headerGradient,
                            onPressed: () async {
                              await GlobalUtils().persistChildFromMap(
                                children[selectedIndex],
                              );
                              if (!mounted) return;
                              Navigator.of(sheetContext).pop();
                              setState(() {});
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Center(
                          child: Container(
                            width: 134.w,
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: AppColors.neutral300,
                              borderRadius: BorderRadius.circular(2.5.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final utils = GlobalUtils();
    final userMap = utils.userData?['user'] as Map<String, dynamic>?;
    final childName = utils.childName ?? 'Meera Prasad';
    final parentLabel = utils.parentName ?? 'Heera Hari';
    final phone = utils.phoneNumber ?? '+91 989510xxxx';
    final email = (userMap?['email'] ?? 'heera123@xxx.com').toString();
    final address = (userMap?['address'] ??
            '123 MG Road, Ernakulam, Kochi, Kerala - 682001, India')
        .toString();
    final gender = utils.childGender ?? 'Female';
    final dob = utils.childDob ?? '03-03-2023';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200.h,
            width: double.infinity,
            child: Container(
              decoration: const BoxDecoration(gradient: _headerGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              width: 36.r,
                              height: 36.r,
                              decoration: BoxDecoration(
                                color: AppColors.white20,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.notifications_outlined,
                            size: 22.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          const LanguageSwitcher(),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'View your personal details and manage your settings',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl.w,
                  20.h,
                  AppSpacing.xl.w,
                  AppSpacing.xl.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50.r,
                          height: 50.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _headerGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purple.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      childName,
                                      style: TextStyle(
                                        fontSize: 25.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _showChooseChildSheet,
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textTertiary,
                                      size: 28.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_iphone_rounded,
                                    size: 14.sp,
                                    color: AppColors.textTertiary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      phone,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w300,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Parent : $parentLabel',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),
                    _detailBlock(
                      label: 'Address',
                      value: address,
                    ),
                    SizedBox(height: 18.h),
                    _detailBlock(
                      label: 'Child’s Gender',
                      value: gender,
                    ),
                    SizedBox(height: 18.h),
                    _detailBlock(
                      label: 'Child’s Date of Birth',
                      value: dob,
                    ),
                    SizedBox(height: 28.h),
                    _AccountMenuTile(
                      icon: Icons.event_available_rounded,
                      title: 'My Appointments',
                      subtitle: 'Manage your appointment details',
                      onTap: () =>
                          Get.toNamed(AppRoutes.appointmentHistory),
                    ),
                    SizedBox(height: 12.h),
                    _AccountMenuTile(
                      icon: Icons.groups_rounded,
                      title: 'Care Team',
                      subtitle: 'Manage your care team',
                      onTap: () => Get.toNamed(AppRoutes.teamCollaboration),
                    ),
                    SizedBox(height: 12.h),
                    _AccountMenuTile(
                      icon: Icons.logout_rounded,
                      title: 'Log out',
                      subtitle: 'Further secure your account for safety',
                      onTap: _logout,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailBlock({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _AccountMenuTile extends StatelessWidget {
  const _AccountMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Icon(icon, color: AppColors.purple, size: 24.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
