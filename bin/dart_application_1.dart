import 'dart:io';
import 'dart:typed_data';

import 'constants.dart';
import 'xiongmai.dart';

void main(List<String> arguments) async {
  final Xiongmai xiongmai = Xiongmai(hostIp, user: user, password: password);

  try {
    await xiongmai.login();  

    await xiongmai.getChannelsStatuses();

    final bytes = await xiongmai.getSnapshot(channel: 1);

    await saveImage(bytes, "${Directory.current.path}/bin/image.jpg");

    await xiongmai.close();
  } catch (e) {
    print(e.toString());
  }
}

Future<void> saveImage(Uint8List bytes, String path) async {
  try {
    File file = File(path);
    await file.writeAsBytes(bytes);
    print("Файл успешно сохранен.");
  } catch (e) {
    print("Ошибка при сохранении файла: $e");
  }
}