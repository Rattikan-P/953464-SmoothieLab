import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/smoothie_item.dart';
import '../models/cart_item.dart';
import '../data/ingredients_data.dart';

class CartProvider extends ChangeNotifier {
  late Box<CartItem> _cartBox;
  bool _isInitialized = false;

  List<CartItem> get items {
    if (!_isInitialized) return [];
    return _cartBox.values.toList();
  }

  int get totalCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.itemPrice);

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

  // Initialize with existing box (opened in main.dart)
  void init(Box<CartItem> cartBox) {
    _cartBox = cartBox;
    _isInitialized = true;
    notifyListeners();
  }

  void addItem(
    SmoothieItem smoothie, {
    String size = 'M',
    List<ToppingItem>? toppings,
    String sweetness = 'หวานปกติ',
    bool isCustom = false,
    List<int>? fruitIndexes,
    List<int>? extrasIndexes,
    List<int>? veggieIndexes,
    List<int>? herbsIndexes,
    List<int>? toppingsIndexes,
  }) async {
    final cartItem = CartItem.fromSmoothie(
      smoothie,
      size: size,
      toppings: toppings,
      sweetness: sweetness,
      isCustom: isCustom,
      fruitIndexes: fruitIndexes,
      extrasIndexes: extrasIndexes,
      veggieIndexes: veggieIndexes,
      herbsIndexes: herbsIndexes,
      toppingsIndexes: toppingsIndexes,
    );
    await _cartBox.add(cartItem);
    notifyListeners();
  }

  void removeAt(int index) async {
    if (index >= 0 && index < items.length) {
      final key = _cartBox.keys.elementAt(index);
      await _cartBox.delete(key);
      notifyListeners();
    }
  }

  void incrementAt(int index) async {
    if (index >= 0 && index < items.length) {
      final key = _cartBox.keys.elementAt(index);
      final item = _cartBox.get(key);
      if (item != null) {
        item.quantity++;
        await item.save();
        notifyListeners();
      }
    }
  }

  // คืนค่า true ถ้าต้องแสดง confirm dialog (qty == 1)
  bool decrementAt(int index) {
    if (index >= 0 && index < items.length) {
      final key = _cartBox.keys.elementAt(index);
      final item = _cartBox.get(key);
      if (item != null) {
        if (item.quantity > 1) {
          item.quantity--;
          item.save();
          notifyListeners();
          return false; // ไม่ต้อง confirm
        }
        return true; // ต้อง confirm ก่อนลบ
      }
    }
    return false;
  }

  void clear() async {
    await _cartBox.clear();
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
    required List<int> herbsIndexes,
    bool isCustom = true,
    List<int>? toppingsIndexes,
  }) async {
    if (index < 0 || index >= items.length) return;

    final key = _cartBox.keys.elementAt(index);
    final oldItem = _cartBox.get(key);

    if (oldItem != null) {
      final oldQty = oldItem.quantity;

      // Create new item with updated data
      final newItem = CartItem.fromSmoothie(
        smoothie,
        size: size,
        toppings: toppings,
        sweetness: sweetness,
        isCustom: isCustom,
        fruitIndexes: fruitIndexes,
        extrasIndexes: extrasIndexes,
        veggieIndexes: veggieIndexes,
        herbsIndexes: herbsIndexes,
        toppingsIndexes: toppingsIndexes,
      )..quantity = oldQty;

      // Update fields in the existing item to preserve HiveObject reference
      oldItem.menuName = newItem.menuName;
      oldItem.menuEmoji = newItem.menuEmoji;
      oldItem.basePrice = newItem.basePrice;
      oldItem.size = newItem.size;
      oldItem.toppingNames = newItem.toppingNames;
      oldItem.sweetness = newItem.sweetness;
      oldItem.isCustom = newItem.isCustom;
      oldItem.fruitIndexes = newItem.fruitIndexes;
      oldItem.extrasIndexes = newItem.extrasIndexes;
      oldItem.veggieIndexes = newItem.veggieIndexes;
      oldItem.herbsIndexes = newItem.herbsIndexes;
      oldItem.toppingsIndexes = newItem.toppingsIndexes;

      await oldItem.save();
      notifyListeners();
    }
  }
}
