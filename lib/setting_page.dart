import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            subtitle:
                const Text('Enable dark mode for a better viewing experience'),
            leading: const Icon(Icons.dark_mode),
            trailing: Switch(
              value: themeNotifier.isDarkMode,
              onChanged: (value) {
                themeNotifier.isDarkMode = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
