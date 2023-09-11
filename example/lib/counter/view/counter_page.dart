import 'dart:developer';

import 'package:example/counter/counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  BluetoothDevice? _device;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            if (_device != null)
              Column(
                children: [
                  StreamBuilder(
                    stream: _device!.connectionState,
                    builder: (context, snapshot) {
                      print('Connection state : ${snapshot.data}');
                      return Text('Connection state : ${snapshot.data}');
                    },
                  ),
                  StreamBuilder(
                    stream: _device!.mtu,
                    builder: (context, snapshot) {
                      print('Con');
                      return Text(snapshot.data.toString());
                    },
                  ),
                ],
              ),
            // StreamBuilder(
            //   // stream: WinBle.connectionStream,
            //   stream: WinBle.connectionStreamOf('cc:17:8a:a0:2a:18'),
            //   builder: (context, snapshot) {
            //     return Text(snapshot.data.toString());
            //   },
            // ),
            // StreamBuilder(
            //   // stream: WinBle.connectionStream,
            //   stream: WinBle.connectionStreamOf('d7:d4:7c:61:1d:c7'),
            //   builder: (context, snapshot) {
            //     return Text(snapshot.data.toString());
            //   },
            // ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () async {
                var isFinished = false;
                var subscription = FlutterBluePlus.scanResults.listen(
                  (results) async {
                    if (isFinished) return;
                    for (ScanResult r in results) {
                      if (r.device.localName.startsWith('HEH001')) {
                        print(r.device);
                        await r.device.connect();
                        isFinished = true;

                        return;
                      }
                    }
                  },
                );

                await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

                await FlutterBluePlus.stopScan();
                subscription.cancel();

                // final a = await WinBle.discoverServices('cc:17:8a:a0:2a:18');
                // print(a);
                // for(final c in a){
                //   print('$c =================');
                //   final b = await WinBle.discoverCharacteristics(address: 'cc:17:8a:a0:2a:18', serviceId: c);
                //   for(final d in b) {
                //     print(d.uuid);
                //   }
                // }
                // WinBle.pair('cc:17:8a:a0:2a:18');
                // WinBle.pair('cc:17:8a:a0:2a:18'.toLowerCase());
              },
              child: const Icon(Icons.bluetooth),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () async {
                final connected = await FlutterBluePlus.connectedSystemDevices;
                print(connected);
                connected
                    .where((element) => element.localName.startsWith('HEH001'))
                    .lastOrNull
                    ?.disconnect();
                // await WinBle.disconnect('cc:17:8a:a0:2a:18'.toLowerCase());
              },
              child: const Icon(Icons.bluetooth_disabled),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () async {
                final devices = await FlutterBluePlus.connectedSystemDevices;
                print(devices);

                if (devices.isNotEmpty) {
                  _device = devices.first;
                }
                setState(() {});
              },
              child: const Icon(Icons.refresh),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () async {
                final _device = this._device;
                if (_device != null) {
                  // log(_device.toString());
                  log((await _device.discoverServices()).join('\n'));
                  // log(_device.toString());
                }
              },
              child: const Icon(Icons.refresh),
            ),

            const SizedBox(height: 8),

            FloatingActionButton(
              onPressed: () async {
                final scan = FlutterBluePlus.startScan(
                  timeout: const Duration(seconds: 2),
                );

                // await scan.then((value) => print(value));
              },
              child: const Icon(Icons.new_label),
            ),
          ],
        ),
      ),
    );
  }
}
