import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_event_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsScreen({super.key, required this.event});

  Future<String?> _getUserRole() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) return null;

    try {
      QuerySnapshot rolesQuery = await FirebaseFirestore.instance
          .collection("users")
          .doc("User_Roles")
          .collection("Users")
          .get();

      for (var doc in rolesQuery.docs) {
        if (doc["email"] == userEmail) {
          return doc.id;
        }
      }
      return null;
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }
/*
  Future<void> _deleteEvent(BuildContext context) async {
  try {
    print("Attempting to delete event with ID: ${event["id"]}");
    
    await FirebaseFirestore.instance
        .collection("events")
        .doc(event["Event_ID"]) // Ensure this ID exists in Firestore
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event deleted successfully")),
    );
    Navigator.pop(context); // Go back after deletion
  } catch (e) {
    print("Error deleting event: $e"); // Debugging
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error deleting event: $e")),
    );
  }
}
*/
Future<void> _deleteEvent(BuildContext context) async {
  try {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("events")
        .where("Title", isEqualTo: event["Title"]) // Ensure unique field
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event deleted successfully")),
      );

      // Ensure navigation happens *after* UI has time to update
      Future.microtask(() {
        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event not found")),
      );
    }
  } catch (e) {
    print("Error deleting event: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error deleting event: $e")),
    );
  }
}

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event["Title"] ?? "Event Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Description: ${event["Description"] ?? "No Description"}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Created by: ${event["createdBy"] ?? "Unknown"}"),
            Text("Created on: ${_formatTimestamp(event["createdAt"])}"),
            const Divider(),
            Text("Start Time: ${_formatTimestamp(event["Start_D/T"])}"),
            Text("End Time: ${_formatTimestamp(event["End_D/T"])}"),
            Text("Max Capacity: ${event["Max_capacity"] ?? 0}"),
            Text("Status: ${event["Status"] ?? "N/A"}"),
            Text("Budget: ${event["Budget"] ?? 0.0}"),
            Text("Age Rating: ${event["Age_Rating"] ?? "N/A"}"),

            const SizedBox(height: 20),

            // Fetch user role and conditionally show Edit & Delete buttons
            FutureBuilder<String?>(
              future: _getUserRole(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && (snapshot.data == "Admin" || snapshot.data == "Event_Manager")) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditEventScreen(event: event)),
                          );
                        },
                        child: const Text("Edit Event"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _showDeleteConfirmation(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Delete Event", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                }
                return const SizedBox(); // Hide buttons if unauthorized
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return "${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year} at ${_formatTime(dateTime)}";
    }
    return "Unknown date";
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  String _getMonthName(int month) {
    const List<String> months = [
      "", "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month];
  }
}
