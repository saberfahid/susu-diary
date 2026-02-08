import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/models/diary_entry.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/ai_service.dart';
import '../widgets/mood_selector.dart';
import '../widgets/ai_writing_toolbar.dart';

class DiaryEntryScreen extends StatefulWidget {
  final String? entryId;
  final String? promptQuestion;

  const DiaryEntryScreen({
    super.key,
    this.entryId,
    this.promptQuestion,
  });

  @override
  State<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  
  String _selectedMood = 'neutral';
  int _energyLevel = 3;
  List<String> _tags = [];
  bool _isLoading = false;
  bool _isAIProcessing = false;
  bool _hasChanges = false;
  DiaryEntry? _existingEntry;
  
  // Image attachment
  String? _attachedImagePath;
  XFile? _pickedImage;

  final List<String> _moods = [
    'happy', 'excited', 'calm', 'grateful', 'hopeful',
    'neutral', 'stressed', 'anxious', 'sad', 'angry', 'frustrated'
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.entryId != null) {
      _loadEntry();
    } else if (widget.promptQuestion != null) {
      _titleController.text = widget.promptQuestion!;
    }
    
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _loadEntry() async {
    setState(() => _isLoading = true);
    
    try {
      final entry = await DatabaseService.instance.getEntry(widget.entryId!);
      if (entry != null && mounted) {
        setState(() {
          _existingEntry = entry;
          _titleController.text = entry.title;
          _contentController.text = entry.content;
          _selectedMood = entry.mood;
          _energyLevel = entry.energyLevel;
          _tags = List.from(entry.tags);
          _attachedImagePath = entry.imageUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveEntry() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save picked image to app's private storage
      String? savedImagePath = _attachedImagePath;
      if (_pickedImage != null && !kIsWeb) {
        savedImagePath = await _saveImageToPrivateStorage(_pickedImage!);
      }
      
      // Analyze mood with AI if available
      Map<String, dynamic>? aiAnalysis;
      if (AIService.instance.isConfigured) {
        aiAnalysis = await AIService.instance.analyzeMood(_contentController.text);
        if (aiAnalysis['mood'] != 'neutral' && _selectedMood == 'neutral') {
          _selectedMood = aiAnalysis['mood'];
        }
      }

      final title = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : _generateTitle(_contentController.text);

      if (_existingEntry != null) {
        // Update existing entry
        final updatedEntry = _existingEntry!.copyWith(
          title: title,
          content: _contentController.text.trim(),
          mood: _selectedMood,
          energyLevel: _energyLevel,
          tags: _tags,
          aiAnalysis: aiAnalysis,
          imageUrl: savedImagePath,
        );
        await DatabaseService.instance.updateEntry(updatedEntry);
      } else {
        // Create new entry
        final entry = DiaryEntry.create(
          title: title,
          content: _contentController.text.trim(),
          mood: _selectedMood,
          energyLevel: _energyLevel,
          tags: _tags,
          imageUrl: savedImagePath,
        );
        await DatabaseService.instance.insertEntry(entry);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_existingEntry != null ? 'Entry updated!' : 'Entry saved!'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      }
    }
  }

  String _generateTitle(String content) {
    // Generate a title from the first line or first few words
    final firstLine = content.split('\n').first;
    if (firstLine.length <= 50) return firstLine;
    return '${firstLine.substring(0, 47)}...';
  }

  // ============ IMAGE ATTACHMENT ============

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '📷 Add Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromSource(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: AppTheme.secondaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromSource(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromSource(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _pickedImage = image;
          _attachedImagePath = image.path;
          _hasChanges = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String> _saveImageToPrivateStorage(XFile image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/diary_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = image.path.split('.').last;
    final newPath = '${imagesDir.path}/diary_$timestamp.$extension';
    
    final bytes = await image.readAsBytes();
    final file = File(newPath);
    await file.writeAsBytes(bytes);
    
    return newPath;
  }

  void _removeImage() {
    setState(() {
      _pickedImage = null;
      _attachedImagePath = null;
      _hasChanges = true;
    });
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _enhanceWithAI() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something first')),
      );
      return;
    }

    setState(() => _isAIProcessing = true);
    _showLoadingDialog('✨ Enhancing your text with AI...');

    try {
      final enhanced = await AIService.instance.enhanceEntry(
        _contentController.text,
      );
      
      _hideLoadingDialog();
      if (mounted) {
        // Show comparison dialog
        _showEnhancedDialog(enhanced);
      }
    } catch (e) {
      _hideLoadingDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isAIProcessing = false);
    }
  }

  Future<void> _expandNote() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something first')),
      );
      return;
    }

    setState(() => _isAIProcessing = true);
    _showLoadingDialog('📝 Expanding your thoughts...');

    try {
      final expanded = await AIService.instance.expandNote(
        _contentController.text,
      );
      
      _hideLoadingDialog();
      if (mounted) {
        _showEnhancedDialog(expanded, title: 'Expanded Entry');
      }
    } catch (e) {
      _hideLoadingDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isAIProcessing = false);
    }
  }

  Future<void> _fixGrammar() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isAIProcessing = true);
    _showLoadingDialog('🔍 Fixing grammar...');

    try {
      final fixed = await AIService.instance.fixGrammar(_contentController.text);
      _hideLoadingDialog();
      _contentController.text = fixed;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grammar fixed!'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    } catch (e) {
      _hideLoadingDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isAIProcessing = false);
    }
  }

  void _showEnhancedDialog(String enhanced, {String title = 'Enhanced Entry'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  enhanced,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Keep Original'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _contentController.text = enhanced;
                        Navigator.pop(context);
                      },
                      child: const Text('Use This'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _existingEntry != null ? 'Edit Entry' : 'New Entry',
          ),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton.icon(
                onPressed: _saveEntry,
                icon: const Icon(Icons.check),
                label: const Text('Save'),
              ),
          ],
        ),
        body: _isLoading && _existingEntry == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mood Selector
                          MoodSelector(
                            selectedMood: _selectedMood,
                            moods: _moods,
                            onMoodSelected: (mood) {
                              setState(() => _selectedMood = mood);
                            },
                          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                          
                          const SizedBox(height: 16),
                          
                          // Energy Level
                          _buildEnergySlider()
                              .animate()
                              .fadeIn(delay: 100.ms)
                              .slideY(begin: 0.1, end: 0),
                          
                          const SizedBox(height: 20),
                          
                          // Title field
                          TextField(
                            controller: _titleController,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            decoration: InputDecoration(
                              hintText: widget.promptQuestion ?? 'Title (optional)',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            maxLines: 2,
                          )
                              .animate()
                              .fadeIn(delay: 200.ms),
                          
                          const Divider(),
                          
                          // Content field
                          TextField(
                            controller: _contentController,
                            focusNode: _contentFocusNode,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                ),
                            decoration: InputDecoration(
                              hintText: 'Start writing your thoughts...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            maxLines: null,
                            minLines: 10,
                            keyboardType: TextInputType.multiline,
                          )
                              .animate()
                              .fadeIn(delay: 300.ms),
                          
                          const SizedBox(height: 20),
                          
                          // Tags
                          _buildTagsSection()
                              .animate()
                              .fadeIn(delay: 400.ms),
                          
                          const SizedBox(height: 20),
                          
                          // Image Attachment
                          _buildImageSection()
                              .animate()
                              .fadeIn(delay: 500.ms),
                        ],
                      ),
                    ),
                  ),
                  
                  // AI Toolbar
                  AIWritingToolbar(
                    isProcessing: _isAIProcessing,
                    onEnhance: _enhanceWithAI,
                    onExpand: _expandNote,
                    onFixGrammar: _fixGrammar,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEnergySlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Energy Level',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                _getEnergyLabel(_energyLevel),
                style: TextStyle(
                  color: _getEnergyColor(_energyLevel),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _getEnergyColor(_energyLevel),
              thumbColor: _getEnergyColor(_energyLevel),
              inactiveTrackColor: _getEnergyColor(_energyLevel).withOpacity(0.2),
            ),
            child: Slider(
              value: _energyLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) {
                setState(() => _energyLevel = value.round());
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getEnergyLabel(int level) {
    switch (level) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Moderate';
    }
  }

  Color _getEnergyColor(int level) {
    switch (level) {
      case 1:
        return Colors.red.shade400;
      case 2:
        return Colors.orange.shade400;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.lightGreen.shade400;
      case 5:
        return Colors.green.shade500;
      default:
        return Colors.yellow.shade700;
    }
  }

  Widget _buildTagsSection() {
    final tagController = TextEditingController();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tag, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tags',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._tags.map((tag) => Chip(
                    label: Text('#$tag'),
                    onDeleted: () {
                      setState(() => _tags.remove(tag));
                    },
                    deleteIconColor: Colors.grey,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 13,
                    ),
                  )),
              // Add tag chip
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Add Tag'),
                      content: TextField(
                        controller: tagController,
                        decoration: const InputDecoration(
                          hintText: 'Enter tag name',
                          prefixText: '#',
                        ),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (tagController.text.trim().isNotEmpty) {
                              setState(() {
                                _tags.add(tagController.text.trim());
                              });
                            }
                            Navigator.pop(context);
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Photo',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (_attachedImagePath == null)
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_attachedImagePath != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(
                          _attachedImagePath!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              _buildImagePlaceholder(),
                        )
                      : Image.file(
                          File(_attachedImagePath!),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              _buildImagePlaceholder(),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _buildImageActionButton(
                        icon: Icons.edit,
                        onTap: _pickImage,
                      ),
                      const SizedBox(width: 8),
                      _buildImageActionButton(
                        icon: Icons.delete,
                        onTap: _removeImage,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add a photo',
                      style: TextStyle(
                        color: AppTheme.primaryColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color ?? Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }
}
