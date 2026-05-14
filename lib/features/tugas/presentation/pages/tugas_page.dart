import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
import 'package:campus_buddy/services/local_storage_service.dart';
import 'package:campus_buddy/widgets/custom_cards.dart';

class StudyTask {
  final String title;
  final String subject;
  final DateTime deadline;
  bool completed;

  StudyTask({
    required this.title,
    required this.subject,
    required this.deadline,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'deadline': deadline.toIso8601String(),
      'completed': completed,
    };
  }

  factory StudyTask.fromMap(Map<String, dynamic> map) {
    return StudyTask(
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      deadline: DateTime.parse(map['deadline'] as String),
      completed: map['completed'] as bool? ?? false,
    );
  }
}

class TugasPage extends StatefulWidget {
  const TugasPage({Key? key}) : super(key: key);

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDeadline;

  static const String _storageKeyTasks = 'study_tasks';
  List<StudyTask> _tasks = [];

  Color _deadlineColor(DateTime deadline) {
    final difference = deadline.difference(DateTime.now()).inDays;
    if (difference < 3) {
      return AppColors.error;
    }
    if (difference <= 7) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  String _formattedDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.neonBlue,
              onPrimary: Colors.white,
              surface: AppColors.darkSurface,
              onSurface: AppColors.darkText,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppColors.darkBg),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedDeadline = picked;
    });
  }

  Future<void> _loadTasks() async {
    final data = await LocalStorageService.instance.loadJsonList(
      _storageKeyTasks,
    );
    if (data.isNotEmpty) {
      setState(() {
        _tasks = data.map(StudyTask.fromMap).toList();
      });
      return;
    }

    final defaultTasks = [
      StudyTask(
        title: 'Tugas UAS - Riset Operasi',
        subject: 'Riset Operasi',
        deadline: DateTime(2026, 6, 23),
      ),
      StudyTask(
        title: 'Presentasi Laporan - Kecerdasan Buatan',
        subject: 'Kecerdasan Buatan',
        deadline: DateTime(2026, 5, 12),
      ),
      StudyTask(
        title: 'Tugas UTS - Analisa Algoritma',
        subject: 'Analisa Algoritma',
        deadline: DateTime(2026, 5, 8),
      ),
      StudyTask(
        title: 'Tugas UAS - Mobile Programming',
        subject: 'Mobile Programming',
        deadline: DateTime(2026, 5, 31),
      ),
    ];

    setState(() {
      _tasks = defaultTasks;
    });
    await _saveTasks();
  }

  Future<void> _saveTasks() async {
    await LocalStorageService.instance.saveJsonList(
      _storageKeyTasks,
      _tasks.map((task) => task.toMap()).toList(),
    );
  }

  Future<void> _removeTaskAt(int index) async {
    setState(() {
      _tasks.removeAt(index);
    });
    await _saveTasks();
  }

  Future<void> _toggleTaskCompleted(int index, bool value) async {
    setState(() {
      _tasks[index].completed = value;
    });
    await _saveTasks();
  }

  void _openAddTaskSheet() {
    _titleController.clear();
    _subjectController.clear();
    _selectedDeadline = null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface.withOpacity(0.96),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: AppColors.neonBlue.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.darkText.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tambah Tugas Baru',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        hintText: 'Nama tugas',
                        icon: Icons.task_alt,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _subjectController,
                        hintText: 'Nama mata kuliah',
                        icon: Icons.school,
                      ),
                      const SizedBox(height: 14),
                      _buildDatePickerField(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveTask,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.neonBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            'Simpan Tugas',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Field ini wajib diisi';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.darkSubText.withOpacity(0.9)),
        prefixIcon: Icon(icon, color: AppColors.neonBlue),
        filled: true,
        fillColor: AppColors.darkSurface.withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.darkBorder.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.darkBorder.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.neonBlue.withOpacity(0.9)),
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return InkWell(
      onTap: _pickDeadline,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.neonPurple),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedDeadline != null
                    ? _formattedDate(_selectedDeadline!)
                    : 'Pilih tanggal deadline',
                style: TextStyle(
                  color: _selectedDeadline != null
                      ? AppColors.darkText
                      : AppColors.darkSubText.withOpacity(0.9),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal deadline terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _tasks.insert(
        0,
        StudyTask(
          title: _titleController.text.trim(),
          subject: _subjectController.text.trim(),
          deadline: _selectedDeadline!,
        ),
      );
    });
    final navigator = Navigator.of(context);
    await _saveTasks();
    if (!mounted) return;
    navigator.pop();
  }

  Widget _buildTaskCard(StudyTask task, int index) {
    final deadlineColor = _deadlineColor(task.deadline);

    return FadeInUp(
      delay: Duration(milliseconds: 80 * index),
      child: GlassmorphismCard(
        glowColor: AppColors.neonBlue,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          task.subject,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            color: AppColors.darkSubText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeTaskAt(index),
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: deadlineColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Deadline: ${_formattedDate(task.deadline)}',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: deadlineColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedScale(
                    scale: task.completed ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Checkbox(
                      value: task.completed,
                      onChanged: (value) {
                        _toggleTaskCompleted(index, value ?? false);
                      },
                      activeColor: AppColors.neonBlue,
                      checkColor: Colors.black,
                      side: BorderSide(
                        color: AppColors.neonBlue.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((task) => task.completed).length;
    final pendingCount = _tasks.length - completedCount;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('Tugas Saya'),
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassmorphismCard(
                glowColor: AppColors.neonPurple,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'StudyMate',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kelola tugas kuliah dengan cepat dan jelas.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                color: AppColors.darkSubText,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _buildInfoChip(
                                  '${pendingCount} Pending',
                                  AppColors.neonBlue,
                                ),
                                const SizedBox(width: 10),
                                _buildInfoChip(
                                  '${completedCount} Selesai',
                                  AppColors.neonPurple,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.neonBlue, AppColors.neonPurple],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.checklist,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _tasks.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.tugasKosong,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: AppColors.darkSubText,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return _buildTaskCard(task, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.neonBlue, AppColors.neonPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.neonBlue.withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openAddTaskSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
