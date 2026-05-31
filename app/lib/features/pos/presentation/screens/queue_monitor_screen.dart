import 'package:flutter/material.dart';

class QueueMonitorScreen extends StatelessWidget {
  const QueueMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor Dapur & Antrean'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _QueueColumn(title: 'Menunggu (Waiting)', color: Colors.orange, items: ['A-001', 'A-002', 'A-004'])),
            const SizedBox(width: 16),
            Expanded(child: _QueueColumn(title: 'Sedang Dimasak', color: Colors.blue, items: ['A-003'])),
            const SizedBox(width: 16),
            Expanded(child: _QueueColumn(title: 'Siap Disajikan', color: Colors.green, items: ['A-000'])),
          ],
        ),
      ),
    );
  }
}

class _QueueColumn extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> items;

  const _QueueColumn({required this.title, required this.color, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: color.withOpacity(0.2),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18), textAlign: TextAlign.center),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(items[index], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    subtitle: const Text('2 Item (Kopi Senja, Roti)'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Geser status antrean ke tahap selanjutnya
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
