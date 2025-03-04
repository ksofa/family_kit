import 'package:flutter/material.dart';
import '../services/medicine_service.dart';

class MedicineSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  @override
  String get searchFieldLabel => 'Search medicines';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
          tooltip: 'Clear',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
      tooltip: 'Back',
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _SearchResults(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SearchResults(query: query);
  }
}

class _SearchResults extends StatefulWidget {
  final String query;

  const _SearchResults({
    Key? key,
    required this.query,
  }) : super(key: key);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<_SearchResults> {
  List<Map<String, dynamic>>? _results;
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _searchMedicines();
  }

  @override
  void didUpdateWidget(_SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _lastQuery) {
      _searchMedicines();
    }
  }

  Future<void> _searchMedicines() async {
    if (widget.query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    if (widget.query.length < 2) return;

    setState(() {
      _isLoading = true;
      _lastQuery = widget.query;
    });

    try {
      final results = await MedicineService.searchMedicines(widget.query);
      if (mounted && widget.query == _lastQuery) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to search medicines: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_results == null || widget.query.isEmpty) {
      return Center(
        child: Text('Enter medicine name or active substance'),
      );
    }

    if (_results!.isEmpty) {
      return Center(
        child: Text('No medicines found'),
      );
    }

    return ListView.builder(
      itemCount: _results!.length,
      itemBuilder: (context, index) {
        final medicine = _results![index];
        return ListTile(
          title: Text(medicine['name']),
          subtitle: Text(medicine['active_substance']),
          trailing: Text(medicine['form']),
          onTap: () => Navigator.pop(context, medicine),
        );
      },
    );
  }
} 