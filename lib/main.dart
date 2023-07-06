// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/widgets/smooth_graph/smooth_graph.dart';
import 'package:torrent_frontend/widgets/torrent/torrent.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor:
            Color.fromARGB(Color.getAlphaFromOpacity(0.6), 0, 0, 0),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(),
          bodyMedium: TextStyle(),
          titleMedium: TextStyle(),
          labelMedium: TextStyle(),
          labelLarge: TextStyle(),
          labelSmall: TextStyle(),
          titleLarge: TextStyle(),
          titleSmall: TextStyle(),
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TorrentTile(),
                      SizedBox(height: 10,),
                      TorrentTile(),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 500,
                height: 200,
                child: SmoothChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
