// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Roc Droid';

  @override
  String get receiver => 'ODBIORNIK';

  @override
  String get sender => 'NADAJNIK';

  @override
  String get receiverStartSenderStep =>
      '1. Uruchom nadajnik na zdalnym urządzeniu';

  @override
  String get receiverUseIPStep =>
      '2. Użyj jednego z adresów IP tego urządzenia jako adresu remote';

  @override
  String get receiverSourceStreamStep =>
      '3. Użyj tego portu dla strumienia źródłowego';

  @override
  String get receiverRepairStreamStep =>
      '4. Użyj tego portu dla strumienia naprawczego';

  @override
  String get receiverStartStep => '5. Uruchom odbiornik na tym urządzeniu';

  @override
  String get startReceiverButton => 'START ODBIORNIKA';

  @override
  String get stopReceiverButton => 'STOP ODBIORNIKA';

  @override
  String get senderStartReceiverStep =>
      '1. Uruchom odbiornik na zdalnym urządzeniu';

  @override
  String get senderSourceStreamStep =>
      '2. Użyj tego portu dla strumienia źródłowego';

  @override
  String get senderRepairStreamStep =>
      '3. Użyj tego portu dla strumienia naprawczego';

  @override
  String get senderPutIPStep =>
      '4. Wpisz adres IP zdalnego urządzenia z odbiornikiem poniżej';

  @override
  String get senderChooseSourceStep => '5. Wybierz źródło audio';

  @override
  String get senderStartStep => '6. Uruchom nadajnik na tym urządzeniu';

  @override
  String get startSenderButton => 'START NADAJNIKA';

  @override
  String get stopSenderButton => 'STOP NADAJNIKA';

  @override
  String get noData => 'Brak danych';

  @override
  String get currentlyPlayingApplications => 'Aplikacje odtwarzające dźwięk';

  @override
  String get microphone => 'Mikrofon';

  @override
  String get about => 'O aplikacji';

  @override
  String get sourceCode => 'KOD ŹRÓDŁOWY';

  @override
  String get bugTracker => 'ZGLASZANIE BŁĘDÓW';

  @override
  String get contributors => 'WSPÓŁTWÓRCY';

  @override
  String get licenseData => 'LICENCJA MOZILLA PUBLIC LICENSE 2.0';

  @override
  String get enterIp => 'Wpisz adres IP';

  @override
  String get permissionError => 'Brak uprawnień';

  @override
  String get deviceError => 'Błąd urządzenia audio';

  @override
  String get networkError => 'Błąd sieci';

  @override
  String get dbError => 'Błąd bazy danych';

  @override
  String get notFoundError => 'Nie znaleziono obiektu';

  @override
  String get internalError => 'Nieoczekiwany błąd';
}
