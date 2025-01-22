import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tnrb/screens/login_screen.dart';

import '../screens/history_screen.dart';

class KAppbar extends AppBar {
  final String appBarTitle;
  final IconData iconData;
  final bool isHistoryPage;
  KAppbar({
    super.key,
    required this.appBarTitle,
    required this.iconData,
    this.isHistoryPage = false,
  });

  @override
  State<KAppbar> createState() => _KAppbarState();
}

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);
  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false);
  }
}

// got the history screen
void goHistoryScreen(BuildContext context) async {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(),
      ));
}

class _KAppbarState extends State<KAppbar> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(MediaQuery.sizeOf(context).width, 100),
      child: AppBar(
        leading: Icon(widget.iconData),
        leadingWidth: 35,
        title: Text(widget.appBarTitle),
        actions: kAppbarActions(context),
      ),
    );
  }

  List<Widget> kAppbarActions(BuildContext context) {
    return [
      Visibility(
        visible: !widget.isHistoryPage,
        child: IconButton(
            onPressed: () => goHistoryScreen(context),
            icon: Icon(Icons.history)),
      ),
      IconButton(onPressed: () => logout(context), icon: Icon(Icons.logout)),
    ];
  }
}
