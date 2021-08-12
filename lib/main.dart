import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Video demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _playIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (kIsWeb)
                ElevatedButton(
                    onPressed: () async {
                      // Go to html5.html on same host as index.html is served at
                      Uri uri = Uri.base;
                      String path = uri.path.replaceAll('index.html', '');
                      if (!path.endsWith('/')) path += '/';
                      path += 'html5.html';
                      uri = uri.replace(path: path, fragment: null);
                      if (await canLaunch(uri.toString())) {
                        launch(uri.toString());
                      }
                    },
                    child: Text('Go to HTML player')),
              Text('W'),

              // https://1251316161.vod2.myqcloud.com/007a649dvodcq1251316161/45d870155285890812491498931/24c2SGTVjrcA.mp4
              // https://vod4.buycar5.cn/20210512/mYvB1MkB/index.m3u8
              // https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8
              MyVideoPlayer(key: Key('video $_playIndex'), url: 'https://vod4.buycar5.cn/20210512/mYvB1MkB/index.m3u8'),
              Text('Video is CC-BY-NC-SA 2.5 from Svenskt Teckenspråkslexikon'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: () {
          setState(() {
            this._playIndex += 1;
          });
        },
      ),
    );
  }
}

class MyVideoPlayer extends StatefulWidget {
  final String url;

  const MyVideoPlayer({Key? key, required this.url}) : super(key: key);

  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    _initController();
    super.initState();
  }

  void _initController() async {
    _controller = VideoPlayerController.network(widget.url);
    await _controller.initialize();
    _controller.setVolume(0);

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      errorBuilder: (context, st) {
        print('chewie controller load error: $st');
        return Icon(
          Icons.mood,
          size: 64,
          color: Colors.white,
        );
      },
    );

    setState(() {
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.isInitialized ? _controller.value.aspectRatio : 16 / 9,
      child: _controller.value.isInitialized
          // ? VideoPlayer(_controller)
          ? Chewie(controller: _chewieController)
          : Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
