import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String productTable = 'product_table';
  String colId = 'id';
  String colProduct = 'product';
  String colCode = 'code';

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'products.db');
    final productsDb = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return productsDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $productTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colProduct TEXT, $colCode TEXT)',
    );
  }

  Future<List<Map<String, dynamic>>> getProductMapList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(productTable);
    return result;
  }

  Future<int> insertProduct(Map<String, String> product) async {
    Database? db = await this.db;
    final int result = await db!.insert(productTable, product);
    return result;
  }

  Future<int> updateProduct(Map<String, String> product) async {
    Database? db = await this.db;
    final int result = await db!.update(
      productTable,
      product,
      where: '$colId = ?',
      whereArgs: [product[colId]],
    );
    return result;
  }

  Future<int> deleteProduct(int id) async {
    Database? db = await this.db;
    final int result = await db!.delete(
      productTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }

  Future<void> close() async {
    Database? db = await this.db;
    if (db != null) {
      await db.close();
    }
  }
}
