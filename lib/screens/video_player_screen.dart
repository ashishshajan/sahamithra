import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../core/global_utils.dart';
import '../core/network/network_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/video_item.dart';
import '../routes/app_routes.dart';
import '../widgets/gradient_header.dart';
import '../providers/language_provider.dart';

/// Pass [Get.arguments] as either:
/// - a [VideoItem] (e.g. from [VideosListScreen]), or
/// - a `Map` with keys: `session_id`, `therapy_id`, `session_name`,
///   `instruction`, `video_url`, `thumbnail_url`, `watch_status`, `duration`.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  TherapyVideoSessionArgs? _args;
  YoutubePlayerController? _ytController;
  VideoPlayerController? _networkController;
  bool _networkLoading = false;
  bool _landscapePreferred = false;
  bool _youtubeFullscreen = false;
  bool _isLandscapeOrientationApplied = false;

  // Watch-tracking state.
  static const Duration _watchReportInterval = Duration(seconds: 15);
  Timer? _watchTimer;
  bool _wasPlaying = false;
  bool _hasEnded = false;
  bool _isReporting = false;
  int _lastReportedSeconds = -1;

  // Therapy session meta (IDs, watch status) is only relevant for authenticated users.
  bool get _isLoggedInUser {
    final t = GlobalUtils().token;
    return t != null && t.trim().isNotEmpty;
  }

  bool get _canReportWatch {
    final args = _args;
    if (args == null) return false;
    if (args.sessionId <= 0) return false;
    if (!_isLoggedInUser) return false;
    if (GlobalUtils().childId == null) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _args = TherapyVideoSessionArgs.fromGetArguments();
    final url = _args?.videoUrl ?? '';
    final id = YoutubePlayer.convertUrlToId(url) ?? '';
    if (id.length == 11) {
      _ytController = YoutubePlayerController(
        initialVideoId: id,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          loop: false,
        ),
      )..addListener(_handlePlayerStateChange);
      return;
    }
    if (_isDirectVideoUrl(url)) {
      _initNetworkVideo(url);
    }
  }

  @override
  void dispose() {
    _stopWatchTimer();
    // Capture a final progress/completion update before tearing down.
    _reportFinalWatchUpdate();
    _ytController?.removeListener(_handlePlayerStateChange);
    _ytController?.dispose();
    _networkController?.removeListener(_handlePlayerStateChange);
    _networkController?.dispose();
    _restorePortraitOrientations();
    super.dispose();
  }

  bool _isDirectVideoUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    final path = uri.path.toLowerCase();
    return path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.m4v') ||
        path.endsWith('.webm');
  }

  Future<void> _initNetworkVideo(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    setState(() => _networkLoading = true);
    final controller = VideoPlayerController.networkUrl(uri);
    try {
      await controller.initialize();
      controller.addListener(_handlePlayerStateChange);
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _networkController = controller;
        _networkLoading = false;
      });
    } catch (_) {
      controller.dispose();
      if (!mounted) return;
      setState(() => _networkLoading = false);
    }
  }

  void _handlePlayerStateChange() {
    if (!_hasActivePlayer) return;
    if (_isPlaybackEnded && !_hasEnded) {
      _hasEnded = true;
      _wasPlaying = false;
      _stopWatchTimer();
      _sendWatchUpdate(
        watchStatus: 2,
        durationSeconds: _totalDurationSeconds,
      );
      return;
    }

    final isPlaying = _isPlaying;
    if (isPlaying && !_wasPlaying) {
      _wasPlaying = true;
      _hasEnded = false;
      _startWatchTimer();
    } else if (!isPlaying && _wasPlaying) {
      _wasPlaying = false;
      _stopWatchTimer();
      // Pause/stop → report current position immediately.
      _sendWatchUpdate(
        watchStatus: 1,
        durationSeconds: _currentPositionSeconds,
      );
    }
  }

  bool get _hasActivePlayer => _ytController != null || _networkController != null;

  bool get _isPlaying {
    if (_ytController != null) return _ytController!.value.isPlaying;
    final network = _networkController;
    if (network != null) return network.value.isPlaying;
    return false;
  }

  bool get _isPlaybackEnded {
    if (_ytController != null) {
      return _ytController!.value.playerState == PlayerState.ended;
    }
    final network = _networkController;
    if (network == null || !network.value.isInitialized) return false;
    final duration = network.value.duration;
    if (duration <= Duration.zero) return false;
    return network.value.position >= duration && !network.value.isPlaying;
  }

  int get _currentPositionSeconds {
    if (_ytController != null) return _ytController!.value.position.inSeconds;
    return _networkController?.value.position.inSeconds ?? 0;
  }

  int get _totalDurationSeconds {
    if (_ytController != null) {
      final total = _ytController!.metadata.duration.inSeconds;
      if (total > 0) return total;
      return _ytController!.value.position.inSeconds;
    }
    final network = _networkController;
    if (network == null) return 0;
    final total = network.value.duration.inSeconds;
    if (total > 0) return total;
    return network.value.position.inSeconds;
  }

  void _startWatchTimer() {
    _watchTimer?.cancel();
    _watchTimer = Timer.periodic(_watchReportInterval, (_) {
      if (!_isPlaying) return;
      _sendWatchUpdate(
        watchStatus: 1,
        durationSeconds: _currentPositionSeconds,
      );
    });
  }

  void _stopWatchTimer() {
    _watchTimer?.cancel();
    _watchTimer = null;
  }

  void _reportFinalWatchUpdate() {
    if (!_hasActivePlayer) return;
    final status = _hasEnded ? 2 : 1;
    final seconds = _hasEnded ? _totalDurationSeconds : _currentPositionSeconds;
    if (seconds <= 0 && status != 2) return;
    _sendWatchUpdate(watchStatus: status, durationSeconds: seconds);
  }

  Future<void> _sendWatchUpdate({
    required int watchStatus,
    required int durationSeconds,
  }) async {
    if (!_canReportWatch) return;
    if (durationSeconds < 0) return;
    // Skip duplicate reports with the same progress unless it's a completion.
    if (watchStatus != 2 && durationSeconds == _lastReportedSeconds) return;
    if (_isReporting) return;

    final args = _args;
    final childId = GlobalUtils().childId;
    if (args == null || childId == null) return;

    _isReporting = true;
    _lastReportedSeconds = durationSeconds;
    try {
      await NetworkHelper().updatePatientSessionWatch(
        childId: childId,
        sessionId: args.sessionId,
        watchStatus: watchStatus,
        duration: durationSeconds,
      );
    } catch (_) {
      // Swallow errors: watch reporting should never block playback.
    } finally {
      _isReporting = false;
    }
  }

  void _restorePortraitOrientations() {
    if (!_isLandscapeOrientationApplied) return;
    _isLandscapeOrientationApplied = false;
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _enterLandscape() {
    if (_isLandscapeOrientationApplied) return;
    _isLandscapeOrientationApplied = true;
    setState(() => _landscapePreferred = true);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitLandscape() {
    setState(() => _landscapePreferred = false);
    _restorePortraitOrientations();
  }

  YoutubePlayer _buildYoutubePlayer() {
    return YoutubePlayer(
      controller: _ytController!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: AppColors.purple,
      progressColors: const ProgressBarColors(
        playedColor: AppColors.purple,
        handleColor: AppColors.pink600,
        bufferedColor: Colors.white24,
        backgroundColor: Colors.white12,
      ),
    );
  }

  Widget _buildScaffoldBody(
    TherapyVideoSessionArgs args, {
    Widget? youtubePlayerFromBuilder,
  }) {
    if (_ytController != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: _buildPortraitBody(
          args,
          youtubePlayerFromBuilder: youtubePlayerFromBuilder,
        ),
      );
    }

    final orientation = MediaQuery.orientationOf(context);
    final isLandscape =
        orientation == Orientation.landscape || _landscapePreferred;
    return Scaffold(
      backgroundColor: isLandscape ? Colors.black : const Color(0xFFF8FAFC),
      body: isLandscape
          ? _buildLandscapeBody(args, youtubePlayerFromBuilder: youtubePlayerFromBuilder)
          : _buildPortraitBody(args, youtubePlayerFromBuilder: youtubePlayerFromBuilder),
    );
  }

  Future<void> _openInBrowser() async {
    final url = _args?.videoUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openFeedbackForm(TherapyVideoSessionArgs args) {
    if (args.sessionId <= 0 || args.therapyId <= 0) {
      Get.snackbar(
        'Unavailable',
        'Feedback is unavailable for this video.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(
      AppRoutes.feedback,
      arguments: <String, dynamic>{
        'session_id': args.sessionId,
        'therapy_id': args.therapyId,
        'session_name': args.sessionName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(LanguageProvider.to.t('videoPlayerTitle'))),
        ),
        body: Center(
          child: Obx(
            () => Text(
              LanguageProvider.to.t('videoPlayerMissingArgs'),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _restorePortraitOrientations();
        }
      },
      child: _ytController != null
          ? YoutubePlayerBuilder(
              player: _buildYoutubePlayer(),
              onEnterFullScreen: () {
                if (_youtubeFullscreen) return;
                _youtubeFullscreen = true;
                _enterLandscape();
              },
              onExitFullScreen: () {
                if (!_youtubeFullscreen) return;
                _youtubeFullscreen = false;
                _restorePortraitOrientations();
              },
              builder: (context, player) {
                return _buildScaffoldBody(
                  args,
                  youtubePlayerFromBuilder: player,
                );
              },
            )
          : _buildScaffoldBody(args),
    );
  }

  Widget _buildLandscapeBody(
    TherapyVideoSessionArgs args, {
    Widget? youtubePlayerFromBuilder,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.black,
          child: _buildPlayerWidget(
            isLandscape: true,
            youtubePlayerFromBuilder: youtubePlayerFromBuilder,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_youtubeFullscreen && _ytController != null) {
                      _ytController!.toggleFullScreenMode();
                      return;
                    }
                    _exitLandscape();
                  },
                  icon: const Icon(Icons.screen_lock_portrait_rounded,
                      color: Colors.white),
                  tooltip: 'Portrait',
                ),
                Expanded(
                  child: Text(
                    args.sessionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _restorePortraitOrientations();
                    Get.back();
                  },
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitBody(
    TherapyVideoSessionArgs args, {
    Widget? youtubePlayerFromBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradientHeader(
          onBack: () => Get.back(),
          title: args.sessionName,
          subtitle: 'Therapy video',
          trailing: IconButton(
            onPressed: () {
              if (_ytController != null) {
                _ytController!.toggleFullScreenMode();
                return;
              }
              _enterLandscape();
            },
            icon: Icon(
              Icons.screen_lock_landscape_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
            tooltip: 'Watch in landscape',
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.base.r),
            children: [
              // if (args.thumbnailUrl != null &&
              //     args.thumbnailUrl!.trim().isNotEmpty)
              //   ClipRRect(
              //     borderRadius: BorderRadius.circular(AppRadius.xl2),
              //     child: CachedNetworkImage(
              //       imageUrl: args.thumbnailUrl!,
              //       height: 140.h,
              //       width: double.infinity,
              //       fit: BoxFit.cover,
              //       placeholder: (context, url) => Container(
              //         height: 140.h,
              //         color: AppColors.neutral100,
              //         child: const Center(
              //           child: CircularProgressIndicator(strokeWidth: 2),
              //         ), 
              //       ),
              //       errorWidget: (context, url, error) =>
              //           const SizedBox.shrink(),
              //     ),
              //   ),
              // if (args.thumbnailUrl != null &&
              //     args.thumbnailUrl!.trim().isNotEmpty)
                SizedBox(height: AppSpacing.base.h),
              _buildPlayerWidget(
                isLandscape: false,
                youtubePlayerFromBuilder: youtubePlayerFromBuilder,
              ),
              SizedBox(height: AppSpacing.lg.h),
              if (_isLoggedInUser) _MetaCard(args: args),
              if (_isLoggedInUser && args.sessionId > 0 && args.therapyId > 0)
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.base.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openFeedbackForm(args),
                      icon: const Icon(Icons.feedback_outlined),
                      label: Obx(
                        () => Text(LanguageProvider.to.t('submitFeedback')),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerWidget({
    required bool isLandscape,
    Widget? youtubePlayerFromBuilder,
  }) {
    if (_ytController != null) {
      final yt = youtubePlayerFromBuilder ?? _buildYoutubePlayer();
      if (isLandscape) {
        return Center(child: yt);
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        child: yt,
      );
    }

    if (_networkLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final network = _networkController;
    if (network != null && network.value.isInitialized) {
      final player = GestureDetector(
        onTap: () {
          if (network.value.isPlaying) {
            network.pause();
          } else {
            network.play();
          }
          setState(() {});
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: network.value.aspectRatio > 0
                  ? network.value.aspectRatio
                  : (16 / 9),
              child: VideoPlayer(network),
            ),
            if (!network.value.isPlaying)
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Icon(Icons.play_arrow_rounded, size: 34.sp, color: Colors.white),
              ),
          ],
        ),
      );
      if (isLandscape) {
        return Center(child: player);
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        child: player,
      );
    }

    return _InvalidVideoCard(
      onOpenExternal: _openInBrowser,
    );
  }
}

class TherapyVideoSessionArgs {
  TherapyVideoSessionArgs({
    required this.sessionId,
    required this.therapyId,
    required this.sessionName,
    required this.instruction,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.watchStatus,
    this.duration,
  });

  final int sessionId;
  final int therapyId;
  final String sessionName;
  final String instruction;
  final String videoUrl;
  final String? thumbnailUrl;
  final int watchStatus;
  final String? duration;

  factory TherapyVideoSessionArgs.fromVideoItem(VideoItem v) {
    return TherapyVideoSessionArgs(
      sessionId: v.sessionId ?? 0,
      therapyId: v.therapyId ?? 0,
      sessionName: v.sessionName,
      instruction: v.instruction,
      videoUrl: v.videoUrl,
      thumbnailUrl: v.thumbnailUrl,
      watchStatus: v.watchStatus ?? 0,
      duration: v.duration,
    );
  }

  static TherapyVideoSessionArgs? fromGetArguments() {
    final raw = Get.arguments;
    if (raw == null) return null;
    if (raw is VideoItem) {
      return TherapyVideoSessionArgs.fromVideoItem(raw);
    }
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(
      raw.map((k, v) => MapEntry(k.toString(), v)),
    );
    return TherapyVideoSessionArgs(
      sessionId: _asInt(m['session_id']),
      therapyId: _asInt(m['therapy_id']),
      sessionName: m['session_name']?.toString() ?? 'Video',
      instruction: m['instruction']?.toString() ?? '',
      videoUrl: m['video_url']?.toString() ?? '',
      thumbnailUrl: m['thumbnail_url']?.toString(),
      watchStatus: _asInt(m['watch_status']),
      duration: m['duration']?.toString(),
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.args});

  final TherapyVideoSessionArgs args;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg.r),
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
          Text(
            'Instructions',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            args.instruction.isEmpty ? '—' : args.instruction,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _chip('Session #${args.sessionId}'),
              _chip('Therapy #${args.therapyId}'),
              _chip('Watch status: ${args.watchStatus}'),
              if (args.duration != null && args.duration!.trim().isNotEmpty)
                _chip('Duration: ${args.duration}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.purple50,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.sp, color: AppColors.purple700),
      ),
    );
  }
}

class _InvalidVideoCard extends StatelessWidget {
  const _InvalidVideoCard({required this.onOpenExternal});

  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl.r),
      decoration: BoxDecoration(
        color: AppColors.amber100,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.amber600.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 40.sp, color: AppColors.amber600),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              LanguageProvider.to.t('videoPlayerExternalFallback'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
            ),
          ),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: onOpenExternal,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Obx(
              () => Text(LanguageProvider.to.t('openLink')),
            ),
          ),
        ],
      ),
    );
  }
}
