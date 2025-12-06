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

  Future<void> close() async {
    Database? db = await this.db;
    if (db != null) {
      await db.close();
    }
  }
}
