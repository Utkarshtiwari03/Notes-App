import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/database/notes_database.dart';
import 'package:notes_app/screens/note_card.dart';
import 'package:notes_app/screens/notes_dialog.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NotesScreenState();
  }
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];

  //fetch notes from db
  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final fetchedNotes = await NotesDatabase.instance.getNotes();

    setState(() {
      notes = fetchedNotes;
    });
  }

  final List<Color> noteColors =[
  const Color(0xFFF3E5F5),// Light
  const Color(0xFFFFF3E0), // Light
  const Color(0xFFE1F5FE), // Light
  const Color(0xFFFCE4EC), // Light R
  const Color(0xFF89CFF0), // Baby Bl
  const Color(0xFFFFABAB), // Light R
  const Color(0xFFB2F9FC), // Light C
  const Color(0xFFFFE4B5), // Moccasin
  const Color(0xFFFFD59A), // Light Pa
  const Color(0xFF98FB98), // Pale Gre
  const Color(0xFFFF0700), // Gold
  const Color(0xCAFEEEE), // Pale Turq
  const Color(0xFFFFB6C1), // Light Pim
  const Color(0xFFFAFAD2), // Light Gol
  const Color(0xFFD30303)
  ];

  void showNoteDialog(
      {int? id, String? title, String? content, int colorIndex = 0})
  {
    showDialog(context: context,
    builder: (dialogContext){
      return NoteDialog(
        colorIndex: colorIndex,
        noteColors: noteColors,
        noteId: id,
        title: title,
        content: content,
        onNoteSaved: (newTitle,newDescription,currentDate,selectedColorIndex) async{
          if(id==null){
            await NotesDatabase.instance.addNote(newTitle, newDescription, currentDate, selectedColorIndex);
          }else{
            await NotesDatabase.instance.updateNote(newTitle, newDescription, currentDate, selectedColorIndex, id);
          }
          fetchNotes();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          "Notes",
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),
      floatingActionButton: FloatingActionButton(
          onPressed:() async{
            showNoteDialog();
          },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add,color: Colors.black),
      ),

      body: notes.isEmpty
      ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notes_outlined,
              size:80,
              color: Colors.grey
            ),
            SizedBox(height: 20),
            Text(
              'No Notes Found',
              style:TextStyle(
                fontSize: 20,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500
              )
            )
          ],
        ),
      )
          : Padding(
            padding: EdgeInsets.all(16),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note= notes[index];

              return NoteCard(
                  note: note,
                  onDelete: () async{
                    await NotesDatabase.instance.deleteNote(note['id']);
                    fetchNotes();
                  },
                  onTap:(){
                    showNoteDialog(
                      id:note['id'],
                      title:note['title'],
                      content: note['description'],
                      colorIndex: note['color']
                    );
                  },
                  noteColors: noteColors
              );
            },
        ),
          )
    );
  }
}
