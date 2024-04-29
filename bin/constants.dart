// ignore_for_file: constant_identifier_names

final String hostIp = "";
final String user = "";
final String password = "";

const DATE_FORMAT = "%Y-%m-%d %H:%M:%S";

const CODES = {
  100: "OK",
  101: "Unknown error",
  102: "Unsupported version",
  103: "Request not permitted",
  104: "User already logged in",
  105: "User is not logged in",
  106: "Username or password is incorrect",
  107: "User does not have necessary permissions",
  203: "Password is incorrect",
  511: "Start of upgrade",
  512: "Upgrade was not started",
  513: "Upgrade data errors",
  514: "Upgrade error",
  515: "Upgrade successful",
};

const QCODES = {
  "AuthorityList": 1470,
  "Users": 1472,
  "Groups": 1474,
  "AddGroup": 1476,
  "ModifyGroup": 1478,
  "DelGroup": 1480,
  "User": 1482,
  "ModifyUser": 1484,
  "DelUser": 1486,
  "ModifyPassword": 1488,
  "AlarmInfo": 1504,
  "AlarmSet": 1500,
  "ChannelTitle": 1046,
  "EncodeCapability": 1360,
  "General": 1042,
  "KeepAlive": 1006,
  "OPMachine": 1450,
  "OPMailTest": 1636,
  "OPMonitor": 1413,
  "OPNetKeyboard": 1550,
  "OPPTZControl": 1400,
  "OPSNAP": 1560,
  "OPSendFile": 0x5F2,
  "OPSystemUpgrade": 0x5F5,
  "OPTalk": 1434,
  "OPTimeQuery": 1452,
  "OPTimeSetting": 1450,
  "NetWork.NetCommon": 1042,
  "OPNetAlarm": 1506,
  "SystemFunction": 1360,
  "SystemInfo": 1020,
};

const OPFEED_QCODES = {
  "OPFeedBook": {
      "SET": 2300,
      "GET": 2302,
  },
  "OPFeedManual": {
      "SET": 2304,
  },
  "OPFeedHistory": {
      "GET": 2306,
      "SET": 2308,
  },
};

const KEY_CODES = {
  "M": "Menu",
  "I": "Info",
  "E": "Esc",
  "F": "Func",
  "S": "Shift",
  "L": "Left",
  "U": "Up",
  "R": "Right",
  "D": "Down",
};

const OK_CODES = [100, 515];

const PORTS = {
  "tcp": 34567,
  "udp": 34568,
};

