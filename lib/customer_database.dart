import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CustomerDatabase {
  static final CustomerDatabase _instance = CustomerDatabase._internal();
  static Database? _database;

  factory CustomerDatabase() {
    return _instance;
  }

  CustomerDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'customer_database.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    // Create Customers table
    // Note: Define your columns below based on your requirements
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        customer_id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        phone VARCHAR(15),
        address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
      ''');
  }

  // Fetch all customers
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await database;
    return await db.query('Customers', orderBy: 'id DESC');
  }

  // Insert a customer
  Future<int> insertCustomer(Map<String, dynamic> customer) async {
    final db = await database;
    return await db.insert('Customers', customer);
  }

  // Update a customer
  Future<int> updateCustomer(int id, Map<String, dynamic> customer) async {
    final db = await database;
    return await db.update(
      'Customers',
      customer,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a customer
  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('Customers', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
