import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
import 'package:campus_buddy/services/local_storage_service.dart';

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<ExpenseItem> _expenses = [];
  final List<String> _categories = [
    'Makan',
    'Transport',
    'Buku',
    'Hiburan',
    'Lainnya',
  ];

  String _selectedCategory = 'Makan';
  DateTime _selectedDate = DateTime.now();
  static const String _storageKeyExpenses = 'keuangan_expenses';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await LocalStorageService.instance.loadJsonList(
      _storageKeyExpenses,
    );
    if (data.isNotEmpty) {
      setState(() {
        _expenses
          ..clear()
          ..addAll(data.map(ExpenseItem.fromMap));
      });
      return;
    }

    final defaultExpenses = [
      ExpenseItem(
        id: '1',
        title: 'Makan',
        amount: 15000,
        category: 'Makan',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ExpenseItem(
        id: '2',
        title: 'Transport',
        amount: 10000,
        category: 'Transport',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ExpenseItem(
        id: '3',
        title: 'Buku',
        amount: 25000,
        category: 'Buku',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    setState(() {
      _expenses
        ..clear()
        ..addAll(defaultExpenses);
    });
    await _saveExpenses();
  }

  Future<void> _saveExpenses() async {
    await LocalStorageService.instance.saveJsonList(
      _storageKeyExpenses,
      _expenses.map((expense) => expense.toMap()).toList(),
    );
  }

  Future<void> _addExpense(ExpenseItem expense) async {
    setState(() {
      _expenses.insert(0, expense);
    });
    await _saveExpenses();
  }

  Future<void> _removeExpenseAt(int index) async {
    setState(() {
      _expenses.removeAt(index);
    });
    await _saveExpenses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _totalExpense =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  String _formatCurrency(double value) {
    final formatted = value.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp $formatted';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Map<String, double> _monthlyExpenseTotals() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(
      now.month == 1 ? now.year - 1 : now.year,
      now.month == 1 ? 12 : now.month - 1,
    );

    double currentTotal = 0;
    double previousTotal = 0;

    for (final expense in _expenses) {
      final expenseMonth = DateTime(expense.date.year, expense.date.month);
      if (expenseMonth == currentMonth) {
        currentTotal += expense.amount;
      } else if (expenseMonth == previousMonth) {
        previousTotal += expense.amount;
      }
    }

    return {
      _monthLabel(previousMonth): previousTotal,
      _monthLabel(currentMonth): currentTotal,
    };
  }

  String _monthLabel(DateTime date) {
    const monthNames = [
      '',
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
    return monthNames[date.month];
  }

  Widget _buildMonthlyExpenseChart() {
    final totals = _monthlyExpenseTotals();
    final monthLabels = totals.keys.toList();
    final previousValue = totals.values.elementAt(0);
    final currentValue = totals.values.elementAt(1);
    final maxValue =
        (previousValue > currentValue ? previousValue : currentValue).clamp(
          100,
          double.infinity,
        );
    final chartMax = maxValue * 1.2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withAlpha((0.92 * 255).round()),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(70),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            AppColors.darkSurface.withAlpha((0.96 * 255).round()),
            AppColors.darkBg.withAlpha((0.9 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Pengeluaran Bulanan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatCurrency(previousValue),
                    style: const TextStyle(
                      color: AppColors.neonPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bulan lalu',
                    style: TextStyle(
                      color: AppColors.darkSubText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(currentValue),
                    style: const TextStyle(
                      color: AppColors.neonBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bulan ini',
                    style: TextStyle(
                      color: AppColors.darkSubText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: chartMax / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value == 0 ? '0' : _formatCurrency(value),
                          style: TextStyle(
                            color: AppColors.darkSubText,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          monthLabels[index],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: previousValue,
                        color: AppColors.neonPurple,
                        width: 24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: currentValue,
                        color: AppColors.neonBlue,
                        width: 24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Makan':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_bus;
      case 'Buku':
        return Icons.menu_book;
      case 'Hiburan':
        return Icons.videogame_asset;
      default:
        return Icons.category;
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'Makan':
        return AppColors.neonBlue;
      case 'Transport':
        return AppColors.neonPurple;
      case 'Buku':
        return AppColors.primary;
      case 'Hiburan':
        return AppColors.secondary;
      default:
        return AppColors.primaryDark;
    }
  }

  void _openAddExpenseModal() {
    _nameController.clear();
    _amountController.clear();
    _selectedCategory = _categories.first;
    _selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: ListView(
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.tambahPengeluaran,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Nama Pengeluaran',
                            hintText: 'Contoh: Makan Siang',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Masukkan nama pengeluaran';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Nominal',
                            hintText: 'Contoh: 20000',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Masukkan nominal';
                            }
                            if (double.tryParse(value.replaceAll('.', '')) ==
                                null) {
                              return 'Nominal tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          dropdownColor: AppColors.darkSurface,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                          ),
                          items: _categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: AppColors.neonBlue,
                                      onPrimary: Colors.white,
                                      surface: AppColors.darkSurface,
                                      onSurface: Colors.white,
                                    ),
                                    dialogTheme: DialogThemeData(
                                      backgroundColor: AppColors.darkBg,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (!mounted || picked == null) return;
                            setState(() {
                              _selectedDate = picked;
                            });
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: AppStrings.tanggal,
                                hintText: _formatDate(_selectedDate),
                                suffixIcon: const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.neonBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonBlue,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final amount = double.parse(
                                  _amountController.text.replaceAll('.', ''),
                                );
                                final navigator = Navigator.of(context);
                                await _addExpense(
                                  ExpenseItem(
                                    id: DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                    title: _nameController.text.trim(),
                                    amount: amount,
                                    category: _selectedCategory,
                                    date: _selectedDate,
                                  ),
                                );
                                if (!mounted) return;
                                navigator.pop();
                              }
                            },
                            child: Text(
                              AppStrings.simpan,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        title: Text(
          AppStrings.keuangan,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _openAddExpenseModal,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.neonBlue,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseModal,
        backgroundColor: AppColors.neonBlue,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                'Pantau biaya kostmu dengan mudah',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.darkSubText),
              ),
              const SizedBox(height: 24),
              _buildMonthlyExpenseChart(),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.neonBlue, AppColors.neonPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonBlue.withAlpha(61),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.totalPengeluaran,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatCurrency(_totalExpense),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildBadge('KostBudget', AppColors.neonPurple),
                        const SizedBox(width: 10),
                        _buildBadge(
                          '${_expenses.length} item',
                          AppColors.neonBlue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.ringkasanKeuangan,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (_expenses.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _expenses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final expense = _expenses[index];
                    return _buildExpenseCard(expense, index);
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(46),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  bool _isDeletePressed = false;

  Future<void> _showDeleteConfirmation(int index) async {
    setState(() {
      _isDeletePressed = true;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text('Konfirmasi Hapus', style: TextStyle(color: Colors.white)),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengeluaran ini?',
          style: TextStyle(color: AppColors.darkSubText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal', style: TextStyle(color: AppColors.neonBlue)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    setState(() {
      _isDeletePressed = false;
    });

    if (result == true) {
      // ignore: use_build_context_synchronously
      await _removeExpenseAt(index);
    }
  }

  Widget _buildExpenseCard(ExpenseItem expense, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_colorForCategory(expense.category), AppColors.darkBg],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(_iconForCategory(expense.category), color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatCurrency(expense.amount),
              style: TextStyle(
                color: AppColors.neonBlue,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${expense.category} • ${_formatDate(expense.date)}',
          style: TextStyle(color: AppColors.darkSubText),
        ),
        trailing: AnimatedScale(
          scale: _isDeletePressed ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: InkWell(
            onTap: () => _showDeleteConfirmation(index),
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.error.withAlpha(50),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.delete_outline,
                color: _isDeletePressed
                    ? AppColors.error
                    : AppColors.darkSubText,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wallet_outlined, size: 72, color: AppColors.darkSubText),
          const SizedBox(height: 14),
          Text(
            AppStrings.pengeluaranKosong,
            style: TextStyle(color: AppColors.darkSubText, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan pengeluaran pertamamu untuk mulai melacak biaya.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.darkSubText.withAlpha(224)),
          ),
        ],
      ),
    );
  }
}

class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
    );
  }
}
