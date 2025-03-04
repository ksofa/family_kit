import 'package:flutter/material.dart';
import '../services/sharing_service.dart';

class ManageUsersScreen extends StatefulWidget {
  final String firstAidKitId;
  final String firstAidKitName;

  const ManageUsersScreen({
    Key? key,
    required this.firstAidKitId,
    required this.firstAidKitName,
  }) : super(key: key);

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<Map<String, dynamic>>? _users;
  bool _isLoading = true;
  bool _canManageUsers = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        SharingService.getFirstAidKitUsers(widget.firstAidKitId),
        SharingService.canManageUsers(widget.firstAidKitId),
      ]);

      setState(() {
        _users = results[0] as List<Map<String, dynamic>>;
        _canManageUsers = results[1] as bool;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserRole(String userId, String currentRole) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Select Role'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'viewer'),
            child: Text('Viewer'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'editor'),
            child: Text('Editor'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'administrator'),
            child: Text('Administrator'),
          ),
        ],
      ),
    );

    if (newRole != null && newRole != currentRole) {
      try {
        await SharingService.updateUserRole(
          widget.firstAidKitId,
          userId,
          newRole,
        );
        _loadData(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user role: $e')),
        );
      }
    }
  }

  Future<void> _removeUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove User'),
        content: Text('Are you sure you want to remove this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SharingService.removeUser(widget.firstAidKitId, userId);
        _loadData(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users == null
              ? Center(child: Text('Failed to load users'))
              : ListView.builder(
                  itemCount: _users!.length,
                  itemBuilder: (context, index) {
                    final user = _users![index];
                    final bool isCurrentUser = user['is_current_user'] ?? false;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user['name']?[0].toUpperCase() ?? '?',
                        ),
                      ),
                      title: Text(user['name'] ?? 'Unknown User'),
                      subtitle: Text(user['email'] ?? ''),
                      trailing: _canManageUsers && !isCurrentUser
                          ? PopupMenuButton<String>(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Text('Change Role'),
                                  value: 'change_role',
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    'Remove',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  value: 'remove',
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'change_role') {
                                  _updateUserRole(
                                    user['id'],
                                    user['role'],
                                  );
                                } else if (value == 'remove') {
                                  _removeUser(user['id']);
                                }
                              },
                            )
                          : null,
                    );
                  },
                ),
    );
  }
} 