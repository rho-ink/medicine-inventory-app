import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';  // Import for date formatting
import 'package:admin_app/controllers/data_controller.dart'; // Adjust according to your project structure
import 'package:admin_app/views/pages/screens/notification_screen.dart'; // Adjust according to your project structure


class NotificationButton extends StatefulWidget {
  @override
  _NotificationButtonState createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  final DataController dataController = DataController();
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount();
  }

  Future<void> _fetchNotificationCount() async {
    final gudangData = await dataController.gudangStream.first;

    final unsafeItems = gudangData.expand((gudang) {
      final dateFormat = DateFormat('dd/MM/yyyy');

      return gudang.expiryDetails.values.where((detail) {
        try {
          DateTime expiryDate = dateFormat.parse(detail.expiryDate);
          DateTime today = DateTime.now();
          Duration difference = expiryDate.difference(today);
          return difference.inDays <= 180; // Items expiring in 6 months or less
        } catch (e) {
          print('Error parsing date: ${detail.expiryDate}');
          return false;
        }
      }).toList();
    }).toList();

    setState(() {
      _notificationCount = unsafeItems.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: badges.Badge(
        badgeContent: Text(
          '$_notificationCount',
          style: TextStyle(color: Colors.white),
        ),
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.circle,
          badgeColor: Colors.purple,
          padding: EdgeInsets.all(4), // Reduce padding to make the badge smaller
          borderRadius: BorderRadius.circular(6), // Adjust borderRadius for size
        ),
        showBadge: _notificationCount > 0,
        child: Icon(Icons.notifications_none),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationScreen()),
        );
      },
    );
  }
}