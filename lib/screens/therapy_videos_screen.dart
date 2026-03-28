import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/video_item.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';
import 'videos_list_screen.dart';

/// Mirrors /components/TherapyVideosScreen.tsx
class TherapyVideosScreen extends StatefulWidget {
  const TherapyVideosScreen({super.key});

  @override
  State<TherapyVideosScreen> createState() => _TherapyVideosScreenState();
}

class _TherapyVideosScreenState extends State<TherapyVideosScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = true;
  String? _error;

  // Filled from `getPatientLibraries` response.
  List<_TabDef> _tabs = [];
  Map<String, List<_VideoModule>> _modules = {};

  @override
  void initState() {
    super.initState();
    _loadLibraries();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadLibraries() async {
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

    final result = await NetworkHelper().getPatientLibraries(
      childId: childId,
      viewMode: 'patient',
    );

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _isLoading = false;
        _error = result['message'] ?? 'Failed to load libraries';
      });
      return;
    }

    final data = result['data']['data'];
    print('Therapy video lists data ${data}');
    if (data is! List) {
      setState(() {
        _isLoading = false;
        _error = 'No videos found for you!';
      });
      return;
    }

    final List<_TabDef> newTabs = [];
    final Map<String, List<_VideoModule>> newModules = {};

    for (final item in data) {
      if (item is! Map) continue;
      for (final entry in item.entries) {
        final categoryLabel = entry.key.toString(); // e.g. "Medical"
        if (entry.value is! Map) continue;

        final categoryMap = entry.value as Map;
        final categoryId = categoryMap['therapy_category_id'];
        final therapyPlansRaw = categoryMap['therapy_plans'];
        if (categoryId == null || therapyPlansRaw is! Map) continue;

        final categoryIdStr = categoryId.toString();
        newTabs.add(_TabDef(categoryLabel, categoryIdStr));

        final List<_VideoModule> modulesForCategory = [];
        for (final planEntry in therapyPlansRaw.entries) {
          final planMap = planEntry.value;
          if (planMap is! Map) continue;

          final therapyName =
              (planMap['therapy_name'] ?? planEntry.key).toString();
          final videosRaw = planMap['videos'];
          final List<VideoItem> videoItems = [];
          final avgDuration = planMap['average_duration']?.toString() ?? '';
          final planDescription = planMap['description']?.toString() ?? '';

          if (videosRaw is Map) {
            for (final videoEntry in videosRaw.entries) {
              final videoValue = videoEntry.value;

              // New model: "videos": { "<key>": [ {videoObj}, ... ] }
              if (videoValue is List) {
                for (final element in videoValue) {
                  if (element is! Map) continue;
                  final v = element;

                  final videoUrl = v['video_url']?.toString();
                  if (videoUrl == null || videoUrl.isEmpty) continue;

                  final sessionId = v['session_id'] is int
                      ? v['session_id'] as int
                      : int.tryParse('${v['session_id'] ?? ''}');
                  final therapyId = v['therapy_id'] is int
                      ? v['therapy_id'] as int
                      : int.tryParse('${v['therapy_id'] ?? ''}');
                  final watchStatus = v['watch_status'] is int
                      ? v['watch_status'] as int
                      : int.tryParse('${v['watch_status'] ?? ''}');
                  final duration = v['duration']?.toString();

                  videoItems.add(
                    VideoItem(
                      sessionId: sessionId,
                      therapyId: therapyId,
                      sessionName:
                          v['session_name']?.toString() ?? videoEntry.key.toString(),
                      instruction: v['instruction']?.toString() ?? '',
                      videoUrl: videoUrl,
                      thumbnailUrl: v['thumbnail_url']?.toString(),
                      watchStatus: watchStatus,
                      duration: duration,
                    ),
                  );
                }
                continue;
              }

              // Backward compatibility: old model could be
              // "videos": { "<key>": { ...videoObj } }
              if (videoValue is Map) {
                final v = videoValue;
                final videoUrl = v['video_url']?.toString();
                if (videoUrl == null || videoUrl.isEmpty) continue;

                final sessionId = v['session_id'] is int
                    ? v['session_id'] as int
                    : int.tryParse('${v['session_id'] ?? ''}');
                final therapyId = v['therapy_id'] is int
                    ? v['therapy_id'] as int
                    : int.tryParse('${v['therapy_id'] ?? ''}');
                final watchStatus = v['watch_status'] is int
                    ? v['watch_status'] as int
                    : int.tryParse('${v['watch_status'] ?? ''}');
                final duration = v['duration']?.toString();

                  videoItems.add(
                    VideoItem(
                    sessionId: sessionId,
                    therapyId: therapyId,
                    sessionName:
                        v['session_name']?.toString() ?? videoEntry.key.toString(),
                    instruction: v['instruction']?.toString() ?? '',
                    videoUrl: videoUrl,
                    thumbnailUrl: v['thumbnail_url']?.toString(),
                    watchStatus: watchStatus,
                    duration: duration,
                  ),
                );
              }
            }
          }

          // Per instruction: _videoModule('{therapy_name}, '','','','') dummy values.
          final int videosCount = videoItems.length;
          modulesForCategory.add(
            _VideoModule(
              title: therapyName,
              duration: avgDuration,
              videos: videosCount,
              videoItems: videoItems,
              description: planDescription,
            ),
          );
        }

        newModules[categoryIdStr] = modulesForCategory;
      }
    }

    if (newTabs.isEmpty) {
      setState(() {
        _tabs = [];
        _modules = {};
        _isLoading = false;
        _error = 'No libraries found';
      });
      return;
    }

    setState(() {
      _tabs = newTabs;
      _modules = newModules;
      _isLoading = false;
      _tabController?.dispose();
      _tabController = TabController(
        length: _tabs.length,
        vsync: this,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          GradientHeader(
            onBack: () => Get.back(),
            title: 'Home Therapy Videos',
            subtitle: 'Curated therapy modules for home practice',
          ),

          // Tab bar
          if (_isLoading)
            const SizedBox.shrink()
          else if (_error != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Text(
                _error!,
                style: TextStyle(color: AppColors.error, fontSize: 14.sp),
              ),
            )
          else if (_tabs.isNotEmpty && _tabController != null)
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.purple,
                unselectedLabelColor: AppColors.textTertiary,
                indicatorColor: AppColors.purple,
                labelStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(fontSize: 12.sp),
                tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
              ),
            ),
          if (!_isLoading && _tabs.isNotEmpty) Container(height: 1, color: AppColors.neutral200),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: ElevatedButton(
                          onPressed: _loadLibraries,
                          child: const Text('Retry'),
                        ),
                      )
                    : (_tabs.isEmpty || _tabController == null)
                        ? Center(
                            child: Text(
                              _error ?? 'No libraries found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp,
                              ),
                            ),
                          )
                    : TabBarView(
                        controller: _tabController!,
                        children: _tabs.map((t) {
                          final modules = _modules[t.key] ?? [];
                          return ListView.separated(
                            padding: EdgeInsets.all(AppSpacing.base.r),
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemCount: modules.length,
                            itemBuilder: (_, i) =>
                                _VideoModuleCard(module: modules[i]),
                          );
                        }).toList(),
                      ),
          ),

          const StandardFooter(),
        ],
      ),
    );
  }
}

class _TabDef {
  final String label;
  final String key;
  const _TabDef(this.label, this.key);
}

class _VideoModule {
  const _VideoModule({
    required this.title,
    required this.duration,
    required this.videos,
    required this.videoItems,
    required this.description,
  });

  final String title;
  final String duration;
  final int videos;
  final List<VideoItem> videoItems;
  final String description;
}

class _VideoModuleCard extends StatefulWidget {
  const _VideoModuleCard({required this.module});
  final _VideoModule module;

  @override
  State<_VideoModuleCard> createState() => _VideoModuleCardState();
}

class _VideoModuleCardState extends State<_VideoModuleCard> {
  bool _isNavigating = false;

  Widget _fallbackThumb() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFEE2E2), Color(0xFFFCE7F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.play_circle_rounded,
          size: 36.sp,
          color: AppColors.pink600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final firstThumb = module.videoItems.isNotEmpty
        ? module.videoItems.first.thumbnailUrl?.trim()
        : null;
    final hasThumb = firstThumb != null && firstThumb.isNotEmpty;

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
        children: [
          Row(
            children: [
              // Thumbnail: first video in this module's list
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Container(
                  width: 90.w,
                  height: 64.h,
                  color: const Color(0xFFFEE2E2),
                  child: hasThumb
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: firstThumb,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFFFCE7F3),
                                child: Center(
                                  child: SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _fallbackThumb(),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.play_circle_rounded,
                                size: 36.sp,
                                color: Colors.white.withOpacity(0.92),
                                shadows: const [
                                  Shadow(
                                    blurRadius: 6,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : _fallbackThumb(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      module.description,
                      style: TextStyle(
                          fontSize: 11.sp, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 12.sp, color: AppColors.textTertiary),
                        SizedBox(width: 3.w),
                        Text(module.duration,
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textTertiary)),
                        SizedBox(width: 12.w),
                        Icon(Icons.video_library_rounded,
                            size: 12.sp, color: AppColors.textTertiary),
                        SizedBox(width: 3.w),
                        Text('${module.videos} videos',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: (module.videoItems.isEmpty || _isNavigating)
                ? null
                : () async {
                    setState(() => _isNavigating = true);
                    await Get.to(
                      () => VideosListScreen(
                        title: module.title,
                        videoItems: module.videoItems,
                      ),
                    );
                    if (mounted) setState(() => _isNavigating = false);
                  },
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.red600,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded,
                      size: 18.sp, color: Colors.white),
                  SizedBox(width: 6.w),
                  Text('Watch Module',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}