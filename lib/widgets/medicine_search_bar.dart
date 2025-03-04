import 'package:flutter/material.dart';

class MedicineSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String) onCategoryChanged;
  final Function(String) onSortChanged;

  const MedicineSearchBar({
    Key? key,
    required this.onSearch,
    required this.onCategoryChanged,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  _MedicineSearchBarState createState() => _MedicineSearchBarState();
}

class _MedicineSearchBarState extends State<MedicineSearchBar> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Все';
  String _selectedSort = 'name_asc';

  final List<String> _categories = [
    'Все',
    'Обезболивающие',
    'Антибиотики',
    'Витамины',
    'Противовирусные',
    'Другое',
  ];

  final Map<String, String> _sortOptions = {
    'name_asc': 'По названию (А-Я)',
    'name_desc': 'По названию (Я-А)',
    'exp_asc': 'Срок годности (сначала истекающие)',
    'exp_desc': 'Срок годности (сначала свежие)',
    'quantity_asc': 'Количество (по возрастанию)',
    'quantity_desc': 'Количество (по убыванию)',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск лекарств...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: widget.onSearch,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  hint: Text('Категория'),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                      widget.onCategoryChanged(value);
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _selectedSort,
                  hint: Text('Сортировка'),
                  items: _sortOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSort = value);
                      widget.onSortChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 