import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Nudge 🔔'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Card Nudge 🔔'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Credit Card Companion!'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your credit cards, payment dues, and never miss a payment again.'**
  String get welcomeDescription;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// No description provided for @buttonArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get buttonArchive;

  /// No description provided for @buttonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// No description provided for @buttonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get buttonUndo;

  /// No description provided for @buttonHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get buttonHome;

  /// No description provided for @buttonAddCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get buttonAddCard;

  /// No description provided for @buttonUpdateCard.
  ///
  /// In en, this message translates to:
  /// **'Update Card'**
  String get buttonUpdateCard;

  /// No description provided for @buttonAddPayment.
  ///
  /// In en, this message translates to:
  /// **'Create Payment Due'**
  String get buttonAddPayment;

  /// No description provided for @retryButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButtonLabel;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again or return to the home screen. If the problem persists, contact support.'**
  String get errorGeneric;

  /// No description provided for @utilization.
  ///
  /// In en, this message translates to:
  /// **'Utilization'**
  String get utilization;

  /// No description provided for @overUtilization.
  ///
  /// In en, this message translates to:
  /// **'Overutilized Cards'**
  String get overUtilization;

  /// No description provided for @totalCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Total Credit Limit'**
  String get totalCreditLimit;

  /// No description provided for @quickInsights.
  ///
  /// In en, this message translates to:
  /// **'Quick Insights'**
  String get quickInsights;

  /// No description provided for @monthlyOverview.
  ///
  /// In en, this message translates to:
  /// **'Payment Overview by Month'**
  String get monthlyOverview;

  /// No description provided for @cardsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Cards'**
  String get cardsScreenTitle;

  /// No description provided for @cardsScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your credit cards and payments'**
  String get cardsScreenSubtitle;

  /// No description provided for @cardsScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep track of your credit cards, payment dues, and upcoming payments.'**
  String get cardsScreenDescription;

  /// No description provided for @cardsScreenEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No Cards Added'**
  String get cardsScreenEmptyStateTitle;

  /// No description provided for @cardsScreenEmptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your credit cards to start tracking payments and dues.'**
  String get cardsScreenEmptyStateSubtitle;

  /// No description provided for @cardsScreenErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Cards'**
  String get cardsScreenErrorTitle;

  /// No description provided for @cardsScreenErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There was an error loading your cards. Please try again later.'**
  String get cardsScreenErrorSubtitle;

  /// No description provided for @cardDetailsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetailsScreenTitle;

  /// No description provided for @cardDetailsScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage your card details'**
  String get cardDetailsScreenSubtitle;

  /// No description provided for @cardDetailsScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'View your card details, upcoming payments, and payment history.'**
  String get cardDetailsScreenDescription;

  /// No description provided for @addCardScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCardScreenTitle;

  /// No description provided for @updateCardScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Card'**
  String get updateCardScreenTitle;

  /// No description provided for @addCardScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a new credit card'**
  String get addCardScreenSubtitle;

  /// No description provided for @updateCardScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your credit card details'**
  String get updateCardScreenSubtitle;

  /// No description provided for @addCardScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your card details to start tracking payments and dues.'**
  String get addCardScreenDescription;

  /// No description provided for @updateCardScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Update your card details to keep your payment information current.'**
  String get updateCardScreenDescription;

  /// No description provided for @cardNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Name *'**
  String get cardNameLabel;

  /// No description provided for @cardNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter card name'**
  String get cardNameHint;

  /// No description provided for @cardNameError.
  ///
  /// In en, this message translates to:
  /// **'Card name is required.'**
  String get cardNameError;

  /// No description provided for @bankLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank *'**
  String get bankLabel;

  /// No description provided for @bankHint.
  ///
  /// In en, this message translates to:
  /// **'Select your bank'**
  String get bankHint;

  /// No description provided for @addPaymentDue.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Due'**
  String get addPaymentDue;

  /// No description provided for @editPaymentDue.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Due'**
  String get editPaymentDue;

  /// No description provided for @dueAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Amount *'**
  String get dueAmountLabel;

  /// No description provided for @minimumDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Due (Optional)'**
  String get minimumDueLabel;

  /// No description provided for @paymentDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Due Date *'**
  String get paymentDateLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectDateError.
  ///
  /// In en, this message translates to:
  /// **'Please select a due date.'**
  String get selectDateError;

  /// No description provided for @invalidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get invalidAmountError;

  /// No description provided for @minimumDueExceedsError.
  ///
  /// In en, this message translates to:
  /// **'Minimum due cannot exceed total due.'**
  String get minimumDueExceedsError;

  /// No description provided for @paymentAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment due added successfully!'**
  String get paymentAddedSuccess;

  /// No description provided for @paymentUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment due updated successfully!'**
  String get paymentUpdatedSuccess;

  /// No description provided for @noDuePaymentAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'No payment due added. You can add it later.'**
  String get noDuePaymentAddedSuccess;

  /// No description provided for @paymentAddError.
  ///
  /// In en, this message translates to:
  /// **'Failed to add payment due.'**
  String get paymentAddError;

  /// No description provided for @addDueButton.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get addDueButton;

  /// No description provided for @noPaymentDue.
  ///
  /// In en, this message translates to:
  /// **'No Payment Required'**
  String get noPaymentDue;

  /// No description provided for @cardLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Name'**
  String get cardLabel;

  /// No description provided for @networkLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Network'**
  String get networkLabel;

  /// No description provided for @last4DigitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Last 4 Digits'**
  String get last4DigitsLabel;

  /// No description provided for @billingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Billing Date'**
  String get billingDateLabel;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDateLabel;

  /// No description provided for @creditLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit'**
  String get creditLimitLabel;

  /// No description provided for @last4DigitsError.
  ///
  /// In en, this message translates to:
  /// **'Enter exactly 4 digits.'**
  String get last4DigitsError;

  /// No description provided for @invalidCreditLimitError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive amount.'**
  String get invalidCreditLimitError;

  /// No description provided for @selectDatesError.
  ///
  /// In en, this message translates to:
  /// **'Please select billing and due dates.'**
  String get selectDatesError;

  /// No description provided for @cardAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully!'**
  String get cardAddedSuccess;

  /// No description provided for @cardUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card updated successfully!'**
  String get cardUpdatedSuccess;

  /// No description provided for @cardSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save card.'**
  String get cardSaveError;

  /// No description provided for @dueDateBeforeBillingError.
  ///
  /// In en, this message translates to:
  /// **'Due date must be after billing date'**
  String get dueDateBeforeBillingError;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @logPayment.
  ///
  /// In en, this message translates to:
  /// **'Log Payment'**
  String get logPayment;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// No description provided for @minimumDue.
  ///
  /// In en, this message translates to:
  /// **'Minimum Due'**
  String get minimumDue;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom Amount'**
  String get customAmount;

  /// No description provided for @customAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Amount'**
  String get customAmountLabel;

  /// No description provided for @enterCustomAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterCustomAmount;

  /// No description provided for @invalidCustomAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive amount.'**
  String get invalidCustomAmountError;

  /// No description provided for @amountExceedsDueError.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot exceed total due.'**
  String get amountExceedsDueError;

  /// No description provided for @paymentLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment logged successfully!'**
  String get paymentLoggedSuccess;

  /// No description provided for @paymentLogError.
  ///
  /// In en, this message translates to:
  /// **'Failed to log payment.'**
  String get paymentLogError;

  /// No description provided for @logPaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Log Payment'**
  String get logPaymentButton;

  /// No description provided for @navigationError.
  ///
  /// In en, this message translates to:
  /// **'Navigation error occurred.'**
  String get navigationError;

  /// No description provided for @paymentNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Payment not found.'**
  String get paymentNotFoundError;

  /// No description provided for @invalidBankError.
  ///
  /// In en, this message translates to:
  /// **'Invalid bank selected.'**
  String get invalidBankError;

  /// No description provided for @cardDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetailsTitle;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get editCard;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteCard;

  /// No description provided for @archiveCard.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveCard;

  /// No description provided for @upcomingPayment.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Payment'**
  String get upcomingPayment;

  /// No description provided for @noUpcomingDueMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a payment to see it here.'**
  String get noUpcomingDueMessage;

  /// Message showing the number of days until the next billing date
  ///
  /// In en, this message translates to:
  /// **'Your next billing date is in {daysUntilBilling,plural, one{1 day} other{{daysUntilBilling} days}}.'**
  String nextBillingDateMessage(num daysUntilBilling);

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @noPastPayments.
  ///
  /// In en, this message translates to:
  /// **'No past payments available.'**
  String get noPastPayments;

  /// No description provided for @paymentHistoryItem.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentHistoryItem;

  /// No description provided for @upcomingPaymentCard.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Payment'**
  String get upcomingPaymentCard;

  /// No description provided for @cardNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Card not found.'**
  String get cardNotFoundError;

  /// No description provided for @paymentLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load payments.'**
  String get paymentLoadError;

  /// No description provided for @deleteCardConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Card'**
  String get deleteCardConfirmation;

  /// No description provided for @deleteCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this card? This action cannot be undone.'**
  String get deleteCardMessage;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @cardDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card deleted successfully!'**
  String get cardDeletedSuccess;

  /// No description provided for @cardDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete card.'**
  String get cardDeleteError;

  /// No description provided for @archiveNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Archive feature not yet available.'**
  String get archiveNotImplemented;

  /// No description provided for @cardArchivedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card archived successfully!'**
  String get cardArchivedSuccess;

  /// No description provided for @deletePaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this payment? This action cannot be undone.'**
  String get deletePaymentMessage;

  /// No description provided for @deletePaymentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Payment'**
  String get deletePaymentConfirmation;

  /// No description provided for @bankDetailsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load bank details.'**
  String get bankDetailsLoadError;

  /// No description provided for @favoriteCard.
  ///
  /// In en, this message translates to:
  /// **'Mark as Favorite'**
  String get favoriteCard;

  /// No description provided for @unfavoriteCard.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get unfavoriteCard;

  /// No description provided for @cardArchiveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive card.'**
  String get cardArchiveError;

  /// No description provided for @cardAddedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Card added to favorites!'**
  String get cardAddedToFavorites;

  /// No description provided for @cardRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Card removed from favorites.'**
  String get cardRemovedFromFavorites;

  /// No description provided for @cardFavoriteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite status.'**
  String get cardFavoriteError;

  /// No description provided for @bankLogo.
  ///
  /// In en, this message translates to:
  /// **'Bank Logo'**
  String get bankLogo;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @undoButton.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoButton;

  /// No description provided for @currentDue.
  ///
  /// In en, this message translates to:
  /// **'Current Due'**
  String get currentDue;

  /// No description provided for @upcomingPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Payments'**
  String get upcomingPaymentsTitle;

  /// No description provided for @noPaymentsMessage.
  ///
  /// In en, this message translates to:
  /// **'No Upcoming or Overdue Payments available.'**
  String get noPaymentsMessage;

  /// No description provided for @addCardButton.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCardButton;

  /// No description provided for @addPaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Create Payment Due'**
  String get addPaymentButton;

  /// No description provided for @invalidCardError.
  ///
  /// In en, this message translates to:
  /// **'Invalid card selected.'**
  String get invalidCardError;

  /// No description provided for @applyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButton;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// No description provided for @editDueDateOnCard.
  ///
  /// In en, this message translates to:
  /// **'Due date can be edited from the card details.'**
  String get editDueDateOnCard;

  /// No description provided for @dueAlreadyExist.
  ///
  /// In en, this message translates to:
  /// **'A payment due already exists for this card.'**
  String get dueAlreadyExist;

  /// No description provided for @spendOverview.
  ///
  /// In en, this message translates to:
  /// **'Spend Overview'**
  String get spendOverview;

  /// No description provided for @monthOnTime.
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get monthOnTime;

  /// No description provided for @monthDelayed.
  ///
  /// In en, this message translates to:
  /// **'Delayed'**
  String get monthDelayed;

  /// No description provided for @monthNotPaid.
  ///
  /// In en, this message translates to:
  /// **'Not Paid'**
  String get monthNotPaid;

  /// No description provided for @monthNoData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get monthNoData;

  /// No description provided for @monthFuture.
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get monthFuture;

  /// No description provided for @dueScreenNoFilterMessage.
  ///
  /// In en, this message translates to:
  /// **'No payments match your filters.'**
  String get dueScreenNoFilterMessage;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @banks.
  ///
  /// In en, this message translates to:
  /// **'Banks'**
  String get banks;

  /// No description provided for @addBank.
  ///
  /// In en, this message translates to:
  /// **'Add Bank'**
  String get addBank;

  /// No description provided for @editBank.
  ///
  /// In en, this message translates to:
  /// **'Edit Bank'**
  String get editBank;

  /// No description provided for @deleteBank.
  ///
  /// In en, this message translates to:
  /// **'Delete Bank'**
  String get deleteBank;

  /// No description provided for @deleteBankConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this bank?'**
  String get deleteBankConfirm;

  /// No description provided for @paymentReminders.
  ///
  /// In en, this message translates to:
  /// **'Payment Reminders'**
  String get paymentReminders;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully!'**
  String get exportDataSuccess;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Local Data'**
  String get clearData;

  /// No description provided for @clearDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all data? This action cannot be undone.'**
  String get clearDataConfirm;

  /// No description provided for @clearDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data cleared successfully!'**
  String get clearDataSuccess;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @versionError.
  ///
  /// In en, this message translates to:
  /// **'Error loading version'**
  String get versionError;

  /// No description provided for @loadingVersion.
  ///
  /// In en, this message translates to:
  /// **'Loading version...'**
  String get loadingVersion;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// No description provided for @syncDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Data with the cloud to keep your information safe.'**
  String get syncDataSubtitle;

  /// No description provided for @syncDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data synced successfully!'**
  String get syncDataSuccess;

  /// No description provided for @syncDataError.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync data. Please try again.'**
  String get syncDataError;

  /// No description provided for @syncDataInProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing data...'**
  String get syncDataInProgress;

  /// No description provided for @syncPreference.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncPreference;

  /// No description provided for @syncPreferenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable to sync your settings and data across devices.'**
  String get syncPreferenceSubtitle;

  /// No description provided for @utilizationAlertDescription.
  ///
  /// In en, this message translates to:
  /// **'Get notified when your credit card utilization exceeds this percentage.'**
  String get utilizationAlertDescription;

  /// No description provided for @utilizationAlert.
  ///
  /// In en, this message translates to:
  /// **'Utilization Threshold'**
  String get utilizationAlert;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @bankCode.
  ///
  /// In en, this message translates to:
  /// **'Bank Code'**
  String get bankCode;

  /// No description provided for @supportNumber.
  ///
  /// In en, this message translates to:
  /// **'Support Number'**
  String get supportNumber;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @bankColor.
  ///
  /// In en, this message translates to:
  /// **'Bank Color'**
  String get bankColor;

  /// No description provided for @selectColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColorLabel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @partiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get partiallyPaid;

  /// No description provided for @noPaymentDueStatus.
  ///
  /// In en, this message translates to:
  /// **'No Payment Due'**
  String get noPaymentDueStatus;

  /// No description provided for @upcomingDue.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Due'**
  String get upcomingDue;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get dueTomorrow;

  /// Message indicating how many days a payment is overdue
  ///
  /// In en, this message translates to:
  /// **'Overdue by {days,plural, one{1 day} other{{days} days}}.'**
  String overdueByDays(num days);

  /// Message indicating how many days until a payment is due
  ///
  /// In en, this message translates to:
  /// **'Due in {days,plural, one{1 day} other{{days} days}}.'**
  String dueInDays(num days);

  /// No description provided for @paidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get paidOn;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due on'**
  String get dueOn;

  /// No description provided for @statementAmount.
  ///
  /// In en, this message translates to:
  /// **'Statement Amount'**
  String get statementAmount;

  /// No description provided for @partiallyPaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid: '**
  String get partiallyPaidAmount;

  /// No description provided for @autoDebitEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto Debit Enabled'**
  String get autoDebitEnabledLabel;

  /// No description provided for @autoDebitEnabledTooltip.
  ///
  /// In en, this message translates to:
  /// **'Automatic payment is enabled for this card'**
  String get autoDebitEnabledTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
