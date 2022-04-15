import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  Payment({required this.name, required this.amount, required this.channel, required this.comments, required this.methodOfPayment, required this.mobile, required this.payOrReceive, this.paidTo, required this.timestamp, required this.user});

  Payment.fromJson(Map<String, Object?> json)
    : this(
        name: json['name'] as String?,
        amount: json['amount'] as double?,
        channel: json['channel'] as String?,
        comments: json['comments'] as String?,
        methodOfPayment: json['methodOfPayment'] as String?,
        mobile: json['mobile'] as double?,
        payOrReceive: json['payOrReceive'] as String?,
        paidTo: json['paidTo'] as String?,
        timestamp:json['timestamp'] as Timestamp?,
        user:json['user'] as String?,
      );

  final String? name;
  final double? amount;
  final String? channel;
  final String? comments;
  final String? methodOfPayment;
  final double? mobile;
  final String? payOrReceive;
  final String? paidTo;
  final Timestamp? timestamp;
  final String? user;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'amount': amount,
      'channel':channel,
      'comments':comments,
      'methodOfPayment':methodOfPayment,
      'mobile':mobile,
      'payOrReceive':payOrReceive,
      'paidTo':paidTo,
      'timestamp':timestamp,
      'user':user,
    };
  }
}