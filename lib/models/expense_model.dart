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
