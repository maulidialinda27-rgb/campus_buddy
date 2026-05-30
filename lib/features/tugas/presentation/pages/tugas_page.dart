import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
import 'package:campus_buddy/services/tugas_service.dart';
import 'package:campus_buddy/widgets/custom_cards.dart';

import 'package:campus_buddy/features/tugas/data/models/tugas_model.dart';

// Rose Pink Theme Constants
class TugasColors {
  static const Color primary = Color(0xFFEC4899);
  static const Color dark = Color(0xFFDB2777);
  static const Color light = Color(0xFFF9A8D4);
  static const Color softBg = Color(0xFFFDF2F8);
}

class TugasPage extends StatefulWidget {
  const TugasPage({super.key});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDeadline;

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _subjectFocusNode = FocusNode();

  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  final TugasService _tugasService = TugasService();
  List<Tugas> _tasks = [];

  Color _deadlineColor(DateTime deadline) {
    final difference = deadline.difference(DateTime.now()).inDays;
    if (difference < 0) return const Color(0xFFEF4444);   // Terlewat - Merah
    if (difference < 3) return const Color(0xFFF97316);   // Mendekati - Oranye
    if (difference <= 7) return const Color(0xFFF59E0B);  // Kurang dari seminggu - Amber
    return const Color(0xFF22C55E);                        // Aman - Hijau
  }

  String _deadlineLabel(DateTime deadline) {
    final difference = deadline.difference(DateTime.now()).inDays;
    if (difference < 0) return 'Terlewat';
    if (difference < 3) return 'Mendekati';
    if (difference <= 7) return 'Segera';
    return 'Aman';
  }

  String _formattedDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _titleFocusNode.addListener(() => setState(() {}));
    _subjectFocusNode.addListener(() => setState(() {}));
    _loadTasks();

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _fabScaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _subjectFocusNode.dispose();
    _titleController.dispose();
    _subjectController.dispose();
    _fabAnimController.dispose();
    super.dispose();
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
            colorScheme: ColorScheme.light(
              primary: TugasColors.primary,
              surface: Theme.of(context).cardColor,
              onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).scaffoldBackgroundColor),
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
    final data = await _tugasService.getAllTugas();
    if (data.isNotEmpty) {
      setState(() {
        _tasks = data;
      });
      return;
    }

    final defaultTasks = [
      Tugas(
        id: '${DateTime.now().millisecondsSinceEpoch}_1',
        judul: 'Tugas UAS - Riset Operasi',
        deskripsi: 'Riset Operasi',
        deadline: DateTime(2026, 6, 23).toIso8601String(),
        dibuatPada: DateTime.now(),
        diperbarui: DateTime.now(),
      ),
      Tugas(
        id: '${DateTime.now().millisecondsSinceEpoch}_2',
        judul: 'Presentasi Laporan - Kecerdasan Buatan',
        deskripsi: 'Kecerdasan Buatan',
        deadline: DateTime(2026, 5, 12).toIso8601String(),
        dibuatPada: DateTime.now(),
        diperbarui: DateTime.now(),
      ),
      Tugas(
        id: '${DateTime.now().millisecondsSinceEpoch}_3',
        judul: 'Tugas UTS - Analisa Algoritma',
        deskripsi: 'Analisa Algoritma',
        deadline: DateTime(2026, 5, 8).toIso8601String(),
        dibuatPada: DateTime.now(),
        diperbarui: DateTime.now(),
      ),
      Tugas(
        id: '${DateTime.now().millisecondsSinceEpoch}_4',
        judul: 'Tugas UAS - Mobile Programming',
        deskripsi: 'Mobile Programming',
        deadline: DateTime(2026, 5, 31).toIso8601String(),
        dibuatPada: DateTime.now(),
        diperbarui: DateTime.now(),
      ),
    ];

    for (var task in defaultTasks) {
      await _tugasService.insertTugas(task);
    }
    
    final savedData = await _tugasService.getAllTugas();

    setState(() {
      _tasks = savedData;
    });
  }

  Future<void> _removeTaskAt(int index) async {
    final task = _tasks[index];
    await _tugasService.deleteTugas(task.id);
    setState(() {
      _tasks.removeAt(index);
    });
  }

  Future<void> _toggleTaskCompleted(int index, bool value) async {
    final task = _tasks[index];
    final updatedTask = task.copyWith(status: value ? 'completed' : 'pending');
    setState(() {
      _tasks[index] = updatedTask;
    });
    await _tugasService.updateTugas(updatedTask);
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDark ? Theme.of(context).colorScheme.surface : Colors.white;
        final inputFillColor = isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF9FAFB);
        final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);
        final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
        final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade600;

        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tambah Tugas Baru',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _titleController,
                          hintText: 'Nama tugas',
                          icon: Icons.task_alt_rounded,
                          focusNode: _titleFocusNode,
                          inputFillColor: inputFillColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _subjectController,
                          hintText: 'Nama mata kuliah',
                          icon: Icons.school_rounded,
                          focusNode: _subjectFocusNode,
                          inputFillColor: inputFillColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        const SizedBox(height: 16),
                        _buildDatePickerField(
                          isDark: isDark,
                          inputFillColor: inputFillColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        const SizedBox(height: 28),
                        Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: TugasColors.primary.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TugasColors.primary,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                            label: const Text(
                              'Simpan Tugas',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required FocusNode focusNode,
    required Color inputFillColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final hasFocus = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (hasFocus)
            BoxShadow(
              color: TugasColors.primary.withValues(alpha: 0.12),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        cursorColor: TugasColors.primary,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Field ini wajib diisi';
          }
          return null;
        },
        style: TextStyle(color: textColor, fontFamily: 'PlusJakartaSans'),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.5), fontFamily: 'PlusJakartaSans'),
          prefixIcon: Icon(
            icon,
            color: hasFocus ? TugasColors.primary : subTextColor.withValues(alpha: 0.6),
            size: 22,
          ),
          filled: true,
          fillColor: inputFillColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: TugasColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required bool isDark,
    required Color inputFillColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return InkWell(
      onTap: _pickDeadline,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: inputFillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              color: _selectedDeadline != null ? TugasColors.primary : subTextColor.withValues(alpha: 0.6),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedDeadline != null
                    ? _formattedDate(_selectedDeadline!)
                    : 'Pilih tanggal deadline',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: _selectedDeadline != null ? textColor : subTextColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: subTextColor.withValues(alpha: 0.5),
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

    final newTask = Tugas(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_titleController.text.hashCode}',
      judul: _titleController.text.trim(),
      deskripsi: _subjectController.text.trim(),
      deadline: _selectedDeadline!.toIso8601String(),
      dibuatPada: DateTime.now(),
      diperbarui: DateTime.now(),
    );
    
    await _tugasService.insertTugas(newTask);
    final updatedData = await _tugasService.getAllTugas();

    if (!mounted) return;
    
    setState(() {
      _tasks = updatedData;
    });
    
    Navigator.of(context).pop();
  }

  Widget _buildTaskCard(Tugas task, int index) {
    final deadlineDate = DateTime.tryParse(task.deadline ?? '') ?? DateTime.now();
    final deadlineColor = _deadlineColor(deadlineDate);
    final deadlineLabel = _deadlineLabel(deadlineDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = task.status == 'completed';
    final cardColor = isDark ? Theme.of(context).colorScheme.surface : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);

    return FadeInUp(
      delay: Duration(milliseconds: 60 * index),
      duration: const Duration(milliseconds: 350),
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TugasColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isCompleted ? Icons.task_alt_rounded : Icons.assignment_outlined,
                          color: isCompleted ? const Color(0xFF22C55E) : TugasColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.judul,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                decorationColor: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  size: 13,
                                  color: TugasColors.primary.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    task.deskripsi ?? '',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeTaskAt(index),
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Deadline badge
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: deadlineColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 13, color: deadlineColor),
                            const SizedBox(width: 6),
                            Text(
                              _formattedDate(deadlineDate),
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                color: deadlineColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status label badge
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          color: deadlineColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isCompleted ? 'Selesai' : deadlineLabel,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            color: isCompleted ? Colors.grey : deadlineColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Checkbox with animation
                      AnimatedScale(
                        scale: isCompleted ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Checkbox(
                          value: isCompleted,
                          onChanged: (value) {
                            _toggleTaskCompleted(index, value ?? false);
                          },
                          activeColor: TugasColors.primary,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          side: BorderSide(
                            color: TugasColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((task) => task.status == 'completed').length;
    final pendingCount = _tasks.length - completedCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade600;
    final cardColor = isDark ? Theme.of(context).colorScheme.surface : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Tugas Saya',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: 0.2,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Card
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
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
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Kelola tugas kuliah dengan cepat dan jelas.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _buildInfoChip('$pendingCount Pending', TugasColors.primary),
                                const SizedBox(width: 10),
                                _buildInfoChip('$completedCount Selesai', const Color(0xFF22C55E)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [TugasColors.primary, TugasColors.dark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: TugasColors.primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.checklist_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _tasks.isEmpty
                    ? _buildEmptyState(isDark, textColor, subTextColor)
                    : ListView.separated(
                        itemCount: _tasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
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
      floatingActionButton: GestureDetector(
        onTapDown: (_) => _fabAnimController.forward(),
        onTapUp: (_) {
          _fabAnimController.reverse();
          _openAddTaskSheet();
        },
        onTapCancel: () => _fabAnimController.reverse(),
        child: ScaleTransition(
          scale: _fabScaleAnim,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TugasColors.primary, TugasColors.dark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: TugasColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textColor, Color subTextColor) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: TugasColors.primary.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 72,
                    color: TugasColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Semua Tugas Selesai!',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu bebas dari tugas untuk saat ini.\nNikmati waktumu atau buat tugas baru!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    height: 1.6,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
