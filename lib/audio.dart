import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicplayer/songs.dart';
import 'playlistscreen.dart';
import 'song.dart';
import 'songs.dart';

class AudioUi extends StatefulWidget {
  const AudioUi({super.key});

  @override
  State<AudioUi> createState() => _AudioUiState();
}

class _AudioUiState extends State<AudioUi> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Map<String, String>> _songs = [
    {
      "asset": "assets/songs/Adangaatha Asuran.mp3",
      "title": "Adangaatha Asuran",
      "artist": "A.R.Rahman, Dhanush"
    },
    {
      "asset": "assets/songs/Odatha da Odatha da.mp3",
      "title": "Odatha da Odatha da",
      "artist": "A.R.Rahman, ADK"
    },
    {
      "asset": "assets/songs/Oh Raaya.mp3",
      "title": "Oh Raaya",
      "artist": "A.R.Rahman, Ganavya Doraiswamy"
    },
    {
      "asset": "assets/songs/Fire-Song-MassTamilan.dev.mp3",
      "title": "Fire-Song-MassTamilan.dev",
      "artist": "V.M. Mahalingam, Senthil Ganesh, Shenbagaraj Ganesalingam, Deepthi Suresh, Devi Sri Prasad"
    },
    {
      "asset": "assets/songs/Coolie Disco.mp3",
      "title": "Coolie Disco",
      "artist": "Anirudh Ravichander"
    },
  ];

  Map<String, List<Map<String, String>>> _playlists = {};

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _createPlaylist() {
    final TextEditingController playlistNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: playlistNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter playlist name",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                String playlistName = playlistNameController.text;
                if (playlistName.isNotEmpty) {
                  setState(() {
                    _playlists[playlistName] = [];
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Playlist name cannot be empty')),
                  );
                }
              },
              child: Text('Create', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _addToPlaylist(String playlistName, Map<String, String> song) {
    if (_playlists.containsKey(playlistName)) {
      setState(() {
        if (!_playlists[playlistName]!.contains(song)) {
          _playlists[playlistName]!.add(song);
        }
      });
    }
  }

  void _showAddToPlaylistDialog(Map<String, String> song) {
    if (_playlists.isEmpty) {
      _showCreatePlaylistPrompt();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add to Playlist'),
            content: DropdownButton<String>(
              isExpanded: true,
              items: _playlists.keys.map((playlistName) {
                return DropdownMenuItem<String>(
                  value: playlistName,
                  child: Text(playlistName),
                );
              }).toList(),
              onChanged: (selectedPlaylist) {
                if (selectedPlaylist != null) {
                  _addToPlaylist(selectedPlaylist, song);
                  Navigator.of(context).pop();
                }
              },
              hint: Text('Select Playlist'),
            ),
          );
        },
      );
    }
  }

  void _showCreatePlaylistPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Playlists Found'),
          content: Text('You need to create a playlist first.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createPlaylist();
              },
              child: Text('Create Playlist'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _playFromPlaylist(String playlistName, int index) {
    if (_playlists.containsKey(playlistName)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Song(
            songModel: Songmodel(
              id: index,
              uri: _playlists[playlistName]![index]["asset"]!,
              displayNameWOExt: _playlists[playlistName]![index]["title"]!,
              artist: _playlists[playlistName]![index]["artist"]!,
            ),
            audioPlayer: _audioPlayer,
            playlist: _playlists[playlistName]!,
            currentIndex: index,
          ),
        ),
      ).then((_) {
        setState(() {}); // Refresh the UI after returning from Song screen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.music_note),
        title: Text("Music Player"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_play),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistScreen(
                    playlists: _playlists,
                    audioPlayer: _audioPlayer,
                    playFromPlaylist: _playFromPlaylist,
                  ),
                ),
              ).then((_) {
                setState(() {}); // Refresh the UI after returning from PlaylistScreen
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          var song = _songs[index];
          return Card(
            elevation: 5,
            child: ListTile(
              leading: Icon(Icons.music_note, color: Colors.deepOrange),
              title: Text(song["title"]!),
              subtitle: Text(song["artist"]!),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  _showAddToPlaylistDialog(song);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Song(
                      songModel: Songmodel(
                        id: index,
                        uri: song["asset"]!,
                        displayNameWOExt: song["title"]!,
                        artist: song["artist"]!,
                      ),
                      audioPlayer: _audioPlayer,
                      playlist: _songs,
                      currentIndex: index,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlaylist,
        child: Icon(Icons.add),
      ),
    );
  }
}
