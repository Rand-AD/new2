import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color tealHeader = Color(0xFF5CA7BC);
  static const Color tealText = Color(0xFF6AAFC1);

  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 95,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: tealHeader,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(38),
                  bottomRight: Radius.circular(38),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GENERAL',
                      style: TextStyle(
                        color: tealText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _settingsTile(
                      icon: Icons.person_outline,
                      title: 'Account',
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: tealText,
                        size: 26,
                      ),
                      onTap: () {},
                    ),

                    _settingsTile(
                      icon: Icons.notifications_none,
                      title: 'Notification',
                      trailing: Switch(
                        value: notificationsEnabled,

                        // ✅ الجديد بدل activeThumbColor
                        thumbColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.white;
                        }),

                        // ✅ الجديد بدل activeTrackColor
                        trackColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return tealHeader;
                          }
                          return Colors.grey.shade300;
                        }),

                        onChanged: (value) {
                          setState(() {
                            notificationsEnabled = value;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          notificationsEnabled = !notificationsEnabled;
                        });
                      },
                    ),

                    _settingsTile(
                      icon: Icons.language,
                      title: 'Language',
                      trailing: const Text(
                        'English',
                        style: TextStyle(
                          color: Color(0xFFB6CED6),
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {},
                    ),

                    _settingsTile(
                      icon: Icons.favorite_border,
                      title: 'Intrests',
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: tealText,
                        size: 26,
                      ),
                      onTap: () {},
                    ),

                    _settingsTile(
                      icon: Icons.delete_outline,
                      title: 'Delete Account',
                      onTap: () {},
                    ),

                    _settingsTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () {},
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      'FEEDBACK',
                      style: TextStyle(
                        color: tealText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _settingsTile(
                      icon: Icons.warning_amber_outlined,
                      title: 'Report a Bug',
                      onTap: () {},
                    ),

                    _settingsTile(
                      icon: Icons.send_outlined,
                      title: 'Send Feedback',
                      onTap: () {},
                    ),

                    _settingsTile(
                      icon: Icons.help_outline,
                      title: 'Help',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(icon, color: tealText, size: 23),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: tealText,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
