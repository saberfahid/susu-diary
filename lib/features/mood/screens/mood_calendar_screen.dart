import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/models/diary_entry.dart';
import '../../../core/services/database_service.dart';

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<DiaryEntry>> _entriesByDate = {};
  List<DiaryEntry> _selectedDayEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);

    try {
      // Load entries for the current month +/- 2 months
      final start = DateTime(_focusedDay.year, _focusedDay.month - 2, 1);
      final end = DateTime(_focusedDay.year, _focusedDay.month + 3, 0);
      
      final entries = await DatabaseService.instance.getEntriesByDateRange(start, end);
      
      final Map<DateTime, List<DiaryEntry>> groupedEntries = {};
      
      for (final entry in entries) {
        final date = DateTime(
          entry.createdAt.year,
          entry.createdAt.month,
          entry.createdAt.day,
        );
        
        if (groupedEntries[date] == null) {
          groupedEntries[date] = [];
        }
        groupedEntries[date]!.add(entry);
      }

      setState(() {
        _entriesByDate = groupedEntries;
        _isLoading = false;
        
        // Select today if it has entries
        final today = DateTime.now();
        final todayKey = DateTime(today.year, today.month, today.day);
        if (_entriesByDate.containsKey(todayKey)) {
          _selectedDay = todayKey;
          _selectedDayEntries = _entriesByDate[todayKey]!;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<DiaryEntry> _getEntriesForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _entriesByDate[key] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final key = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    setState(() {
      _selectedDay = key;
      _focusedDay = focusedDay;
      _selectedDayEntries = _entriesByDate[key] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Calendar'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.moodAnalytics),
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'View Analytics',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TableCalendar<DiaryEntry>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    eventLoader: _getEntriesForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(),
                      todayDecoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonDecoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      formatButtonTextStyle: const TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                      titleCentered: true,
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return null;
                        
                        final entry = events.first;
                        final moodColor = AppTheme.getMoodColor(entry.mood);
                        
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: moodColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    onDaySelected: _onDaySelected,
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                      _loadEntries();
                    },
                  ),
                ).animate().fadeIn().slideY(begin: -0.1, end: 0),

                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildLegend(),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 16),

                // Selected day entries
                Expanded(
                  child: _buildSelectedDaySection(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRouter.diaryEntry),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLegend() {
    final moods = ['happy', 'calm', 'neutral', 'stressed', 'sad', 'angry'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: moods.map((mood) {
          final color = AppTheme.getMoodColor(mood);
          
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _capitalize(mood),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedDaySection() {
    if (_selectedDay == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a day to see entries',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(_selectedDay!),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${_selectedDayEntries.length} ${_selectedDayEntries.length == 1 ? 'entry' : 'entries'}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _selectedDayEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No entries for this day',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRouter.diaryEntry,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Entry'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedDayEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _selectedDayEntries[index];
                      final moodColor = AppTheme.getMoodColor(entry.mood);
                      final moodEmoji = AppTheme.getMoodEmoji(entry.mood);

                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.diaryDetail,
                          arguments: entry.id,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: moodColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: moodColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  moodEmoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('h:mm a').format(entry.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: 50 * index),
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
