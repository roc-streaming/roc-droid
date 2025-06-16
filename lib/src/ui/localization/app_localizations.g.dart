import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Roc Droid'**
  String get appTitle;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'RECEIVER'**
  String get receiver;

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'SENDER'**
  String get sender;

  /// No description provided for @receiverStartSenderStep.
  ///
  /// In en, this message translates to:
  /// **'1. Start sender on the remote device'**
  String get receiverStartSenderStep;

  /// No description provided for @receiverUseIPStep.
  ///
  /// In en, this message translates to:
  /// **'2. Use one of IP addresses of this device as the remote on the sender'**
  String get receiverUseIPStep;

  /// No description provided for @receiverSourceStreamStep.
  ///
  /// In en, this message translates to:
  /// **'3. Use this port for source stream'**
  String get receiverSourceStreamStep;

  /// No description provided for @receiverRepairStreamStep.
  ///
  /// In en, this message translates to:
  /// **'4. Use this port for repair stream'**
  String get receiverRepairStreamStep;

  /// No description provided for @receiverStartStep.
  ///
  /// In en, this message translates to:
  /// **'5. Start receiver on this device'**
  String get receiverStartStep;

  /// No description provided for @startReceiverButton.
  ///
  /// In en, this message translates to:
  /// **'START RECEIVER'**
  String get startReceiverButton;

  /// No description provided for @stopReceiverButton.
  ///
  /// In en, this message translates to:
  /// **'STOP RECEIVER'**
  String get stopReceiverButton;

  /// No description provided for @senderStartReceiverStep.
  ///
  /// In en, this message translates to:
  /// **'1. Start receiver on the remote device'**
  String get senderStartReceiverStep;

  /// No description provided for @senderSourceStreamStep.
  ///
  /// In en, this message translates to:
  /// **'2. Use this port for source stream'**
  String get senderSourceStreamStep;

  /// No description provided for @senderRepairStreamStep.
  ///
  /// In en, this message translates to:
  /// **'3. Use this port for repair stream'**
  String get senderRepairStreamStep;

  /// No description provided for @senderPutIPStep.
  ///
  /// In en, this message translates to:
  /// **'4. Put IP address of the remote receiver device below'**
  String get senderPutIPStep;

  /// No description provided for @senderChooseSourceStep.
  ///
  /// In en, this message translates to:
  /// **'5. Choose source to capture audio from'**
  String get senderChooseSourceStep;

  /// No description provided for @senderStartStep.
  ///
  /// In en, this message translates to:
  /// **'6. Start sender on this device'**
  String get senderStartStep;

  /// No description provided for @startSenderButton.
  ///
  /// In en, this message translates to:
  /// **'START SENDER'**
  String get startSenderButton;

  /// No description provided for @stopSenderButton.
  ///
  /// In en, this message translates to:
  /// **'STOP SENDER'**
  String get stopSenderButton;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @currentlyPlayingApplications.
  ///
  /// In en, this message translates to:
  /// **'Currently playing applications'**
  String get currentlyPlayingApplications;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'SOURCE CODE'**
  String get sourceCode;

  /// No description provided for @bugTracker.
  ///
  /// In en, this message translates to:
  /// **'BUG TRACKER'**
  String get bugTracker;

  /// No description provided for @contributors.
  ///
  /// In en, this message translates to:
  /// **'CONTRIBUTORS'**
  String get contributors;

  /// No description provided for @licenseData.
  ///
  /// In en, this message translates to:
  /// **'MOZILLA PUBLIC LICENSE 2.0'**
  String get licenseData;

  /// No description provided for @enterIp.
  ///
  /// In en, this message translates to:
  /// **'Enter IP address'**
  String get enterIp;

  /// No description provided for @permissionError.
  ///
  /// In en, this message translates to:
  /// **'Permission not granted'**
  String get permissionError;

  /// No description provided for @deviceError.
  ///
  /// In en, this message translates to:
  /// **'Audio device error'**
  String get deviceError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @dbError.
  ///
  /// In en, this message translates to:
  /// **'Database error'**
  String get dbError;

  /// No description provided for @notFoundError.
  ///
  /// In en, this message translates to:
  /// **'Object not found'**
  String get notFoundError;

  /// No description provided for @internalError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected internal error'**
  String get internalError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
