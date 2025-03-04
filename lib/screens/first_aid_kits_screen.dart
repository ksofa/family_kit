import 'package:flutter/material.dart';
import '../models/first_aid_kit.dart';
import '../services/first_aid_kit_service.dart';
import 'create_first_aid_kit_screen.dart';
import 'first_aid_kit_details_screen.dart';
import '../services/sharing_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class FirstAidKitsScreen extends StatefulWidget {
  @override
  _FirstAidKitsScreenState createState() => _FirstAidKitsScreenState();
}

class _FirstAidKitsScreenState extends State<FirstAidKitsScreen> {
  List<FirstAidKit> _firstAidKits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFirstAidKits();
  }

  Future<void> _loadFirstAidKits() async {
    try {
      setState(() => _isLoading = true);
      final kits = await FirstAidKitService.getUserFirstAidKits();
      setState(() {
        _firstAidKits = kits;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load first aid kits: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createFirstAidKit() async {
    final result = await Navigator.push<FirstAidKit>(
      context,
      MaterialPageRoute(builder: (context) => CreateFirstAidKitScreen()),
    );

    if (result != null) {
      setState(() => _firstAidKits.add(result));
    }
  }

  Future<void> _deleteFirstAidKit(FirstAidKit kit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete First Aid Kit'),
        content: Text(
          'Are you sure you want to delete "${kit.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirstAidKitService.deleteFirstAidKit(kit.id);
        setState(() {
          _firstAidKits.removeWhere((k) => k.id == kit.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('First aid kit deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete first aid kit: $e')),
        );
      }
    }
  }

  Future<void> _shareFirstAidKit(FirstAidKit kit) async {
    try {
      final role = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Share First Aid Kit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select access level for new user:'),
              SizedBox(height: 16),
              ListTile(
                title: Text('Administrator'),
                subtitle: Text('Full access to manage medicines and users'),
                onTap: () => Navigator.pop(context, 'administrator'),
              ),
              ListTile(
                title: Text('Editor'),
                subtitle: Text('Can add and update medicines'),
                onTap: () => Navigator.pop(context, 'editor'),
              ),
              ListTile(
                title: Text('Observer'),
                subtitle: Text('Can only view medicines'),
                onTap: () => Navigator.pop(context, 'observer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      );

      if (role != null) {
        final accessCode = await SharingService.generateAccessCode(
          kit.id,
          role,
        );

        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Share Access Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share this code with the person you want to grant access to:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          accessCode,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: accessCode));
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Access code copied to clipboard')),
                          );
                        },
                        tooltip: 'Copy to clipboard',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'This code will expire in 24 hours.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.share),
                label: Text('Share'),
                onPressed: () {
                  Share.share(
                    'Join my first aid kit with this access code: $accessCode\n\n'
                    'This code will expire in 24 hours.',
                  );
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate access code: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My First Aid Kits'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _firstAidKits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No first aid kits yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _createFirstAidKit,
                        icon: Icon(Icons.add),
                        label: Text('Create First Aid Kit'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFirstAidKits,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _firstAidKits.length,
                    itemBuilder: (context, index) {
                      final kit = _firstAidKits[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.medical_services),
                          ),
                          title: Text(kit.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (kit.description.isNotEmpty)
                                Text(
                                  kit.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.people, size: 16),
                                  SizedBox(width: 4),
                                  Text(kit.userCount),
                                  SizedBox(width: 16),
                                  Icon(Icons.access_time, size: 16),
                                  SizedBox(width: 4),
                                  Text(kit.lastUpdated),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'share',
                                child: ListTile(
                                  leading: Icon(Icons.share),
                                  title: Text('Share'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete_outline),
                                  title: Text('Delete'),
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'share':
                                  _shareFirstAidKit(kit);
                                  break;
                                case 'delete':
                                  _deleteFirstAidKit(kit);
                                  break;
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FirstAidKitDetailsScreen(
                                  firstAidKit: kit,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: _firstAidKits.isNotEmpty
          ? FloatingActionButton(
              onPressed: _createFirstAidKit,
              child: Icon(Icons.add),
              tooltip: 'Create First Aid Kit',
            )
          : null,
    );
  }
} 