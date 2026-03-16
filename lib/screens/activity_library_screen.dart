import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/standard_footer.dart';

/// Mirrors /components/ActivityLibraryScreen.tsx
class ActivityLibraryScreen extends StatefulWidget {
  const ActivityLibraryScreen({super.key});

  @override
  State<ActivityLibraryScreen> createState() => _ActivityLibraryScreenState();
}

class _ActivityLibraryScreenState extends State<ActivityLibraryScreen> {
  String _selectedCategory = 'all';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<_Category> _categories = [
    _Category('all', 'All Activities', 245),
    _Category('gross-motor', 'Gross Motor', 58),
    _Category('fine-motor', 'Fine Motor', 42),
    _Category('speech', 'Speech & Language', 65),
    _Category('cognitive', 'Cognitive', 38),
    _Category('social', 'Social Skills', 42),
  ];

  static const List<_Activity> _activities = [
    _Activity(
      id: 1,
      title: 'Ball Rolling Exercise',
      category: 'Gross Motor',
      categoryKey: 'gross-motor',
      ageRange: '2–4 years',
      duration: '10–15 min',
      difficulty: 'Easy',
      materials: 'Medium-sized ball',
      description: 'Improve coordination and balance through guided ball rolling',
      hasVideo: true,
      isPrescribed: false,
    ),
    _Activity(
      id: 2,
      title: 'Building Block Stacking',
      category: 'Fine Motor',
      categoryKey: 'fine-motor',
      ageRange: '3–5 years',
      duration: '15–20 min',
      difficulty: 'Medium',
      materials: 'Building blocks set',
      description: 'Enhance hand-eye coordination and precision',
      hasVideo: true,
      isPrescribed: true,
    ),
    _Activity(
      id: 3,
      title: 'Picture Naming Game',
      category: 'Speech & Language',
      categoryKey: 'speech',
      ageRange: '2–6 years',
      duration: '10 min',
      difficulty: 'Easy',
      materials: 'Picture cards',
      description: 'Vocabulary building through visual recognition',
      hasVideo: true,
      isPrescribed: false,
    ),
    _Activity(
      id: 4,
      title: 'Color Sorting Activity',
      category: 'Cognitive',
      categoryKey: 'cognitive',
      ageRange: '3–5 years',
      duration: '15 min',
      difficulty: 'Easy',
      materials: 'Colored objects/cards',
      description: 'Teach color recognition and categorization skills',
      hasVideo: false,
      isPrescribed: false,
    ),
    _Activity(
      id: 5,
      title: 'Simon Says Game',
      category: 'Social Skills',
      categoryKey: 'social',
      ageRange: '3–6 years',
      duration: '10–20 min',
      difficulty: 'Easy',
      materials: 'None required',
      description: 'Build listening skills and social engagement through play',
      hasVideo: false,
      isPrescribed: false,
    ),
    _Activity(
      id: 6,
      title: 'Bead Threading',
      category: 'Fine Motor',
      categoryKey: 'fine-motor',
      ageRange: '4–6 years',
      duration: '15 min',
      difficulty: 'Medium',
      materials: 'Beads and lace',
      description: 'Develop pincer grasp and eye-hand coordination',
      hasVideo: true,
      isPrescribed: false,
    ),
  ];

  List<_Activity> get _filtered {
    return _activities.where((a) {
      final matchesCat =
          _selectedCategory == 'all' || a.categoryKey == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.cyan600,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: Column(
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
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 16.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text('Activity Library',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    // Search bar
                    Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 12.w),
                          Icon(Icons.search_rounded,
                              size: 18.sp, color: AppColors.textTertiary),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              decoration: InputDecoration(
                                hintText: 'Search activities...',
                                hintStyle: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textTertiary),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Category chips
          Container(
            color: Colors.white,
            height: 50.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final sel = _selectedCategory == cat.id;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.cyan600 : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Center(
                      child: Text(
                        '${cat.name} (${cat.count})',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: sel
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: sel
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(height: 1, color: AppColors.neutral200),

          // Results header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${filtered.length} activities found',
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.textSecondary)),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neutral300),
                      borderRadius:
                          BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list_rounded,
                            size: 14.sp, color: AppColors.textSecondary),
                        SizedBox(width: 4.w),
                        Text('Filter',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48.sp, color: AppColors.textTertiary),
                        SizedBox(height: 12.h),
                        Text('No activities found',
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textTertiary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) =>
                        _ActivityCard(activity: filtered[i]),
                  ),
          ),
          const StandardFooter(),
        ],
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.cyan600,
        child: Icon(Icons.add_rounded, size: 26.sp, color: Colors.white),
      ),
    );
  }
}

// ── Models ───────────────────────────────────────────────────────────────────

class _Category {
  final String id, name;
  final int count;
  const _Category(this.id, this.name, this.count);
}

class _Activity {
  final int id;
  final String title, category, categoryKey, ageRange, duration, difficulty,
      materials, description;
  final bool hasVideo, isPrescribed;
  const _Activity({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryKey,
    required this.ageRange,
    required this.duration,
    required this.difficulty,
    required this.materials,
    required this.description,
    required this.hasVideo,
    required this.isPrescribed,
  });
}

// ── Activity card ─────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});
  final _Activity activity;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(activity.title,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                        ),
                        if (activity.isPrescribed)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: AppColors.green100,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text('Prescribed',
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.green600,
                                    fontWeight: FontWeight.w500)),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      children: [
                        _Chip(activity.category, AppColors.blue100,
                            AppColors.blue600),
                        _Chip(activity.difficulty, AppColors.purple100,
                            AppColors.purple),
                      ],
                    ),
                  ],
                ),
              ),
              if (activity.hasVideo) ...[
                SizedBox(width: 12.w),
                Container(
                  width: 58.r,
                  height: 58.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCFFAFE), Color(0xFFDBEAFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(Icons.play_circle_rounded,
                      size: 28.sp, color: AppColors.cyan600),
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          Text(activity.description,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  height: 1.4)),
          SizedBox(height: 10.h),
          Row(
            children: [
              _InfoItem('Age', activity.ageRange),
              SizedBox(width: 16.w),
              _InfoItem('Duration', activity.duration),
            ],
          ),
          SizedBox(height: 4.h),
          _InfoItem('Materials', activity.materials),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.cyan600,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded,
                            size: 16.sp, color: Colors.white),
                        SizedBox(width: 4.w),
                        Text('Add to Program',
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.neutral300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_rounded,
                            size: 16.sp, color: AppColors.textSecondary),
                        SizedBox(width: 4.w),
                        Text('View Details',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary)),
                      ],
                    ),
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

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.bg, this.text);
  final String label;
  final Color bg, text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10.sp, color: text, fontWeight: FontWeight.w500)),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
        children: [
          TextSpan(text: '$label: ',
              style: const TextStyle(color: AppColors.textTertiary)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
