import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_header.dart';
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
    final lang = LanguageProvider.to;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final childId = GlobalUtils().childId;

    if (childId == null) {
      setState(() {
        _isLoading = false;
        _error = lang.t('teamErrorChildIdNotFound');
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
        _error = result['message']?.toString() ??
            lang.t('teamErrorLoadFailed');
      }
    });
  }

  Widget _buildCareTeamSection(LanguageProvider lang) {
    final primary = _careTeam?['primary_therapist'] as Map<String, dynamic>?;
    final additional =
        List<Map<String, dynamic>>.from(_careTeam?['additional_therapists'] ?? []);

    if (primary == null && additional.isEmpty) {
      return Text(
        lang.t('teamNoneAssigned'),
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
          name: primary['name']?.toString().trim().isNotEmpty == true
              ? primary['name'].toString()
              : lang.t('teamPrimaryTherapist'),
          speciality: primary['speciality']?.toString() ?? '',
          bgColor: AppColors.purple100,
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

    for (var i = 0; i < additional.length; i++) {
      final t = additional[i];
      final Color bg = i.isEven ? AppColors.pink100 : AppColors.blue100;
      widgets.add(
        _TeamMember(
          name: t['name']?.toString().trim().isNotEmpty == true
              ? t['name'].toString()
              : lang.t('teamTherapistFallback'),
          speciality: t['speciality']?.toString() ?? '',
          bgColor: bg,
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
    return Obx(() {
      final lang = LanguageProvider.to;
      final childName = GlobalUtils().childName;
      final subtitle = (childName != null && childName.isNotEmpty)
          ? '$childName${lang.t('teamSubtitlePossessiveSuffix')}'
          : lang.t('careTeam');

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            GradientHeader(
              onBack: () => Get.back(),
              title: lang.t('teamCollaborationTitle'),
              subtitle: subtitle,
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
                              SizedBox(
                                width: 200.w,
                                child: GradientButton(
                                  onPressed: _loadCareTeam,
                                  height: 44.h,
                                  child: Text(
                                    lang.t('retry'),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
                    iconColor: AppColors.purple,
                    title: lang.t('teamMultidisciplinary'),
                    child: _buildCareTeamSection(lang),
                  ),
                  SizedBox(height: 12.h),

                  // Recent updates
                  _Section(
                    icon: Icons.update_rounded,
                    iconColor: AppColors.pink600,
                    title: lang.t('teamRecentUpdates'),
                    child: Column(
                      children: [
                        _Update(
                          'Dr. Rajesh Kumar',
                          lang.t('teamUpdateTime2hAgo'),
                          lang.t('teamUpdate1Text'),
                          AppColors.purple,
                          lang,
                        ),
                        _Update(
                          'Dr. Sarah Thompson',
                          lang.t('teamUpdateTime5hAgo'),
                          lang.t('teamUpdate2Text'),
                          AppColors.pink600,
                          lang,
                        ),
                        _Update(
                          'Ms. Priya Menon',
                          lang.t('teamUpdateTime1dAgo'),
                          lang.t('teamUpdate3Text'),
                          AppColors.blue600,
                          lang,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Shared documents
                  _Section(
                    icon: Icons.folder_shared_rounded,
                    iconColor: AppColors.blue600,
                    title: lang.t('teamSharedDocuments'),
                    child: Column(
                      children: [
                        _DocumentRow(
                            lang.t('teamDoc1Title'),
                            lang.t('teamDoc1Subtitle'),
                            AppColors.purple100,
                            AppColors.purple),
                        _DocumentRow(
                            lang.t('teamDoc2Title'),
                            lang.t('teamDoc2Subtitle'),
                            AppColors.pink100,
                            AppColors.pink600),
                        _DocumentRow(
                            lang.t('teamDoc3Title'),
                            lang.t('teamDoc3Subtitle'),
                            AppColors.blue100,
                            AppColors.blue600),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          onPressed: () {},
                          height: 48.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_call_rounded,
                                  size: 18.sp, color: Colors.white),
                              SizedBox(width: 6.w),
                              Text(lang.t('teamMeeting'),
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.chat_bubble_outline_rounded,
                              size: 18.sp, color: AppColors.purple),
                          label: Text(lang.t('teamGroupChat'),
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.purple)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(0, 48.h),
                            side: BorderSide(color: AppColors.purple),
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
    });
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
                  Builder(builder: (_) {
                    final lang = LanguageProvider.to;
                    final label = isPrimary
                        ? (speciality.isNotEmpty
                            ? '$speciality — ${lang.t('teamPrimaryTherapist')}'
                            : lang.t('teamPrimaryTherapist'))
                        : speciality;
                    return Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    );
                  }),
                  if (experience != null)
                    Builder(builder: (_) {
                      final lang = LanguageProvider.to;
                      return Text(
                        '$experience ${lang.t('teamYearsExperience')}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textTertiary,
                        ),
                      );
                    }),
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
  const _Update(this.name, this.time, this.text, this.borderColor, this.lang);
  final String name, time, text;
  final Color borderColor;
  final LanguageProvider lang;

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
          Text(lang.t('viewDetails'),
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
