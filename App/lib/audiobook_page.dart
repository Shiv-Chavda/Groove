import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:galaxtune/profile_page.dart';
import 'package:get/get.dart';
import 'package:galaxtune/search.dart';
import 'audioplay_page.dart';
import 'colors.dart' as color;
import 'package:http/http.dart' as http;
import 'api.dart';
import 'store.dart';

class AudioBookPage extends StatefulWidget {
  const AudioBookPage({super.key});

  @override
  State<AudioBookPage> createState() => _AudioBookPageState();
}

class _AudioBookPageState extends State<AudioBookPage> {
  List popularBooks = [];
  List books = [];
  List recommendBooks = [];
  late ScrollController _scrollController;
  int _selectedIndex = 0; // 0: New, 1: Popular, 2: Recommend
  _initData() async {
  final url = Api.path('/api/music');
    final accessToken = box.read("token")["access_token"];
    final response = await http.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      List popularBooksdata = json.decode(response.body);
      popularBooksdata
          .sort((a, b) => b["likes"].length.compareTo(a["likes"].length));
      List recommendBooksdata = json.decode(response.body).where((book) {
        return book["recommend"] == true;
      }).toList();
      setState(() {
        popularBooks = popularBooksdata.sublist(0, 5);
        books = jsonDecode(response.body);
        recommendBooks = recommendBooksdata;
      });
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
  void initState() {
    super.initState();
  _scrollController = ScrollController();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.AppColor.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: color.AppColor.background,
          body: Column(
            children: [
              // Header with subtle gradient
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.AppColor.gradientFirst, color.AppColor.gradientSecond],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.multitrack_audio_rounded,
                          color: color.AppColor.textPrimary,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Groove',
                                style: TextStyle(color: color.AppColor.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('Discover & Listen', style: TextStyle(color: color.AppColor.textSecondary, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.to(
                              const Search(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 500),
                              arguments: [recommendBooks],
                            );
                          },
                          icon: Icon(Icons.search, color: color.AppColor.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: () {
                            Get.to(
                              const ProfilePage(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                          icon: Icon(Icons.person_outline_rounded, color: color.AppColor.textPrimary),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Popular carousel
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.78),
                  itemCount: popularBooks.length,
                  itemBuilder: (context, i) {
          final coverRaw = (popularBooks.isNotEmpty)
            ? (popularBooks[i]["thumbnailCover"] ?? popularBooks[i]["thumbnail"])
            : null;
          final cover = coverRaw ?? '';
          final normalizedCover = Api.normalizeUrl(cover);
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          const AudioPlayPage(),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 400),
                          arguments: [popularBooks, i, recommendBooks],
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12, left: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 12, offset: const Offset(0, 6)),
                          ],
                          color: cover.isEmpty ? color.AppColor.surface : null,
                          border: Border.all(color: color.AppColor.cardBorder.withOpacity(0.6)),
                        ),
                        child: Stack(
                          children: [
                            // background image or placeholder
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: cover.isNotEmpty
                                  ? Image.network(
                                      normalizedCover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: color.AppColor.surface),
                                    )
                                  : Container(),
                            ),
                            // dark overlay for readability
                            Container(
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.45)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                              ),
                            ),
                            Positioned(
                              left: 14,
                              bottom: 14,
                              right: 14,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          popularBooks[i]["title"] ?? 'Unknown',
                                          style: TextStyle(color: color.AppColor.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          (popularBooks[i]["artist"] ?? popularBooks[i]["authors"] ?? '').toString(),
                                          style: TextStyle(color: color.AppColor.textSecondary, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: color.AppColor.audioBlueBackground.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
                                    child: Icon(Icons.play_arrow, color: color.AppColor.textPrimary),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Now playing preview (shows first popular item if exists)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.AppColor.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 4))],
                    border: Border.all(color: color.AppColor.cardBorder.withOpacity(0.6)),
                  ),
                  child: Row(
                    children: [
                      // artwork
                      Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
              image: popularBooks.isNotEmpty && (popularBooks[0]["thumbnailCover"] != null || popularBooks[0]["thumbnail"] != null)
                ? DecorationImage(image: NetworkImage(Api.normalizeUrl(popularBooks[0]["thumbnailCover"] ?? popularBooks[0]["thumbnail"])), fit: BoxFit.cover)
                : null,
                          color: color.AppColor.audioGreyBackground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // title & slider
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
              Text(popularBooks.isNotEmpty ? (popularBooks[0]["title"] ?? 'Unknown') : 'No song selected',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color.AppColor.textPrimary)),
                            const SizedBox(height: 6),
              Text(
                popularBooks.isNotEmpty
                    ? ((popularBooks[0]["artist"] ?? popularBooks[0]["authors"] ?? '') as String)
                    : '',
                style: TextStyle(color: color.AppColor.textSecondary, fontSize: 12),
              ),
                            const SizedBox(height: 10),
                            // fake progress slider for visual
                            Row(
                              children: [
                                Text('0:00', style: TextStyle(fontSize: 11, color: color.AppColor.textSecondary)),
                                Expanded(
                                  child: Slider.adaptive(
                                    value: 0.26,
                                    onChanged: (v) {},
                                    activeColor: color.AppColor.audioBlueBackground,
                                    inactiveColor: color.AppColor.audioBluishBackground,
                                  ),
                                ),
                                Text('3:12', style: TextStyle(fontSize: 11, color: color.AppColor.textSecondary)),
                              ],
                            )
                          ],
                        ),
                      ),
                      // controls
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.favorite_border, color: color.AppColor.loveColor),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.skip_previous),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (popularBooks.isNotEmpty) {
                                    Get.to(
                                      const AudioPlayPage(),
                                      transition: Transition.rightToLeftWithFade,
                                      duration: const Duration(milliseconds: 400),
                                      arguments: [popularBooks, 0, recommendBooks],
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(color: color.AppColor.audioBlueBackground, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.AppColor.audioBlueBackground.withOpacity(0.22), blurRadius: 10, offset: const Offset(0,4))]),
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(Icons.play_arrow, color: color.AppColor.textPrimary),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.skip_next),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Section selector + list
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.AppColor.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
                          border: Border.all(color: color.AppColor.cardBorder.withOpacity(0.6)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(3, (i) {
                            final labels = ['New', 'Popular', 'Recommend'];
                            final colors = [color.AppColor.menu1Color, color.AppColor.menu2Color, color.AppColor.menu3Color];
                            final selected = _selectedIndex == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedIndex = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: selected
                                        ? LinearGradient(colors: [colors[i].withOpacity(0.95), colors[i].withOpacity(0.75)])
                                        : null,
                                    color: selected ? null : color.AppColor.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: selected ? Colors.transparent : color.AppColor.cardBorder.withOpacity(0.6)),
                                  ),
                                  child: Center(
                                    child: Text(labels[i], style: TextStyle(color: selected ? color.AppColor.textPrimary : color.AppColor.textSecondary, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // List of items for the selected section
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => _initData(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          itemCount: _currentList().length,
                          itemBuilder: (context, idx) {
                            final item = _currentList()[idx];
                            final thumbRaw = (item != null) ? (item["thumbnailCover"] ?? item["thumbnail"]) : null;
                            final thumb = thumbRaw != null ? Api.normalizeUrl(thumbRaw) : null;
                            return GestureDetector(
                              onTap: () {
                                final source = _selectedIndex == 1 ? popularBooks : (_selectedIndex == 2 ? recommendBooks : books);
                                final indexInSource = source.indexWhere((it) => it["_id"] == item["_id"]);
                                Get.to(
                                  const AudioPlayPage(),
                                  transition: Transition.rightToLeftWithFade,
                                  duration: const Duration(milliseconds: 400),
                                  arguments: [source, indexInSource < 0 ? idx : indexInSource, recommendBooks],
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.AppColor.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0,4))],
                                  border: Border.all(color: color.AppColor.cardBorder.withOpacity(0.6)),
                                ),
                                child: Row(
                                  children: [
                                    // thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 64,
                                        width: 64,
                                        color: color.AppColor.audioGreyBackground,
                                        child: thumb != null && thumb.isNotEmpty
                                            ? Image.network(
                                                thumb,
                                                fit: BoxFit.cover,
                                              )
                                            : Icon(Icons.music_note, color: color.AppColor.textSecondary),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // title and artist
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["title"] ?? 'Unknown',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: color.AppColor.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            (item["artist"] ?? item["authors"] ?? 'Unknown').toString(),
                                            style: TextStyle(
                                              color: color.AppColor.textSecondary,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // quick play button
                                    GestureDetector(
                                      onTap: () {
                                        final source = _selectedIndex == 1 ? popularBooks : (_selectedIndex == 2 ? recommendBooks : books);
                                        final indexInSource = source.indexWhere((it) => it["_id"] == item["_id"]);
                                        Get.to(
                                          const AudioPlayPage(),
                                          transition: Transition.rightToLeftWithFade,
                                          duration: const Duration(milliseconds: 400),
                                          arguments: [source, indexInSource < 0 ? idx : indexInSource, recommendBooks],
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: color.AppColor.audioBlueBackground,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.AppColor.audioBlueBackground.withOpacity(0.22),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(Icons.play_arrow, color: color.AppColor.textPrimary, size: 20),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List _currentList() {
    if (_selectedIndex == 1) return popularBooks;
    if (_selectedIndex == 2) return recommendBooks;
    return books;
  }
}
// end
