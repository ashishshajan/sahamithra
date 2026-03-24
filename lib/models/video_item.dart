class VideoItem {
  const VideoItem({
    required this.sessionName,
    required this.videoUrl,
    this.sessionId,
    this.therapyId,
    this.instruction = '',
    this.thumbnailUrl,
    this.watchStatus,
    this.duration,
  });

  final int? sessionId;
  final int? therapyId;
  final String sessionName;
  final String instruction;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? watchStatus;
  final String? duration;
}

