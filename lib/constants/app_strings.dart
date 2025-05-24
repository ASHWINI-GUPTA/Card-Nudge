class AppStrings {
  // Dashboard
  static const dashboardTitle = "Nudge 🔔";

  static const cardsTitle = 'Cards';
  static const noCardsMessage = 'You have not added any cards yet.';
  static const errorLoadingCards = 'Failed to load cards. Please try again.';
  static const retry = 'Retry';
  static const addCard = 'Add a new card';

  // Due Bottom Sheet
  static const createPaymentDue = 'Create Payment Due';
  static const dueAmountLabel = 'Due Amount *';
  static const minimumDueLabel = 'Minimum Due (Optional)';
  static const paymentDateLabel = 'Payment Date *';
  static const selectDate = 'Select date';
  static const selectDateError = 'Please select a payment date';
  static const invalidAmountError = 'Enter a valid amount';
  static const minimumDueExceedsError = 'Minimum due cannot exceed due amount';
  static const paymentAddedSuccess = 'Payment due added successfully';
  static const paymentAddError = 'Failed to add payment due';
  static const createDueButton = "Add";

  // Add/Update Card
  static const updateCard = 'Update Card';
  static const cardLabel = 'Card';
  static const bankLabel = 'Bank';
  static const networkLabel = 'Network';
  static const last4DigitsLabel = 'Last 4 Digits';
  static const billingDateLabel = 'Billing Date';
  static const dueDateLabel = 'Due Date';
  static const creditLimitLabel = 'Credit Limit';
  static const requiredFieldError = 'This field is required';
  static const last4DigitsError = 'Enter exactly 4 digits';
  static const invalidCreditLimitError = 'Enter a valid positive number';
  static const selectDatesError = 'Please select billing and due dates';
  static const cardAddedSuccess = 'Card added successfully';
  static const cardUpdatedSuccess = 'Card updated successfully';
  static const cardSaveError = 'Failed to save card';

  static const saveButton = "Save";

  // Log Payment Bottom Sheet
  static const logPayment = 'Log Payment';
  static const totalDue = 'Total Due';
  static const minimumDue = 'Minimum Due';
  static const customAmount = 'Custom Amount';
  static const customAmountLabel = 'Custom Amount (₹)';
  static const enterCustomAmount = 'Enter custom amount';
  static const invalidCustomAmountError = 'Enter a valid positive amount';
  static const amountExceedsDueError = 'Amount cannot exceed due amount';
  static const paymentLoggedSuccess = 'Payment logged successfully';
  static const paymentLogError = 'Failed to log payment';
  static const logPaymentButton = 'Log Payment';

  static const navigationError = 'Navigation error';
  static const paymentNotFoundError = 'Payment not found';

  // List
  static const cardLoadError = 'Failed to load cards';
  static const retryButton = 'Retry';

  // Details
  static const invalidBankError = 'Invalid bank selected';
  static const cardDetailsTitle = 'Card Details';
  static const editCard = 'Edit';
  static const deleteCard = 'Delete';
  static const archiveCard = 'Archive';
  static const upcomingPayment = 'Upcoming Payment';
  static const noUpcomingDues = 'No upcoming dues';
  static const paymentHistory = 'Payment History';
  static const noPastPayments = 'No past payments yet';
  static const paymentHistoryItem = 'Payment';
  static const upcomingPaymentCard = 'Upcoming Payment Card';
  static const cardNotFoundError = 'Card not found';
  static const paymentLoadError = 'Failed to load payments';
  static const deleteCardConfirmation = 'Delete Card Confirmation';
  static const deleteCardMessage = 'Are you sure you want to delete this card?';
  static const cancelButton = 'Cancel';
  static const deleteButton = 'Delete';
  static const cardDeletedSuccess = 'Card deleted successfully';
  static const cardDeleteError = 'Failed to delete card';
  static const archiveNotImplemented = 'Archive feature not implemented';
  static const cardArchivedSuccess = 'Card archived successfully';

  // Tile
  static const bankLoadError = 'Failed to load bank details';
  static const favoriteCard = 'Favorite';
  static const unfavoriteCard = 'Unfavorite';
  static const cardArchiveError = 'Failed to archive card';
  static const cardAddedToFavorites = 'Card added to favorites';
  static const cardRemovedFromFavorites = 'Card removed from favorites';
  static const cardFavoriteError = 'Failed to update favorite status';
  static const bankLogo = 'Bank Logo';
  static const dueToday = 'Due Today';
  static const undoButton = 'Undo';
  static const currentDue = 'Undo';

  // Upcoming Due
  static const upcomingPaymentsTitle = 'Upcoming Payments';
  static const noPaymentsMessage = 'No upcoming or overdue payments.';
  static const addCardButton = 'Add Card';
  static const addPaymentButton = 'Add Payment';

  static const invalidCardError = "Invalid Card";

  static const applyButton = 'Apply';

  static const editDueDateOnCard = 'Due date can be edit from Card.';

  static const dueAlreadyExist = 'A due already exists for this card.';

  // Charts
  static const spendOverview = 'Spend Overview';
  static const monthOnTime = 'On Time';
  static const monthDelayed = 'Delayed';
  static const monthNotPaid = 'Not Paid';
  static const monthNoData = 'No Data';
  static const monthFuture = 'Future';
}
