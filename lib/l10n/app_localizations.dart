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

  /// Title text for the app section
  ///
  /// In en, this message translates to:
  /// **'Card Nudge 🔔'**
  String get appTitle;

  /// Title text for the welcome section
  ///
  /// In en, this message translates to:
  /// **'Welcome to Card Nudge 🔔'**
  String get welcomeTitle;

  /// Subtitle text for the welcome section
  ///
  /// In en, this message translates to:
  /// **'Your Credit Card Companion!'**
  String get welcomeSubtitle;

  /// Description text for welcome
  ///
  /// In en, this message translates to:
  /// **'Track your credit cards, payment dues, and never miss a payment again.'**
  String get welcomeDescription;

  /// Label for the 'Ok' button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// Label for the 'Cancel' button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Label for the 'Close' button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// Label for the 'Save' button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// Label for the 'Add' button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// Label for the 'Delete' button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// Label for the 'Edit' button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// Label for the 'Archive' button
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get buttonArchive;

  /// Label for the 'Unarchive' button
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get buttonUnarchive;

  /// Title text for the archived cards section
  ///
  /// In en, this message translates to:
  /// **'Archived Cards'**
  String get archivedCardsTitle;

  /// Title text for the archived cards empty state section
  ///
  /// In en, this message translates to:
  /// **'No Archived Cards'**
  String get archivedCardsEmptyStateTitle;

  /// Subtitle text for the archived cards empty state section
  ///
  /// In en, this message translates to:
  /// **'You have not archived any cards yet.'**
  String get archivedCardsEmptyStateSubtitle;

  /// Label for the 'Retry' button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// Label for the 'Undo' button
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get buttonUndo;

  /// Label for the 'Home' button
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get buttonHome;

  /// Label for the 'Add Card' button
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get buttonAddCard;

  /// Label for the 'Update Card' button
  ///
  /// In en, this message translates to:
  /// **'Update Card'**
  String get buttonUpdateCard;

  /// Label for the 'Add Payment' button
  ///
  /// In en, this message translates to:
  /// **'Create Payment Due'**
  String get buttonAddPayment;

  /// Label for the retry button input field or element
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButtonLabel;

  /// Text representing validation required
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// Text representing error generic
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again or return to the home screen. If the problem persists, contact support.'**
  String get errorGeneric;

  /// Text representing utilization
  ///
  /// In en, this message translates to:
  /// **'Utilization'**
  String get utilization;

  /// Text representing over utilization
  ///
  /// In en, this message translates to:
  /// **'Overutilized Cards'**
  String get overUtilization;

  /// Text representing total credit limit
  ///
  /// In en, this message translates to:
  /// **'Total Credit Limit'**
  String get totalCreditLimit;

  /// Text representing quick insights
  ///
  /// In en, this message translates to:
  /// **'Quick Insights'**
  String get quickInsights;

  /// Text representing monthly overview
  ///
  /// In en, this message translates to:
  /// **'Payment Overview by Month'**
  String get monthlyOverview;

  /// Title text for the cards screen section
  ///
  /// In en, this message translates to:
  /// **'Your Cards'**
  String get cardsScreenTitle;

  /// Subtitle text for the cards screen section
  ///
  /// In en, this message translates to:
  /// **'Manage your credit cards and payments'**
  String get cardsScreenSubtitle;

  /// Description text for cards screen
  ///
  /// In en, this message translates to:
  /// **'Keep track of your credit cards, payment dues, and upcoming payments.'**
  String get cardsScreenDescription;

  /// Title text for the cards screen empty state section
  ///
  /// In en, this message translates to:
  /// **'No Cards Added'**
  String get cardsScreenEmptyStateTitle;

  /// Subtitle text for the cards screen empty state section
  ///
  /// In en, this message translates to:
  /// **'Add your credit cards to start tracking payments and dues.'**
  String get cardsScreenEmptyStateSubtitle;

  /// Title text for the cards screen error section
  ///
  /// In en, this message translates to:
  /// **'Error Loading Cards'**
  String get cardsScreenErrorTitle;

  /// Subtitle text for the cards screen error section
  ///
  /// In en, this message translates to:
  /// **'There was an error loading your cards. Please try again later.'**
  String get cardsScreenErrorSubtitle;

  /// Title text for the card details screen section
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetailsScreenTitle;

  /// Subtitle text for the card details screen section
  ///
  /// In en, this message translates to:
  /// **'View and manage your card details'**
  String get cardDetailsScreenSubtitle;

  /// Description text for card details screen
  ///
  /// In en, this message translates to:
  /// **'View your card details, upcoming payments, and payment history.'**
  String get cardDetailsScreenDescription;

  /// Title text for the add card screen section
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCardScreenTitle;

  /// Title text for the update card screen section
  ///
  /// In en, this message translates to:
  /// **'Update Card'**
  String get updateCardScreenTitle;

  /// Subtitle text for the add card screen section
  ///
  /// In en, this message translates to:
  /// **'Add a new credit card'**
  String get addCardScreenSubtitle;

  /// Subtitle text for the update card screen section
  ///
  /// In en, this message translates to:
  /// **'Update your credit card details'**
  String get updateCardScreenSubtitle;

  /// Description text for add card screen
  ///
  /// In en, this message translates to:
  /// **'Enter your card details to start tracking payments and dues.'**
  String get addCardScreenDescription;

  /// Description text for update card screen
  ///
  /// In en, this message translates to:
  /// **'Update your card details to keep your payment information current.'**
  String get updateCardScreenDescription;

  /// Label for the card name input field or element
  ///
  /// In en, this message translates to:
  /// **'Card Name *'**
  String get cardNameLabel;

  /// Text representing card name hint
  ///
  /// In en, this message translates to:
  /// **'Enter card name'**
  String get cardNameHint;

  /// Error message indicating card name issue
  ///
  /// In en, this message translates to:
  /// **'Card name is required.'**
  String get cardNameError;

  /// Label for the bank input field or element
  ///
  /// In en, this message translates to:
  /// **'Bank *'**
  String get bankLabel;

  /// Text representing bank hint
  ///
  /// In en, this message translates to:
  /// **'Select your bank'**
  String get bankHint;

  /// Text representing add payment due
  ///
  /// In en, this message translates to:
  /// **'Add Payment Due'**
  String get addPaymentDue;

  /// Text representing edit payment due
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Due'**
  String get editPaymentDue;

  /// Label for the due amount input field or element
  ///
  /// In en, this message translates to:
  /// **'Due Amount *'**
  String get dueAmountLabel;

  /// Label for the minimum due input field or element
  ///
  /// In en, this message translates to:
  /// **'Minimum Due (Optional)'**
  String get minimumDueLabel;

  /// Label for the payment date input field or element
  ///
  /// In en, this message translates to:
  /// **'Payment Due Date *'**
  String get paymentDateLabel;

  /// Text representing select date
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Error message indicating select date issue
  ///
  /// In en, this message translates to:
  /// **'Please select a due date.'**
  String get selectDateError;

  /// Error message indicating invalid amount issue
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get invalidAmountError;

  /// Error message indicating minimum due exceeds issue
  ///
  /// In en, this message translates to:
  /// **'Minimum due cannot exceed total due.'**
  String get minimumDueExceedsError;

  /// Success message shown after payment added
  ///
  /// In en, this message translates to:
  /// **'Payment due added successfully!'**
  String get paymentAddedSuccess;

  /// Success message shown after payment updated
  ///
  /// In en, this message translates to:
  /// **'Payment due updated successfully!'**
  String get paymentUpdatedSuccess;

  /// Success message shown after no due payment added
  ///
  /// In en, this message translates to:
  /// **'No payment due added. You can add it later.'**
  String get noDuePaymentAddedSuccess;

  /// Error message indicating payment add issue
  ///
  /// In en, this message translates to:
  /// **'Failed to add payment due.'**
  String get paymentAddError;

  /// Text representing add due button
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get addDueButton;

  /// Text representing no payment due
  ///
  /// In en, this message translates to:
  /// **'No Payment Required'**
  String get noPaymentDue;

  /// Label for the card input field or element
  ///
  /// In en, this message translates to:
  /// **'Card Name'**
  String get cardLabel;

  /// Label for the network input field or element
  ///
  /// In en, this message translates to:
  /// **'Card Network'**
  String get networkLabel;

  /// Label for the last4digits input field or element
  ///
  /// In en, this message translates to:
  /// **'Last 4 Digits'**
  String get last4DigitsLabel;

  /// Label for the billing date input field or element
  ///
  /// In en, this message translates to:
  /// **'Billing Date'**
  String get billingDateLabel;

  /// Label for the due date input field or element
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDateLabel;

  /// Label for the credit limit input field or element
  ///
  /// In en, this message translates to:
  /// **'Credit Limit'**
  String get creditLimitLabel;

  /// Error message indicating last4digits issue
  ///
  /// In en, this message translates to:
  /// **'Enter exactly 4 digits.'**
  String get last4DigitsError;

  /// Error message indicating invalid credit limit issue
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive amount.'**
  String get invalidCreditLimitError;

  /// Error message indicating select dates issue
  ///
  /// In en, this message translates to:
  /// **'Please select billing and due dates.'**
  String get selectDatesError;

  /// Success message shown after card added
  ///
  /// In en, this message translates to:
  /// **'Card added successfully!'**
  String get cardAddedSuccess;

  /// Success message shown after card updated
  ///
  /// In en, this message translates to:
  /// **'Card updated successfully!'**
  String get cardUpdatedSuccess;

  /// Error message indicating card save issue
  ///
  /// In en, this message translates to:
  /// **'Failed to save card.'**
  String get cardSaveError;

  /// Error message indicating due date before billing issue
  ///
  /// In en, this message translates to:
  /// **'Due date must be after billing date'**
  String get dueDateBeforeBillingError;

  /// Text representing save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Text representing log payment
  ///
  /// In en, this message translates to:
  /// **'Log Payment'**
  String get logPayment;

  /// Text representing total due
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// Text representing minimum due
  ///
  /// In en, this message translates to:
  /// **'Minimum Due'**
  String get minimumDue;

  /// Text representing custom amount
  ///
  /// In en, this message translates to:
  /// **'Custom Amount'**
  String get customAmount;

  /// Label for the custom amount input field or element
  ///
  /// In en, this message translates to:
  /// **'Custom Amount'**
  String get customAmountLabel;

  /// Text representing enter custom amount
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterCustomAmount;

  /// Error message indicating custom amount required issue
  ///
  /// In en, this message translates to:
  /// **'Custom amount is required.'**
  String get customAmountRequiredError;

  /// Error message indicating invalid custom amount issue
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive amount.'**
  String get invalidCustomAmountError;

  /// Error message indicating amount exceeds due issue
  ///
  /// In en, this message translates to:
  /// **'Amount cannot exceed total due.'**
  String get amountExceedsDueError;

  /// Success message shown after payment logged
  ///
  /// In en, this message translates to:
  /// **'Payment logged successfully!'**
  String get paymentLoggedSuccess;

  /// Error message indicating payment log issue
  ///
  /// In en, this message translates to:
  /// **'Failed to log payment.'**
  String get paymentLogError;

  /// Text representing log payment button
  ///
  /// In en, this message translates to:
  /// **'Log Payment'**
  String get logPaymentButton;

  /// Error message indicating navigation issue
  ///
  /// In en, this message translates to:
  /// **'Navigation error occurred.'**
  String get navigationError;

  /// Error message indicating payment not found issue
  ///
  /// In en, this message translates to:
  /// **'Payment not found.'**
  String get paymentNotFoundError;

  /// Error message indicating invalid bank issue
  ///
  /// In en, this message translates to:
  /// **'Invalid bank selected.'**
  String get invalidBankError;

  /// Title text for the card details section
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetailsTitle;

  /// Text representing edit card
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get editCard;

  /// Text representing delete card
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteCard;

  /// Text representing archive card
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveCard;

  /// Text representing upcoming payment
  ///
  /// In en, this message translates to:
  /// **'Upcoming Payment'**
  String get upcomingPayment;

  /// Message indicating no upcoming due
  ///
  /// In en, this message translates to:
  /// **'Add a payment to see it here.'**
  String get noUpcomingDueMessage;

  /// Message showing the number of days until the next billing date
  ///
  /// In en, this message translates to:
  /// **'Your next billing date is in {daysUntilBilling,plural, one{1 day} other{{daysUntilBilling} days}}.'**
  String nextBillingDateMessage(num daysUntilBilling);

  /// Text representing payment history
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// Text representing no past payments
  ///
  /// In en, this message translates to:
  /// **'No past payments available.'**
  String get noPastPayments;

  /// Text representing payment history item
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentHistoryItem;

  /// Text representing upcoming payment card
  ///
  /// In en, this message translates to:
  /// **'Upcoming Payment'**
  String get upcomingPaymentCard;

  /// Error message indicating card not found issue
  ///
  /// In en, this message translates to:
  /// **'Card not found.'**
  String get cardNotFoundError;

  /// Error message indicating payment load issue
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load payments.'**
  String get paymentLoadError;

  /// Text representing delete card confirmation
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Card'**
  String get deleteCardConfirmation;

  /// Message indicating delete card
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this card? This action cannot be undone.'**
  String get deleteCardMessage;

  /// Text representing cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Text representing delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// Success message shown after card deleted
  ///
  /// In en, this message translates to:
  /// **'Card deleted successfully!'**
  String get cardDeletedSuccess;

  /// Error message indicating card delete issue
  ///
  /// In en, this message translates to:
  /// **'Failed to delete card.'**
  String get cardDeleteError;

  /// Text representing archive not implemented
  ///
  /// In en, this message translates to:
  /// **'Archive feature not yet available.'**
  String get archiveNotImplemented;

  /// Success message shown after card archived
  ///
  /// In en, this message translates to:
  /// **'Card archived successfully!'**
  String get cardArchivedSuccess;

  /// Success message shown after card unarchived
  ///
  /// In en, this message translates to:
  /// **'Card unarchived successfully!'**
  String get cardUnarchivedSuccess;

  /// Message indicating delete payment
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this payment? This action cannot be undone.'**
  String get deletePaymentMessage;

  /// Text representing delete payment confirmation
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Payment'**
  String get deletePaymentConfirmation;

  /// Error message indicating bank details load issue
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load bank details.'**
  String get bankDetailsLoadError;

  /// Text representing favorite card
  ///
  /// In en, this message translates to:
  /// **'Mark as Favorite'**
  String get favoriteCard;

  /// Text representing unfavorite card
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get unfavoriteCard;

  /// Error message indicating card archive issue
  ///
  /// In en, this message translates to:
  /// **'Failed to archive card.'**
  String get cardArchiveError;

  /// Text representing card added to favorites
  ///
  /// In en, this message translates to:
  /// **'Card added to favorites!'**
  String get cardAddedToFavorites;

  /// Text representing card removed from favorites
  ///
  /// In en, this message translates to:
  /// **'Card removed from favorites.'**
  String get cardRemovedFromFavorites;

  /// Error message indicating card favorite issue
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite status.'**
  String get cardFavoriteError;

  /// Text representing bank logo
  ///
  /// In en, this message translates to:
  /// **'Bank Logo'**
  String get bankLogo;

  /// Text representing due today
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// Text representing undo button
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoButton;

  /// Text representing current due
  ///
  /// In en, this message translates to:
  /// **'Current Due'**
  String get currentDue;

  /// Title text for the upcoming payments section
  ///
  /// In en, this message translates to:
  /// **'Upcoming Payments'**
  String get upcomingPaymentsTitle;

  /// Message indicating no payments
  ///
  /// In en, this message translates to:
  /// **'No Upcoming or Overdue Payments available.'**
  String get noPaymentsMessage;

  /// Text representing add card button
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCardButton;

  /// Text representing add payment button
  ///
  /// In en, this message translates to:
  /// **'Create Payment Due'**
  String get addPaymentButton;

  /// Error message indicating invalid card issue
  ///
  /// In en, this message translates to:
  /// **'Invalid card selected.'**
  String get invalidCardError;

  /// Text representing apply button
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButton;

  /// Text representing reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// Text representing clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// Text representing edit due date on card
  ///
  /// In en, this message translates to:
  /// **'Due date can be edited from the card details.'**
  String get editDueDateOnCard;

  /// Text representing due already exist
  ///
  /// In en, this message translates to:
  /// **'A payment due already exists for this card.'**
  String get dueAlreadyExist;

  /// Text representing spend overview
  ///
  /// In en, this message translates to:
  /// **'Spend Overview'**
  String get spendOverview;

  /// Text representing month on time
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get monthOnTime;

  /// Text representing month delayed
  ///
  /// In en, this message translates to:
  /// **'Delayed'**
  String get monthDelayed;

  /// Text representing month not paid
  ///
  /// In en, this message translates to:
  /// **'Not Paid'**
  String get monthNotPaid;

  /// Text representing month no data
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get monthNoData;

  /// Text representing month future
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get monthFuture;

  /// Message indicating due screen no filter
  ///
  /// In en, this message translates to:
  /// **'No payments match your filters.'**
  String get dueScreenNoFilterMessage;

  /// Title text for the settings screen section
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// Text representing edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Text representing language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Text representing english
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Text representing hindi
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// Text representing currency
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Text representing theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Text representing light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Text representing dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Text representing system
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Text representing banks
  ///
  /// In en, this message translates to:
  /// **'Banks'**
  String get banks;

  /// Text representing add bank
  ///
  /// In en, this message translates to:
  /// **'Add Bank'**
  String get addBank;

  /// Text representing edit bank
  ///
  /// In en, this message translates to:
  /// **'Edit Bank'**
  String get editBank;

  /// Text representing delete bank
  ///
  /// In en, this message translates to:
  /// **'Delete Bank'**
  String get deleteBank;

  /// Text representing delete bank confirm
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this bank?'**
  String get deleteBankConfirm;

  /// Text representing payment reminders
  ///
  /// In en, this message translates to:
  /// **'Payment Reminders'**
  String get paymentReminders;

  /// Text representing reminder time
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// Text representing export data
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Success message shown after export data
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully!'**
  String get exportDataSuccess;

  /// Text representing clear data
  ///
  /// In en, this message translates to:
  /// **'Clear Local Data'**
  String get clearData;

  /// Text representing clear data confirm
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all data? This action cannot be undone.'**
  String get clearDataConfirm;

  /// Success message shown after clear data
  ///
  /// In en, this message translates to:
  /// **'All data cleared successfully!'**
  String get clearDataSuccess;

  /// Text representing app version
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Text representing terms conditions
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// Text representing privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Text representing contact support
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Text representing save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Text representing cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Text representing add
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Text representing delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Error message indicating version issue
  ///
  /// In en, this message translates to:
  /// **'Error loading version'**
  String get versionError;

  /// Text representing loading version
  ///
  /// In en, this message translates to:
  /// **'Loading version...'**
  String get loadingVersion;

  /// Text representing sync data
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// Subtitle text for the sync data section
  ///
  /// In en, this message translates to:
  /// **'Sync Data with the cloud to keep your information safe.'**
  String get syncDataSubtitle;

  /// Success message shown after sync data
  ///
  /// In en, this message translates to:
  /// **'Data synced successfully!'**
  String get syncDataSuccess;

  /// Error message indicating sync data issue
  ///
  /// In en, this message translates to:
  /// **'Failed to sync data. Please try again.'**
  String get syncDataError;

  /// Text representing sync data in progress
  ///
  /// In en, this message translates to:
  /// **'Syncing data...'**
  String get syncDataInProgress;

  /// Text representing sync preference
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncPreference;

  /// Subtitle text for the sync preference section
  ///
  /// In en, this message translates to:
  /// **'Enable to sync your settings and data across devices.'**
  String get syncPreferenceSubtitle;

  /// Description text for utilization alert
  ///
  /// In en, this message translates to:
  /// **'Get notified when your credit card utilization exceeds this percentage.'**
  String get utilizationAlertDescription;

  /// Text representing utilization alert
  ///
  /// In en, this message translates to:
  /// **'Utilization Threshold'**
  String get utilizationAlert;

  /// Text representing bank name
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// Text representing bank code
  ///
  /// In en, this message translates to:
  /// **'Bank Code'**
  String get bankCode;

  /// Text representing support number
  ///
  /// In en, this message translates to:
  /// **'Support Number'**
  String get supportNumber;

  /// Text representing website
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Text representing bank color
  ///
  /// In en, this message translates to:
  /// **'Bank Color'**
  String get bankColor;

  /// Label for the select color input field or element
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColorLabel;

  /// Text representing logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Text representing overdue
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// Text representing today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Text representing paid
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// Text representing partially paid
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get partiallyPaid;

  /// Text representing no payment due status
  ///
  /// In en, this message translates to:
  /// **'No Payment Due'**
  String get noPaymentDueStatus;

  /// Text representing upcoming due
  ///
  /// In en, this message translates to:
  /// **'Upcoming Due'**
  String get upcomingDue;

  /// Text representing due tomorrow
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

  /// Text representing paid on
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get paidOn;

  /// Text representing due on
  ///
  /// In en, this message translates to:
  /// **'Due on'**
  String get dueOn;

  /// Text representing statement amount
  ///
  /// In en, this message translates to:
  /// **'Statement Amount'**
  String get statementAmount;

  /// Text representing partially paid amount
  ///
  /// In en, this message translates to:
  /// **'Partially Paid: '**
  String get partiallyPaidAmount;

  /// Label for the auto debit enabled input field or element
  ///
  /// In en, this message translates to:
  /// **'Auto Debit Enabled'**
  String get autoDebitEnabledLabel;

  /// Text representing auto debit enabled tooltip
  ///
  /// In en, this message translates to:
  /// **'Automatic payment is enabled for this card'**
  String get autoDebitEnabledTooltip;

  /// Text representing ai generated summary
  ///
  /// In en, this message translates to:
  /// **'AI Generated Summary'**
  String get aiGeneratedSummary;

  /// Text representing card benefits
  ///
  /// In en, this message translates to:
  /// **'Card Benefits'**
  String get cardBenefits;

  /// Text representing no benefits summary available
  ///
  /// In en, this message translates to:
  /// **'No benefits information available.'**
  String get noBenefitsSummaryAvailable;

  /// Success message shown after payment deleted
  ///
  /// In en, this message translates to:
  /// **'Payment deleted successfully!'**
  String get paymentDeletedSuccess;

  /// Name of the month January
  ///
  /// In en, this message translates to:
  /// **'🎉 Jan'**
  String get january;

  /// Name of the month February
  ///
  /// In en, this message translates to:
  /// **'❤️ Feb'**
  String get february;

  /// Name of the month March
  ///
  /// In en, this message translates to:
  /// **'🌍 March'**
  String get march;

  /// Name of the month April
  ///
  /// In en, this message translates to:
  /// **'🌱 April'**
  String get april;

  /// Name of the month May
  ///
  /// In en, this message translates to:
  /// **'👩 May'**
  String get may;

  /// Name of the month June
  ///
  /// In en, this message translates to:
  /// **'🌈 June'**
  String get june;

  /// Name of the month July
  ///
  /// In en, this message translates to:
  /// **'🇺🇳 July'**
  String get july;

  /// Name of the month August
  ///
  /// In en, this message translates to:
  /// **'☀️ Aug'**
  String get august;

  /// Name of the month September
  ///
  /// In en, this message translates to:
  /// **'📚 Sept'**
  String get september;

  /// Name of the month October
  ///
  /// In en, this message translates to:
  /// **'🎃 Oct'**
  String get october;

  /// Name of the month November
  ///
  /// In en, this message translates to:
  /// **'✊ Nov'**
  String get november;

  /// Name of the month December
  ///
  /// In en, this message translates to:
  /// **'🎄 Dec'**
  String get december;

  /// Greeting message for morning
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get morningGreeting;

  /// Greeting message for afternoon
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get afternoonGreeting;

  /// Greeting message for evening
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get eveningGreeting;

  /// Greeting message for night
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get nightGreeting;

  /// Message showing number of credit cards that are over-utilized beyond threshold
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} card over-utilized (> {threshold}%)} other{{count} cards over-utilized (> {threshold}%)} }'**
  String overUtilizedCards(int count, String threshold);

  /// Message showing number of credit cards due soon within next 7 days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} card due in next 7 days} other{{count} cards due in next 7 days}}'**
  String dueSoonCards(int count);

  /// Text representing something went wrong
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get somethingWentWrong;

  /// Text representing loading
  ///
  /// In en, this message translates to:
  /// **'Loading, please wait...'**
  String get loading;

  /// Title text for the spend analysis section
  ///
  /// In en, this message translates to:
  /// **'Spend Analysis'**
  String get spendAnalysisTitle;

  /// Description text for spend analysis
  ///
  /// In en, this message translates to:
  /// **'Analyze your spending patterns and manage your finances better.'**
  String get spendAnalysisDescription;

  /// Label for the year input field or element
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// Label for the filter input field or element
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterLabel;

  /// Label for the filter cards input field or element
  ///
  /// In en, this message translates to:
  /// **'Filter Cards'**
  String get filterCardsLabel;

  /// Text representing total spend
  ///
  /// In en, this message translates to:
  /// **'Total Spend'**
  String get totalSpend;

  /// Label showing number of cards (singular/plural handled automatically)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} card} other{{count} cards}}'**
  String cardsLabel(int count);

  /// Text representing alerts
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// Text representing search
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// Text representing no results found
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// Text representing due grace period
  ///
  /// In en, this message translates to:
  /// **'Due Grace Period (days)'**
  String get dueGracePeriod;

  /// Text representing due grace period helper
  ///
  /// In en, this message translates to:
  /// **'How many days after billing the payment is due'**
  String get dueGracePeriodHelper;

  /// Error message indicating due grace period issue
  ///
  /// In en, this message translates to:
  /// **'Enter valid days (0-60)'**
  String get dueGracePeriodError;

  /// Menu item for Dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Menu item for Cards
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// Menu item for Dues
  ///
  /// In en, this message translates to:
  /// **'Dues'**
  String get dues;

  /// Menu item for Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Menu item for Demo Mode
  ///
  /// In en, this message translates to:
  /// **'Demo Mode'**
  String get demoMode;

  /// Text representing demo mode active
  ///
  /// In en, this message translates to:
  /// **'Demo Mode Active'**
  String get demoModeActive;

  /// Text representing demo mode description
  ///
  /// In en, this message translates to:
  /// **'You are currently running in Demo Mode. Your card dues and details are stored locally.\n\nTo sync your cards across devices, please sign in with an account.'**
  String get demoModeDescription;

  /// Text representing continue demo
  ///
  /// In en, this message translates to:
  /// **'Continue Demo'**
  String get continueDemo;

  /// Text representing exit and sign in
  ///
  /// In en, this message translates to:
  /// **'Exit & Sign In'**
  String get exitAndSignIn;

  /// Text representing developer email
  ///
  /// In en, this message translates to:
  /// **'Developer Email'**
  String get developerEmail;

  /// Text representing suggest feature
  ///
  /// In en, this message translates to:
  /// **'Suggest a Feature'**
  String get suggestFeature;

  /// Text representing suggest feature subtitle
  ///
  /// In en, this message translates to:
  /// **'Share your ideas with us'**
  String get suggestFeatureSubtitle;

  /// Error message for load user details
  ///
  /// In en, this message translates to:
  /// **'Failed to load user details'**
  String get loadUserError;

  /// Ascending
  ///
  /// In en, this message translates to:
  /// **'ASC'**
  String get asc;

  /// Descending
  ///
  /// In en, this message translates to:
  /// **'DESC'**
  String get desc;

  /// Any filter option
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {error}'**
  String authError(String error);

  /// Google Sign-In failed
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed: {error}'**
  String googleSignInFailed(String error);

  /// GitHub Sign-In failed
  ///
  /// In en, this message translates to:
  /// **'GitHub Sign-In failed: {error}'**
  String githubSignInFailed(String error);

  /// Error deleting payment
  ///
  /// In en, this message translates to:
  /// **'Error deleting payment: {error}'**
  String deletePaymentError(String error);

  /// Error updating due date
  ///
  /// In en, this message translates to:
  /// **'Error updating due date: {error}'**
  String updateDueDateError(String error);

  /// Label for selecting a card
  ///
  /// In en, this message translates to:
  /// **'Select Card'**
  String get selectCard;

  /// Validation error when card is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select a card'**
  String get pleaseSelectCard;
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
