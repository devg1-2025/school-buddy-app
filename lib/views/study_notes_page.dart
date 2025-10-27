import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/study_notes_viewmodel.dart';
import '../../models/file_notes_model.dart';

class StudyNotesPage extends StatefulWidget {
  const StudyNotesPage({super.key});

  @override
  State<StudyNotesPage> createState() => _StudyNotesPageState();
}

class _StudyNotesPageState extends State<StudyNotesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<StudyNotesViewModel>().loadAllNotes());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudyNotesViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Study Notes"),
        backgroundColor: const Color(0xFF073B4C),
        actions: [
          Switch(
            value: vm.showKeyPointsOnly,
            onChanged: vm.toggleKeyPointFilter,
            activeThumbColor: Colors.amber,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Center(child: Text("Key Points")),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: vm.search,
            ),
          ),
          Expanded(
            child: vm.filteredNotes.isEmpty
                ? const Center(child: Text("No notes found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: vm.filteredNotes.length,
                    itemBuilder: (_, i) {
                      final note = vm.filteredNotes[i];
                      return _buildNoteCard(note);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(FileNote note) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: note.isKeyPoint ? Colors.amber[50] : Colors.white,
      child: ListTile(
        leading: Icon(
          note.isKeyPoint ? Icons.star : Icons.note_alt_outlined,
          color: note.isKeyPoint ? Colors.amber : Colors.blueGrey,
        ),
        title: Text(note.text),
        subtitle: Text(
          "File: ${note.fileName}\n${note.createdAt.toLocal()}".split('.')[0],
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
