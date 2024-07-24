// import 'dart:convert';
//
// import 'package:musicplayer/playlist.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class PlaylistService {
//   static const String _key = 'playlists';
//
//   Future<void> savePlaylists(List<Playlist> playlists) async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<Map<String, dynamic>> playlistMaps = playlists.map((p) => p.toMap()).toList();
//     await prefs.setString('$_key', playlistMaps.toString());
//   }
//
//   Future<List<Playlist>> loadPlaylists() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? jsonString = prefs.getString(_key);
//     if (jsonString != null) {
//       final List<dynamic> playlistMaps = List.from(json.decode(jsonString));
//       return playlistMaps.map((map) => Playlist.fromMap(Map<String, dynamic>.from(map))).toList();
//     }
//     return [];
//   }
// }
