import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sahamitra1_0/widgets/gradient_header.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../providers/app_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/standard_footer.dart';
import '../widgets/standard_header.dart';

/// Mirrors /components/GamificationScreen.tsx
class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              onBack: () => Get.back(),
              showLogo: true,
              title: 'Achievements',
              subtitle: 'Keep up the great work! 🌟',
            ),

            // Points display banner
            _buildPointsBanner(),

            // Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.base.r),
                children: [
                  _buildStreakCard(),
                  SizedBox(height: AppSpacing.base.h),
                  _buildBadgesCard(),
                  SizedBox(height: AppSpacing.base.h),
                  _buildWeeklyChallengesCard(),
                  SizedBox(height: AppSpacing.base.h),
                  _buildRewardsStore(),
                ],
              ),
            ),

            const StandardFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsBanner() {
    return Obx(() {
      final progress = AppProvider.to.progressData.value;
      return Container(
        decoration: const BoxDecoration(gradient: AppColors.purplePinkGradient),
        padding: EdgeInsets.all(AppSpacing.base.r),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.base.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppRadius.xl2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Points',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '${progress.points}',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: AppColors.yellow400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 32.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStreakCard() {
    return Obx(() {
      final progress = AppProvider.to.progressData.value;
      return Container(
        padding: EdgeInsets.all(AppSpacing.xl.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: AppColors.orange100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bolt_rounded,
                      size: 24.sp, color: AppColors.orange600),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Streak',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Keep going to maintain your streak!',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text('🔥', style: TextStyle(fontSize: 48.sp)),
            SizedBox(height: 8.h),
            Text(
              '${progress.streak}',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.orange600,
              ),
            ),
            Text(
              'days in a row',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBadgesCard() {
    return Obx(() {
      final progress = AppProvider.to.progressData.value;
      final badgeGradients = [
        const LinearGradient(
            colors: [Color(0xFFFACC15), Color(0xFFCA8A04)]),
        const LinearGradient(
            colors: [Color(0xFF60A5FA), Color(0xFF2563EB)]),
        const LinearGradient(
            colors: [Color(0xFF4ADE80), Color(0xFF16A34A)]),
        const LinearGradient(
            colors: [Color(0xFFC084FC), Color(0xFF9333EA)]),
        const LinearGradient(
            colors: [Color(0xFFF472B6), Color(0xFFDB2777)]),
        const LinearGradient(
            colors: [Color(0xFFFB923C), Color(0xFFEA580C)]),
      ];
      final badgeIcons = [
        Icons.star_rounded,
        Icons.gps_fixed_rounded,
        Icons.emoji_events_rounded,
        Icons.bolt_rounded,
        Icons.workspace_premium_rounded,
        Icons.card_giftcard_rounded,
      ];

      return Container(
        padding: EdgeInsets.all(AppSpacing.xl.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Badges Earned',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${progress.badges.length}/20',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.base.h),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              children: List.generate(
                progress.badges.length.clamp(0, 6),
                (i) => Column(
                  children: [
                    Container(
                      width: 64.r,
                      height: 64.r,
                      decoration: BoxDecoration(
                        gradient: badgeGradients[i],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                badgeGradients[i].colors.first.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        badgeIcons[i],
                        size: 32.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      progress.badges[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWeeklyChallengesCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Challenges',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.base.h),

          _ChallengeItem(
            title: 'Complete 5 activities',
            progress: 1.0,
            progressColor: AppColors.success,
            borderColor: const Color(0xFFBBF7D0),
            bgColor: const Color(0xFFF0FDF4),
            points: '+100 pts',
            pointsBg: AppColors.success,
            statusText: '✓ Completed! Reward claimed',
            statusColor: const Color(0xFF15803D),
          ),
          SizedBox(height: 12.h),
          _ChallengeItem(
            title: 'Practice speech for 3 days',
            progress: 0.66,
            progressColor: AppColors.blue600,
            borderColor: const Color(0xFFBFDBFE),
            bgColor: const Color(0xFFEFF6FF),
            points: '+75 pts',
            pointsBg: AppColors.blue600,
            statusText: '2/3 days completed',
            statusColor: const Color(0xFF1D4ED8),
          ),
          SizedBox(height: 12.h),
          _ChallengeItem(
            title: 'Try 2 new activities',
            progress: 0.50,
            progressColor: AppColors.purple,
            borderColor: const Color(0xFFE9D5FF),
            bgColor: const Color(0xFFFAF5FF),
            points: '+50 pts',
            pointsBg: AppColors.purple,
            statusText: '1/2 activities completed',
            statusColor: const Color(0xFF7E22CE),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsStore() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard_rounded,
                  size: 20.sp, color: AppColors.pink600),
              SizedBox(width: 8.w),
              Text(
                'Rewards Store',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.base.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.1,
            children: const [
              _RewardCard(emoji: '🎨', label: 'Color Set', points: '500 pts'),
              _RewardCard(emoji: '🧩', label: 'Puzzle Game', points: '750 pts'),
              _RewardCard(emoji: '📚', label: 'Story Book', points: '600 pts'),
              _RewardCard(emoji: '⚽', label: 'Play Ball', points: '800 pts'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChallengeItem extends StatelessWidget {
  const _ChallengeItem({
    required this.title,
    required this.progress,
    required this.progressColor,
    required this.borderColor,
    required this.bgColor,
    required this.points,
    required this.pointsBg,
    required this.statusText,
    required this.statusColor,
  });

  final String title;
  final double progress;
  final Color progressColor;
  final Color borderColor;
  final Color bgColor;
  final String points;
  final Color pointsBg;
  final String statusText;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: pointsBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  points,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(progressColor),
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11.sp,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.emoji,
    required this.label,
    required this.points,
  });

  final String emoji;
  final String label;
  final String points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200, width: 2),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 32.sp)),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            height: 32.h,
            decoration: BoxDecoration(
              color: AppColors.pink600,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                points,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
