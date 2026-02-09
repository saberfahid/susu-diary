import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/diary_entry.dart';
import '../../../core/services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceDiaryScreen extends StatefulWidget {
  const VoiceDiaryScreen({super.key});

  @override
  State<VoiceDiaryScreen> createState() => _VoiceDiaryScreenState();
}

class _VoiceDiaryScreenState extends State<VoiceDiaryScreen> {
  static const _channel = MethodChannel('com.susu.diary/recorder');
  bool _isRecording = false;
  String? _currentPath;
  List<FileSystemEntity> _voiceEntries = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingPath;
  Duration _recordDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/voice_diary');
    if (!await folder.exists()) await folder.create();
    final entries = folder.listSync().where((f) => f.path.endsWith('.m4a')).toList();
    entries.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    setState(() {
      _voiceEntries = entries;
    });
  }

  Future<void> _startRecording() async {
    // Request microphone permission at runtime
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to record')),
        );
      }
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/voice_diary');
    if (!await folder.exists()) await folder.create();
    final id = const Uuid().v4();
    final path = '${folder.path}/$id.m4a';
    try {
      await _channel.invokeMethod('startRecording', {'path': path});
      setState(() {
        _isRecording = true;
        _currentPath = path;
        _recordDuration = Duration.zero;
      });
      _tickTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start recording: $e')),
        );
      }
    }
  }

  void _tickTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() => _recordDuration += const Duration(seconds: 1));
        _tickTimer();
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      await _channel.invokeMethod('stopRecording');
    } catch (_) {}
    
    // Save as a DiaryEntry so it appears on the home page
    if (_currentPath != null) {
      final entry = DiaryEntry.create(
        title: 'Voice Diary',
        content: 'Voice diary entry recorded on ${_formatDate(DateTime.now())}',
        mood: 'happy',
        energyLevel: 3,
        tags: ['voice'],
        voiceNoteUrl: _currentPath,
        isVoiceEntry: true,
      );
      await DatabaseService.instance.insertEntry(entry);
    }
    
    setState(() {
      _isRecording = false;
      _currentPath = null;
    });
    await _loadEntries();
  }

  Future<void> _playEntry(String path) async {
    await _audioPlayer.play(DeviceFileSource(path));
    setState(() => _playingPath = path);
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingPath = null);
    });
  }

  Future<void> _deleteEntry(FileSystemEntity entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This voice diary entry will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      // Also remove from database
      final allEntries = await DatabaseService.instance.getAllEntries();
      for (final dbEntry in allEntries) {
        if (dbEntry.voiceNoteUrl == entry.path) {
          await DatabaseService.instance.deleteEntry(dbEntry.id);
          break;
        }
      }
      await entry.delete();
      await _loadEntries();
    }
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.primaryColor,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voice Diary',
          style: TextStyle(
            color: AppTheme.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.2),
                    AppTheme.accentColor.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 60,
                color: _isRecording ? AppTheme.accentColor : AppTheme.primaryColor,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1500.ms,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1, 1),
                  duration: 1500.ms,
                ),
            const SizedBox(height: 24),
            Text(
              _isRecording ? 'Recording... ${_formatDuration(_recordDuration)}' : 'Tap to record your diary',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightText,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? AppTheme.accentColor : AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
              onPressed: () {
                if (_isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Your Voice Diary Entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _voiceEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No voice diary entries yet.',
                        style: TextStyle(color: AppTheme.lightTextSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _voiceEntries.length,
                      itemBuilder: (context, idx) {
                        final entry = _voiceEntries[idx];
                        final stat = entry.statSync();
                        final date = stat.modified;
                        final isPlaying = _playingPath == entry.path;
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: Icon(Icons.record_voice_over, color: AppTheme.primaryColor),
                            title: Text('Entry ${idx + 1}'),
                            subtitle: Text(_formatDate(date)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.pause_circle : Icons.play_arrow,
                                    color: AppTheme.accentColor,
                                  ),
                                  onPressed: () {
                                    if (isPlaying) {
                                      _audioPlayer.pause();
                                      setState(() => _playingPath = null);
                                    } else {
                                      _playEntry(entry.path);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteEntry(entry),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
