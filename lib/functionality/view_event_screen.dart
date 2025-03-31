import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_details_screen.dart'; // Import the event details screen

class ViewEventsScreen extends StatelessWidget {
  const ViewEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Events")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No events found."));
          }

          var events = snapshot.data!.docs;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index].data();
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(event["Title"] ?? "No Title"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event["Description"] ?? "No Description"),
                      Text("Created by: ${event["createdBy"] ?? "Unknown"}"),
                      Text("Created on: ${_formatTimestamp(event["createdAt"])}"),
                    ],
                  ),
                  trailing: Text("Capacity: ${event["Max_capacity"] ?? 0}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(event: event),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

String _formatTimestamp(dynamic timestamp) {
  if (timestamp is Timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Firestore timestamp to DateTime
    return "${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year} at "
           "${_formatTime(dateTime)}";
  }
  return "Unknown date";
}

// Helper function to format time in 12-hour format with AM/PM
String _formatTime(DateTime dateTime) {
  int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12; // Convert 0 to 12
  String minute = dateTime.minute.toString().padLeft(2, '0'); // Ensure two-digit minutes
  String period = dateTime.hour >= 12 ? "PM" : "AM";
  return "$hour:$minute $period";
}

// Helper function to get month name
String _getMonthName(int month) {
  const List<String> months = [
    "", "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  return months[month];
}

}