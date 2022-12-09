import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project/Screens/Authorization/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../../Utils/CheckConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/offline_ui.dart';
import '../../../Utils/url.dart';

class SettingOutVideo extends StatefulWidget {
  const SettingOutVideo({Key? key}) : super(key: key);

  @override
  State<SettingOutVideo> createState() => _SettingOutVideoState();
}

class _SettingOutVideoState extends State<SettingOutVideo> {
  late String videoUrl;

  VideoPlayerController? controller;

  bool isNotAvailable = false;
  bool loader = false;
  bool checkConnection = false;

  checkConnectivity() async {
    if (await connection()) {
      loadData();
      setState(() {
        checkConnection = false;
      });
    } else {
      setState(() {
        checkConnection = true;
      });
    }
  }

  loadData() async {
    setState(() {
      loader = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString("userToken");

    try {
      http.Response response = await http.get(Uri.parse(settingOutVideoURL),
          headers: {"Authorization": "Bearer $userToken"});

      Map jsonData = jsonDecode(response.body);
      print(jsonData);

      if (jsonData['status'] == 1) {
        setState(() {
          loader = false;
          videoUrl = jsonData['data']['video'];
        });
        print(videoUrl);
        if (videoUrl.isNotEmpty) {
          loadVideoPlayer(videoUrl.toString());
        } else {
          setState(() {
            isNotAvailable = true;
          });
        }
      } else {
        setState(() {
          isNotAvailable = true;
          loader = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        loader = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something went wrong!")));
    }
  }

  loadVideoPlayer(String url) {
    setState(() {
      loader = true;
    });
    print(url);
    controller = VideoPlayerController.network(
      url,
      //"https://accountpos.shoaibkanwalacademy.com/Questionbook/public/uploads/video/1662469801.mp4",
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
      ),
      //formatHint: VideoFormat.other,
    );
    controller!.addListener(() {
    });
    controller!.initialize().then((value) {
    });

    setState((){
      loader=false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    checkConnectivity();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller!.pause();
    controller!.dispose();
    controller!.removeListener(() { });
  }

  @override
  Widget build(BuildContext context) {
    return checkConnection
        ? OfflineUI(function: checkConnectivity)
        : Scaffold(
            appBar: AppBar(
              title: const Text("Watching the video"),
              backgroundColor: kLight,
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  controller!.pause();
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios),
              ),
            ),
            body: controller == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: isNotAvailable
                        ? const Center(
                            child: Text("Video is not available"),
                          )
                        : Column(children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              height: MediaQuery.of(context).size.height * 0.6,
                              width: MediaQuery.of(context).size.width,
                              child: /*loader
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  :*/ VideoPlayer(controller!),
                            ),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.centerRight,
                                child: Text("${controller!.value.duration}")),
                            VideoProgressIndicator(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                controller!,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  backgroundColor: Colors.redAccent,
                                  playedColor: Colors.green,
                                  bufferedColor: Colors.purple,
                                )),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      if (controller!.value.isPlaying) {
                                        controller!.pause();
                                      } else {
                                        controller!.play();
                                      }

                                      setState(() {});
                                    },
                                    icon: Icon(controller!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow)),
                                IconButton(
                                    onPressed: () {
                                      controller!
                                          .seekTo(const Duration(seconds: 0));
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.stop))
                              ],
                            )
                          ]),
                  ),
          );
  }
}
