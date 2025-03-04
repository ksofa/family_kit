import 'package:flutter/material.dart';
import '../screens/join_first_aid_kit_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/profile_settings_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Family Medicine Manager',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text('Join First Aid Kit'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JoinFirstAidKitScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Настройки профиля'),
            onTap: () {
              Navigator.pop(context); // Закрыть drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Настройки уведомлений'),
            onTap: () {
              Navigator.pop(context); // Закрыть drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationSettingsScreen(),
                ),
              );
            },
          ),
          // ... other drawer items ...
        ],
      ),
    );
  }
} 