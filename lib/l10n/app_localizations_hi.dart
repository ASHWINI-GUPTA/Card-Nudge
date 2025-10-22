// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'कार्ड नज 🔔';

  @override
  String get welcomeTitle => 'कार्ड नज में आपका स्वागत है 🔔';

  @override
  String get welcomeSubtitle => 'आपका क्रेडिट कार्ड साथी!';

  @override
  String get welcomeDescription =>
      'अपने क्रेडिट कार्ड, भुगतान की तारीख और बकाया राशि को ट्रैक करें। अब कभी भुगतान मिस न करें।';

  @override
  String get buttonOk => 'ठीक है';

  @override
  String get buttonCancel => 'रद्द करें';

  @override
  String get buttonClose => 'बंद करें';

  @override
  String get buttonSave => 'सहेजें';

  @override
  String get buttonAdd => 'जोड़ें';

  @override
  String get buttonDelete => 'हटाएं';

  @override
  String get buttonEdit => 'संपादित करें';

  @override
  String get buttonArchive => 'आर्काइव करें';

  @override
  String get buttonRetry => 'पुनः प्रयास करें';

  @override
  String get buttonUndo => 'पूर्ववत करें';

  @override
  String get buttonHome => 'होम';

  @override
  String get buttonAddCard => 'कार्ड जोड़ें';

  @override
  String get buttonUpdateCard => 'कार्ड अपडेट करें';

  @override
  String get buttonAddPayment => 'भुगतान बकाया बनाएं';

  @override
  String get retryButtonLabel => 'पुनः प्रयास करें';

  @override
  String get validationRequired => 'यह फ़ील्ड ज़रूरी है।';

  @override
  String get errorGeneric =>
      'एक अनपेक्षित त्रुटि हुई। कृपया फिर से कोशिश करें या होम स्क्रीन पर जाएं। अगर समस्या बनी रहती है, तो सहायता से संपर्क करें।';

  @override
  String get utilization => 'उपयोग';

  @override
  String get overUtilization => 'अधिक उपयोग किए गए कार्ड';

  @override
  String get totalCreditLimit => 'कुल क्रेडिट सीमा';

  @override
  String get quickInsights => 'तेज़ जानकारी';

  @override
  String get monthlyOverview => 'मासिक भुगतान अवलोकन';

  @override
  String get cardsScreenTitle => 'आपके कार्ड';

  @override
  String get cardsScreenSubtitle =>
      'अपने क्रेडिट कार्ड और भुगतान प्रबंधित करें';

  @override
  String get cardsScreenDescription =>
      'अपने क्रेडिट कार्ड, बकाया भुगतान और आगामी भुगतानों पर नज़र रखें।';

  @override
  String get cardsScreenEmptyStateTitle => 'कोई कार्ड नहीं जोड़ा गया';

  @override
  String get cardsScreenEmptyStateSubtitle =>
      'अपने क्रेडिट कार्ड जोड़ें ताकि भुगतान और बकाया ट्रैक करना शुरू हो सके।';

  @override
  String get cardsScreenErrorTitle => 'कार्ड लोड करने में त्रुटि';

  @override
  String get cardsScreenErrorSubtitle =>
      'आपके कार्ड लोड करने में त्रुटि हुई। कृपया बाद में फिर से कोशिश करें।';

  @override
  String get cardDetailsScreenTitle => 'कार्ड विवरण';

  @override
  String get cardDetailsScreenSubtitle =>
      'अपने कार्ड विवरण देखें और प्रबंधित करें';

  @override
  String get cardDetailsScreenDescription =>
      'अपने कार्ड विवरण, आगामी भुगतान और भुगतान इतिहास देखें।';

  @override
  String get addCardScreenTitle => 'कार्ड जोड़ें';

  @override
  String get updateCardScreenTitle => 'कार्ड अपडेट करें';

  @override
  String get addCardScreenSubtitle => 'नया क्रेडिट कार्ड जोड़ें';

  @override
  String get updateCardScreenSubtitle => 'अपने क्रेडिट कार्ड विवरण अपडेट करें';

  @override
  String get addCardScreenDescription =>
      'भुगतान और बकाया ट्रैक करने के लिए अपने कार्ड विवरण दर्ज करें।';

  @override
  String get updateCardScreenDescription =>
      'अपने भुगतान जानकारी को अपडेट रखने के लिए कार्ड विवरण अपडेट करें।';

  @override
  String get cardNameLabel => 'कार्ड का नाम *';

  @override
  String get cardNameHint => 'कार्ड का नाम दर्ज करें';

  @override
  String get cardNameError => 'कार्ड का नाम ज़रूरी है।';

  @override
  String get bankLabel => 'बैंक *';

  @override
  String get bankHint => 'अपना बैंक चुनें';

  @override
  String get addPaymentDue => 'भुगतान बकाया जोड़ें';

  @override
  String get editPaymentDue => 'भुगतान बकाया संपादित करें';

  @override
  String get dueAmountLabel => 'बकाया राशि *';

  @override
  String get minimumDueLabel => 'न्यूनतम बकाया (वैकल्पिक)';

  @override
  String get paymentDateLabel => 'भुगतान की तारीख *';

  @override
  String get selectDate => 'तारीख चुनें';

  @override
  String get selectDateError => 'कृपया बकाया तारीख चुनें।';

  @override
  String get invalidAmountError => 'सही राशि दर्ज करें।';

  @override
  String get minimumDueExceedsError =>
      'न्यूनतम बकाया कुल बकाया से अधिक नहीं हो सकता।';

  @override
  String get paymentAddedSuccess => 'भुगतान बकाया सफलतापूर्वक जोड़ा गया!';

  @override
  String get paymentUpdatedSuccess =>
      'भुगतान बकाया सफलतापूर्वक अपडेट किया गया!';

  @override
  String get noDuePaymentAddedSuccess =>
      'कोई भुगतान बकाया नहीं जोड़ा गया। आप बाद में जोड़ सकते हैं।';

  @override
  String get paymentAddError => 'भुगतान बकाया जोड़ने में विफल।';

  @override
  String get addDueButton => 'भुगतान';

  @override
  String get noPaymentDue => 'कोई भुगतान आवश्यक नहीं';

  @override
  String get cardLabel => 'कार्ड का नाम';

  @override
  String get networkLabel => 'कार्ड नेटवर्क';

  @override
  String get last4DigitsLabel => 'अंतिम 4 अंक';

  @override
  String get billingDateLabel => 'बिलिंग तारीख';

  @override
  String get dueDateLabel => 'बकाया तारीख';

  @override
  String get creditLimitLabel => 'क्रेडिट सीमा';

  @override
  String get last4DigitsError => 'ठीक 4 अंक दर्ज करें।';

  @override
  String get invalidCreditLimitError => 'सही सकारात्मक राशि दर्ज करें।';

  @override
  String get selectDatesError => 'कृपया बिलिंग और बकाया तारीख चुनें।';

  @override
  String get cardAddedSuccess => 'कार्ड सफलतापूर्वक जोड़ा गया!';

  @override
  String get cardUpdatedSuccess => 'कार्ड सफलतापूर्वक अपडेट किया गया!';

  @override
  String get cardSaveError => 'कार्ड सहेजने में विफल।';

  @override
  String get dueDateBeforeBillingError =>
      'बकाया तारीख बिलिंग तारीख के बाद होनी चाहिए';

  @override
  String get saveButton => 'सहेजें';

  @override
  String get logPayment => 'भुगतान दर्ज करें';

  @override
  String get totalDue => 'कुल बकाया';

  @override
  String get minimumDue => 'न्यूनतम बकाया';

  @override
  String get customAmount => 'कस्टम राशि';

  @override
  String get customAmountLabel => 'कस्टम राशि';

  @override
  String get enterCustomAmount => 'राशि दर्ज करें';

  @override
  String get customAmountRequiredError => 'राशि ज़रूरी है।';

  @override
  String get invalidCustomAmountError => 'सही सकारात्मक राशि दर्ज करें।';

  @override
  String get amountExceedsDueError => 'राशि कुल बकाया से अधिक नहीं हो सकती।';

  @override
  String get paymentLoggedSuccess => 'भुगतान सफलतापूर्वक दर्ज किया गया!';

  @override
  String get paymentLogError => 'भुगतान दर्ज करने में विफल।';

  @override
  String get logPaymentButton => 'भुगतान दर्ज करें';

  @override
  String get navigationError => 'नेविगेशन त्रुटि हुई।';

  @override
  String get paymentNotFoundError => 'भुगतान नहीं मिला।';

  @override
  String get invalidBankError => 'अमान्य बैंक चुना गया।';

  @override
  String get cardDetailsTitle => 'कार्ड विवरण';

  @override
  String get editCard => 'अपडेट करें';

  @override
  String get deleteCard => 'हटाएं';

  @override
  String get archiveCard => 'आर्काइव करें';

  @override
  String get upcomingPayment => 'आगामी भुगतान';

  @override
  String get noUpcomingDueMessage => 'यहां देखने के लिए भुगतान जोड़ें।';

  @override
  String nextBillingDateMessage(num daysUntilBilling) {
    String _temp0 = intl.Intl.pluralLogic(
      daysUntilBilling,
      locale: localeName,
      other: '$daysUntilBilling दिनों',
      one: '1 दिन',
    );
    return 'आपकी अगली बिलिंग तारीख $_temp0 में है।';
  }

  @override
  String get paymentHistory => 'भुगतान इतिहास';

  @override
  String get noPastPayments => 'कोई पुराना भुगतान उपलब्ध नहीं।';

  @override
  String get paymentHistoryItem => 'भुगतान';

  @override
  String get upcomingPaymentCard => 'आगामी भुगतान';

  @override
  String get cardNotFoundError => 'कार्ड नहीं मिला।';

  @override
  String get paymentLoadError => 'भुगतान लोड नहीं हो सके।';

  @override
  String get deleteCardConfirmation => 'कार्ड हटाने की पुष्टि करें';

  @override
  String get deleteCardMessage =>
      'क्या आप वाकई इस कार्ड को हटाना चाहते हैं? यह कार्रवाई वापस नहीं की जा सकती।';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String get deleteButton => 'हटाएं';

  @override
  String get cardDeletedSuccess => 'कार्ड सफलतापूर्वक हटाया गया!';

  @override
  String get cardDeleteError => 'कार्ड हटाने में विफल।';

  @override
  String get archiveNotImplemented => 'आर्काइव सुविधा अभी उपलब्ध नहीं है।';

  @override
  String get cardArchivedSuccess => 'कार्ड सफलतापूर्वक आर्काइव किया गया!';

  @override
  String get deletePaymentMessage =>
      'क्या आप वाकई इस भुगतान को हटाना चाहते हैं? यह कार्रवाई वापस नहीं की जा सकती।';

  @override
  String get deletePaymentConfirmation => 'भुगतान हटाने की पुष्टि करें';

  @override
  String get bankDetailsLoadError => 'बैंक विवरण लोड नहीं हो सके।';

  @override
  String get favoriteCard => 'पसंदीदा के रूप में चिह्नित करें';

  @override
  String get unfavoriteCard => 'पसंदीदा से हटाएं';

  @override
  String get cardArchiveError => 'कार्ड आर्काइव करने में विफल।';

  @override
  String get cardAddedToFavorites => 'कार्ड पसंदीदा में जोड़ा गया!';

  @override
  String get cardRemovedFromFavorites => 'कार्ड पसंदीदा से हटाया गया।';

  @override
  String get cardFavoriteError => 'पसंदीदा स्थिति अपडेट करने में विफल।';

  @override
  String get bankLogo => 'बैंक लोगो';

  @override
  String get dueToday => 'आज बकाया';

  @override
  String get undoButton => 'पूर्ववत करें';

  @override
  String get currentDue => 'वर्तमान बकाया';

  @override
  String get upcomingPaymentsTitle => 'आगामी भुगतान';

  @override
  String get noPaymentsMessage => 'कोई आगामी या अतिदेय भुगतान उपलब्ध नहीं।';

  @override
  String get addCardButton => 'कार्ड जोड़ें';

  @override
  String get addPaymentButton => 'भुगतान बकाया बनाएं';

  @override
  String get invalidCardError => 'अमान्य कार्ड चुना गया।';

  @override
  String get applyButton => 'लागू करें';

  @override
  String get resetButton => 'रीसेट करें';

  @override
  String get clearButton => 'साफ करें';

  @override
  String get editDueDateOnCard =>
      'बकाया तारीख को कार्ड विवरण से संपादित किया जा सकता है।';

  @override
  String get dueAlreadyExist =>
      'इस कार्ड के लिए पहले से ही एक बकाया भुगतान मौजूद है।';

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
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

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
  String get light => 'हल्का';

  @override
  String get dark => 'गहरा';

  @override
  String get system => 'सिस्टम';

  @override
  String get banks => 'बैंक';

  @override
  String get addBank => 'बैंक जोड़ें';

  @override
  String get editBank => 'बैंक संपादित करें';

  @override
  String get deleteBank => 'बैंक हटाएं';

  @override
  String get deleteBankConfirm => 'क्या आप वाकई इस बैंक को हटाना चाहते हैं?';

  @override
  String get paymentReminders => 'भुगतान रिमाइंडर';

  @override
  String get reminderTime => 'रिमाइंडर समय';

  @override
  String get exportData => 'डेटा निर्यात करें';

  @override
  String get exportDataSuccess => 'डेटा सफलतापूर्वक निर्यात किया गया!';

  @override
  String get clearData => 'स्थानीय डेटा साफ करें';

  @override
  String get clearDataConfirm =>
      'क्या आप वाकई सारा डेटा साफ करना चाहते हैं? यह कार्रवाई वापस नहीं की जा सकती।';

  @override
  String get clearDataSuccess => 'सारा डेटा सफलतापूर्वक साफ किया गया!';

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
  String get delete => 'हटाएं';

  @override
  String get versionError => 'संस्करण लोड करने में त्रुटि';

  @override
  String get loadingVersion => 'संस्करण लोड हो रहा है...';

  @override
  String get syncData => 'डेटा सिंक करें';

  @override
  String get syncDataSubtitle =>
      'अपनी जानकारी को सुरक्षित रखने के लिए डेटा को क्लाउड के साथ सिंक करें।';

  @override
  String get syncDataSuccess => 'डेटा सफलतापूर्वक सिंक किया गया!';

  @override
  String get syncDataError =>
      'डेटा सिंक करने में विफल। कृपया फिर से कोशिश करें।';

  @override
  String get syncDataInProgress => 'डेटा सिंक हो रहा है...';

  @override
  String get syncPreference => 'सिंक';

  @override
  String get syncPreferenceSubtitle =>
      'अपनी सेटिंग्स और डेटा को डिवाइसों में सिंक करने के लिए सक्षम करें।';

  @override
  String get utilizationAlertDescription =>
      'जब आपके क्रेडिट कार्ड का उपयोग इस प्रतिशत से अधिक हो, तो सूचना प्राप्त करें।';

  @override
  String get utilizationAlert => 'उपयोग सीमा';

  @override
  String get bankName => 'बैंक का नाम';

  @override
  String get bankCode => 'बैंक कोड';

  @override
  String get supportNumber => 'सहायता नंबर';

  @override
  String get website => 'वेबसाइट';

  @override
  String get bankColor => 'बैंक रंग';

  @override
  String get selectColorLabel => 'रंग चुनें';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get overdue => 'अतिदेय';

  @override
  String get today => 'आज';

  @override
  String get paid => 'भुगतान किया';

  @override
  String get partiallyPaid => 'आंशिक रूप से भुगतान किया';

  @override
  String get noPaymentDueStatus => 'कोई भुगतान बकाया नहीं';

  @override
  String get upcomingDue => 'आगामी बकाया';

  @override
  String get dueTomorrow => 'कल बकाया';

  @override
  String overdueByDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिनों',
      one: '1 दिन',
    );
    return '$_temp0 से अतिदेय।';
  }

  @override
  String dueInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिनों',
      one: '1 दिन',
    );
    return '$_temp0 में बकाया।';
  }

  @override
  String get paidOn => 'भुगतान किया गया';

  @override
  String get dueOn => 'बकाया है';

  @override
  String get statementAmount => 'विवरण राशि';

  @override
  String get partiallyPaidAmount => 'आंशिक रूप से भुगतान: ';

  @override
  String get autoDebitEnabledLabel => 'ऑटो डेबिट चालू किया गया है';

  @override
  String get autoDebitEnabledTooltip =>
      'इस कार्ड के लिए स्वचालित भुगतान सक्रिय है';

  @override
  String get aiGeneratedSummary => 'एआई जनरेटेड सारांश';

  @override
  String get cardBenefits => 'कार्ड लाभ';

  @override
  String get noBenefitsSummaryAvailable => 'कोई लाभ जानकारी उपलब्ध नहीं है';

  @override
  String get paymentDeletedSuccess => 'भुगतान सफलतापूर्वक हटाया गया!';

  @override
  String get january => '🪁 जनवरी';

  @override
  String get february => '📚 फ़रवरी';

  @override
  String get march => '🎨 मार्च';

  @override
  String get april => '🌾 अप्रैल';

  @override
  String get may => '🙏 मई';

  @override
  String get june => '🧘 जून';

  @override
  String get july => '🌧️ जुलाई';

  @override
  String get august => '🇮🇳 अगस्त';

  @override
  String get september => '🕉️ सितम्बर';

  @override
  String get october => '🏹 अक्टूबर';

  @override
  String get november => '🪔 नवम्बर';

  @override
  String get december => '🎄 दिसेम्बर';

  @override
  String get morningGreeting => 'सुप्रभात';

  @override
  String get afternoonGreeting => 'नमस्ते';

  @override
  String get eveningGreeting => 'शुभ संध्या';

  @override
  String get nightGreeting => 'शुभ रात्रि';

  @override
  String overUtilizedCards(int count, String threshold) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कार्ड अधिक उपयोग किए गए (> $threshold%)',
      one: '$count कार्ड अधिक उपयोग किया गया (> $threshold%)',
    );
    return '$_temp0';
  }

  @override
  String dueSoonCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कार्ड अगले 7 दिनों में देय',
      one: '$count कार्ड अगले 7 दिनों में देय',
    );
    return '$_temp0';
  }

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया!';

  @override
  String get loading => 'लोड हो रहा है, कृपया प्रतीक्षा करें...';

  @override
  String get spendAnalysisTitle => 'खर्च विश्लेषण';

  @override
  String get spendAnalysisDescription =>
      'अपने खर्च के पैटर्न का विश्लेषण करें और अपनी वित्तीय स्थिति को बेहतर ढंग से प्रबंधित करें।';

  @override
  String get yearLabel => 'वर्ष';

  @override
  String get filterLabel => 'फिल्टर';

  @override
  String get totalSpend => 'कुल खर्च';
}
