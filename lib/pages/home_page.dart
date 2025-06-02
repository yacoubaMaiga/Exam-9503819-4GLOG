import 'dart:convert';

import 'package:exam/widgets/film_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Film> _films = [];
  final List<String> _type = ['Film', 'Série'];

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  Future<void> _saveFilms() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_films.map((e) => e.toJson()).toList());
    await prefs.setString('films', encoded);
  }

  Future<void> _loadFilms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString('films');
    if (encoded != null) {
      final List decoded = jsonDecode(encoded);
      setState(() {
        _films.clear();
        _films.addAll(decoded.map((e) => Film.fromJson(e)));
      });
    }
  }

  void _addFilm() {
    final titreController = TextEditingController();
    final typeController = TextEditingController();
    final descController = TextEditingController();
    final statutController = false;
    final noteController = TextEditingController();
    String typeSelectionne = _type[0];

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text('Ajouter un Film / Série'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titreController,
                          decoration: const InputDecoration(labelText: 'Titre'),
                        ),
                        DropdownButtonFormField<String>(
                          value: typeSelectionne,
                          items:
                              _type
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              typeSelectionne = value!;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'Type'),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Marquer comme vu'),
                            Checkbox(value: false, onChanged: (value) {}),
                          ],
                        ),
                        TextField(
                          controller: noteController,
                          decoration: const InputDecoration(labelText: 'Note'),
                        ),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description (facultatif)',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 209, 39, 27),
                      ),
                      onPressed: () {
                        final titre = titreController.text.trim();
                        final type = typeController.text;
                        final desc = descController.text.trim();
                        final note = noteController.text;
                        // final statut = statutController.value;
                        setState(() {
                          _films.add(
                            Film(titre, type, desc, false, note as double),
                          );
                        });
                        _saveFilms();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Ajouter',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _removeFilm(int index) {
    setState(() {
      _films.removeAt(index);
    });
    _saveFilms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromARGB(255, 209, 39, 27),
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF3F5FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 209, 39, 27),
        onPressed: _addFilm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            _films.isEmpty
                ? const Center(child: Text('Aucun Film/Série enregistré.'))
                : Builder(
                  builder: (context) {
                    final sortedFilm = List<Film>.from(_films)
                      ..sort((a, b) => b.titre.compareTo(a.titre));
                    return ListView.separated(
                      itemCount: sortedFilm.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final film = sortedFilm[index];
                        return InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                film.titre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(film.type),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _removeFilm(_films.indexOf(film)),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class Film {
  final String titre;
  final String type;
  final bool statut;
  final double note;
  final String description;
  Film(this.titre, this.type, this.description, this.statut, this.note);

  Map<String, dynamic> toJson() => {
    'titre': titre,
    'type': type,
    'statut': statut ? 1 : 0,
    'note': note,
    'description': description,
  };

  factory Film.fromJson(Map<String, dynamic> json) => Film(
    json['titre'],
    json['type'],
    json['description'],
    json['statut'],
    json['note'],
  );
}
