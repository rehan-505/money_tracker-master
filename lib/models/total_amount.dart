class TotalAmount{
  final double cash;
  final double cashAllTimeAdded;
  final double cashAllTimeWithdraw;

  final double card;
  final double cardAllTimeAdded;
  final double cardAllTimeWithdraw;

  final double bank;
  final double bankAllTimeAdded;
  final double bankAllTimeWithdraw;


  Map<String, dynamic> toMap() {
    return {
      'cash': cash,
      'card': card,
      'cardAllTimeAdded': cardAllTimeAdded,
      'cardAllTimeWithdraw': cardAllTimeWithdraw,
      'cashAllTimeAdded': cashAllTimeAdded,
      'cashAllTimeWithdraw': cashAllTimeWithdraw,

      'bank': bank,
      'bankAllTimeAdded': bankAllTimeAdded,
      'bankAllTimeWithdraw': bankAllTimeWithdraw

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
      bank: map['bank'] as double,
      bankAllTimeAdded: map['bankAllTimeAdded'] as double,
      bankAllTimeWithdraw: map['bankAllTimeWithdraw'] as double,


    );
  }

  const TotalAmount({
    required this.cash,
    required this.card,
    required this.cardAllTimeAdded,
    required this.cardAllTimeWithdraw,
    required this.cashAllTimeAdded,
    required this.cashAllTimeWithdraw,
    required this.bank,
    required this.bankAllTimeAdded,
    required this.bankAllTimeWithdraw
  });
}