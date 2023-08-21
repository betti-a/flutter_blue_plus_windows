import 'package:flutter_blue_plus/flutter_blue_plus.dart' as BLE;
import 'package:win_ble/win_ble.dart';
import 'package:win_ble/win_file.dart';

class FlutterBluePlusWindows {
  static bool _initialized = false;

  static Future<void> _initialize() async {
    if (_initialized) return;
    await WinBle.initialize(
      serverPath: await WinServer.path,
      enableLog: false,
    );
    _initialized = true;
  }

  static Future<bool> get isAvailable async {
    await _initialize();
    return true;
  }

  static Future<String> get adapterName async {
    await _initialize();
    return 'Windows';
  }

  static Stream<bool> get isScanning async* {
    await _initialize();
    await for (final s in Stream<bool>.empty()) {
      yield s;
    }
  }

  static bool get isScanningNow {
    return false;
  }

  static Future<void> turnOn({int timeout = 10}) async {
    await _initialize();
    await WinBle.updateBluetoothState(true);
  }

  static Stream<List<BLE.ScanResult>> get scanResults async* {
    await _initialize();

    final List<BLE.ScanResult> list = [];

    await for (final s in WinBle.scanStream) {
      final device = BLE.BluetoothDevice(
        remoteId: BLE.DeviceIdentifier(s.address),
        localName: s.name,
        type: BLE.BluetoothDeviceType.unknown,
      );
      final result = BLE.ScanResult(
        device: device,
        advertisementData: BLE.AdvertisementData(
          localName: s.name,
          txPowerLevel: null,
          connectable: s.advType.contains('Connectable'),
          manufacturerData: {},
          serviceData: {},
          serviceUuids:
          s.serviceUuids.map((e) => (e as List).first as String).toList(),
        ),
        rssi: int.tryParse(s.rssi) ?? -100,
        timeStamp: DateTime.fromMillisecondsSinceEpoch(
          ((double.tryParse(s.timestamp) ?? 0) * 100).toInt(),
        ),
      );
      if(!list.map((e) => e.device.remoteId).contains(device.remoteId)){
        list.add(result);
      }
      yield list;
    }
  }

  static Stream<BLE.BluetoothAdapterState> get adapterState async* {
    await _initialize();
    await for (final s in Stream<BLE.BluetoothAdapterState>.empty()) {
      yield s;
    }
  }

  static Future<List<BLE.BluetoothDevice>> get connectedSystemDevices async {
    await _initialize();
    return [];
  }

  static Future<List<BLE.BluetoothDevice>> get bondedDevices async {
    await _initialize();
    return [];
  }

  static Stream<BLE.ScanResult> scan({
    BLE.ScanMode scanMode = BLE.ScanMode.lowLatency,
    List<BLE.Guid> withServices = const [],
    List<String> macAddresses = const [],
    Duration? timeout,
    bool allowDuplicates = false,
    bool androidUsesFineLocation = false,
  }) async* {
    await _initialize();
    // await for (final s in Stream<BLE.ScanResult>.empty()) {
    //   yield s;
    // }
  }

  static Future<void> startScan({
    BLE.ScanMode scanMode = BLE.ScanMode.lowLatency,
    List<BLE.Guid> withServices = const [],
    List<String> macAddresses = const [],
    Duration? timeout,
    bool allowDuplicates = false,
    bool androidUsesFineLocation = false,
  }) async {
    await _initialize();
    WinBle.startScanning();

    if (timeout != null) {
      Future.delayed(
        timeout,
        () {
          stopScan();
        },
      );
    }
  }

  /// Stops a scan for Bluetooth Low Energy devices
  static Future<void> stopScan() async {
    await _initialize();
    WinBle.stopScanning();
  }

  /// Sets the internal FlutterBlue log level
  static void setLogLevel(BLE.LogLevel level, {color = true}) {
    return;
  }

  @Deprecated('Deprecated in Android SDK 33 with no replacement')
  static Future<void> turnOff({int timeout = 10}) async {
    await _initialize();
    await WinBle.updateBluetoothState(false);
  }

  static Future<bool> get isOn async {
    await _initialize();
    return await WinBle.bleState.first == BleState.On;
  }
}
