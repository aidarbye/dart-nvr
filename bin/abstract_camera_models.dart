// * Abstract classes for another channel and receivers
abstract class Channel {
  String? channelName();
  String? channelStatus();
}

abstract class Receiver {
  num? numberOfChannels();
}