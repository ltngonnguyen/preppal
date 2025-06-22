import 'package:flutter/material.dart';
import 'package:preppal/utils/simple_logger.dart';

class LogViewerScreen extends StatelessWidget {
  const LogViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              SimpleLogger.clear();
            },
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: SimpleLogger.logStream,
        initialData: SimpleLogger.messages, // Show current logs immediately
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logs yet.'));
          }
          final logs = snapshot.data!;
          return ListView.builder(
            reverse: true, // Show newest logs at the bottom and auto-scroll
            itemCount: logs.length,
            itemBuilder: (context, index) {
              // Displaying in reverse order from the list for newest at bottom
              final logEntry = logs[logs.length - 1 - index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Text(
                  logEntry,
                  style: const TextStyle(fontSize: 10.0, fontFamily: 'monospace'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}