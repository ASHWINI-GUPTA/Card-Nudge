class AppStrings {
  static const appTitle = 'Card Nudge 🔔';

  // Dashboard
  static const dashboardTitle = 'Nudge 🔔';

  // Cards
  static const cardsTitle = 'Cards';
  static const noCardsMessage = 'No cards added yet.';
  static const errorLoadingCards = 'Couldn\'t load cards. Try again.';
  static const retryButtonLabel = 'Retry';
  static const addCard = 'Add New Card';

  // Payment Due Bottom Sheet
  static const addPaymentDue = 'Add Payment Due';
  static const dueAmountLabel = 'Due Amount *';
  static const minimumDueLabel = 'Minimum Due (Optional)';
  static const paymentDateLabel = 'Payment Due Date *';
  static const selectDate = 'Select Date';
  static const selectDateError = 'Please select a due date.';
  static const invalidAmountError = 'Enter a valid amount.';
  static const minimumDueExceedsError = 'Minimum due cannot exceed total due.';
  static const paymentAddedSuccess = 'Payment due added successfully!';
  static const paymentAddError = 'Failed to add payment due.';
  static const addDueButton = 'Add';

  // Add/Update Card
  static const updateCard = 'Update Card';
  static const cardLabel = 'Card Name';
  static const bankLabel = 'Bank';
  static const networkLabel = 'Card Network';
  static const last4DigitsLabel = 'Last 4 Digits';
  static const billingDateLabel = 'Billing Date';
  static const dueDateLabel = 'Due Date';
  static const creditLimitLabel = 'Credit Limit';
  static const requiredFieldError = 'This field is required.';
  static const last4DigitsError = 'Enter exactly 4 digits.';
  static const invalidCreditLimitError = 'Enter a valid positive amount.';
  static const selectDatesError = 'Please select billing and due dates.';
  static const cardAddedSuccess = 'Card added successfully!';
  static const cardUpdatedSuccess = 'Card updated successfully!';
  static const cardSaveError = 'Failed to save card.';
  static const dueDateBeforeBillingError =
      'Due date must be after billing date';
  static const saveButton = 'Save';

  // Log Payment Bottom Sheet
  static const logPayment = 'Log Payment';
  static const totalDue = 'Total Due';
  static const minimumDue = 'Minimum Due';
  static const customAmount = 'Custom Amount';
  static const customAmountLabel = 'Custom Amount';
  static const enterCustomAmount = 'Enter amount';
  static const invalidCustomAmountError = 'Enter a valid positive amount.';
  static const amountExceedsDueError = 'Amount cannot exceed total due.';
  static const paymentLoggedSuccess = 'Payment logged successfully!';
  static const paymentLogError = 'Failed to log payment.';
  static const logPaymentButton = 'Log Payment';

  // Navigation and General Errors
  static const navigationError = 'Navigation error occurred.';
  static const paymentNotFoundError = 'Payment not found.';

  // Card List
  static const cardLoadError = 'Couldn\'t load cards.';

  // Card Details
  static const invalidBankError = 'Invalid bank selected.';
  static const cardDetailsTitle = 'Card Details';
  static const editCard = 'Edit Card';
  static const deleteCard = 'Delete Card';
  static const archiveCard = 'Archive Card';
  static const upcomingPayment = 'Upcoming Payment';
  static const noUpcomingDues = 'No upcoming payments.';
  static const paymentHistory = 'Payment History';
  static const noPastPayments = 'No past payments yet.';
  static const paymentHistoryItem = 'Payment';
  static const upcomingPaymentCard = 'Upcoming Payment';
  static const cardNotFoundError = 'Card not found.';
  static const paymentLoadError = 'Couldn\'t load payments.';
  static const deleteCardConfirmation = 'Confirm Delete Card';
  static const deleteCardMessage =
      'Are you sure you want to delete this card? This action cannot be undone.';
  static const cancelButton = 'Cancel';
  static const deleteButton = 'Delete';
  static const cardDeletedSuccess = 'Card deleted successfully!';
  static const cardDeleteError = 'Failed to delete card.';
  static const archiveNotImplemented = 'Archive feature not yet available.';
  static const cardArchivedSuccess = 'Card archived successfully!';

  // Card Tile
  static const bankDetailsLoadError = 'Couldn\'t load bank details.';
  static const favoriteCard = 'Mark as Favorite';
  static const unfavoriteCard = 'Remove from Favorites';
  static const cardArchiveError = 'Failed to archive card.';
  static const cardAddedToFavorites = 'Card added to favorites!';
  static const cardRemovedFromFavorites = 'Card removed from favorites.';
  static const cardFavoriteError = 'Failed to update favorite status.';
  static const bankLogo = 'Bank Logo';
  static const dueToday = 'Due Today';
  static const undoButton = 'Undo';
  static const currentDue = 'Current Due';

  // Upcoming Payments
  static const upcomingPaymentsTitle = 'Upcoming Payments';
  static const noPaymentsMessage = 'No upcoming or overdue payments.';
  static const addCardButton = 'Add Card';
  static const addPaymentButton = 'Add Payment';

  static const invalidCardError = 'Invalid card selected.';

  static const applyButton = 'Apply';
  static const resetButton = 'Reset';
  static const clearButton = 'Clear';

  static const editDueDateOnCard =
      'Due date can be edited from the card details.';

  static const dueAlreadyExist = 'A payment due already exists for this card.';

  // Charts
  static const spendOverview = 'Spend Overview';
  static const monthOnTime = 'On Time';
  static const monthDelayed = 'Delayed';
  static const monthNotPaid = 'Not Paid';
  static const monthNoData = 'No Data';
  static const monthFuture = 'Future';

  // Filter
  static const dueScreenNoFilterMessage = 'No payments match your filters.';

  // Settings
  static const settingsScreenTitle = 'Settings';
  static const editProfile = 'Edit Profile';
  static const language = 'Language';
  static const english = 'English';
  static const hindi = 'Hindi';
  static const currency = 'Currency';
  static const theme = 'Theme';
  static const light = 'Light';
  static const dark = 'Dark';
  static const system = 'System';
  static const banks = 'Banks';
  static const addBank = 'Add Bank';
  static const editBank = 'Edit Bank';
  static const deleteBank = 'Delete Bank';
  static const deleteBankConfirm = 'Are you sure you want to delete this bank?';
  static const paymentReminders = 'Payment Reminders';
  static const reminderTime = 'Reminder Time';
  static const exportData = 'Export Data';
  static const exportDataSuccess = 'Data exported successfully!';
  static const clearData = 'Clear All Data';
  static const clearDataConfirm =
      'Are you sure you want to clear all data? This action cannot be undone.';
  static const clearDataSuccess = 'All data cleared successfully!';
  static const appVersion = 'App Version';
  static const termsConditions = 'Terms & Conditions';
  static const privacyPolicy = 'Privacy Policy';
  static const contactSupport = 'Contact Support';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const add = 'Add';
  static const delete = 'Delete';
  static const versionError = 'Error loading version';
  static const loadingVersion = 'Loading version...';
  static const syncData = 'Sync Data';
  static const syncDataSubtitle =
      'Sync Data with the cloud to keep your information safe.';
  static const syncDataSuccess = 'Data synced successfully!';
  static const syncDataError = 'Failed to sync data. Please try again.';
  static const syncDataInProgress = 'Syncing data...';
  static const syncPreference = 'Sync';
  static const syncPreferenceSubtitle =
      'Enable to sync your settings and data across devices.';

  // Bank Details
  static const bankName = 'Bank Name';
  static const bankCode = 'Bank Code';
  static const supportNumber = 'Support Number';
  static const website = 'Website';
  static const bankColor = 'Bank Color';
  static const selectColorLabel = 'Select Color';

  static const logout = 'Logout';
}
