import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'message.dart';
import '../models/item.dart';

const String socketUrl = 'ws://10.0.2.2:2307'; //todo

class DataNotification extends StatelessWidget {
  final channel = WebSocketChannel.connect(Uri.parse(socketUrl));

  DataNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        builder: (context, snapshot) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (snapshot.hasData) {
              var data =
                  FinanceData.fromJson(jsonDecode(snapshot.data.toString()));
              message(context, data.toString(), "Data added");
            }
          });
          return const Text('');
        },
        stream: channel.stream.asBroadcastStream());
  }
}