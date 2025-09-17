// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Card Nudge 🔔';

  @override
  String get welcomeTitle => 'Welcome to Card Nudge 🔔';

  @override
  String get welcomeSubtitle => 'Your Credit Card Companion!';

  @override
  String get welcomeDescription =>
      'Track your credit cards, payment dues, and never miss a payment again.';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get buttonArchive => 'Archive';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get buttonUndo => 'Undo';

  @override
  String get buttonHome => 'Home';

  @override
  String get buttonAddCard => 'Add Card';

  @override
  String get buttonUpdateCard => 'Update Card';

  @override
  String get buttonAddPayment => 'Create Payment Due';

  @override
  String get retryButtonLabel => 'Retry';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get errorGeneric =>
      'An unexpected error occurred. Please try again or return to the home screen. If the problem persists, contact support.';

  @override
  String get utilization => 'Utilization';

  @override
  String get overUtilization => 'Overutilized Cards';

  @override
  String get totalCreditLimit => 'Total Credit Limit';

  @override
  String get quickInsights => 'Quick Insights';

  @override
  String get monthlyOverview => 'Payment Overview by Month';

  @override
  String get cardsScreenTitle => 'Your Cards';

  @override
  String get cardsScreenSubtitle => 'Manage your credit cards and payments';

  @override
  String get cardsScreenDescription =>
      'Keep track of your credit cards, payment dues, and upcoming payments.';

  @override
  String get cardsScreenEmptyStateTitle => 'No Cards Added';

  @override
  String get cardsScreenEmptyStateSubtitle =>
      'Add your credit cards to start tracking payments and dues.';

  @override
  String get cardsScreenErrorTitle => 'Error Loading Cards';

  @override
  String get cardsScreenErrorSubtitle =>
      'There was an error loading your cards. Please try again later.';

  @override
  String get cardDetailsScreenTitle => 'Card Details';

  @override
  String get cardDetailsScreenSubtitle => 'View and manage your card details';

  @override
  String get cardDetailsScreenDescription =>
      'View your card details, upcoming payments, and payment history.';

  @override
  String get addCardScreenTitle => 'Add Card';

  @override
  String get updateCardScreenTitle => 'Update Card';

  @override
  String get addCardScreenSubtitle => 'Add a new credit card';

  @override
  String get updateCardScreenSubtitle => 'Update your credit card details';

  @override
  String get addCardScreenDescription =>
      'Enter your card details to start tracking payments and dues.';

  @override
  String get updateCardScreenDescription =>
      'Update your card details to keep your payment information current.';

  @override
  String get cardNameLabel => 'Card Name *';

  @override
  String get cardNameHint => 'Enter card name';

  @override
  String get cardNameError => 'Card name is required.';

  @override
  String get bankLabel => 'Bank *';

  @override
  String get bankHint => 'Select your bank';

  @override
  String get addPaymentDue => 'Add Payment Due';

  @override
  String get editPaymentDue => 'Edit Payment Due';

  @override
  String get dueAmountLabel => 'Due Amount *';

  @override
  String get minimumDueLabel => 'Minimum Due (Optional)';

  @override
  String get paymentDateLabel => 'Payment Due Date *';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectDateError => 'Please select a due date.';

  @override
  String get invalidAmountError => 'Enter a valid amount.';

  @override
  String get minimumDueExceedsError => 'Minimum due cannot exceed total due.';

  @override
  String get paymentAddedSuccess => 'Payment due added successfully!';

  @override
  String get paymentUpdatedSuccess => 'Payment due updated successfully!';

  @override
  String get noDuePaymentAddedSuccess =>
      'No payment due added. You can add it later.';

  @override
  String get paymentAddError => 'Failed to add payment due.';

  @override
  String get addDueButton => 'Payment';

  @override
  String get noPaymentDue => 'No Payment Required';

  @override
  String get cardLabel => 'Card Name';

  @override
  String get networkLabel => 'Card Network';

  @override
  String get last4DigitsLabel => 'Last 4 Digits';

  @override
  String get billingDateLabel => 'Billing Date';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get creditLimitLabel => 'Credit Limit';

  @override
  String get last4DigitsError => 'Enter exactly 4 digits.';

  @override
  String get invalidCreditLimitError => 'Enter a valid positive amount.';

  @override
  String get selectDatesError => 'Please select billing and due dates.';

  @override
  String get cardAddedSuccess => 'Card added successfully!';

  @override
  String get cardUpdatedSuccess => 'Card updated successfully!';

  @override
  String get cardSaveError => 'Failed to save card.';

  @override
  String get dueDateBeforeBillingError => 'Due date must be after billing date';

  @override
  String get saveButton => 'Save';

  @override
  String get logPayment => 'Log Payment';

  @override
  String get totalDue => 'Total Due';

  @override
  String get minimumDue => 'Minimum Due';

  @override
  String get customAmount => 'Custom Amount';

  @override
  String get customAmountLabel => 'Custom Amount';

  @override
  String get enterCustomAmount => 'Enter amount';

  @override
  String get customAmountRequiredError => 'Custom amount is required.';

  @override
  String get invalidCustomAmountError => 'Enter a valid positive amount.';

  @override
  String get amountExceedsDueError => 'Amount cannot exceed total due.';

  @override
  String get paymentLoggedSuccess => 'Payment logged successfully!';

  @override
  String get paymentLogError => 'Failed to log payment.';

  @override
  String get logPaymentButton => 'Log Payment';

  @override
  String get navigationError => 'Navigation error occurred.';

  @override
  String get paymentNotFoundError => 'Payment not found.';

  @override
  String get invalidBankError => 'Invalid bank selected.';

  @override
  String get cardDetailsTitle => 'Card Details';

  @override
  String get editCard => 'Update';

  @override
  String get deleteCard => 'Delete';

  @override
  String get archiveCard => 'Archive';

  @override
  String get upcomingPayment => 'Upcoming Payment';

  @override
  String get noUpcomingDueMessage => 'Add a payment to see it here.';

  @override
  String nextBillingDateMessage(num daysUntilBilling) {
    String _temp0 = intl.Intl.pluralLogic(
      daysUntilBilling,
      locale: localeName,
      other: '$daysUntilBilling days',
      one: '1 day',
    );
    return 'Your next billing date is in $_temp0.';
  }

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get noPastPayments => 'No past payments available.';

  @override
  String get paymentHistoryItem => 'Payment';

  @override
  String get upcomingPaymentCard => 'Upcoming Payment';

  @override
  String get cardNotFoundError => 'Card not found.';

  @override
  String get paymentLoadError => 'Couldn\'t load payments.';

  @override
  String get deleteCardConfirmation => 'Confirm Delete Card';

  @override
  String get deleteCardMessage =>
      'Are you sure you want to delete this card? This action cannot be undone.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get cardDeletedSuccess => 'Card deleted successfully!';

  @override
  String get cardDeleteError => 'Failed to delete card.';

  @override
  String get archiveNotImplemented => 'Archive feature not yet available.';

  @override
  String get cardArchivedSuccess => 'Card archived successfully!';

  @override
  String get deletePaymentMessage =>
      'Are you sure you want to delete this payment? This action cannot be undone.';

  @override
  String get deletePaymentConfirmation => 'Confirm Delete Payment';

  @override
  String get bankDetailsLoadError => 'Couldn\'t load bank details.';

  @override
  String get favoriteCard => 'Mark as Favorite';

  @override
  String get unfavoriteCard => 'Remove from Favorites';

  @override
  String get cardArchiveError => 'Failed to archive card.';

  @override
  String get cardAddedToFavorites => 'Card added to favorites!';

  @override
  String get cardRemovedFromFavorites => 'Card removed from favorites.';

  @override
  String get cardFavoriteError => 'Failed to update favorite status.';

  @override
  String get bankLogo => 'Bank Logo';

  @override
  String get dueToday => 'Due Today';

  @override
  String get undoButton => 'Undo';

  @override
  String get currentDue => 'Current Due';

  @override
  String get upcomingPaymentsTitle => 'Upcoming Payments';

  @override
  String get noPaymentsMessage => 'No Upcoming or Overdue Payments available.';

  @override
  String get addCardButton => 'Add Card';

  @override
  String get addPaymentButton => 'Create Payment Due';

  @override
  String get invalidCardError => 'Invalid card selected.';

  @override
  String get applyButton => 'Apply';

  @override
  String get resetButton => 'Reset';

  @override
  String get clearButton => 'Clear';

  @override
  String get editDueDateOnCard =>
      'Due date can be edited from the card details.';

  @override
  String get dueAlreadyExist => 'A payment due already exists for this card.';

  @override
  String get spendOverview => 'Spend Overview';

  @override
  String get monthOnTime => 'On Time';

  @override
  String get monthDelayed => 'Delayed';

  @override
  String get monthNotPaid => 'Not Paid';

  @override
  String get monthNoData => 'No Data';

  @override
  String get monthFuture => 'Future';

  @override
  String get dueScreenNoFilterMessage => 'No payments match your filters.';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get currency => 'Currency';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get banks => 'Banks';

  @override
  String get addBank => 'Add Bank';

  @override
  String get editBank => 'Edit Bank';

  @override
  String get deleteBank => 'Delete Bank';

  @override
  String get deleteBankConfirm => 'Are you sure you want to delete this bank?';

  @override
  String get paymentReminders => 'Payment Reminders';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataSuccess => 'Data exported successfully!';

  @override
  String get clearData => 'Clear Local Data';

  @override
  String get clearDataConfirm =>
      'Are you sure you want to clear all data? This action cannot be undone.';

  @override
  String get clearDataSuccess => 'All data cleared successfully!';

  @override
  String get appVersion => 'App Version';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get versionError => 'Error loading version';

  @override
  String get loadingVersion => 'Loading version...';

  @override
  String get syncData => 'Sync Data';

  @override
  String get syncDataSubtitle =>
      'Sync Data with the cloud to keep your information safe.';

  @override
  String get syncDataSuccess => 'Data synced successfully!';

  @override
  String get syncDataError => 'Failed to sync data. Please try again.';

  @override
  String get syncDataInProgress => 'Syncing data...';

  @override
  String get syncPreference => 'Sync';

  @override
  String get syncPreferenceSubtitle =>
      'Enable to sync your settings and data across devices.';

  @override
  String get utilizationAlertDescription =>
      'Get notified when your credit card utilization exceeds this percentage.';

  @override
  String get utilizationAlert => 'Utilization Threshold';

  @override
  String get bankName => 'Bank Name';

  @override
  String get bankCode => 'Bank Code';

  @override
  String get supportNumber => 'Support Number';

  @override
  String get website => 'Website';

  @override
  String get bankColor => 'Bank Color';

  @override
  String get selectColorLabel => 'Select Color';

  @override
  String get logout => 'Logout';

  @override
  String get overdue => 'Overdue';

  @override
  String get today => 'Today';

  @override
  String get paid => 'Paid';

  @override
  String get partiallyPaid => 'Partially Paid';

  @override
  String get noPaymentDueStatus => 'No Payment Due';

  @override
  String get upcomingDue => 'Upcoming Due';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String overdueByDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Overdue by $_temp0.';
  }

  @override
  String dueInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Due in $_temp0.';
  }

  @override
  String get paidOn => 'Paid on';

  @override
  String get dueOn => 'Due on';

  @override
  String get statementAmount => 'Statement Amount';

  @override
  String get partiallyPaidAmount => 'Partially Paid: ';

  @override
  String get autoDebitEnabledLabel => 'Auto Debit Enabled';

  @override
  String get autoDebitEnabledTooltip =>
      'Automatic payment is enabled for this card';

  @override
  String get aiGeneratedSummary => 'AI Generated Summary';

  @override
  String get cardBenefits => 'Card Benefits';

  @override
  String get noBenefitsSummaryAvailable => 'No benefits information available.';

  @override
  String get paymentDeletedSuccess => 'Payment deleted successfully!';

  @override
  String get january => '🎉 Jan';

  @override
  String get february => '❤️ Feb';

  @override
  String get march => '🌍 March';

  @override
  String get april => '🌱 April';

  @override
  String get may => '👩 May';

  @override
  String get june => '🌈 June';

  @override
  String get july => '🇺🇳 July';

  @override
  String get august => '☀️ Aug';

  @override
  String get september => '📚 Sept';

  @override
  String get october => '🎃 Oct';

  @override
  String get november => '✊ Nov';

  @override
  String get december => '🎄 Dec';

  @override
  String get morningGreeting => 'Good Morning';

  @override
  String get afternoonGreeting => 'Good Afternoon';

  @override
  String get eveningGreeting => 'Good Evening';

  @override
  String get nightGreeting => 'Good Night';

  @override
  String overUtilizedCards(int count, String threshold) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards over-utilized (> $threshold%)',
      one: '$count card over-utilized (> $threshold%)',
    );
    return '$_temp0';
  }

  @override
  String dueSoonCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due in next 7 days',
      one: '$count card due in next 7 days',
    );
    return '$_temp0';
  }
}
