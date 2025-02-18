import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'customers.db'),
      onCreate: (db, version) {
        return db.execute("CREATE TABLE customers(id INTEGER PRIMARY KEY, name TEXT, phone TEXT, email TEXT, image TEXT, address TEXT, latitude TEXT, longitude TEXT, geoAddress TEXT)");
      },
      version: 1,
    );
  }

  static Future<void> insertCustomer(Map<String, dynamic> customer) async {
    final db = await database();
    print(customer);
    print("customer");
    await db.insert('customers', customer);
  }


  static Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await database();
    return db.query('customers');
  }
}
