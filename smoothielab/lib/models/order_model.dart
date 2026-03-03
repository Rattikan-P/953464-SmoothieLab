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
  List<String> toppings = [];

  @HiveField(5)
  late double totalPrice; // ยอดที่จ่ายจริง (หลัง discount + VAT) proportional ต่อ item

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

  @HiveField(11)
  List<String> ingredients = [];

  @HiveField(12)
  late String sweetness;

  /// ราคา item ก่อน discount และ VAT (= CartItem.itemPrice)
  /// ใช้สำหรับ Order Again เพื่อ reconstruct CartItem ได้ราคาถูกต้อง
  @HiveField(13)
  late double itemPriceRaw;
}
