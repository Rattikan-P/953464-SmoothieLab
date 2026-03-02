import 'package:flutter/material.dart';
import '../models/smoothie_item.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.itemPrice);

  // Dynamic discount tiers
  // ≥ 300฿ → ลด 15%
  // ≥ 200฿ → ลด 10%
  // ≥ 100฿ → ลด 5%
  double get discountRate {
    if (subtotal >= 300) return 0.15;
    if (subtotal >= 200) return 0.10;
    if (subtotal >= 100) return 0.05;
    return 0.0;
  }

  String get discountLabel {
    if (subtotal >= 300) return 'ลด 15% (ยอดเกิน ฿300)';
    if (subtotal >= 200) return 'ลด 10% (ยอดเกิน ฿200)';
    if (subtotal >= 100) return 'ลด 5% (ยอดเกิน ฿100)';
    return '';
  }

  double get discount => subtotal * discountRate;
  double get afterDiscount => subtotal - discount;
  double get vat => afterDiscount * 0.07;
  double get total => afterDiscount + vat;

  void addItem(
    SmoothieItem smoothie, {
    String size = 'M',
    List<ToppingItem>? toppings,
    String sweetness = 'หวานปกติ',
    bool isCustom = false,
    List<int>? fruitIndexes,
    List<int>? extrasIndexes,
    List<int>? veggieIndexes,
  }) {
    _items.add(
      CartItem(
        smoothie: smoothie,
        size: size,
        toppings: toppings ?? [],
        sweetness: sweetness,
        isCustom: isCustom,
        fruitIndexes: fruitIndexes ?? [],
        extrasIndexes: extrasIndexes ?? [],
        veggieIndexes: veggieIndexes ?? [],
      ),
    );
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void incrementAt(int index) {
    _items[index].quantity++;
    notifyListeners();
  }

  // คืนค่า true ถ้าต้องแสดง confirm dialog (qty == 1)
  bool decrementAt(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
      notifyListeners();
      return false; // ไม่ต้อง confirm
    }
    return true; // ต้อง confirm ก่อนลบ
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void updateItemAt(
    int index,
    SmoothieItem smoothie, {
    required String size,
    required List<ToppingItem> toppings,
    required String sweetness,
    required List<int> fruitIndexes,
    required List<int> extrasIndexes,
    required List<int> veggieIndexes,
    bool isCustom = true, // ✅ เพิ่ม
  }) {
    if (index < 0 || index >= _items.length) return;
    final oldQty = _items[index].quantity;
    _items[index] = CartItem(
      smoothie: smoothie,
      size: size,
      toppings: toppings,
      sweetness: sweetness,
      isCustom: isCustom, // ✅
      fruitIndexes: fruitIndexes,
      extrasIndexes: extrasIndexes,
      veggieIndexes: veggieIndexes,
      quantity: oldQty,
    );
    notifyListeners();
  }
}
