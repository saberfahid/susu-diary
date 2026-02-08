import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class VoiceDiaryScreen extends StatefulWidget {
  const VoiceDiaryScreen({super.key});

  @override
  State<VoiceDiaryScreen> createState() => _VoiceDiaryScreenState();
}

class _VoiceDiaryScreenState extends State<VoiceDiaryScreen> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _currentPath;
  List<FileSystemEntity> _voiceEntries = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadEntries();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }

  Future<void> _loadEntries() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/voice_diary');
    if (!await folder.exists()) await folder.create();
    setState(() {
      _voiceEntries = folder.listSync().where((f) => f.path.endsWith('.aac')).toList();
    });
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/voice_diary');
    if (!await folder.exists()) await folder.create();
    final id = const Uuid().v4();
    final path = '${folder.path}/$id.aac';
    await _recorder!.startRecorder(toFile: path, codec: Codec.aacADTS);
    setState(() {
      _isRecording = true;
      _currentPath = path;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _currentPath = null;
    });
    await _loadEntries();
  }

  Future<void> _playEntry(String path) async {
    await _audioPlayer.play(DeviceFileSource(path));
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
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
              _isRecording ? 'Recording...' : 'Tap to record your diary',
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
                        final name = entry.path.split('/').last;
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: Icon(Icons.record_voice_over, color: AppTheme.primaryColor),
                            title: Text('Entry ${idx + 1}'),
                            subtitle: Text(name),
                            trailing: IconButton(
                              icon: Icon(Icons.play_arrow, color: AppTheme.accentColor),
                              onPressed: () => _playEntry(entry.path),
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
