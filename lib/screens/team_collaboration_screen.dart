import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/TeamCollaborationScreen.tsx
class TeamCollaborationScreen extends StatefulWidget {
  const TeamCollaborationScreen({super.key});

  @override
  State<TeamCollaborationScreen> createState() => _TeamCollaborationScreenState();
}

class _TeamCollaborationScreenState extends State<TeamCollaborationScreen> {
  Map<String, dynamic>? _careTeam;
  Map<String, dynamic>? _pagination;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCareTeam();
  }

  Future<void> _loadCareTeam() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final childId = GlobalUtils().childId;

    if (childId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Child id not found';
      });
      return;
    }

    final result = await NetworkHelper().getCareTeam(childId: childId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _careTeam = result['data']?['data'] as Map<String, dynamic>?;
        _pagination = result['data']?['pagination'] as Map<String, dynamic>?;
      } else {
        _error = result['message'] ?? 'Failed to load care team';
      }
    });
  }

  Widget _buildCareTeamSection() {
    final primary = _careTeam?['primary_therapist'] as Map<String, dynamic>?;
    final additional =
        List<Map<String, dynamic>>.from(_careTeam?['additional_therapists'] ?? []);

    if (primary == null && additional.isEmpty) {
      return Text(
        'No care team assigned yet.',
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
      );
    }

    final widgets = <Widget>[];

    if (primary != null) {
      widgets.add(
        _TeamMember(
          name: primary['name'] ?? 'Primary Therapist',
          speciality: primary['speciality'] ?? '',
          bgColor: const Color(0xFFDBEAFE),
          emoji: '👨‍⚕️',
          email: primary['email']?.toString(),
          phone: primary['phone']?.toString(),
          experience: primary['experience'] is int
              ? primary['experience'] as int
              : int.tryParse('${primary['experience'] ?? ''}'),
          isPrimary: true,
        ),
      );
    }

    for (final t in additional) {
      widgets.add(
        _TeamMember(
          name: t['name'] ?? 'Therapist',
          speciality: t['speciality'] ?? '',
          bgColor: const Color(0xFFF3E8FF),
          emoji: '👩‍⚕️',
          email: t['email']?.toString(),
          phone: t['phone']?.toString(),
          experience: t['experience'] is int
              ? t['experience'] as int
              : int.tryParse('${t['experience'] ?? ''}'),
        ),
      );
    }

    return Column(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.orange600,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: AppColors.white20,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16.sp, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Team Collaboration',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text(
                            GlobalUtils().childName != null
                                ? "${GlobalUtils().childName}'s Care Team"
                                : "Care Team",
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 14.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: _loadCareTeam,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: EdgeInsets.all(AppSpacing.base.r),
                        children: [
                // Care team
                _Section(
                  icon: Icons.groups_rounded,
                  iconColor: AppColors.orange600,
                  title: 'Multidisciplinary Team',
                  child: _buildCareTeamSection(),
                ),
                SizedBox(height: 12.h),

                // Recent updates
                _Section(
                  icon: Icons.update_rounded,
                  iconColor: AppColors.blue600,
                  title: 'Recent Team Updates',
                  child: Column(
                    children: [
                      _Update('Dr. Rajesh Kumar', '2 hours ago',
                          'Updated medical assessment notes. Recommended additional vitamin D supplementation.',
                          const Color(0xFF3B82F6)),
                      _Update('Dr. Sarah Thompson', '5 hours ago',
                          'Modified physiotherapy program to focus on balance exercises.',
                          AppColors.purple),
                      _Update('Ms. Priya Menon', '1 day ago',
                          'Great progress in speech therapy! Aarav is now forming 2-word sentences consistently.',
                          AppColors.green600),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Shared documents
                _Section(
                  icon: Icons.folder_shared_rounded,
                  iconColor: AppColors.orange600,
                  title: 'Shared Documents',
                  child: Column(
                    children: [
                      _DocumentRow('Comprehensive Care Plan', 'Updated by Dr. Rajesh • Nov 15',
                          AppColors.red100, AppColors.red600),
                      _DocumentRow('Home Exercise Guide', 'Shared by Dr. Sarah • Nov 12',
                          AppColors.blue100, AppColors.blue600),
                      _DocumentRow('Speech Development Goals', 'Shared by Ms. Priya • Nov 10',
                          AppColors.green100, AppColors.green600),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.video_call_rounded,
                            size: 18.sp, color: Colors.white),
                        label: Text('Team Meeting',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(0, 48.h),
                          backgroundColor: AppColors.orange600,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xl)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.chat_bubble_outline_rounded,
                            size: 18.sp, color: AppColors.orange600),
                        label: Text('Group Chat',
                            style: TextStyle(
                                fontSize: 13.sp, color: AppColors.orange600)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 48.h),
                          side: const BorderSide(color: AppColors.orange600),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xl)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.base.h),
              ],
            ),
          ),
          const StandardFooter(),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section(
      {required this.icon,
      required this.iconColor,
      required this.title,
      required this.child});

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.sp, color: iconColor),
              SizedBox(width: 8.w),
              Text(title,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  const _TeamMember({
    required this.name,
    required this.speciality,
    required this.bgColor,
    required this.emoji,
    this.email,
    this.phone,
    this.experience,
    this.isPrimary = false,
  });

  final String name;
  final String speciality;
  final String emoji;
  final Color bgColor;
  final String? email;
  final String? phone;
  final int? experience;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: TextStyle(fontSize: 20.sp)),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isPrimary
                        ? '$speciality — Primary Therapist'
                        : speciality,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (experience != null)
                    Text(
                      '${experience} yrs experience',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  if (email != null && email!.isNotEmpty)
                    Text(
                      email!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            if (phone != null && phone!.isNotEmpty)
              Row(
                children: [
                  _IconBtn(Icons.phone_rounded, onTap: () {
                    launchUrl(Uri.parse('tel:$phone'));
                  }),
                  SizedBox(width: 4.w),
                  _IconBtn(Icons.chat_bubble_outline_rounded, onTap: () {
                    launchUrl(Uri.parse('https://wa.me/$phone'));
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn(this.icon, {this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 16.sp, color: AppColors.textSecondary),
      ),
    );
  }
}

class _Update extends StatelessWidget {
  const _Update(this.name, this.time, this.text, this.borderColor);
  final String name, time, text;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 10.w, 10.h),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              SizedBox(width: 6.w),
              Text(time,
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.textTertiary)),
            ],
          ),
          SizedBox(height: 4.h),
          Text(text,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  height: 1.4)),
          SizedBox(height: 4.h),
          Text('View Details',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: borderColor,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow(
      this.title, this.subtitle, this.bgColor, this.iconColor);
  final String title, subtitle;
  final Color bgColor, iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Icon(Icons.description_rounded,
                size: 20.sp, color: iconColor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
