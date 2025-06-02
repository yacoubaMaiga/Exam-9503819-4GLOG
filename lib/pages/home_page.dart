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
  final List<Film> _Films = [];
  final List<String> _type = ['Film', 'Série'];

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  Future<void> _saveFilms() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_Films.map((e) => e.toJson()).toList());
    await prefs.setString('Films', encoded);
  }

  Future<void> _loadFilms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString('Films');
    if (encoded != null) {
      final List decoded = jsonDecode(encoded);
      setState(() {
        _Films.clear();
        _Films.addAll(decoded.map((e) => Film.fromJson(e)));
      });
    }
  }

  void _addFilm() {
    final titreController = TextEditingController();
    final typeController = TextEditingController();
    final descController = TextEditingController();
    final statutController = TextEditingController();
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
                          children: [
                            Text('Statut'),
                            Checkbox(value: false, onChanged: (value) {}),
                          ],
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
                      onPressed: () {
                        final titre = titreController.text.trim();
                        final type = typeController.text;
                        final desc = descController.text.trim();
                        final note = noteController.value;
                        // final statut = statutController.value;
                        if (titre.isEmpty || type.isEmpty) return;
                        setState(() {
                          _Films.add(
                            Film(titre, type, desc, false, note as double),
                          );
                        });
                        _saveFilms();
                        Navigator.pop(context);
                      },
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showFilmDetails(Film Film) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(Film.titre),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Catégorie : ${Film.note}'),
                const SizedBox(height: 8),
                // Text(
                //   'statut : ${Film.statut.day}/${Film.statut.month}/${Film.statut.year}',
                // ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Type'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                Text(
                  'Description :\n${Film.description.isEmpty ? "Aucune" : Film.description}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  void _removeFilm(int index) {
    setState(() {
      _Films.removeAt(index);
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
        onPressed: _addFilm,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(children: [FilmCard()]),
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
