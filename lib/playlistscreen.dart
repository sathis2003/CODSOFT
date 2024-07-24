import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'song.dart';

class PlaylistScreen extends StatelessWidget {
  final Map<String, List<Map<String, String>>> playlists;
  final AudioPlayer audioPlayer;
  final Function(String, int) playFromPlaylist;

  const PlaylistScreen({
    Key? key,
    required this.playlists,
    required this.audioPlayer,
    required this.playFromPlaylist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playlists"),
      ),
      body: ListView(
        children: playlists.entries.map((entry) {
          String playlistName = entry.key;
          List<Map<String, String>> playlist = entry.value;

          return ExpansionTile(
            title: Text(playlistName),
            children: playlist.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, String> song = entry.value;

              return ListTile(
                leading: Icon(Icons.music_note, color: Colors.deepOrange),
                title: Text(song["title"]!),
                subtitle: Text(song["artist"]!),
                trailing: IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    playFromPlaylist(playlistName, index);
                  },
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
