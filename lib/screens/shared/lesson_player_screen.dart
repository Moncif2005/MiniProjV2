import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minipr/services/progress_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../theme/app_colors.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String lessonTitle;
  final String courseId;
  final String lessonId;

  const LessonPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.lessonTitle,
    required this.courseId,
    required this.lessonId,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isCompleted = false;
  
  // ✅✅✅ المكان الصحيح لتعريف الخدمة: هنا كمتغير للكلاس
  final ProgressService _progressService = ProgressService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _markAsComplete() async {
    await _progressService.markLessonAsComplete(widget.courseId, widget.lessonId);
    
    setState(() => _isCompleted = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lesson completed! 🎉'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: YoutubePlayerBuilder(
        onExitFullScreen: () {
          SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        },
        onEnterFullScreen: () {
           SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        },
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
          topActions: <Widget>[
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                _controller.metadata.title.isNotEmpty 
                  ? _controller.metadata.title 
                  : widget.lessonTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
          onReady: () {
            debugPrint('Player is ready.');
          },
        ),
        builder: (context, player) {
          return Scaffold(
            backgroundColor: c.bg,
            appBar: AppBar(
              backgroundColor: c.surface,
              elevation: 0,
              title: Text(
                widget.lessonTitle,
                style: TextStyle(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                player,

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lessonTitle,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Watch the full video to complete this lesson.',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ✅✅✅ زر إكمال الدرس مع StreamBuilder
                        StreamBuilder<bool>(
                          stream: _progressService.isLessonCompletedStream(widget.courseId, widget.lessonId),
                          builder: (context, snap) {
                            final isDone = snap.data ?? false;
                            // تحديث الحالة المحلية لتحديث الواجهة فوراً دون انتظار
                            if (isDone && !_isCompleted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if(mounted) setState(() => _isCompleted = true);
                              });
                            }
                            
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: isDone ? null : _markAsComplete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDone ? AppColors.green : AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: Icon(isDone ? Icons.check_circle : Icons.play_circle_fill, color: Colors.white),
                                label: Text(
                                  isDone ? 'Completed' : 'Mark as Complete',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: c.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: c.textMuted),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your progress is saved automatically when you mark a lesson as complete.',
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}