import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F2P Games Database',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const GameListScreen(),
    );
  }
}

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  List<dynamic> games = [];
  List<dynamic> filteredGames = [];
  String searchQuery = '';
  String selectedGenre = 'All';
  String selectedPlatform = 'All';
  String selectedDate = 'All';

  final genres = ['All', 'MMORPG', 'Shooter', 'MOBA', 'Card Game', 'Racing', 'Strategy', 'Sports', 'Social', 'Action RPG', 'Battle Royale', 'ARPG', 'Fighting'];
  final platforms = ['All', 'PC (Windows)', 'Browser'];
  final dates = ['All', '2024', '2023', '2022', '2021', '2020', '2019', '2018', '2017', '2016', '2015', '2014', '2013', '2012', '2011', '2010', '2009', '2008', '2007', '2006', '2005', '2004', '2003', '2002', '2001'];

  @override
  void initState() {
    super.initState();
    fetchGames();
  }

  Future<void> fetchGames() async {
    const url = 'https://free-to-play-games-database.p.rapidapi.com/api/games';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-rapidapi-host': 'free-to-play-games-database.p.rapidapi.com',
          'x-rapidapi-key': 'cb0c0ee228msh0ca851f34039cf5p18ba64jsn029142110be2',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          games = data;
          filteredGames = data;
        });
      } else {
        throw Exception('Failed to load games');
      }
    } catch (error) {
      throw Exception('Error fetching games: $error');
    }
  }

  void filterGames() {
    setState(() {
      filteredGames = games.where((game) {
        final matchesSearch = game['title'].toLowerCase().contains(searchQuery.toLowerCase());
        final matchesGenre = selectedGenre == 'All' || game['genre'].contains(selectedGenre);
        final matchesPlatform = selectedPlatform == 'All' || game['platform'].contains(selectedPlatform);
        final matchesDate = selectedDate == 'All' || game['release_date'].startsWith(selectedDate);
        return matchesSearch && matchesGenre && matchesPlatform && matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F2P Games Database'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search games...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  filterGames();
                });
              },
            ),
          ),
          // Filter Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Genre Dropdown
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedGenre,
                    items: genres.map((String genre) {
                      return DropdownMenuItem<String>(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGenre = value!;
                        filterGames();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10.0),
                // Platform Dropdown
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedPlatform,
                    items: platforms.map((String platform) {
                      return DropdownMenuItem<String>(
                        value: platform,
                        child: Text(platform),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPlatform = value!;
                        filterGames();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10.0),
                // Release Date Dropdown
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedDate,
                    items: dates.map((String date) {
                      return DropdownMenuItem<String>(
                        value: date,
                        child: Text(date),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDate = value!;
                        filterGames();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Display number of tracked games
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Number of tracked games: ${filteredGames.length}',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: filteredGames.isEmpty
                ? const Center(child: Text('No games found.'))
                : ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: filteredGames.length,
              itemBuilder: (context, index) {
                final game = filteredGames[index];

                return Card(
                  elevation: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.blueGrey.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        // Thumbnail on the left
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            game['thumbnail'],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        // Game details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                game['title'],
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              // Genre
                              Row(
                                children: [
                                  const Icon(Icons.videogame_asset,
                                      color: Colors.lightBlueAccent, size: 18),
                                  const SizedBox(width: 5.0),
                                  Text(game['genre'],
                                      style: const TextStyle(
                                          color: Colors.lightBlueAccent)),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              // Platform
                              Row(
                                children: [
                                  const Icon(Icons.computer,
                                      color: Colors.grey, size: 18),
                                  const SizedBox(width: 5.0),
                                  Text(game['platform'],
                                      style: TextStyle(
                                          color: Colors.grey[400])),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              // Publisher & Developer
                              Row(
                                children: [
                                  const Icon(Icons.people,
                                      color: Colors.lightBlueAccent, size: 18),
                                  const SizedBox(width: 5.0),
                                  Text('Publisher: ${game['publisher']}',
                                      style: TextStyle(
                                          color: Colors.grey[400])),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  const Icon(Icons.build,
                                      color: Colors.lightBlueAccent, size: 18),
                                  const SizedBox(width: 5.0),
                                  Text('Developer: ${game['developer']}',
                                      style: TextStyle(
                                          color: Colors.grey[400])),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              // Release Date
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.lightBlueAccent, size: 18),
                                  const SizedBox(width: 5.0),
                                  Text('Release Date: ${game['release_date']}',
                                      style: TextStyle(
                                          color: Colors.grey[400])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Play Now Button
                        ElevatedButton(
                          onPressed: () async {
                            final url = game['game_url'];
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent, // button color
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text('Play Now',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: 60.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        const url = 'https://maxcomperatore.com/';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Made by ',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Max Comperatore',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Icon(
                    Icons.open_in_new,
                    color: Colors.blueAccent,
                    size: 18.0,
                  ),
                ],
              ),
            ),
          ),


        ],
    ),
    );
  }
}
