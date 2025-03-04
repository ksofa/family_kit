import 'package:flutter/material.dart';
import '../models/first_aid_kit.dart';
import '../models/medicine.dart';
import '../services/first_aid_kit_service.dart';
import '../services/medicine_service.dart';
import '../services/sharing_service.dart';
import 'manage_users_screen.dart';
import 'add_medicine_screen.dart';
import 'statistics_screen.dart';
import 'scan_medicine_screen.dart';
import 'medicine_details_screen.dart';
import 'medicine_search_bar.dart';
import 'export_import_screen.dart';
import 'audit_log_screen.dart';
import 'medicine_list_item.dart';
import 'debouncer.dart';

class FirstAidKitDetailsScreen extends StatefulWidget {
  final FirstAidKit firstAidKit;

  const FirstAidKitDetailsScreen({
    Key? key,
    required this.firstAidKit,
  }) : super(key: key);

  @override
  _FirstAidKitDetailsScreenState createState() => _FirstAidKitDetailsScreenState();
}

class _FirstAidKitDetailsScreenState extends State<FirstAidKitDetailsScreen> {
  List<Medicine> _allMedicines = [];
  List<Medicine> _filteredMedicines = [];
  String _searchQuery = '';
  String _selectedCategory = 'Все';
  String _currentSort = 'name_asc';
  bool _isLoading = true;
  bool _canEdit = false;
  final _debouncer = Debouncer(milliseconds: 500);
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        MedicineService.getFirstAidKitMedicines(widget.firstAidKit.id),
        SharingService.canEditMedicines(widget.firstAidKit.id),
      ]);

      setState(() {
        _allMedicines = results[0] as List<Medicine>;
        _filteredMedicines = List.from(_allMedicines);
        _canEdit = results[1] as bool;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredMedicines = _allMedicines.where((medicine) {
        final matchesSearch = medicine.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            medicine.activeSubstance.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        final matchesCategory = _selectedCategory == 'Все' ||
            medicine.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();

      switch (_currentSort) {
        case 'name_asc':
          _filteredMedicines.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'name_desc':
          _filteredMedicines.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'exp_asc':
          _filteredMedicines.sort(
            (a, b) => a.expirationDate.compareTo(b.expirationDate),
          );
          break;
        case 'exp_desc':
          _filteredMedicines.sort(
            (a, b) => b.expirationDate.compareTo(a.expirationDate),
          );
          break;
        case 'quantity_asc':
          _filteredMedicines.sort(
            (a, b) => a.remainingQuantity.compareTo(b.remainingQuantity),
          );
          break;
        case 'quantity_desc':
          _filteredMedicines.sort(
            (a, b) => b.remainingQuantity.compareTo(a.remainingQuantity),
          );
          break;
      }
    });
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      setState(() => _searchQuery = query);
      _applyFilters();
    });
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    
    try {
      await _loadData();
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _addMedicine() async {
    final result = await Navigator.push<Medicine>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicineScreen(
          firstAidKitId: widget.firstAidKit.id,
        ),
      ),
    );

    if (result != null) {
      setState(() => _allMedicines.add(result));
      _applyFilters();
    }
  }

  Future<void> _editFirstAidKit() async {
    final nameController = TextEditingController(text: widget.firstAidKit.name);
    final descController = TextEditingController(text: widget.firstAidKit.description);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit First Aid Kit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'name': nameController.text,
              'description': descController.text,
            }),
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final updatedKit = await FirstAidKitService.updateFirstAidKit(
          widget.firstAidKit.id,
          result,
        );

        setState(() {
          widget.firstAidKit
            ..name = updatedKit.name
            ..description = updatedKit.description;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('First aid kit updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update first aid kit: $e')),
        );
      }
    }
  }

  Future<void> _shareFirstAidKit() async {
    try {
      await SharingService.shareFirstAidKit(
        widget.firstAidKit.id,
        widget.firstAidKit.name,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share first aid kit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.firstAidKit.name),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareFirstAidKit,
            tooltip: 'Share First Aid Kit',
          ),
          if (_canEdit)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _editFirstAidKit,
              tooltip: 'Edit First Aid Kit',
            ),
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageUsersScreen(
                    firstAidKitId: widget.firstAidKit.id,
                    firstAidKitName: widget.firstAidKit.name,
                  ),
                ),
              );
            },
            tooltip: 'Manage Users',
          ),
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsScreen(
                    firstAidKitId: widget.firstAidKit.id,
                  ),
                ),
              );
            },
            tooltip: 'Статистика',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.import_export),
                  title: Text('Экспорт/Импорт'),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExportImportScreen(
                        firstAidKit: widget.firstAidKit,
                        medicines: _allMedicines,
                      ),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('История действий'),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuditLogScreen(
                        firstAidKitId: widget.firstAidKit.id,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.firstAidKit.description.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        widget.firstAidKit.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.people, size: 16),
                        SizedBox(width: 4),
                        Text(widget.firstAidKit.userCount),
                        SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16),
                        SizedBox(width: 4),
                        Text('Last updated ${widget.firstAidKit.lastUpdated}'),
                      ],
                    ),
                  ),
                  Divider(height: 32),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Medicines',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  MedicineSearchBar(
                    onSearch: _onSearchChanged,
                    onCategoryChanged: (category) {
                      setState(() => _selectedCategory = category);
                      _applyFilters();
                    },
                    onSortChanged: (sort) {
                      setState(() => _currentSort = sort);
                      _applyFilters();
                    },
                  ),
                  Expanded(
                    child: _filteredMedicines.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'No medicines added yet'
                                  : 'No medicines found',
                            ),
                          )
                        : ListView.builder(
                            addAutomaticKeepAlives: true,
                            addRepaintBoundaries: true,
                            itemCount: _filteredMedicines.length,
                            itemBuilder: (context, index) {
                              final medicine = _filteredMedicines[index];
                              return RepaintBoundary(
                                child: MedicineListItem(
                                  medicine: medicine,
                                  onTap: () => _navigateToDetails(medicine),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _canEdit
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    final medicine = await Navigator.push<Medicine>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanMedicineScreen(
                          firstAidKitId: widget.firstAidKit.id,
                        ),
                      ),
                    );

                    if (medicine != null) {
                      setState(() => _allMedicines.add(medicine));
                      _applyFilters();
                    }
                  },
                  heroTag: 'scan',
                  child: Icon(Icons.qr_code_scanner),
                  tooltip: 'Сканировать лекарство',
                ),
                SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: _addMedicine,
                  heroTag: 'add',
                  child: Icon(Icons.add),
                  tooltip: 'Добавить лекарство',
                ),
              ],
            )
          : null,
    );
  }

  void _navigateToDetails(Medicine medicine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailsScreen(
          medicine: medicine,
          firstAidKitId: widget.firstAidKit.id,
        ),
      ),
    );
  }
} 