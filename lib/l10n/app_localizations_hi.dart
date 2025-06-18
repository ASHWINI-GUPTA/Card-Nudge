// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get dashboardTitle => 'नज 🔔';

  @override
  String get cardsTitle => 'कार्ड';

  @override
  String get noCardsMessage => 'आपने अभी तक कोई कार्ड नहीं जोड़ा है।';

  @override
  String get errorLoadingCards =>
      'कार्ड लोड करने में विफल। कृपया फिर से प्रयास करें।';

  @override
  String get retryButtonLabel => 'पुनः प्रयास करें';

  @override
  String get addCard => 'नया कार्ड जोड़ें';

  @override
  String get addPaymentDue => 'भुगतान देय जोड़ें';

  @override
  String get dueAmountLabel => 'देय राशि *';

  @override
  String get minimumDueLabel => 'न्यूनतम देय (वैकल्पिक)';

  @override
  String get paymentDateLabel => 'भुगतान देय तिथि *';

  @override
  String get selectDate => 'तिथि चुनें';

  @override
  String get selectDateError => 'कृपया देय तिथि चुनें।';

  @override
  String get invalidAmountError => 'मान्य राशि दर्ज करें।';

  @override
  String get minimumDueExceedsError =>
      'न्यूनतम देय राशि कुल देय से अधिक नहीं हो सकती।';

  @override
  String get paymentAddedSuccess => 'भुगतान देय सफलतापूर्वक जोड़ा गया!';

  @override
  String get paymentAddError => 'भुगतान देय जोड़ने में विफल।';

  @override
  String get addDueButton => 'जोड़ें';

  @override
  String get updateCard => 'कार्ड अपडेट करें';

  @override
  String get cardLabel => 'कार्ड का नाम';

  @override
  String get bankLabel => 'बैंक';

  @override
  String get networkLabel => 'कार्ड नेटवर्क';

  @override
  String get last4DigitsLabel => 'अंतिम 4 अंक';

  @override
  String get billingDateLabel => 'बिलिंग तिथि';

  @override
  String get dueDateLabel => 'देय तिथि';

  @override
  String get creditLimitLabel => 'क्रेडिट सीमा';

  @override
  String get requiredFieldError => 'यह फ़ील्ड आवश्यक है।';

  @override
  String get last4DigitsError => 'ठीक 4 अंक दर्ज करें।';

  @override
  String get invalidCreditLimitError => 'मान्य धनात्मक राशि दर्ज करें।';

  @override
  String get selectDatesError => 'कृपया बिलिंग और देय तिथियाँ चुनें।';

  @override
  String get cardAddedSuccess => 'कार्ड सफलतापूर्वक जोड़ा गया!';

  @override
  String get cardUpdatedSuccess => 'कार्ड सफलतापूर्वक अपडेट किया गया!';

  @override
  String get cardSaveError => 'कार्ड सहेजने में विफल।';

  @override
  String get saveButton => 'सहेजें';

  @override
  String get logPayment => 'भुगतान लॉग करें';

  @override
  String get totalDue => 'कुल देय';

  @override
  String get minimumDue => 'न्यूनतम देय';

  @override
  String get customAmount => 'कस्टम राशि';

  @override
  String get customAmountLabel => 'कस्टम राशि';

  @override
  String get enterCustomAmount => 'राशि दर्ज करें';

  @override
  String get invalidCustomAmountError => 'मान्य धनात्मक राशि दर्ज करें।';

  @override
  String get amountExceedsDueError => 'राशि कुल देय से अधिक नहीं हो सकती।';

  @override
  String get paymentLoggedSuccess => 'भुगतान सफलतापूर्वक लॉग किया गया!';

  @override
  String get paymentLogError => 'भुगतान लॉग करने में विफल।';

  @override
  String get logPaymentButton => 'भुगतान लॉग करें';

  @override
  String get navigationError => 'नेविगेशन त्रुटि हुई।';

  @override
  String get paymentNotFoundError => 'भुगतान नहीं मिला।';

  @override
  String get cardLoadError => 'कार्ड लोड करने में विफल।';

  @override
  String get invalidBankError => 'अमान्य बैंक चयनित।';

  @override
  String get cardDetailsTitle => 'कार्ड विवरण';

  @override
  String get editCard => 'कार्ड संपादित करें';

  @override
  String get deleteCard => 'कार्ड हटाएँ';

  @override
  String get archiveCard => 'कार्ड संग्रहित करें';

  @override
  String get upcomingPayment => 'आगामी भुगतान';

  @override
  String get noUpcomingDues => 'कोई आगामी भुगतान नहीं।';

  @override
  String get paymentHistory => 'भुगतान इतिहास';

  @override
  String get noPastPayments => 'अभी तक कोई पिछले भुगतान नहीं।';

  @override
  String get paymentHistoryItem => 'भुगतान';

  @override
  String get upcomingPaymentCard => 'आगामी भुगतान';

  @override
  String get cardNotFoundError => 'कार्ड नहीं मिला।';

  @override
  String get paymentLoadError => 'भुगतान लोड करने में विफल।';

  @override
  String get deleteCardConfirmation => 'कार्ड हटाने की पुष्टि';

  @override
  String get deleteCardMessage =>
      'क्या आप वाकई इस कार्ड को हटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String get deleteButton => 'हटाएँ';

  @override
  String get cardDeletedSuccess => 'कार्ड सफलतापूर्वक हटाया गया!';

  @override
  String get cardDeleteError => 'कार्ड हटाने में विफल।';

  @override
  String get archiveNotImplemented => 'संग्रह सुविधा अभी उपलब्ध नहीं है।';

  @override
  String get cardArchivedSuccess => 'कार्ड सफलतापूर्वक संग्रहित!';

  @override
  String get bankDetailsLoadError => 'बैंक विवरण लोड करने में विफल।';

  @override
  String get favoriteCard => 'पसंदीदा के रूप में चिह्नित करें';

  @override
  String get unfavoriteCard => 'पसंदीदा से हटाएँ';

  @override
  String get cardArchiveError => 'कार्ड संग्रहित करने में विफल।';

  @override
  String get cardAddedToFavorites => 'कार्ड पसंदीदा में जोड़ा गया!';

  @override
  String get cardRemovedFromFavorites => 'कार्ड पसंदीदा से हटाया गया।';

  @override
  String get cardFavoriteError => 'पसंदीदा स्थिति अपडेट करने में विफल।';

  @override
  String get bankLogo => 'बैंक लोगो';

  @override
  String get dueToday => 'आज देय';

  @override
  String get undoButton => 'पूर्ववत करें';

  @override
  String get currentDue => 'वर्तमान देय';

  @override
  String get upcomingPaymentsTitle => 'आगामी भुगतान';

  @override
  String get noPaymentsMessage => 'कोई आगामी या अतिदेय भुगतान नहीं।';

  @override
  String get addCardButton => 'कार्ड जोड़ें';

  @override
  String get addPaymentButton => 'भुगतान जोड़ें';

  @override
  String get invalidCardError => 'अमान्य कार्ड चयनित।';

  @override
  String get applyButton => 'लागू करें';

  @override
  String get resetButton => 'रीसेट करें';

  @override
  String get clearButton => 'साफ करें';

  @override
  String get editDueDateOnCard =>
      'देय तिथि को कार्ड विवरण से संपादित किया जा सकता है।';

  @override
  String get dueAlreadyExist =>
      'इस कार्ड के लिए पहले से ही एक देय भुगतान मौजूद है।';

  @override
  String get spendOverview => 'खर्च अवलोकन';

  @override
  String get monthOnTime => 'समय पर';

  @override
  String get monthDelayed => 'विलंबित';

  @override
  String get monthNotPaid => 'भुगतान नहीं किया';

  @override
  String get monthNoData => 'कोई डेटा नहीं';

  @override
  String get monthFuture => 'भविष्य';

  @override
  String get dueScreenNoFilterMessage =>
      'आपके फ़िल्टर से कोई भुगतान मेल नहीं खाता।';

  @override
  String get settingsScreenTitle => 'सेटिंग्स';

  @override
  String get editProfile => 'प्रोफाइल संपादित करें';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'अंग्रेजी';

  @override
  String get hindi => 'हिंदी';

  @override
  String get currency => 'मुद्रा';

  @override
  String get theme => 'थीम';

  @override
  String get light => 'प्रकाश';

  @override
  String get dark => 'अंधेरा';

  @override
  String get system => 'सिस्टम';

  @override
  String get banks => 'बैंक';

  @override
  String get addBank => 'बैंक जोड़ें';

  @override
  String get editBank => 'बैंक संपादित करें';

  @override
  String get deleteBank => 'बैंक हटाएँ';

  @override
  String get deleteBankConfirm => 'क्या आप वाकई इस बैंक को हटाना चाहते हैं?';

  @override
  String get paymentReminders => 'भुगतान अनुस्मारक';

  @override
  String get reminderTime => 'अनुस्मारक समय';

  @override
  String get exportData => 'डेटा निर्यात करें';

  @override
  String get exportDataSuccess => 'डेटा सफलतापूर्वक निर्यात किया गया!';

  @override
  String get clearData => 'सभी डेटा साफ करें';

  @override
  String get clearDataConfirm =>
      'क्या आप वाकई सभी डेटा साफ करना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।';

  @override
  String get clearDataSuccess => 'सभी डेटा सफलतापूर्वक साफ किया गया!';

  @override
  String get appVersion => 'ऐप संस्करण';

  @override
  String get termsConditions => 'नियम और शर्तें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get contactSupport => 'सहायता से संपर्क करें';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get add => 'जोड़ें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get bankName => 'बैंक का नाम';

  @override
  String get bankCode => 'बैंक कोड';

  @override
  String get supportNumber => 'सहायता नंबर';

  @override
  String get website => 'वेबसाइट';

  @override
  String get bankColor => 'बैंक का रंग';

  @override
  String get selectColorLabel => 'रंग चुनें';
}
