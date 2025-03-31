import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxCapacityController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _ageRatingController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _createEvent() async {
    final firestore = FirebaseFirestore.instance;
    final eventRef = firestore.collection("events").doc();
    final user = FirebaseAuth.instance.currentUser; // Get logged-in user

    await eventRef.set({
      "Event_ID": eventRef.id,
      "Title": _titleController.text,
      "Description": _descriptionController.text,
      "Start_D/T": _startDate != null ? Timestamp.fromDate(_startDate!) : null,
      "End_D/T": _endDate != null ? Timestamp.fromDate(_endDate!) : null,
      "Max_capacity": int.tryParse(_maxCapacityController.text) ?? 0,
      "Status": _statusController.text,
      "Budget": _budgetController.text,
      "Age_Rating": _ageRatingController.text,
      "createdBy": user?.email ?? "Unknown", // Store creator email
      "createdAt": Timestamp.now(), // Store event creation timestamp
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event Created Successfully")),
    );
    Navigator.pop(context);
  }

  Future<void> _pickDate(bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: _maxCapacityController, decoration: const InputDecoration(labelText: "Max Capacity")),
              TextField(controller: _statusController, decoration: const InputDecoration(labelText: "Status")),
              TextField(controller: _budgetController, decoration: const InputDecoration(labelText: "Budget")),
              TextField(controller: _ageRatingController, decoration: const InputDecoration(labelText: "Age Rating")),
              
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(_startDate == null ? "Pick Start Date" : "Start: ${_startDate.toString()}")),
                  IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(true)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text(_endDate == null ? "Pick End Date" : "End: ${_endDate.toString()}")),
                  IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(false)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _createEvent, child: const Text("Create Event")),
            ],
          ),
        ),
      ),
    );
  }
}
