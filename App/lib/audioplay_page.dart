import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:galaxtune/store.dart';
import 'colors.dart' as color;
import 'package:http/http.dart' as http;
import 'api.dart';

class AudioPlayPage extends StatefulWidget {
  const AudioPlayPage({super.key});

  @override
  State<AudioPlayPage> createState() => _AudioPlayPageState();
}

class _AudioPlayPageState extends State<AudioPlayPage> {
  late AudioPlayer audioPlayer;
  List booksData = Get.arguments[0];
  int index = Get.arguments[1];
  List recommendBooks = Get.arguments[2];
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool isPlaying = false;
  bool isRepeat = false;
  bool isLike = false;
  Color repeatColor = Colors.black;
  final List<IconData> _icons = [
    Icons.play_circle_fill,
    Icons.pause_circle_filled,
  ];
  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });
  audioPlayer.setSourceUrl(_streamUrlForIndex(index));
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _position = const Duration(seconds: 0);
        isPlaying = false;
        isRepeat = false;
        if (isRepeat) {
          isPlaying = true;
        } else {
          isPlaying = false;
          isRepeat = false;
        }
      });
    });
    isLike = booksData[index]["likes"].contains(box.read("user")["_id"]);
    super.initState();
  }

  String _streamUrlForIndex(int i) {
    try {
      final raw = booksData[i]["audio"].toString();
      if (raw.isEmpty) return '';
      final uri = Uri.tryParse(raw);
      final filename = (uri != null && uri.pathSegments.isNotEmpty)
          ? uri.pathSegments.last
          : raw.split('/').last;
      return Api.streamByFilename(filename);
    } catch (_) {
      return '';
    }
  }

  void handleLike() async {
    List likes = booksData[index]["likes"];
    if (isLike) {
      likes.remove(box.read("user")["_id"]);
      setState(() {
        isLike = false;
      });
    } else {
      likes.add(box.read("user")["_id"]);
      setState(() {
        isLike = true;
      });
    }
  final url = Api.like(booksData[index]["_id"]);
    final accessToken = box.read("token")["access_token"];
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      },
      body: jsonEncode(<String, List>{
        "likes": likes,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("Success");
    } else {
      Get.snackbar("Something Wrong !", "",
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(
            Icons.face,
            size: 30,
            color: Colors.white,
          ),
          backgroundColor: color.AppColor.gradientSecond,
          colorText: Colors.white,
          messageText: const Text(
            "An error occurred, please try again later.",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ));
    }
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: color.AppColor.audioBluishBackground,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight / 3,
            child: Container(
              color: color.AppColor.audioBlueBackground,
            ),
          ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Get.back();
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  ),
                ],
                backgroundColor: Colors.transparent,
                elevation: 0,
              )),
          Positioned(
              left: 0,
              right: 0,
              top: screenHeight * 0.215,
              height: screenHeight * 0.36,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white,
                ),
                child: Column(children: [
                  SizedBox(
                    height: screenHeight * 0.1,
                  ),
                  Text(
                    booksData[index]["title"],
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    booksData[index]["authors"],
                    style: const TextStyle(fontSize: 20),
                  ),
                  Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_position.toString().split(".")[0],
                                  style: const TextStyle(fontSize: 16)),
                              Text(_duration.toString().split(".")[0],
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          )),
                      slider(),
                      loadAsset(),
                    ],
                  )
                ]),
              )),
          Positioned(
            top: screenHeight * 0.12,
            left: (screenWidth - 140) / 2,
            right: (screenWidth - 140) / 2,
            height: screenHeight * 0.18,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
                color: color.AppColor.audioGreyBackground,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                    color: color.AppColor.audioGreyBackground,
                  ),
                  child: Builder(builder: (ctx) {
                    final thumb = Api.normalizeUrl(booksData[index]["thumbnail"]);
                    if (thumb.isEmpty) return const SizedBox.shrink();
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: NetworkImage(thumb), fit: BoxFit.fill),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.35,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: const Text("Recommend Books",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: screenHeight * 0.1,
            child: SizedBox(
              height: 180,
              child: Stack(children: [
                Positioned(
                  top: 0,
                  left: -240,
                  right: 0,
                  child: SizedBox(
                      height: 180,
                      child: PageView.builder(
                          controller: PageController(viewportFraction: 0.2),
                          // ignore: unnecessary_null_comparison
                          itemCount: recommendBooks == null
                              ? 0
                              : recommendBooks.length,
                          itemBuilder: (_, i) {
                            return InkWell(
                              onTap: () async {
                                if (booksData[index]["_id"] ==
                                    recommendBooks[i]["_id"]) {
                                  return;
                                }
                                // Stop current track and clear repeat
                                await audioPlayer.stop();
                                if (isRepeat) {
                                  await audioPlayer.setReleaseMode(ReleaseMode.release);
                                  repeatColor = Colors.black;
                                  isRepeat = false;
                                }
                                booksData = recommendBooks;
                                index = i;
                                _position = const Duration(seconds: 0);
                                final newUrl = Api.streamByFilename(booksData[index]["audio"].split("/").last);
                                await audioPlayer.play(UrlSource(newUrl));
                                setState(() {
                                  isPlaying = true;
                                });
                              },
                              child: Container(
                                height: 180,
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                                      Api.normalizeUrl(recommendBooks[i]["thumbnail"])),
                                        fit: BoxFit.fill)),
                              ),
                            );
                          })),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget btnStart() {
    return IconButton(
      padding: const EdgeInsets.only(bottom: 10),
      icon: isPlaying == false
          ? Icon(
              _icons[0],
              size: 50,
              color: Colors.blue,
            )
          : Icon(_icons[1], size: 50, color: Colors.blue),
      onPressed: () async {
        if (isPlaying == false) {
          final url = _streamUrlForIndex(index);
          await audioPlayer.play(UrlSource(url));
          setState(() {
            isPlaying = true;
          });
        } else {
          await audioPlayer.pause();
          setState(() {
            isPlaying = false;
          });
        }
      },
    );
  }

  Widget loadAsset() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          btnLike(),
          btnPrevious(),
          btnStart(),
          btnNext(),
          btnRepeat(),
        ]);
  }

  Widget slider() {
    return Slider(
      activeColor: Colors.blue,
      inactiveColor: color.AppColor.audioBluishBackground,
      value: _position.inSeconds.toDouble(),
      min: 0.0,
      max: _duration.inSeconds.toDouble(),
      onChanged: (double value) {
        setState(() {
          changeToSecond(value.toInt());
          value = value;
        });
      },
    );
  }

  void changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
    if (!isPlaying) {
      // If not playing, (re)start current track at new position
      final url = _streamUrlForIndex(index);
      audioPlayer.play(UrlSource(url));
      setState(() {
        isPlaying = true;
      });
    }
  }

  Widget btnNext() {
    return IconButton(
        icon: const ImageIcon(AssetImage("assets/forward.png"),
            size: 15, color: Colors.black),
        onPressed: () async {
          // Stop current playback cleanly to avoid overlap
          await audioPlayer.stop();
          if (isRepeat) {
            await audioPlayer.setReleaseMode(ReleaseMode.release);
            repeatColor = Colors.black;
            isRepeat = false;
          }
          // Advance index
          if (booksData.length > index + 1) {
            index++;
          } else {
            index = 0;
          }
          final newUrl = _streamUrlForIndex(index);
          _position = const Duration(seconds: 0);
          isLike = booksData[index]["likes"].contains(box.read("user")["_id"]);
          // Play new source
          await audioPlayer.play(UrlSource(newUrl));
          setState(() {
            isPlaying = true;
          });
        });
  }

  Widget btnPrevious() {
    return IconButton(
        icon: const ImageIcon(AssetImage("assets/backword.png"),
            size: 15, color: Colors.black),
        onPressed: () async {
          await audioPlayer.stop();
          if (isRepeat) {
            await audioPlayer.setReleaseMode(ReleaseMode.release);
            repeatColor = Colors.black;
            isRepeat = false;
          }
          if (index > 0) {
            index--;
          } else {
            index = booksData.length - 1;
          }
          final newUrl = _streamUrlForIndex(index);
          _position = const Duration(seconds: 0);
          isLike = booksData[index]["likes"].contains(box.read("user")["_id"]);
          await audioPlayer.play(UrlSource(newUrl));
          setState(() {
            isPlaying = true;
          });
        });
  }

  Widget btnLike() {
    return IconButton(
      icon: ImageIcon(
        AssetImage(isLike ? "assets/liked.png" : "assets/like.png"),
        size: 25,
        color: isLike ? Colors.blue : Colors.black,
      ),
      onPressed: () {
        setState(() {
          handleLike();
        });
      },
    );
  }

  Widget btnRepeat() {
    return IconButton(
        icon: ImageIcon(
          const AssetImage("assets/repeat.png"),
          size: 15,
          color: repeatColor,
        ),
        onPressed: () {
          if (isRepeat == false) {
            audioPlayer.setReleaseMode(ReleaseMode.loop);
            setState(() {
              isRepeat = true;
              repeatColor = Colors.blue;
            });
          } else {
            audioPlayer.setReleaseMode(ReleaseMode.release);
            repeatColor = Colors.black;
            isRepeat = false;
          }
        });
  }
}
