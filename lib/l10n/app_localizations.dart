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
      'appTitle': 'Pulse Budget',
      'navHome': 'Home',
      'navAdd': 'Add',
      'navStats': 'Stats',
      'language': 'Language',
      'languageEnglish': 'English',
      'languageVietnamese': 'Vietnamese',
      'signOut': 'Sign out',
      'greeting': 'Hello, {name}',
      'dashboardSubtitle': 'Here is your money flow for the week.',
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
      'budgetPaceSubtitle': '72% of this month budget used',
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
      'processing': 'Processing...',
      'requiredField': 'This field is required.',
      'invalidEmail': 'Invalid email address.',
      'authEmailInUse': 'Email already in use.',
      'insightsTitle': 'Insights',
      'insightsSubtitle': 'This month overview',
      'week': 'Week',
      'month': 'Month',
      'year': 'Year',
      'totalSpending': 'Total spending',
      'monthlyTrend': 'Monthly trend',
      'spendingPulse': 'Spending pulse',
      'spendingByCategory': 'Spending by category',
      'noSpendingData': 'No spending data for this range.',
      'savingsGoal': 'Savings goal',
      'savingsSubtitle': 'Reach {target} by June',
      'saved': 'Saved',
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
      'appTitle': 'Pulse Budget',
      'navHome': 'Trang chủ',
      'navAdd': 'Thêm',
      'navStats': 'Thống kê',
      'language': 'Ngôn ngữ',
      'languageEnglish': 'Tiếng Anh',
      'languageVietnamese': 'Tiếng Việt',
      'signOut': 'Đăng xuất',
      'greeting': 'Xin chào, {name}',
      'dashboardSubtitle': 'Dòng tiền tuần này của bạn.',
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
      'budgetPaceSubtitle': 'Đã dùng 72% ngân sách tháng',
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
      'processing': 'Đang xử lý...',
      'requiredField': 'Không được để trống.',
      'invalidEmail': 'Email không hợp lệ.',
      'authEmailInUse': 'Email đã tồn tại.',
      'insightsTitle': 'Thống kê',
      'insightsSubtitle': 'Tổng quan tháng này',
      'week': 'Tuần',
      'month': 'Tháng',
      'year': 'Năm',
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
  String get budgetPaceSubtitle => _text('budgetPaceSubtitle');
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
  String get processing => _text('processing');
  String get requiredField => _text('requiredField');
  String get invalidEmail => _text('invalidEmail');
  String get authEmailInUse => _text('authEmailInUse');
  String get insightsTitle => _text('insightsTitle');
  String get insightsSubtitle => _text('insightsSubtitle');
  String get week => _text('week');
  String get month => _text('month');
  String get year => _text('year');
  String get totalSpending => _text('totalSpending');
  String get monthlyTrend => _text('monthlyTrend');
  String get spendingPulse => _text('spendingPulse');
  String get spendingByCategory => _text('spendingByCategory');
  String get noSpendingData => _text('noSpendingData');
  String get savingsGoal => _text('savingsGoal');
  String get saved => _text('saved');
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
