class Goal {
  final String id;
  final String title;
  final DateTime expiredDate;
  final double amount;
  double savings = 0;

  Goal(
      {required this.id,
      required this.title,
      required this.expiredDate,
      required this.amount});
}
