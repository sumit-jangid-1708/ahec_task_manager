import 'package:flutter/material.dart';

class ClientCard extends StatelessWidget {
  final String number;
  final String name;
  final String date;
  final String email;
  final String mobile;
  final String status;
  final String university;
  final VoidCallback onEdit;

  const ClientCard({
    super.key,
    required this.number,
    required this.name,
    required this.date,
    required this.email,
    required this.mobile,
    required this.status,
    required this.onEdit,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
color: Colors.white,
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ------- Row 1 : Number | Name | Date -------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(number, style: const TextStyle(fontSize: 11)),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(date, style: const TextStyle(fontSize: 11)),
              ],
            ),

            const SizedBox(height: 10),

            /// ------- Row 2 : Email | Mobile -------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  mobile,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),

            Text(university, style: const TextStyle(fontSize: 12), ),

            const SizedBox(height: 12),

            /// ------- Row 3 : Status Box + Edit Button -------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Box
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Edit Button
                ElevatedButton.icon(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F63F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                  label: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
