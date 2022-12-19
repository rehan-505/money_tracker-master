class TotalAmount{
  final double cash;
  final double card;
  final double cardAllTimeAdded;
  final double cardAllTimeWithdraw;
  final double cashAllTimeAdded;
  final double cashAllTimeWithdraw;


  Map<String, dynamic> toMap() {
    return {
      'cash': cash,
      'card': card,
      'cardAllTimeAdded': cardAllTimeAdded,
      'cardAllTimeWithdraw': cardAllTimeWithdraw,
      'cashAllTimeAdded': cashAllTimeAdded,
      'cashAllTimeWithdraw': cashAllTimeWithdraw,
    };
  }

  factory TotalAmount.fromMap(Map<String, dynamic> map) {
    return TotalAmount(
      cash: map['cash'] as double,
      card: map['card'] as double,
      cardAllTimeAdded: map['cardAllTimeAdded'] as double,
      cardAllTimeWithdraw: map['cardAllTimeWithdraw'] as double,
      cashAllTimeAdded: map['cashAllTimeAdded'] as double,
      cashAllTimeWithdraw: map['cashAllTimeWithdraw'] as double,
    );
  }

  const TotalAmount({
    required this.cash,
    required this.card,
    required this.cardAllTimeAdded,
    required this.cardAllTimeWithdraw,
    required this.cashAllTimeAdded,
    required this.cashAllTimeWithdraw,
  });
}