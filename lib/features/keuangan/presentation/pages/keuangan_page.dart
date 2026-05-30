import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
import 'package:campus_buddy/services/local_storage_service.dart';
import 'package:campus_buddy/models/expense_model.dart';

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

  String _formatShortCurrency(double value) {
    if (value >= 1000000) {
      double val = value / 1000000;
      return 'Rp ${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}jt';
    } else if (value >= 1000) {
      double val = value / 1000;
      return 'Rp ${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}rb';
    }
    return 'Rp ${value.toInt()}';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makan':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Buku':
        return Icons.menu_book_rounded;
      case 'Hiburan':
        return Icons.sports_esports_rounded;
      default:
        return Icons.local_mall_rounded;
    }
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
      final expenseMonth = DateTime(
        expense.date.year,
        expense.date.month,
      );

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

    final maxValue = (previousValue > currentValue ? previousValue : currentValue)
        .clamp(100.0, double.infinity);
    final chartMax = maxValue * 1.3; // Extra headroom for the tooltip on top

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: isDark ? 0.05 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Pengeluaran Bulanan',
            style: TextStyle(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 220,
            child: BarChart(
              swapAnimationDuration: const Duration(milliseconds: 500),
              swapAnimationCurve: Curves.easeOutCubic,
              BarChartData(
                maxY: chartMax,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 6,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        _formatCurrency(rod.toY),
                        TextStyle(
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),

                titlesData: FlTitlesData(
                  show: true,

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 64,
                      interval: (chartMax / 4).clamp(1.0, double.infinity),
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max) return const SizedBox.shrink();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value == 0 ? '0' : _formatShortCurrency(value),
                            style: TextStyle(
                              color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= monthLabels.length) {
                          return const SizedBox.shrink();
                        }

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(
                            monthLabels[index],
                            style: TextStyle(
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (chartMax / 4).clamp(1.0, double.infinity),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).dividerColor.withValues(alpha: isDark ? 0.08 : 0.15),
                      strokeWidth: 1,
                      dashArray: [6, 6],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),

                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: previousValue,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF22C55E).withValues(alpha: 0.3),
                            const Color(0xFF4ADE80).withValues(alpha: 0.3),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 28,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ],
                    showingTooltipIndicators: const [0],
                  ),

                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: currentValue,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF22C55E),
                            Color(0xFF4ADE80),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 28,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ],
                    showingTooltipIndicators: const [0],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseItem expense, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: isDark ? 0.05 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: const Color(0xFF22C55E),
            size: 24,
          ),
        ),
        title: Text(
          expense.title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${expense.category} • ${_formatDate(expense.date)}',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.darkSubText,
              fontSize: 13,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '- ${_formatCurrency(expense.amount)}',
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: isDark ? const Color(0xFF9CA3AF) : AppColors.lightSubText,
                size: 20,
              ),
              onPressed: () => _removeExpenseAt(index),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: isDark ? 0.05 : 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: const Color(0xFF22C55E).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Pengeluaran',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Catat pengeluaran harianmu untuk memantau keuanganmu di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.darkSubText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddExpenseModal() {
    _nameController.clear();
    _amountController.clear();

    _selectedCategory = _categories.first;
    _selectedDate = DateTime.now();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldFillColor = isDark ? const Color(0xFF1F2937) : AppColors.gray100;
    final inputTextColor = isDark ? const Color(0xFFD1D5DB) : AppColors.lightText;
    final labelStyleColor = isDark ? const Color(0xFF9CA3AF) : AppColors.lightSubText;
    final borderColor = isDark ? const Color(0xFF374151) : AppColors.lightBorder;

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
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),

              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),

                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tambah Pengeluaran',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.darkText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: inputTextColor),
                          decoration: InputDecoration(
                            labelText: 'Nama Pengeluaran',
                            labelStyle: TextStyle(color: labelStyleColor),
                            filled: true,
                            fillColor: fieldFillColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: borderColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: inputTextColor),
                          decoration: InputDecoration(
                            labelText: 'Nominal',
                            labelStyle: TextStyle(color: labelStyleColor),
                            filled: true,
                            fillColor: fieldFillColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: borderColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(color: inputTextColor),
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            labelStyle: TextStyle(color: labelStyleColor),
                            filled: true,
                            fillColor: fieldFillColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: borderColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
                            ),
                          ),
                          items: _categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category, style: TextStyle(color: inputTextColor)),
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
                            );

                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },

                          child: AbsorbPointer(
                            child: TextFormField(
                              style: TextStyle(color: inputTextColor),
                              decoration: InputDecoration(
                                labelText: AppStrings.tanggal,
                                labelStyle: TextStyle(color: labelStyleColor),
                                hintText: _formatDate(_selectedDate),
                                hintStyle: TextStyle(color: inputTextColor),
                                filled: true,
                                fillColor: fieldFillColor,
                                suffixIcon: const Icon(
                                  Icons.calendar_month,
                                  color: Color(0xFF22C55E),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderColor, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF22C55E), Color(0xFF15803D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              final amountText = _amountController.text.trim();

                              if (amountText.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Nominal tidak boleh kosong"),
                                  ),
                                );
                                return;
                              }

                              final amount = double.tryParse(amountText) ?? 0.0;

                              await _addExpense(
                                ExpenseItem(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  title: _nameController.text,
                                  amount: amount,
                                  category: _selectedCategory,
                                  date: _selectedDate,
                                ),
                              );

                              if (!context.mounted) return;

                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Simpan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,

        iconTheme: IconThemeData(
          color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
        ),

        title: Text(
          'Keuangan',
          style: TextStyle(
            color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _openAddExpenseModal,
            icon: Icon(
              Icons.add_circle_outline,
              color: AppColors.categoryKeuangan,
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseModal,
        backgroundColor: AppColors.categoryKeuangan,
        child: Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: ListView(
            children: [
              Text(
                'Pantau pengeluaranmu dengan mudah',
                style: TextStyle(
                  color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText),
                ),
              ),

              const SizedBox(height: 24),

              _buildMonthlyExpenseChart(),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF15803D), Color(0xFF22C55E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
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
                            'TOTAL PENGELUARAN',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _formatCurrency(_totalExpense),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_expenses.length} Item',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Riwayat Pengeluaran',
                style: TextStyle(
                  color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              if (_expenses.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    return _buildExpenseCard(
                      _expenses[index],
                      index,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}