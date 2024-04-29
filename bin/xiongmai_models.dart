import 'abstract_camera_models.dart';

// * Xiongmai 
class XiongmaiReceiverModel implements Receiver {
  final num? number;

  const XiongmaiReceiverModel._({
    required this.number
  });

  factory XiongmaiReceiverModel.fromJson(Map<String,dynamic>? json) {
    return XiongmaiReceiverModel._(
      number: json?['ChannelNum']
    );
  }

  @override
  numberOfChannels() => number;
}

class XiongmaiChannelModel implements Channel {
  final String? name;
  final String? status;

  const XiongmaiChannelModel._({
    required this.name, 
    required this.status
  });

  factory XiongmaiChannelModel.fromJson(Map<String, dynamic>? json) {
    return XiongmaiChannelModel._(
      name  : json?['ChnName'],
      status: json?['Status'],
    );
  }

  @override
  channelName() => name;
  @override
  channelStatus() => status;
}