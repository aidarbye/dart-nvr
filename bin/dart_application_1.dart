import 'constants.dart';
import 'xiongmai.dart';

void main(List<String> arguments) async {
  final Xiongmai xiongmai = Xiongmai(hostIp, user: user, password: password);

  try {
    await xiongmai.login();  

    await xiongmai.getChannelsStatuses();

    await xiongmai.getSnapshot(channel: 1);

    await xiongmai.close();
  } catch (e) {
    print(e.toString());
  }
}