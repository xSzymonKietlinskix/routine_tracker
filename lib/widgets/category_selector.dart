import 'package:flutter/material.dart';
import '../db/firestore_db.dart';

class CategorySelector extends StatefulWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  CategorySelector({this.selectedCategory, required this.onCategorySelected});

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  List<String> _categories = [];
  TextEditingController _categoryController = TextEditingController();
  final FirestoreDb _firestoreDb = FirestoreDb();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Pobierz kategorie z Firestore
  Future<void> _loadCategories() async {
    List<String> categories = await _firestoreDb.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  // Dodaj nową kategorię do Firestore
  void _addNewCategory() async {
    if (_categoryController.text.isNotEmpty &&
        !_categories.contains(_categoryController.text)) {
      // Dodajemy nową kategorię do Firestore
      await _firestoreDb.addCategory(_categoryController.text);

      // Po dodaniu kategorii, załaduj je ponownie z Firestore
      await _loadCategories();

      widget.onCategorySelected(_categoryController.text);
      _categoryController.clear();
      Navigator.pop(context);
    }
  }

  // Pokaż okno dialogowe do dodawania kategorii
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Category"),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(hintText: "Enter category name"),
          ),
          actions: [
            TextButton(
              onPressed: _addNewCategory,
              child: Text("Add"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 35.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Category", style: TextStyle(fontSize: 16)),
          Spacer(),
          DropdownButton<String>(
            value: widget.selectedCategory,
            items: _categories
                .map((category) =>
                    DropdownMenuItem(value: category, child: Text(category)))
                .toList()
              ..add(
                DropdownMenuItem<String>(
                  value: "add_new", // Unikalna wartość dla "Add New Category"
                  child: Text("Add New Category"),
                ),
              ),
            onChanged: (value) {
              if (value == "add_new") {
                _showAddCategoryDialog();
              } else if (value != null) {
                widget.onCategorySelected(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
