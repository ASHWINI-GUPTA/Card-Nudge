// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'Nudge 🔔';

  @override
  String get cardsTitle => 'Cards';

  @override
  String get noCardsMessage => 'No cards added yet.';

  @override
  String get errorLoadingCards => 'Couldn\'t load cards. Try again.';

  @override
  String get retryButtonLabel => 'Retry';

  @override
  String get addCard => 'Add New Card';

  @override
  String get addPaymentDue => 'Add Payment Due';

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
  String get paymentAddError => 'Failed to add payment due.';

  @override
  String get addDueButton => 'Add';

  @override
  String get updateCard => 'Update Card';

  @override
  String get cardLabel => 'Card Name';

  @override
  String get bankLabel => 'Bank';

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
  String get requiredFieldError => 'This field is required.';

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
  String get cardLoadError => 'Couldn\'t load cards.';

  @override
  String get invalidBankError => 'Invalid bank selected.';

  @override
  String get cardDetailsTitle => 'Card Details';

  @override
  String get editCard => 'Edit Card';

  @override
  String get deleteCard => 'Delete Card';

  @override
  String get archiveCard => 'Archive Card';

  @override
  String get upcomingPayment => 'Upcoming Payment';

  @override
  String get noUpcomingDues => 'No upcoming payments.';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get noPastPayments => 'No past payments yet.';

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
  String get noPaymentsMessage => 'No upcoming or overdue payments.';

  @override
  String get addCardButton => 'Add Card';

  @override
  String get addPaymentButton => 'Add Payment';

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
  String get clearData => 'Clear All Data';

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
}
