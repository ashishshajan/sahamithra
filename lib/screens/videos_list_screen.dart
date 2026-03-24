import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';

import '../models/video_item.dart';

class VideosListScreen extends StatelessWidget {
  const VideosListScreen({
    super.key,
    required this.title,
    required this.videoItems,
  });

  final String title;
  final List<VideoItem> videoItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          GradientHeader(
            onBack: () => Get.back(),
            title: 'Videos',
            subtitle: title,
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(AppSpacing.base.r),
              itemCount: videoItems.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, i) {
                final v = videoItems[i];
                return _VideoRow(video: v);
              },
            ),
          ),
          const StandardFooter(),
        ],
      ),
    );
  }
}

class _VideoRow extends StatelessWidget {
  const _VideoRow({required this.video});

  final VideoItem video;

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 90.w,
                height: 64.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEE2E2), Color(0xFFFCE7F3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(
                  Icons.play_circle_rounded,
                  size: 36,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.sessionName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    if (video.instruction.isNotEmpty)
                      Text(
                        video.instruction,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 12.sp, color: AppColors.textTertiary),
              SizedBox(width: 6.w),
              Text(
                video.duration ?? '',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () async {
                  if (video.videoUrl.isEmpty) return;
                  final uri = Uri.parse(video.videoUrl);
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: Icon(Icons.play_arrow_rounded,
                    size: 16.sp, color: AppColors.orange600),
                label: Text(
                  'Play',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.orange600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

