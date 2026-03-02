import 'package:flutter/material.dart';
import '../models/smoothie_item.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.itemPrice);
  double get discount  => subtotal > 100 ? 10.0 : 0.0;
  double get afterDiscount => subtotal - discount;
  double get vat   => afterDiscount * 0.07;
  double get total => afterDiscount + vat;

  void addItem(
    SmoothieItem smoothie, {
    String size = 'M',
    List<ToppingItem>? toppings,
    String sweetness = 'หวานปกติ',
  }) {
    _items.add(CartItem(
      smoothie: smoothie,
      size: size,
      toppings: toppings ?? [],
      sweetness: sweetness,
    ));
    notifyListeners();
  }

  void removeAt(int index) { _items.removeAt(index); notifyListeners(); }
  void incrementAt(int index) { _items[index].quantity++; notifyListeners(); }
  void decrementAt(int index) {
    if (_items[index].quantity > 1) _items[index].quantity--;
    else _items.removeAt(index);
    notifyListeners();
  }
  void clear() { _items.clear(); notifyListeners(); }
}