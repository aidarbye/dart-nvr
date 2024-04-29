// ignore_for_file: unused_local_variable, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import './constants.dart';

class Xiongmai {
  late final String ip;
  late final String user;
  late final String password;
  late final String hashPass = sofiaHash(password);

  late final String proto = "tcp";

  late final int port = PORTS[proto]!;

  int packetCount = 0;
  int session = 0;
  int timeout = 0;

  Socket? socket;
  Stream<Uint8List>? broadcast;

  Xiongmai(
    this.ip,
    {
      required this.user,
      required this.password,
    }
  );

  String sofiaHash(String password) {
    List<int> bytes = utf8.encode(password);
    List<int> md5Bytes = md5.convert(bytes).bytes;
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    var result = Iterable<int>.generate(md5Bytes.length ~/ 2, (i) {
      return (md5Bytes[2 * i] + md5Bytes[2 * i + 1]) % 62;
    }).map((index) => chars[index]).join();
    return result;
  }

  Future connect([int timeout = 10]) async {
    try {
      this.timeout = timeout;
      print("Start Connecting 🕓");
      socket = await Socket.connect(
        ip, 
        port,
        timeout: Duration(seconds: timeout)
      );

      broadcast = socket?.asBroadcastStream();

      print("Socket Connected ✅");
    } catch (e) {
      throw e.toString();
    }
  }

  Future login() async {
    if (socket == null) {
      await connect();
    }
    
    final reply = await send(1000, {
      "EncryptType": "MD5",
      "LoginType": "DVRIP-Web",
      "PassWord": hashPass,
      "UserName": user,
    });

    session = int.parse(reply['SessionID'].replaceFirst('0x',''), radix: 16);

    await keepAlive();

    print("Logged successfully ✅");
  }

  Future send(
    dynamic msg, 
    Map<String, dynamic> data,
    {
      bool waitResponse = true
    }
  ) async {
    if (socket == null) return {'Ret': 101};

    var jsonData = utf8.encode(json.encode(data));

    var len = jsonData.length + 2;
    var header = ByteData(20);
    header.setUint8(0, 0xFF);
    header.setUint8(1, 0x00);
    header.setUint32(4, session, Endian.little);
    header.setUint32(8, packetCount++, Endian.little);
    header.setUint32(14, msg, Endian.little);
    header.setUint32(16, len, Endian.little);

    List<int> packet = header.buffer.asUint8List().toList();

    packet.addAll(jsonData);
    packet.addAll([0x0a, 0x00]); 

    socket?.add(packet);

    await socket?.flush();

    if (waitResponse) {
      final reply = await receiveResponse();
      
      print("\nMSG   📩 $msg\nReply ✅: $reply\n");

      return reply;
    }
  }

  Future receiveResponse() async {
    try {
      Completer<Map<String, dynamic>> completer = Completer<Map<String, dynamic>>();
      Map<String,dynamic> reply = {"Ret": 101};

      List<int> data = []; 

      packetCount++;

      StreamSubscription? streamSubscription;

      int? limit;

      streamSubscription = broadcast?.listen((event) { 
        final int lendata = processReceivedData(event);

        limit ??= lendata;
        
        data.addAll(event);
        print("dataadded");
        print(data.length);
        print(lendata);

        if (data.length - 20 >= limit!) {
          Uint8List processedData =  Uint8List.fromList(data.sublist(20, limit! - 1 + 20));
          String jsonString = utf8.decode(processedData);
          Map<String, dynamic> jsonMap = json.decode(jsonString);
          reply = jsonMap;
          completer.complete(reply);
          streamSubscription?.cancel();
        }
      },
      onError: (error) {
        print(error);
      });

      return await completer.future;
    } catch (e) {
      print(e);
    }
  }

  int processReceivedData(Uint8List data) {
    ByteData byteData = ByteData.sublistView(data);
    int session = byteData.getUint32(4, Endian.little);
    this.session = session;
    int lenData = byteData.getUint32(16, Endian.little);
    return lenData;
  }

  Future keepAlive() async {
    await send(
      QCODES["KeepAlive"], 
      {
        "Name": "KeepAlive", 
        "SessionID": session
      },
    );
  }

  Future getChannelsStatuses() async {
    await send(
      1042, 
      {
        "Name": "NetWork.ChnStatus", 
        "SessionID": session
      },
    );
  }

  Future getChannelsTitles() async {
    await send(
      1048, 
      {
        "Name": "ChannelTitle", 
        "SessionID": session
      },
    );
  }

  Future getSnapshot(
    {int channel = 0}
  ) async {
    final String command = "OPSNAP";
    await send(
      QCODES[command], 
      {
        "Name": command, 
        "SessionID": session,
        command: {'Channel': channel}
      },
      waitResponse: false
    );
    final packet = await reassembleBinPayload();
    return packet;
  }

  Future reassembleBinPayload() async {
    try {
      Completer<Map<String, dynamic>> completer = Completer<Map<String, dynamic>>();
      Map<String,dynamic> reply = {"Ret": 101};

      List<int> data = []; 

      packetCount++;

      StreamSubscription? streamSubscription;

      int? limit;

      streamSubscription = broadcast?.listen((event) { 
        final int lendata = processReceivedData(event);

        limit ??= lendata;
        
        data.addAll(event);

        print("data added");
        print("data progress ${data.length}");
        print("limit is $limit");

        if (data.length - 20 >= limit!) {
          int frameLen = 0;
          
          Uint8List? media;
          frameLen = 8;

          ByteData byteData = ByteData.sublistView(Uint8List.fromList(data));

          int dataType = byteData.buffer.asByteData().getUint32(4, Endian.big);

          print(dataType);

          // Uint8List processedData =  Uint8List.fromList(data.sublist(20, limit! - 1 + 20));
          // String jsonString = utf8.decode(processedData);
          // Map<String, dynamic> jsonMap = json.decode(jsonString);
          // reply = jsonMap;
          // completer.complete(reply);
          // streamSubscription?.cancel();
        }
      },
      onError: (error) {
        print(error);
      });

      return await completer.future;
    } catch (e) {
      print(e);
    }
  }

  Future close() async {
    await socket?.close();
    print('\nDisconnected 🛑');
  }

  String? internalToType(int dataType, int value) {
    if (dataType == 0x1FC || dataType == 0x1FD) {
      if (value == 1) {
        return "mpeg4";
      } else if (value == 2) {
        return "h264";
      } else if (value == 3) {
        return "h265";
      }
    } else if (dataType == 0x1F9) {
      if (value == 1 || value == 6) {
        return "info";
      }
    } else if (dataType == 0x1FA) {
      if (value == 0xE) {
        return "g711a";
      }
    } else if (dataType == 0x1FE && value == 0) {
      return "jpeg";
    }
    return null;
  }

  DateTime internalToDatetime(int value) {
    int second = value & 0x3F;
    int minute = (value & 0xFC0) >> 6;
    int hour = (value & 0x1F000) >> 12;
    int day = (value & 0x3E0000) >> 17;
    int month = (value & 0x3C00000) >> 22;
    int year = ((value & 0xFC000000) >> 26) + 2000;
    return DateTime(year, month, day, hour, minute, second);
  }
}

String uint8ListToHex(Uint8List data) {
  return data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

