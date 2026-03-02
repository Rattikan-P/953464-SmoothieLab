import 'package:hive/hive.dart';

part 'order_model.g.dart';

@HiveType(typeId: 0)
class OrderModel extends HiveObject {
  @HiveField(0)
  late String orderId;

  @HiveField(1)
  late String menuName;

  @HiveField(2)
  late String menuEmoji;

  @HiveField(3)
  late String size;

  @HiveField(4)
  late List<String> toppings;

  @HiveField(5)
  late double totalPrice;

  @HiveField(6)
  late DateTime orderDate;

  @HiveField(7)
  late String status; // 'processing', 'completed', 'cancelled'

  @HiveField(8)
  late double subtotal;

  @HiveField(9)
  late double discount;

  @HiveField(10)
  late double vat;
}