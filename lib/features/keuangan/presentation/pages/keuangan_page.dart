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

    final maxValue =
        (previousValue > currentValue ? previousValue : currentValue)
            .clamp(100, double.infinity);

    final chartMax = maxValue * 1.2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Pengeluaran Bulanan',
            style: TextStyle(
              color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

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

                      getTitlesWidget: (value, meta) {
                        return Text(
                          value == 0 ? '0' : _formatCurrency(value),
                          style: TextStyle(
                            color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,

                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= monthLabels.length) {
                          return const SizedBox.shrink();
                        }

                        return Text(
                          monthLabels[index],
                          style: TextStyle(
                            color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
                            fontWeight: FontWeight.bold,
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
                        color: AppColors.categoryKeuangan.withValues(alpha: 0.5),
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
                        color: AppColors.categoryKeuangan,
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

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseItem expense, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          backgroundColor: AppColors.categoryKeuangan.withValues(alpha: 0.15),
          child: Icon(
            Icons.account_balance_wallet,
            color: AppColors.categoryKeuangan,
          ),
        ),

        title: Text(
          expense.title,
          style: TextStyle(
            color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          '${expense.category} • ${_formatDate(expense.date)}',
          style: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText)),
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatCurrency(expense.amount),
              style: TextStyle(
                color: AppColors.categoryKeuangan,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            GestureDetector(
              onTap: () => _removeExpenseAt(index),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Belum ada pengeluaran',
          style: TextStyle(
            color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText),
            fontSize: 16,
          ),
        ),
      ),
    );
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),

              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),

                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tambah Pengeluaran',
                    style: TextStyle(
                      color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
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
                          style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                          decoration: InputDecoration(
                            labelText: 'Nama Pengeluaran',
                            filled: true,
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            labelStyle: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                          decoration: InputDecoration(
                            labelText: 'Nominal',
                            filled: true,
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            labelStyle: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            filled: true,
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            labelStyle: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: _categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category, style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText))),
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
                              style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                              decoration: InputDecoration(
                                labelText: AppStrings.tanggal,
                                hintText: _formatDate(_selectedDate),
                                filled: true,
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                hintStyle: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                                labelStyle: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText)),
                                suffixIcon: Icon(
                                  Icons.calendar_month,
                                  color: AppColors.categoryKeuangan,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
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
                              backgroundColor: AppColors.categoryKeuangan,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            onPressed: () async {
                              final amount = double.parse(
                                _amountController.text,
                              );

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

                            child: Text(
                              'Simpan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppColors.categoryKeuangan,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pengeluaran',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _formatCurrency(_totalExpense),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildBadge(
                      '${_expenses.length} Item',
                      Colors.white,
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