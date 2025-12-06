import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';

class ProductDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getProductMapList() async {
    final Database? db = await _dbHelper.db;
    final List<Map<String, dynamic>> result =
        await db!.query(_dbHelper.productTable);
    return result;
  }

  Future<int> insertProduct(Map<String, String> product) async {
    final Database? db = await _dbHelper.db;
    final int result = await db!.insert(_dbHelper.productTable, product);
    return result;
  }

  Future<int> updateProduct(Map<String, String> product) async {
    final Database? db = await _dbHelper.db;
    final int result = await db!.update(
      _dbHelper.productTable,
      product,
      where: '${_dbHelper.colId} = ?',
      whereArgs: [product[_dbHelper.colId]],
    );
    return result;
  }

  Future<int> deleteProduct(int id) async {
    final Database? db = await _dbHelper.db;
    final int result = await db!.delete(
      _dbHelper.productTable,
      where: '${_dbHelper.colId} = ?',
      whereArgs: [id],
    );
    return result;
  }
}
