// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Roc Droid';

  @override
  String get receiver => 'RECEIVER';

  @override
  String get sender => 'SENDER';

  @override
  String get receiverStartSenderStep => '1. Start sender on the remote device';

  @override
  String get receiverUseIPStep =>
      '2. Use one of IP addresses of this device as the remote on the sender';

  @override
  String get receiverSourceStreamStep => '3. Use this port for source stream';

  @override
  String get receiverRepairStreamStep => '4. Use this port for repair stream';

  @override
  String get receiverStartStep => '5. Start receiver on this device';

  @override
  String get startReceiverButton => 'START RECEIVER';

  @override
  String get stopReceiverButton => 'STOP RECEIVER';

  @override
  String get senderStartReceiverStep =>
      '1. Start receiver on the remote device';

  @override
  String get senderSourceStreamStep => '2. Use this port for source stream';

  @override
  String get senderRepairStreamStep => '3. Use this port for repair stream';

  @override
  String get senderPutIPStep =>
      '4. Put IP address of the remote receiver device below';

  @override
  String get senderChooseSourceStep => '5. Choose source to capture audio from';

  @override
  String get senderStartStep => '6. Start sender on this device';

  @override
  String get startSenderButton => 'START SENDER';

  @override
  String get stopSenderButton => 'STOP SENDER';

  @override
  String get noData => 'No data';

  @override
  String get currentlyPlayingApplications => 'Currently playing applications';

  @override
  String get microphone => 'Microphone';

  @override
  String get about => 'About';

  @override
  String get sourceCode => 'SOURCE CODE';

  @override
  String get bugTracker => 'BUG TRACKER';

  @override
  String get contributors => 'CONTRIBUTORS';

  @override
  String get licenseData => 'MOZILLA PUBLIC LICENSE 2.0';

  @override
  String get enterIp => 'Enter IP address';

  @override
  String get permissionError => 'Permission not granted';

  @override
  String get deviceError => 'Audio device error';

  @override
  String get networkError => 'Network error';

  @override
  String get dbError => 'Database error';

  @override
  String get notFoundError => 'Object not found';

  @override
  String get internalError => 'Unexpected internal error';
}
