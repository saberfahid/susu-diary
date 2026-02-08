import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/diary_entry.dart';
import '../../../core/services/database_service.dart';

class VoiceDiaryScreen extends StatefulWidget {
  const VoiceDiaryScreen({super.key});

  @override
  State<VoiceDiaryScreen> createState() => _VoiceDiaryScreenState();
}

class _VoiceDiaryScreenState extends State<VoiceDiaryScreen>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _hasRecording = false;
  bool _isSaving = false;
  
  String? _recordingPath;
  String? _recordingBase64; // For web storage
  
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  Timer? _durationTimer;
  late AnimationController _pulseController;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedMood = 'neutral';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _player.onPositionChanged.listen((position) {
      setState(() => _playbackPosition = position);
    });
    
    _player.onDurationChanged.listen((duration) {
      setState(() => _totalDuration = duration);
    });
    
    _player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _playbackPosition = Duration.zero;
      });
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        // Configure recording format
        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );
        
        if (kIsWeb) {
          // On web, use stream recording and convert to base64
          await _recorder.start(config, path: '');
        } else {
          // On mobile/desktop, record to file
          final path = await _getRecordingPath();
          await _recorder.start(config, path: path);
          _recordingPath = path;
        }
        
        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
          _hasRecording = false;
        });
        
        // Start duration timer
        _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
        });
      } else {
        _showError('Microphone permission required');
      }
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }

  Future<String> _getRecordingPath() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Store in app's private documents directory - NOT accessible by other apps or file managers
    if (!kIsWeb) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final voiceDir = Directory('${appDir.path}/voice_notes');
        if (!await voiceDir.exists()) {
          await voiceDir.create(recursive: true);
        }
        return '${voiceDir.path}/voice_diary_$timestamp.m4a';
      } catch (e) {
        // Fallback to temp directory (also private)
        final tempDir = await getTemporaryDirectory();
        return '${tempDir.path}/voice_diary_$timestamp.m4a';
      }
    }
    
    // Web uses blob URLs (already private)
    return 'voice_diary_$timestamp.m4a';
  }

  Future<void> _stopRecording() async {
    try {
      _durationTimer?.cancel();
      
      final path = await _recorder.stop();
      
      setState(() {
        _isRecording = false;
        _hasRecording = true;
        if (path != null && !kIsWeb) {
          _recordingPath = path;
        }
      });
      
      // On web, we need to handle the recording data differently
      if (kIsWeb && path != null) {
        // Store the path/blob URL for web playback
        _recordingPath = path;
      }
    } catch (e) {
      _showError('Failed to stop recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;
    
    try {
      if (_isPlaying) {
        await _player.pause();
        setState(() => _isPlaying = false);
      } else {
        if (kIsWeb) {
          await _player.play(UrlSource(_recordingPath!));
        } else {
          await _player.play(DeviceFileSource(_recordingPath!));
        }
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      _showError('Failed to play recording: $e');
    }
  }

  Future<void> _deleteRecording() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording?'),
        content: const Text('This will delete your voice recording. You cannot undo this.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _player.stop();
      setState(() {
        _hasRecording = false;
        _recordingPath = null;
        _recordingDuration = Duration.zero;
        _playbackPosition = Duration.zero;
        _isPlaying = false;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_hasRecording) {
      _showError('Please record something first');
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      final title = _titleController.text.trim().isEmpty
          ? 'Voice Note - ${_formatDate(DateTime.now())}'
          : _titleController.text.trim();
      
      final content = _notesController.text.trim().isEmpty
          ? '🎙️ Voice recording (${_formatDuration(_recordingDuration)})'
          : '🎙️ Voice recording (${_formatDuration(_recordingDuration)})\n\n${_notesController.text.trim()}';
      
      final entry = DiaryEntry.create(
        title: title,
        content: content,
        mood: _selectedMood,
        energyLevel: 3,
        isVoiceEntry: true,
        voiceNoteUrl: _recordingPath,
      );
      
      await DatabaseService.instance.insertEntry(entry);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice diary saved!'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to save: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Diary'),
        actions: [
          if (_hasRecording)
            IconButton(
              onPressed: _deleteRecording,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete recording',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Recording status
            _buildRecordingStatus(),
            
            const SizedBox(height: 40),
            
            // Record button
            _buildRecordButton(),
            
            const SizedBox(height: 40),
            
            // Playback controls (if recorded)
            if (_hasRecording) ...[
              _buildPlaybackControls(),
              const SizedBox(height: 32),
              _buildEntryForm(),
            ],
            
            // Instructions (if not recorded)
            if (!_hasRecording && !_isRecording)
              _buildInstructions(),
            
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      
      // Save button
      bottomNavigationBar: _hasRecording
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveEntry,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Voice Diary'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildRecordingStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _isRecording
            ? Colors.red.withOpacity(0.1)
            : _hasRecording
                ? AppTheme.secondaryColor.withOpacity(0.1)
                : AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isRecording)
            ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(_pulseController),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            )
          else
            Icon(
              _hasRecording ? Icons.check_circle : Icons.mic_none,
              color: _hasRecording ? AppTheme.secondaryColor : AppTheme.primaryColor,
              size: 20,
            ),
          const SizedBox(width: 10),
          Text(
            _isRecording
                ? 'Recording... ${_formatDuration(_recordingDuration)}'
                : _hasRecording
                    ? 'Recording ready (${_formatDuration(_recordingDuration)})'
                    : 'Tap to start recording',
            style: TextStyle(
              color: _isRecording
                  ? Colors.red
                  : _hasRecording
                      ? AppTheme.secondaryColor
                      : AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse animation when recording
          if (_isRecording)
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.3).animate(_pulseController),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.2),
                ),
              ),
            ),
          
          // Main button
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? Colors.red : AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? Colors.red : AppTheme.primaryColor)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 100.ms);
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.audiotrack, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              const Text(
                'Your Recording',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                _formatDuration(_recordingDuration),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _playbackPosition.inSeconds.toDouble(),
              max: _totalDuration.inSeconds > 0 
                  ? _totalDuration.inSeconds.toDouble() 
                  : _recordingDuration.inSeconds.toDouble(),
              activeColor: AppTheme.primaryColor,
              inactiveColor: Colors.grey.shade300,
              onChanged: (value) async {
                await _player.seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          
          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_playbackPosition),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  _formatDuration(_totalDuration.inSeconds > 0 ? _totalDuration : _recordingDuration),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Play button
          ElevatedButton.icon(
            onPressed: _playRecording,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            label: Text(_isPlaying ? 'Pause' : 'Play'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildEntryForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Details (Optional)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'Give your voice note a title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 16),
          
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes',
              hintText: 'Add any additional notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mood selector
          const Text(
            'How are you feeling?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMoodChip('happy', '😊'),
              _buildMoodChip('excited', '🤩'),
              _buildMoodChip('calm', '😌'),
              _buildMoodChip('neutral', '😐'),
              _buildMoodChip('sad', '😢'),
              _buildMoodChip('stressed', '😰'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMoodChip(String mood, String emoji) {
    final isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = mood),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              mood.substring(0, 1).toUpperCase() + mood.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      children: [
        Icon(
          Icons.mic_none_rounded,
          size: 64,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          'Record Your Thoughts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the microphone button to start recording.\nYour voice will be saved as an audio file.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade500,
            height: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _pulseController.dispose();
    _recorder.dispose();
    _player.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
