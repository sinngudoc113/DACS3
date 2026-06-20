import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('vi')];

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    if (localizations == null) {
      throw StateError('AppLocalizations not found in widget tree.');
    }
    return localizations;
  }

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'appTitle': 'EggTrack',
      'navHome': 'Home',
      'navAdd': 'Add',
      'navHistory': 'History',
      'navBudget': 'Budget',
      'navGroupFund': 'Group fund',
      'navStats': 'Stats',
      'language': 'Language',
      'languageEnglish': 'English',
      'languageVietnamese': 'Vietnamese',
      'signOut': 'Sign out',
      'greeting': 'Hello, {name}',
      'dashboardSubtitle': 'Track every egg in your money basket.',
      'totalBalance': 'Total balance',
      'income': 'Income',
      'spent': 'Spent',
      'quickActions': 'Quick actions',
      'customize': 'Customize',
      'addTransactionAction': 'Add transaction',
      'categoriesAction': 'Categories',
      'insightsAction': 'Insights',
      'tapToOpen': 'Tap to open',
      'budgetPace': 'Budget pace',
      'budgetPaceSubtitle': '{percent}% of this month budget used',
      'recentTransactions': 'Recent transactions',
      'seeAll': 'See all',
      'noTransactions':
          'No transactions yet. Add your first one from the Add tab.',
      'noTransactionsSummary': 'No transactions yet',
      'transactionsThisMonth': '{count} transactions this month',
      'newTransaction': 'New transaction',
      'newTransactionSubtitle': 'Capture every detail before it fades.',
      'typeLabel': 'Type',
      'expense': 'Expense',
      'details': 'Details',
      'titleLabel': 'Title',
      'amountLabel': 'Amount',
      'categoryLabel': 'Category',
      'notesLabel': 'Notes',
      'noteHint': 'Write a note (optional)',
      'schedule': 'Schedule',
      'account': 'Account',
      'scheduleSubtitle': 'Today, 9:40 AM',
      'accountSubtitle': 'Everyday card',
      'saveTransaction': 'Save transaction',
      'saving': 'Saving...',
      'enterTitle': 'Enter a title.',
      'enterAmount': 'Enter an amount.',
      'enterValidNumber': 'Enter a valid number.',
      'enterValidAmount': 'Enter a valid amount.',
      'transactionSaved': 'Transaction saved.',
      'transactionSaveFailed': 'Failed to save: {error}',
      'transactionDeleted': 'Transaction deleted.',
      'transactionDeleteFailed': 'Failed to delete: {error}',
      'processing': 'Processing...',
      'requiredField': 'This field is required.',
      'invalidEmail': 'Invalid email address.',
      'authEmailInUse': 'Email already in use.',
      'insightsTitle': 'Insights',
      'insightsSubtitle': 'This month overview',
      'statsTitle': 'Cashflow movement',
      'week': 'Day',
      'month': 'Month',
      'year': 'Year',
      'difference': 'Difference',
      'selectMonth': 'Selected month',
      'selectYear': 'Selected year',
      'trendTitle': 'Movement',
      'compareSamePeriod': 'Compare period',
      'periodWeek': 'yesterday',
      'periodMonth': 'last month',
      'periodYear': 'last year',
      'currentWeek': 'today',
      'currentMonth': 'selected month',
      'currentYear': 'selected year',
      'totalIncomeForRange': 'Total income {range}',
      'totalExpenseForRange': 'Total spending {range}',
      'totalDifferenceForRange': 'Total difference {range}',
      'increaseComparedTo': 'Up {amount} vs {range}',
      'decreaseComparedTo': 'Down {amount} vs {range}',
      'balanceBreakdown': 'Monthly breakdown',
      'detailByMonth': 'Monthly breakdown',
      'detailByWeek': 'Weekly breakdown',
      'detailByHour': 'Hourly breakdown',
      'detailByDay': 'Daily breakdown',
      'childCategories': 'Child categories',
      'totalSpending': 'Total spending',
      'monthlyTrend': 'Monthly trend',
      'spendingPulse': 'Spending pulse',
      'spendingByCategory': 'Spending by category',
      'noSpendingData': 'No spending data for this range.',
      'savingsGoal': 'Savings goal',
      'savingsSubtitle': 'Reach {target} by June',
      'saved': 'Saved',
      'historyTitle': 'Transaction history',
      'historySubtitle': 'Search, filter, and manage every money movement.',
      'searchTransactions': 'Search transactions',
      'allTransactions': 'All',
      'historyCount': '{count} matching transactions',
      'noMatchingTransactions': 'No matching transactions found.',
      'budgetTitle': 'Monthly budget',
      'budgetSubtitle': 'Set limits and monitor spending pace in real time.',
      'setMonthlyBudget': 'Set monthly limit',
      'budgetLimitLabel': 'Budget limit',
      'saveBudget': 'Save budget',
      'budgetSaved': 'Budget saved.',
      'budgetSaveFailed': 'Failed to save budget: {error}',
      'groupFundTitle': 'Group fund',
      'groupFundSubtitle': 'Create a shared fund and track money together.',
      'groupFundGoogleOnlyTitle': 'Google account required',
      'groupFundGoogleOnlySubtitle':
          'Group funds use Google identity so leaders can invite members safely.',
      'signInWithGoogleToUse': 'Sign in with Google to use group funds',
      'createGroupFund': 'Create group fund',
      'groupFundName': 'Fund name',
      'inviteMember': 'Invite member',
      'memberEmail': 'Member email',
      'addFundTransaction': 'Add fund transaction',
      'noGroupFunds': 'No group funds yet. Create one to start.',
      'fundMembers': 'Members',
      'fundBalance': 'Fund balance',
      'leader': 'Leader',
      'member': 'Member',
      'currentBudgetProgress': 'Current progress',
      'noBudgetYet': 'No budget has been set for this month.',
      'dailyReminder': 'Daily recording reminder',
      'dailyReminderSubtitle':
          'Open the app every evening to keep your spending history complete.',
      'reminderEnabled': 'Daily reminder enabled.',
      'reminderDisabled': 'Daily reminder disabled.',
      'overallBudget': 'Overall budget',
      'authLoginTitle': 'Welcome back',
      'authRegisterTitle': 'Create an account',
      'authLoginSubtitle': 'Sign in to manage your money flow.',
      'authRegisterSubtitle': 'Start tracking expenses in minutes.',
      'nameLabel': 'Full name',
      'emailLabel': 'Email',
      'passwordLabel': 'Password',
      'confirmPasswordLabel': 'Confirm password',
      'loginButton': 'Sign in',
      'registerButton': 'Create account',
      'googleSignIn': 'Continue with Google',
      'switchToRegister': 'No account? Create one',
      'switchToLogin': 'Already have an account? Sign in',
      'orContinueWith': 'Or continue with',
      'authError': 'Authentication failed. Please try again.',
      'invalidLogin':
          'Email or password is incorrect. Create an account first if you are new.',
      'googleAuthError':
          'Google sign-in failed. Please check Firebase setup and try again.',
      'passwordTooShort': 'Password must be at least 6 characters.',
      'passwordMismatch': 'Passwords do not match.',
      'forgotPassword': 'Forgot password?',
      'resetPasswordTitle': 'Reset Password',
      'resetPasswordSubtitle': 'Enter your email to receive a reset link.',
      'resetPasswordSent': 'Password reset link sent to your email.',
      'resetPasswordFailed': 'Failed to send reset link.',
      'incomeType': 'Income',
      'categoryFood': 'Food',
      'categoryBills': 'Bills',
      'categoryTravel': 'Travel',
      'categoryShopping': 'Shopping',
      'categoryOther': 'Other',
      'defaultUserName': 'friend',
    },
    'vi': {
      'appTitle': 'EggTrack',
      'navHome': 'Trang chủ',
      'navAdd': 'Thêm',
      'navHistory': 'Lịch sử',
      'navBudget': 'Ngân sách',
      'navGroupFund': 'Quỹ nhóm',
      'navStats': 'Thống kê',
      'language': 'Ngôn ngữ',
      'languageEnglish': 'Tiếng Anh',
      'languageVietnamese': 'Tiếng Việt',
      'signOut': 'Đăng xuất',
      'greeting': 'Xin chào, {name}',
      'dashboardSubtitle': 'Theo dõi từng khoản tiền trong giỏ EggTrack.',
      'totalBalance': 'Số dư tổng',
      'income': 'Thu nhập',
      'spent': 'Chi tiêu',
      'quickActions': 'Tác vụ nhanh',
      'customize': 'Tùy chỉnh',
      'addTransactionAction': 'Thêm giao dịch',
      'categoriesAction': 'Danh mục',
      'insightsAction': 'Thống kê',
      'tapToOpen': 'Nhấn để mở',
      'budgetPace': 'Tiến độ ngân sách',
      'budgetPaceSubtitle': 'Đã dùng {percent}% ngân sách tháng',
      'recentTransactions': 'Giao dịch gần đây',
      'seeAll': 'Xem tất cả',
      'noTransactions':
          'Chưa có giao dịch. Hãy thêm giao dịch đầu tiên ở tab Thêm.',
      'noTransactionsSummary': 'Chưa có giao dịch',
      'transactionsThisMonth': '{count} giao dịch trong tháng',
      'newTransaction': 'Giao dịch mới',
      'newTransactionSubtitle': 'Lưu lại mọi chi tiết quan trọng.',
      'typeLabel': 'Loại',
      'expense': 'Chi tiêu',
      'details': 'Chi tiết',
      'titleLabel': 'Tiêu đề',
      'amountLabel': 'Số tiền',
      'categoryLabel': 'Danh mục',
      'notesLabel': 'Ghi chú',
      'noteHint': 'Thêm ghi chú (tùy chọn)',
      'schedule': 'Thời gian',
      'account': 'Tài khoản',
      'scheduleSubtitle': 'Hôm nay, 9:40',
      'accountSubtitle': 'Thẻ hằng ngày',
      'saveTransaction': 'Lưu giao dịch',
      'saving': 'Đang lưu...',
      'enterTitle': 'Nhập tiêu đề.',
      'enterAmount': 'Nhập số tiền.',
      'enterValidNumber': 'Nhập số hợp lệ.',
      'enterValidAmount': 'Số tiền không hợp lệ.',
      'transactionSaved': 'Đã lưu giao dịch.',
      'transactionSaveFailed': 'Lưu thất bại: {error}',
      'transactionDeleted': 'Đã xóa giao dịch.',
      'transactionDeleteFailed': 'Xóa thất bại: {error}',
      'historyTitle': 'Lịch sử giao dịch',
      'historySubtitle': 'Tìm kiếm, lọc và quản lý mọi giao dịch.',
      'searchTransactions': 'Tìm giao dịch',
      'allTransactions': 'Tất cả',
      'historyCount': '{count} giao dịch phù hợp',
      'noMatchingTransactions': 'Không tìm thấy giao dịch phù hợp.',
      'budgetTitle': 'Ngân sách tháng',
      'budgetSubtitle': 'Đặt giới hạn và theo dõi tốc độ chi tiêu.',
      'setMonthlyBudget': 'Đặt hạn mức tháng',
      'budgetLimitLabel': 'Hạn mức ngân sách',
      'saveBudget': 'Lưu ngân sách',
      'budgetSaved': 'Đã lưu ngân sách.',
      'budgetSaveFailed': 'Lưu ngân sách thất bại: {error}',
      'currentBudgetProgress': 'Tiến độ hiện tại',
      'noBudgetYet': 'Chưa đặt ngân sách cho tháng này.',
      'dailyReminder': 'Nhắc ghi chép hằng ngày',
      'dailyReminderSubtitle':
          'Mở ứng dụng mỗi tối để giữ lịch sử chi tiêu đầy đủ.',
      'reminderEnabled': 'Đã bật nhắc ghi chép hằng ngày.',
      'reminderDisabled': 'Đã tắt nhắc ghi chép hằng ngày.',
      'overallBudget': 'Ngân sách tổng',
      'groupFundTitle': 'Quỹ nhóm',
      'groupFundSubtitle': 'Tạo quỹ chung và theo dõi tiền cùng nhau.',
      'groupFundGoogleOnlyTitle': 'Cần tài khoản Google',
      'groupFundGoogleOnlySubtitle':
          'Quỹ nhóm dùng danh tính Google để trưởng nhóm mời thành viên an toàn.',
      'signInWithGoogleToUse': 'Đăng nhập Google để dùng Quỹ nhóm',
      'createGroupFund': 'Tạo Quỹ nhóm',
      'groupFundName': 'Tên quỹ',
      'inviteMember': 'Mời thành viên',
      'memberEmail': 'Email thành viên',
      'addFundTransaction': 'Thêm giao dịch quỹ',
      'noGroupFunds': 'Chưa có Quỹ nhóm. Hãy tạo một quỹ để bắt đầu.',
      'fundMembers': 'Thành viên',
      'fundBalance': 'Số dư quỹ',
      'leader': 'Trưởng nhóm',
      'member': 'Thành viên',
      'processing': 'Đang xử lý...',
      'requiredField': 'Không được để trống.',
      'invalidEmail': 'Email không hợp lệ.',
      'authEmailInUse': 'Email đã tồn tại.',
      'insightsTitle': 'Thống kê',
      'insightsSubtitle': 'Tổng quan tháng này',
      'statsTitle': 'Biến động thu chi',
      'week': 'Ngày',
      'month': 'Tháng',
      'year': 'Năm',
      'difference': 'Chênh lệch',
      'selectMonth': 'Chọn tháng',
      'selectYear': 'Chọn năm',
      'trendTitle': 'Biến động',
      'compareSamePeriod': 'So với cùng kỳ',
      'periodWeek': 'hôm qua',
      'periodMonth': 'tháng trước',
      'periodYear': 'năm trước',
      'currentWeek': 'hôm nay',
      'currentMonth': 'tháng đang chọn',
      'currentYear': 'năm đang chọn',
      'totalIncomeForRange': 'Tổng thu {range}',
      'totalExpenseForRange': 'Tổng chi {range}',
      'totalDifferenceForRange': 'Tổng chênh lệch {range}',
      'increaseComparedTo': 'Tăng {amount} so với cùng kỳ {range}',
      'decreaseComparedTo': 'Giảm {amount} so với cùng kỳ {range}',
      'balanceBreakdown': 'Chi tiết theo tháng',
      'detailByMonth': 'Chi tiết theo tháng',
      'detailByWeek': 'Chi tiết theo tuần',
      'detailByHour': 'Chi tiết theo giờ',
      'detailByDay': 'Chi tiết theo ngày',
      'childCategories': 'Danh mục con',
      'totalSpending': 'Tổng chi tiêu',
      'monthlyTrend': 'Xu hướng tháng',
      'spendingPulse': 'Nhịp chi tiêu',
      'spendingByCategory': 'Chi tiêu theo danh mục',
      'noSpendingData': 'Chưa có dữ liệu chi tiêu.',
      'savingsGoal': 'Mục tiêu tiết kiệm',
      'savingsSubtitle': 'Đạt {target} vào tháng 6',
      'saved': 'Tiết kiệm',
      'authLoginTitle': 'Chào mừng quay lại',
      'authRegisterTitle': 'Tạo tài khoản',
      'authLoginSubtitle': 'Đăng nhập để quản lý dòng tiền.',
      'authRegisterSubtitle': 'Bắt đầu theo dõi chi tiêu trong vài phút.',
      'nameLabel': 'Họ và tên',
      'emailLabel': 'Email',
      'passwordLabel': 'Mật khẩu',
      'confirmPasswordLabel': 'Nhập lại mật khẩu',
      'loginButton': 'Đăng nhập',
      'registerButton': 'Đăng ký',
      'googleSignIn': 'Tiếp tục với Google',
      'switchToRegister': 'Chưa có tài khoản? Đăng ký',
      'switchToLogin': 'Đã có tài khoản? Đăng nhập',
      'orContinueWith': 'Hoặc tiếp tục với',
      'authError': 'Đăng nhập thất bại. Vui lòng thử lại.',
      'invalidLogin':
          'Email hoặc mật khẩu không đúng. Nếu chưa có tài khoản, hãy đăng ký trước.',
      'googleAuthError':
          'Đăng nhập Google thất bại. Vui lòng kiểm tra cấu hình Firebase rồi thử lại.',
      'passwordTooShort': 'Mật khẩu phải có ít nhất 6 ký tự.',
      'passwordMismatch': 'Mật khẩu không khớp.',
      'forgotPassword': 'Quên mật khẩu?',
      'resetPasswordTitle': 'Đặt lại mật khẩu',
      'resetPasswordSubtitle': 'Nhập email để nhận link đặt lại mật khẩu.',
      'resetPasswordSent': 'Link đặt lại mật khẩu đã được gửi đến email.',
      'resetPasswordFailed': 'Không thể gửi link đặt lại mật khẩu.',
      'incomeType': 'Thu nhập',
      'categoryFood': 'Ăn uống',
      'categoryBills': 'Hóa đơn',
      'categoryTravel': 'Đi lại',
      'categoryShopping': 'Mua sắm',
      'categoryOther': 'Khác',
      'defaultUserName': 'bạn',
    },
  };

  String _text(String key) {
    final lang = locale.languageCode;
    return _values[lang]?[key] ?? _values['en']![key] ?? key;
  }

  String _format(String key, Map<String, String> params) {
    var value = _text(key);
    params.forEach((name, replacement) {
      value = value.replaceAll('{$name}', replacement);
    });
    return value;
  }

  String get appTitle => _text('appTitle');
  String get navHome => _text('navHome');
  String get navAdd => _text('navAdd');
  String get navHistory => _text('navHistory');
  String get navBudget => _text('navBudget');
  String get navGroupFund => _text('navGroupFund');
  String get navStats => _text('navStats');
  String get language => _text('language');
  String get languageEnglish => _text('languageEnglish');
  String get languageVietnamese => _text('languageVietnamese');
  String get signOut => _text('signOut');
  String get dashboardSubtitle => _text('dashboardSubtitle');
  String get totalBalance => _text('totalBalance');
  String get income => _text('income');
  String get spent => _text('spent');
  String get quickActions => _text('quickActions');
  String get customize => _text('customize');
  String get addTransactionAction => _text('addTransactionAction');
  String get categoriesAction => _text('categoriesAction');
  String get insightsAction => _text('insightsAction');
  String get tapToOpen => _text('tapToOpen');
  String get budgetPace => _text('budgetPace');
  String budgetPaceSubtitle(int percent) =>
      _format('budgetPaceSubtitle', {'percent': '$percent'});
  String get recentTransactions => _text('recentTransactions');
  String get seeAll => _text('seeAll');
  String get noTransactions => _text('noTransactions');
  String get noTransactionsSummary => _text('noTransactionsSummary');
  String get newTransaction => _text('newTransaction');
  String get newTransactionSubtitle => _text('newTransactionSubtitle');
  String get typeLabel => _text('typeLabel');
  String get expense => _text('expense');
  String get incomeType => _text('incomeType');
  String get details => _text('details');
  String get titleLabel => _text('titleLabel');
  String get amountLabel => _text('amountLabel');
  String get categoryLabel => _text('categoryLabel');
  String get notesLabel => _text('notesLabel');
  String get noteHint => _text('noteHint');
  String get schedule => _text('schedule');
  String get account => _text('account');
  String get scheduleSubtitle => _text('scheduleSubtitle');
  String get accountSubtitle => _text('accountSubtitle');
  String get saveTransaction => _text('saveTransaction');
  String get saving => _text('saving');
  String get enterTitle => _text('enterTitle');
  String get enterAmount => _text('enterAmount');
  String get enterValidNumber => _text('enterValidNumber');
  String get enterValidAmount => _text('enterValidAmount');
  String get transactionSaved => _text('transactionSaved');
  String get transactionDeleted => _text('transactionDeleted');
  String get processing => _text('processing');
  String get requiredField => _text('requiredField');
  String get invalidEmail => _text('invalidEmail');
  String get authEmailInUse => _text('authEmailInUse');
  String get insightsTitle => _text('insightsTitle');
  String get insightsSubtitle => _text('insightsSubtitle');
  String get statsTitle => _text('statsTitle');
  String get week => _text('week');
  String get month => _text('month');
  String get year => _text('year');
  String get difference => _text('difference');
  String get selectMonth => _text('selectMonth');
  String get selectYear => _text('selectYear');
  String get trendTitle => _text('trendTitle');
  String get compareSamePeriod => _text('compareSamePeriod');
  String get periodWeek => _text('periodWeek');
  String get periodMonth => _text('periodMonth');
  String get periodYear => _text('periodYear');
  String get currentWeek => _text('currentWeek');
  String get currentMonth => _text('currentMonth');
  String get currentYear => _text('currentYear');
  String totalIncomeForRange(String range) =>
      _format('totalIncomeForRange', {'range': range});
  String totalExpenseForRange(String range) =>
      _format('totalExpenseForRange', {'range': range});
  String totalDifferenceForRange(String range) =>
      _format('totalDifferenceForRange', {'range': range});
  String increaseComparedTo(String amount, String range) =>
      _format('increaseComparedTo', {'amount': amount, 'range': range});
  String decreaseComparedTo(String amount, String range) =>
      _format('decreaseComparedTo', {'amount': amount, 'range': range});
  String get balanceBreakdown => _text('balanceBreakdown');
  String get detailByMonth => _text('detailByMonth');
  String get detailByWeek => _text('detailByWeek');
  String get detailByHour => _text('detailByHour');
  String get detailByDay => _text('detailByDay');
  String get childCategories => _text('childCategories');
  String get totalSpending => _text('totalSpending');
  String get monthlyTrend => _text('monthlyTrend');
  String get spendingPulse => _text('spendingPulse');
  String get spendingByCategory => _text('spendingByCategory');
  String get noSpendingData => _text('noSpendingData');
  String get savingsGoal => _text('savingsGoal');
  String get saved => _text('saved');
  String get historyTitle => _text('historyTitle');
  String get historySubtitle => _text('historySubtitle');
  String get searchTransactions => _text('searchTransactions');
  String get allTransactions => _text('allTransactions');
  String get noMatchingTransactions => _text('noMatchingTransactions');
  String get budgetTitle => _text('budgetTitle');
  String get budgetSubtitle => _text('budgetSubtitle');
  String get setMonthlyBudget => _text('setMonthlyBudget');
  String get budgetLimitLabel => _text('budgetLimitLabel');
  String get saveBudget => _text('saveBudget');
  String get budgetSaved => _text('budgetSaved');
  String get groupFundTitle => _text('groupFundTitle');
  String get groupFundSubtitle => _text('groupFundSubtitle');
  String get groupFundGoogleOnlyTitle => _text('groupFundGoogleOnlyTitle');
  String get groupFundGoogleOnlySubtitle =>
      _text('groupFundGoogleOnlySubtitle');
  String get signInWithGoogleToUse => _text('signInWithGoogleToUse');
  String get createGroupFund => _text('createGroupFund');
  String get groupFundName => _text('groupFundName');
  String get inviteMember => _text('inviteMember');
  String get memberEmail => _text('memberEmail');
  String get addFundTransaction => _text('addFundTransaction');
  String get noGroupFunds => _text('noGroupFunds');
  String get fundMembers => _text('fundMembers');
  String get fundBalance => _text('fundBalance');
  String get leader => _text('leader');
  String get member => _text('member');
  String get currentBudgetProgress => _text('currentBudgetProgress');
  String get noBudgetYet => _text('noBudgetYet');
  String get dailyReminder => _text('dailyReminder');
  String get dailyReminderSubtitle => _text('dailyReminderSubtitle');
  String get reminderEnabled => _text('reminderEnabled');
  String get reminderDisabled => _text('reminderDisabled');
  String get overallBudget => _text('overallBudget');
  String get authLoginTitle => _text('authLoginTitle');
  String get authRegisterTitle => _text('authRegisterTitle');
  String get authLoginSubtitle => _text('authLoginSubtitle');
  String get authRegisterSubtitle => _text('authRegisterSubtitle');
  String get nameLabel => _text('nameLabel');
  String get emailLabel => _text('emailLabel');
  String get passwordLabel => _text('passwordLabel');
  String get confirmPasswordLabel => _text('confirmPasswordLabel');
  String get loginButton => _text('loginButton');
  String get registerButton => _text('registerButton');
  String get googleSignIn => _text('googleSignIn');
  String get switchToRegister => _text('switchToRegister');
  String get switchToLogin => _text('switchToLogin');
  String get orContinueWith => _text('orContinueWith');
  String get authError => _text('authError');
  String get invalidLogin => _text('invalidLogin');
  String get googleAuthError => _text('googleAuthError');
  String get passwordTooShort => _text('passwordTooShort');
  String get passwordMismatch => _text('passwordMismatch');
  String get forgotPassword => _text('forgotPassword');
  String get resetPasswordTitle => _text('resetPasswordTitle');
  String get resetPasswordSubtitle => _text('resetPasswordSubtitle');
  String get resetPasswordSent => _text('resetPasswordSent');
  String get resetPasswordFailed => _text('resetPasswordFailed');
  String get defaultUserName => _text('defaultUserName');

  String greeting(String name) => _format('greeting', {'name': name});

  String transactionsThisMonth(int count) =>
      _format('transactionsThisMonth', {'count': '$count'});

  String transactionSaveFailed(String error) =>
      _format('transactionSaveFailed', {'error': error});

  String transactionDeleteFailed(String error) =>
      _format('transactionDeleteFailed', {'error': error});

  String budgetSaveFailed(String error) =>
      _format('budgetSaveFailed', {'error': error});

  String historyCount(int count) =>
      _format('historyCount', {'count': '$count'});

  String savingsSubtitle(String target) =>
      _format('savingsSubtitle', {'target': target});

  String categoryName(String key) {
    switch (key) {
      case 'food':
        return _text('categoryFood');
      case 'bills':
        return _text('categoryBills');
      case 'travel':
        return _text('categoryTravel');
      case 'shopping':
        return _text('categoryShopping');
      default:
        return _text('categoryOther');
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
