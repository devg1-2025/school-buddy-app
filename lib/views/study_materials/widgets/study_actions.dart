import 'package:flutter/material.dart';
import '../../../../models/study_file_model.dart';

class NotesBottomSheet extends StatelessWidget {
  final StudyFileModel file;
  const NotesBottomSheet({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📝 Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (file.notes.isEmpty)
              const Text('No notes yet.')
            else
              ...file.notes.map((n) => ListTile(
                    title: Text(n['text']),
                    subtitle: Text(n['date']),
                  )),
            const Divider(height: 32),
            const Text('⭐ Key Points',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (file.keyPoints.isEmpty)
              const Text('No key points yet.')
            else
              ...file.keyPoints
                  .map((kp) => ListTile(
                        leading: const Icon(Icons.star, color: Colors.amber),
                        title: Text(kp),
                      ))
                  ,
          ],
        ),
      ),
    );
  }
}
