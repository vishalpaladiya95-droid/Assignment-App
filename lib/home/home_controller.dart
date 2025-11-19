import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../model/item_model.dart';

class HomeController extends GetxController {
  static Database? _database;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Item> allTodoData = [];
  Map<String, int> animalCount = {};

  Map<String, List<Map<String, String?>>> animalData = {
    "animals": [
      {"animal": "dog,cat,dog,cow,monkey"},
      {"animal": "cow,cat,cat,lion"},
      {"animal": null},
      {"animal": ""},
    ],
  };

  @override
  void onInit() {
    super.onInit();
    refreshItemList();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('items_database.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create database table
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');
  }

  // Insert item
  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  // Retrieve all items
  Future<List<Item>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');

    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  // Update item
  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete item
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  // Refresh itemsList
  void refreshItemList() async {
    final items = await getAllItems();
    allTodoData = items;
    update();
  }

  //BottomSheet
  void showBottomSheet(context, {Item? existingItem}) {
    if (existingItem != null) {
      _nameController.text = existingItem.title;
      _descriptionController.text = existingItem.description;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Item Name',
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Description',
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _nameController.clear();
                            _descriptionController.clear();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final name = _nameController.text;
                            final description = _descriptionController.text;
                            if (name.isNotEmpty && description.isNotEmpty) {
                              if (existingItem == null) {
                                await insertItem(
                                  Item(
                                    title: name,
                                    description: description,
                                    status: 'Created',
                                    time: DateTime.now().toIso8601String(),
                                  ),
                                );
                              } else {
                                await updateItem(
                                  Item(
                                    id: existingItem.id,
                                    title: name,
                                    description: description,
                                    status: 'Edited',
                                    time: DateTime.now().toIso8601String(),
                                  ),
                                );
                              }
                              refreshItemList();
                              _nameController.clear();
                              _descriptionController.clear();
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  //Count
  void findAnimalCount() {
    List<dynamic> animals = animalData['animals']!;

    for (var obj in animals) {
      String? animalString = obj['animal'];
      if (animalString == null || animalString.isEmpty) {
        return;
      }

      List<String> animalList = animalString.split(',');
      for (var animal in animalList) {
        animal = animal.trim();
        if (animal.isNotEmpty) {
          animalCount[animal] = (animalCount[animal] ?? 0) + 1;
        }
      }
    }
    print(animalCount);
  }
}
