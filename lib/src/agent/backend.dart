import 'android_bridge.g.dart';

// This is intended to be platform-independent interface for streaming backend,
// implemented differently on mobile and desktop.
//
// Currently we support only android and for now this class just mirrors
// AndroidConnector interface mostly one-to-one.
//
// Later we will add support for desktop (via rocd), and rework this interface
// to be more generic. In particular, we'll remove start/stop sender/receiver
// methods, and introduce concepts of Hosts, Devices, and Links.
//
// Sender and receiver will become a special case of creating a Link between local
// Device and remote Host.
//
// AndroidConnector, used by AndroidBackend, likely will remain unmodified. But
// AndroidBackend will be reworked to implement new generic interface on top of
// simpler AndroidConnector.
//
// Similarly, AndroidReceiverSettings and AndroidSenderSettings likely will remain
// as is, but Backend will use some higher-level classes (e.g. LinkConfig, HostConfig).
abstract class Backend {
  Future<List<String>> getLocalAddresses();

  Future<void> startReceiver(AndroidReceiverSettings settings);
  Future<void> stopReceiver();
  Future<bool> isReceiverAlive();

  Future<void> startSender(AndroidSenderSettings settings);
  Future<void> stopSender();
  Future<bool> isSenderAlive();
}
