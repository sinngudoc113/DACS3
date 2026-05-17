import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('vi'),
  ];

  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
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
      'noTransactions': 'No transactions yet. Add your first one from the Add tab.',
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
      'authRegisterTitle': 'Create account',
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
      'passwordTooShort': 'Password must be at least 6 characters.',
      'passwordMismatch': 'Passwords do not match.',
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
      'navHome': 'Trang chu',
      'navAdd': 'Them',
      'navStats': 'Thong ke',
      'language': 'Ngon ngu',
      'languageEnglish': 'Tieng Anh',
      'languageVietnamese': 'Tieng Viet',
      'signOut': 'Dang xuat',
      'greeting': 'Xin chao, {name}',
      'dashboardSubtitle': 'Dong tien tuan nay cua ban.',
      'totalBalance': 'So du tong',
      'income': 'Thu nhap',
      'spent': 'Chi tieu',
      'quickActions': 'Tac vu nhanh',
      'customize': 'Tuy chinh',
      'addTransactionAction': 'Them giao dich',
      'categoriesAction': 'Danh muc',
      'insightsAction': 'Thong ke',
      'tapToOpen': 'Nhan de mo',
      'budgetPace': 'Tien do ngan sach',
      'budgetPaceSubtitle': 'Da dung 72% ngan sach thang',
      'recentTransactions': 'Giao dich gan day',
      'seeAll': 'Xem tat ca',
      'noTransactions': 'Chua co giao dich. Hay them giao dich dau tien o tab Them.',
      'noTransactionsSummary': 'Chua co giao dich',
      'transactionsThisMonth': '{count} giao dich trong thang',
      'newTransaction': 'Giao dich moi',
      'newTransactionSubtitle': 'Luu lai moi chi tiet quan trong.',
      'typeLabel': 'Loai',
      'expense': 'Chi tieu',
      'details': 'Chi tiet',
      'titleLabel': 'Tieu de',
      'amountLabel': 'So tien',
      'categoryLabel': 'Danh muc',
      'notesLabel': 'Ghi chu',
      'noteHint': 'Them ghi chu (tuy chon)',
      'schedule': 'Thoi gian',
      'account': 'Tai khoan',
      'scheduleSubtitle': 'Hom nay, 9:40',
      'accountSubtitle': 'The hang ngay',
      'saveTransaction': 'Luu giao dich',
      'saving': 'Dang luu...',
      'enterTitle': 'Nhap tieu de.',
      'enterAmount': 'Nhap so tien.',
      'enterValidNumber': 'Nhap so hop le.',
      'enterValidAmount': 'So tien khong hop le.',
      'transactionSaved': 'Da luu giao dich.',
      'transactionSaveFailed': 'Luu that bai: {error}',
      'processing': 'Dang xu ly...',
      'requiredField': 'Khong duoc de trong.',
      'invalidEmail': 'Email khong hop le.',
      'authEmailInUse': 'Email da ton tai.',
      'insightsTitle': 'Thong ke',
      'insightsSubtitle': 'Tong quan thang nay',
      'week': 'Tuan',
      'month': 'Thang',
      'year': 'Nam',
      'totalSpending': 'Tong chi tieu',
      'monthlyTrend': 'Xu huong thang',
      'spendingPulse': 'Nhip chi tieu',
      'spendingByCategory': 'Chi tieu theo danh muc',
      'noSpendingData': 'Chua co du lieu chi tieu.',
      'savingsGoal': 'Muc tieu tiet kiem',
      'savingsSubtitle': 'Dat {target} vao thang 6',
      'saved': 'Tiet kiem',
      'authLoginTitle': 'Chao mung quay lai',
      'authRegisterTitle': 'Tao tai khoan',
      'authLoginSubtitle': 'Dang nhap de quan ly dong tien.',
      'authRegisterSubtitle': 'Bat dau theo doi chi tieu trong vai phut.',
      'nameLabel': 'Ho va ten',
      'emailLabel': 'Email',
      'passwordLabel': 'Mat khau',
      'confirmPasswordLabel': 'Nhap lai mat khau',
      'loginButton': 'Dang nhap',
      'registerButton': 'Dang ky',
      'googleSignIn': 'Tiep tuc voi Google',
      'switchToRegister': 'Chua co tai khoan? Dang ky',
      'switchToLogin': 'Da co tai khoan? Dang nhap',
      'orContinueWith': 'Hoac tiep tuc voi',
      'authError': 'Dang nhap that bai. Vui long thu lai.',
      'passwordTooShort': 'Mat khau toi thieu 6 ky tu.',
      'passwordMismatch': 'Mat khau khong khop.',
      'incomeType': 'Thu nhap',
      'categoryFood': 'An uong',
      'categoryBills': 'Hoa don',
      'categoryTravel': 'Di lai',
      'categoryShopping': 'Mua sam',
      'categoryOther': 'Khac',
      'defaultUserName': 'ban',
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
  String get passwordTooShort => _text('passwordTooShort');
  String get passwordMismatch => _text('passwordMismatch');
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
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
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
