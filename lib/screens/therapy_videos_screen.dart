import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/gradient_header.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/TherapyVideosScreen.tsx
class TherapyVideosScreen extends StatefulWidget {
  const TherapyVideosScreen({super.key});

  @override
  State<TherapyVideosScreen> createState() => _TherapyVideosScreenState();
}

class _TherapyVideosScreenState extends State<TherapyVideosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const List<_TabDef> _tabs = [
    _TabDef('Physio', 'physiotherapy'),
    _TabDef('Development', 'developmental'),
    _TabDef('Speech', 'speech'),
    _TabDef('Special Ed', 'special'),
    _TabDef('Medical', 'medical'),
    _TabDef('Psychology', 'psychology'),
  ];

  static const Map<String, List<_VideoModule>> _modules = {
    'physiotherapy': [
      _VideoModule('Mission Mobility and Control', '3–4 min', 12,
          'Neck control, crawling, sitting'),
      _VideoModule('Sitting Balance & Transition', '3–4 min', 5,
          'Core stability, transitions'),
      _VideoModule('Standing Control & Balance', '3–4 min', 4,
          'Standing with support'),
      _VideoModule('Early Walking Training', '3–4 min', 4,
          'Gait training, ambulation'),
    ],
    'developmental': [
      _VideoModule('Blossoming Beginnings (2–9 months)', '3–4 min', 6,
          'Tummy time, grasping, tracking'),
      _VideoModule('First Steps of Independence (12–18 months)', '3–4 min', 7,
          'Walking, scribbling, self-feeding'),
      _VideoModule('Exploring the World (2–2.6 years)', '3–4 min', 8,
          'Running, pretend play, sorting'),
      _VideoModule('Growing Together (3 years)', '3–4 min', 8,
          'Jumping, cooperative play, counting'),
    ],
    'speech': [
      _VideoModule('General Awareness', '4–5 min', 1,
          'Speech milestones for parents'),
      _VideoModule('Tiny Talks: Development', '4–5 min', 1,
          'Vocalizations, first words'),
      _VideoModule('Nurturing Language', '4–5 min', 4,
          'Vocabulary growth techniques'),
      _VideoModule('Fostering Communication', '4–5 min', 13,
          'Pronouns, verbs, commands'),
    ],
    'special': [
      _VideoModule('Focus Power — Attention & Thinking', '3–6 min', 5,
          'Focus games, problem-solving'),
      _VideoModule('Little Voices — Language Growth', '3–6 min', 2,
          'Speech boosters, storytelling'),
      _VideoModule('Growing Together — Social Skills', '3–6 min', 2,
          'Play therapy, emotions'),
      _VideoModule('Pre-Academic Skills', '3–6 min', 6,
          'Pre-reading, writing, maths'),
    ],
    'medical': [
      _VideoModule('General Awareness', '3–5 min', 5,
          'Anemia, vitamin deficiency, thyroid'),
      _VideoModule('Parenting Techniques', '3–5 min', 9,
          'Quality time, screen usage, hygiene'),
      _VideoModule('Syndromic Diseases', '3–5 min', 1,
          'Understanding syndromes'),
    ],
    'psychology': [
      _VideoModule('Understanding Early Development', '3–5 min', 5,
          'Normal vs delayed development'),
      _VideoModule('Neurodevelopmental Disorders', '3–5 min', 6,
          'Autism, ADHD, cerebral palsy'),
      _VideoModule('Core Psychological Areas', '3–5 min', 13,
          'Cognitive, behavioral, emotional'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
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
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              labelColor: AppColors.purple,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.purple,
              labelStyle: TextStyle(
                  fontSize: 12.sp, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 12.sp),
              tabs: _tabs
                  .map((t) => Tab(text: t.label))
                  .toList(),
            ),
          ),
          Container(height: 1, color: AppColors.neutral200),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: _tabs.map((t) {
                final modules = _modules[t.key] ?? [];
                return ListView.separated(
                  padding: EdgeInsets.all(AppSpacing.base.r),
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemCount: modules.length,
                  itemBuilder: (_, i) => _VideoModuleCard(module: modules[i]),
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
  final String title;
  final String duration;
  final int videos;
  final String description;
  const _VideoModule(
      this.title, this.duration, this.videos, this.description);
}

class _VideoModuleCard extends StatelessWidget {
  const _VideoModuleCard({required this.module});
  final _VideoModule module;

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
        children: [
          Row(
            children: [
              // Thumbnail
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
                child: Icon(Icons.play_circle_rounded,
                    size: 36.sp, color: AppColors.pink600),
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
            onTap: () {},
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