import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicplayer/songs.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Song extends StatefulWidget {
  const Song({
    Key? key,
    required this.songModel,
    required this.audioPlayer,
    required this.playlist,
    required this.currentIndex,
  }) : super(key: key);

  final Songmodel songModel;
  final AudioPlayer audioPlayer;
  final List<Map<String, String>> playlist;
  final int currentIndex;

  @override
  _SongState createState() => _SongState();
}

class _SongState extends State<Song> {
  bool isPlaying = false;
  bool isShuffling = false;
  Duration duration = const Duration();
  Duration position = const Duration();
  List<Map<String, String>> shuffledPlaylist = [];

  @override
  void initState() {
    super.initState();
    shuffledPlaylist = List.from(widget.playlist);
    playSong(widget.currentIndex);
  }

  Future<void> playSong(int index) async {
    try {
      final assetPath = shuffledPlaylist[index]["asset"];
      if (assetPath != null) {
        await widget.audioPlayer.setAudioSource(
          AudioSource.asset(assetPath),
        );
        widget.audioPlayer.play();
        setState(() {
          isPlaying = true;
        });

        widget.audioPlayer.durationStream.listen((event) {
          setState(() {
            duration = event ?? const Duration();
          });
        });

        widget.audioPlayer.positionStream.listen((event) {
          setState(() {
            position = event;
          });
        });
      } else {
        print("Asset path is null");
      }
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  void seekToSeconds(double seconds) {
    final position = Duration(seconds: seconds.toInt());
    widget.audioPlayer.seek(position);
  }

  void shufflePlaylist() {
    setState(() {
      shuffledPlaylist.shuffle();
      isShuffling = true;
    });
  }

  void skipToNext() {
    int nextIndex;
    if (isShuffling) {
      nextIndex = shuffledPlaylist.indexOf(
        widget.playlist[widget.currentIndex],
      );
      nextIndex = (nextIndex + 1) % shuffledPlaylist.length;
    } else {
      nextIndex = (widget.currentIndex + 1) % widget.playlist.length;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Song(
          songModel: Songmodel(
            id: nextIndex,
            uri: shuffledPlaylist[nextIndex]["asset"]!,
            displayNameWOExt: shuffledPlaylist[nextIndex]["title"]!,
            artist: shuffledPlaylist[nextIndex]["artist"] ?? "Unknown Artist",
          ),
          audioPlayer: widget.audioPlayer,
          playlist: widget.playlist,
          currentIndex: nextIndex,
        ),
      ),
    );
  }

  void skipToPrevious() {
    int prevIndex;
    if (isShuffling) {
      prevIndex = shuffledPlaylist.indexOf(
        widget.playlist[widget.currentIndex],
      );
      prevIndex = (prevIndex - 1 + shuffledPlaylist.length) % shuffledPlaylist.length;
    } else {
      prevIndex = (widget.currentIndex - 1 + widget.playlist.length) % widget.playlist.length;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Song(
          songModel: Songmodel(
            id: prevIndex,
            uri: shuffledPlaylist[prevIndex]["asset"]!,
            displayNameWOExt: shuffledPlaylist[prevIndex]["title"]!,
            artist: shuffledPlaylist[prevIndex]["artist"] ?? "Unknown Artist",
          ),
          audioPlayer: widget.audioPlayer,
          playlist: widget.playlist,
          currentIndex: prevIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100,
                child: Center(
                  child: QueryArtworkWidget(
                    id: widget.songModel.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: Icon(Icons.music_note, size: 80),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.songModel.displayNameWOExt,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.songModel.artist ?? "Unknown Artist",
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(position.toString().split('.')[0]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: position.inSeconds.toDouble(),
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        seekToSeconds(value);
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(duration.toString().split('.')[0])
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    onPressed: skipToPrevious,
                  ),
                  IconButton(
                    icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        if (isPlaying) {
                          widget.audioPlayer.pause();
                        } else {
                          widget.audioPlayer.play();
                        }
                        isPlaying = !isPlaying;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: skipToNext,
                  ),
                  IconButton(
                    icon: Icon(isShuffling ? Icons.shuffle : Icons.shuffle_outlined),
                    onPressed: () {
                      setState(() {
                        if (isShuffling) {
                          widget.audioPlayer.setShuffleModeEnabled(false);
                          isShuffling = false;
                        } else {
                          shufflePlaylist();
                          widget.audioPlayer.setShuffleModeEnabled(true);
                        }
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
