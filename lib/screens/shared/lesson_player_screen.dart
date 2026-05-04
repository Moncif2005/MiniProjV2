import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../services/progress_service.dart';
import '../../l10n/app_localizations.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String lessonTitle;
  final String courseId;
  final String lessonId;
  final String lessonType;
  final bool isLocked;
  final String description;
  final bool isFirstLesson; // ✅ للتتبع

  const LessonPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.lessonTitle,
    required this.courseId,
    required this.lessonId,
    this.lessonType = 'video',
    this.isLocked = false,
    this.description = '',
    this.isFirstLesson = false,
  });
  
  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  YoutubePlayerController? _videoController;
  final ProgressService _progressService = ProgressService();
  bool _hasEnrolled = false;

  // ✅ دالة لتحديد لون التمييز حسب نوع الدرس
  Color get _accentColor => widget.lessonType == 'video' ? AppColors.primary : AppColors.purple;

  @override
  void initState() {
    super.initState();
    _setupOrientation();
    _initVideo();
    _handleEnrollment(); // ✅ تنفيذ التتبع
  }

  void _setupOrientation() {
    if (widget.lessonType == 'video') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  void _initVideo() {
    if (widget.lessonType == 'video' && !widget.isLocked) {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId != null) {
        _videoController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: true, mute: false, enableCaption: false),
        );
      }
    }
  }

Future<void> _handleEnrollment() async {
  // ✅✅✅ إزالة شرط isFirstLesson ✅✅✅
  // نسجل الطالب عند فتح أي درس، والدالة تتعامل مع التكرار تلقائياً
  if (!_hasEnrolled) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _progressService.enrollStudentInCourse(
        courseId: widget.courseId,
        studentId: user.uid,
      );
      _hasEnrolled = true; // لمنع الاستدعاء المتكرر أثناء نفس الجلسة
    }
  }
}
  @override
  void dispose() {
    _videoController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  void _markAsComplete() async {
    if (widget.isLocked) return;
    await _progressService.markLessonAsComplete(widget.courseId, widget.lessonId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white), const SizedBox(width: 8), Text(AppLocalizations.of(context).lessonCompleted)]),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
        return true;
      },
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: isLandscape && widget.lessonType == 'video' ? null : AppBar(
          backgroundColor: c.surface,
          elevation: 0,
          title: Text(widget.lessonTitle, style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary), onPressed: () => Navigator.pop(context)),
          actions: [
            if (widget.lessonType == 'video')
              IconButton(icon: Icon(Icons.fullscreen_rounded, color: c.textSecondary), onPressed: () { /* منطق ملء الشاشة */ }),
          ],
        ),
        body: Column(
          children: [
            // ── Media Player / Locked State ──
            _buildMediaSection(c),
            
            // ── Content & Actions ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ العنوان مع شريط ملون جانبي
                    Row(
                      children: [
                        Container(width: 4, height: 24, decoration: BoxDecoration(color: _accentColor, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(widget.lessonTitle, style: TextStyle(color: c.textPrimary, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // ✅ الوصف في بطاقة أنيقة
                    if (widget.description.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border.withOpacity(0.5))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [Icon(Icons.info_outline_rounded, size: 16, color: _accentColor), const SizedBox(width: 6), Text(AppLocalizations.of(context).aboutThisLesson, style: TextStyle(color: c.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))]),
                            const SizedBox(height: 10),
                            Text(widget.description, style: TextStyle(color: c.textSecondary.withOpacity(0.9), fontSize: 14, fontFamily: 'Inter', height: 1.6)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ✅ تعليمات إكمال الدرس
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: _accentColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: _accentColor.withOpacity(0.2))),
                      child: Row(
                        children: [
                          Icon(widget.lessonType == 'video' ? Icons.play_circle_outline_rounded : Icons.menu_book_rounded, color: _accentColor, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(widget.lessonType == 'video' ? 'Watch the full video to complete this lesson.' : 'Read the document carefully to complete this lesson.', style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter'))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ✅ زر الإجراء الرئيسي (محسّن)
                    StreamBuilder<bool>(
                      stream: _progressService.isLessonCompletedStream(widget.courseId, widget.lessonId),
                      builder: (context, snap) {
                        final isDone = snap.data ?? false;
                        final isDisabled = widget.isLocked || isDone;
                        return SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: isDisabled ? null : _markAsComplete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.isLocked ? c.iconBg : (isDone ? AppColors.green : _accentColor),
                              disabledBackgroundColor: c.iconBg,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: widget.isLocked ? 0 : 4,
                              shadowColor: _accentColor.withOpacity(0.3),
                            ),
                            icon: Icon(
                              widget.isLocked ? Icons.lock_outline_rounded : (isDone ? Icons.check_circle_rounded : Icons.play_circle_fill_rounded),
                              color: widget.isLocked ? c.textMuted : Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              widget.isLocked ? 'Complete Previous Lesson' : (isDone ? 'Lesson Completed ✓' : 'Mark as Complete'),
                              style: TextStyle(color: widget.isLocked ? c.textMuted : Colors.white, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // ✅ ملاحظة مساعدة صغيرة
                    if (widget.isLocked)
                      Text('🔒 Unlock this lesson by completing the previous one.', style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter', fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ودجت منفصل لقسم الوسائط (فيديو/بي دي إف/مقفول)
  Widget _buildMediaSection(ThemeColors c) {
    if (widget.isLocked) {
      return _buildLockedState(c);
    } else if (widget.lessonType == 'video') {
      return _buildVideoPlayer(c);
    } else {
      return _buildPdfViewer(c);
    }
  }

  Widget _buildLockedState(ThemeColors c) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width * 9 / 16,
      decoration: BoxDecoration(color: c.surface2, border: Border.all(color: c.border), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: c.iconBg, shape: BoxShape.circle), child: Icon(Icons.lock_outline_rounded, size: 32, color: c.textMuted)),
          const SizedBox(height: 16),
          Text('This lesson is locked', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Text('Complete the previous lesson to unlock', style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(ThemeColors c) {
    if (_videoController == null) {
      return Container(height: 200, color: c.surface2, child: const Center(child: CircularProgressIndicator()));
    }
    return YoutubePlayerBuilder(
      onEnterFullScreen: () => SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]),
      onExitFullScreen: () => SystemChrome.setPreferredOrientations(DeviceOrientation.values),
      player: YoutubePlayer(controller: _videoController!, showVideoProgressIndicator: true, progressIndicatorColor: _accentColor, ),
      builder: (context, player) {
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        return Container(decoration: BoxDecoration(color: Colors.black, borderRadius: isLandscape ? BorderRadius.zero : const BorderRadius.vertical(bottom: Radius.circular(20))), child: isLandscape ? Expanded(child: player) : player);
      },
    );
  }

  Widget _buildPdfViewer(ThemeColors c) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(color: c.surface2, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)), border: Border.all(color: c.border)),
      child: ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)), child: SfPdfViewer.network(widget.videoUrl, canShowScrollHead: false)),
    );
  }
}