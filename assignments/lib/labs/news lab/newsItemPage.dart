import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newslab/BB.dart';
import 'newsItem.dart';

class NewsItemPage extends StatelessWidget {
  final int newsID;
  NewsItemPage(this.newsID, {super.key});

  @override
  Widget build(BuildContext context) {
    Future<NewsItem> ni = fetch(newsID);
    return Scaffold(
        appBar: AppBar(
          title: Text("News Item Page"),
        ),
        body: FutureBuilder(
            future: ni,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.text);
              } else {
                return BB("Loading...");
              }
            }));
  }
}

Future<NewsItem> fetch(int id) async {
  String root = "https://hacker-news.firebaseio.com/v0/";
  final url = Uri.parse('${root}item/${id}.json');
  final response = await http.get(url);
  Map<String, dynamic> theItem = jsonDecode(response.body);
  NewsItem ni = NewsItem.fromJson(theItem);
  return ni;
}
