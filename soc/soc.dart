import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process_run/shell.dart';

class Com {
  static  WebSocket? webk;
  static  Timer? timer;
  static Future<void> send(Map map) async {
    var no = 'vps';
    map['name'] = no;
    map['type'] = 'msg';
    var kk = json.encode(map);
    webk.add(kk.toString());
  }

  static void end() {
    webk.close();
    // init();
  }

  static Future<void> as_service() async {
    init();
  }

  static Future<void> senddata(Map map) async {
    var no = 'vps';
    map['name'] = no;
    map['type'] = 'D';
    // map['type'] = 'fun';
    var kk = json.encode(map);
    webk.add(kk.toString());
  }

  static void init() async {
    String server = 'ws://fledu.co:8088';
    try {
      await webk.close();
    } catch (e) {
      print(e);
    }

    try {
      webk = await WebSocket.connect(server);

      if (webk?.readyState == WebSocket.open) {
        var no = 'vps';
        webk.add(json.encode({'name': no.toString(), 'type': 'C'}));
        // webk.add(json.encode({'name': no.toString(), 'type': 'A'}));
      }
      webk.listen((data) {
        var jsonkk = Utf8Decoder().convert(data);
        print("from:::" + jsonkk.toString());
        var map = jsonDecode(jsonkk.toString());
        run(map["runner"]);
      }, onDone: () {
        print('done : wecsoc');
        try {
          webk.close();
        } catch (e) {}
      }, onError: (e) {
        try {
          webk.close();
        } catch (e) {}
        // Error();
      }, cancelOnError: true);
    } catch (e) {
      print("catch e" + e.toString());
      try {
        webk.close();
      } catch (e) {}
    }

    timer = Timer.periodic(Duration(seconds: 30), (Timer t) async {
      if (webk?.readyState == WebSocket.open) {
        var no = 'vps';
        var win = '';
        if (Platform.isWindows) {
          win = "win:::";
        }
        try {
          webk.add(json.encode({'$no+$win': 'p', 'type': 'msg'}));
        } catch (e) {
          timer.cancel();
          init();
        }
      } else {
        timer.cancel();
        init();
      }
    });
  }
}

// void main(List<String> args) {
//   Com.as_service();
//   var line = stdin.readLineSync(encoding: utf8);
//   print(line?.trim() == '2' ? 'Yup!' : 'Nope :(');
// }

void main() {
  Com.as_service();
}

Future run(String fun) async {
  try {
    var shell = Shell();
    // shell.
    print('runnindg:::::::::' + fun);
    await shell.run(
      fun,
      onProcess: (process) {
        process.outLines.listen((event) {
          Com.senddata({"lines": "$event"});
          print(event);
        });
        //   process.outLines.forEach((element) {
        //     Com.senddata({"lines": "$element"});
        //     print(element);
        //   });
      },
    );
  } catch (e) {
    // print(e.toString() + 'ssssss');
  }
}
