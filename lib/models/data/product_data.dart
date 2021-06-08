import 'dart:convert';
import 'dart:io';

final productData = ProductData(dataPath: 'assets/product_data.json');

class ProductData {
  final String dataPath;

  Map<String, int>? _data;

  ProductData({required this.dataPath});

  Future<int> getBoostCount(String productId) async {
    if (_data == null) {
      await load();
    }

    return _data![productId] ?? 0;
  }

  Future<void> load() async {
    final jsonString = await File(dataPath).readAsString();
    final jsonObj = json.decode(jsonString) as Map<String, dynamic>;
    _data = jsonObj.map((key, value) => MapEntry(key, value as int));
  }
}
