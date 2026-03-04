// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 1;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      size: fields[3] as String,
      toppingNames: (fields[4] as List).cast<String>(),
      sweetness: fields[5] as String,
      quantity: fields[6] as int,
      isCustom: fields[7] as bool,
      fruitIndexes: (fields[8] as List).cast<int>(),
      extrasIndexes: (fields[9] as List).cast<int>(),
      veggieIndexes: (fields[10] as List).cast<int>(),
      herbsIndexes: (fields[11] as List).cast<int>(),
      toppingsIndexes: (fields[12] as List).cast<int>(),
    )
      ..menuName = fields[0] as String
      ..menuEmoji = fields[1] as String
      ..basePrice = fields[2] as double;
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.menuName)
      ..writeByte(1)
      ..write(obj.menuEmoji)
      ..writeByte(2)
      ..write(obj.basePrice)
      ..writeByte(3)
      ..write(obj.size)
      ..writeByte(4)
      ..write(obj.toppingNames)
      ..writeByte(5)
      ..write(obj.sweetness)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.isCustom)
      ..writeByte(8)
      ..write(obj.fruitIndexes)
      ..writeByte(9)
      ..write(obj.extrasIndexes)
      ..writeByte(10)
      ..write(obj.veggieIndexes)
      ..writeByte(11)
      ..write(obj.herbsIndexes)
      ..writeByte(12)
      ..write(obj.toppingsIndexes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
