// lib/core/utils/logger.dart
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error }

class Logger {
  static bool _isEnabled = true;
  static LogLevel _minLevel = LogLevel.debug;
  static File? _logFile;

  static void configure({
    bool enabled = true,
    LogLevel minLevel = LogLevel.debug,
    bool writeToFile = false,
  }) {
    _isEnabled = enabled;
    _minLevel = minLevel;
    
    if (writeToFile) {
      _initLogFile();
    }
  }

  static Future<void> _initLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/smart_money_bell.log');
    } catch (e) {
      print('Failed to initialize log file: $e');
    }
  }

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  static void _log(LogLevel level, String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isEnabled || level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();
    final logMessage = '[$timestamp] [$levelStr] $message';

    // نمایش در کنسول
    developer.log(
      message,
      name: 'SmartMoneyBell',
      time: DateTime.now(),
      level: _getLogLevelValue(level),
      error: error,
      stackTrace: stackTrace,
    );

    // نوشتن در فایل
    _writeToFile(logMessage, error, stackTrace);
  }

  static int _getLogLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  static void _writeToFile(String message, [Object? error, StackTrace? stackTrace]) {
    if (_logFile == null) return;

    try {
      var logEntry = message;
      if (error != null) {
        logEntry += '\nError: $error';
      }
      if (stackTrace != null) {
        logEntry += '\nStackTrace: $stackTrace';
      }
      logEntry += '\n';

      _logFile!.writeAsStringSync(logEntry, mode: FileMode.append);
    } catch (e) {
      print('Failed to write to log file: $e');
    }
  }

  static Future<String?> getLogFileContent() async {
    if (_logFile == null || !await _logFile!.exists()) return null;
    
    try {
      return await _logFile!.readAsString();
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearLogFile() async {
    if (_logFile == null) return;
    
    try {
      await _logFile!.writeAsString('');
    } catch (e) {
      print('Failed to clear log file: $e');
    }
  }
}

// lib/core/utils/constants.dart
class AppConstants {
  // اطلاعات اپلیکیشن
  static const String appName = 'Smart Money Bell';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'دستیار هوشمند یک دو سه';

  // تنظیمات دیتابیس
  static const String databaseName = 'smart_money_bell.db';
  static const int databaseVersion = 1;

  // تنظیمات توکن
  static const double defaultTokenConversionRate = 500.0; // 1 توکن = 500 تومان
  static const int dailyLoginBonus = 10;
  static const int referralBonus = 100;
  static const int investmentTokenRate = 5; // 5 توکن به ازای هر 100 هزار تومان

  // تنظیمات گیمیفیکیشن
  static const List<int> levelThresholds = [
    0,     // سطح 1
    100,   // سطح 2
    250,   // سطح 3
    500,   // سطح 4
    1000,  // سطح 5
    2000,  // سطح 6
    5000,  // سطح 7
    10000, // سطح 8
  ];

  // تنظیمات UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 16.0;

  // مدت زمان انیمیشن‌ها
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // URL ها و API
  static const String supportEmail = 'support@smartmoneybell.com';
  static const String termsUrl = 'https://smartmoneybell.com/terms';
  static const String privacyUrl = 'https://smartmoneybell.com/privacy';

  // کلیدهای SharedPreferences
  static const String keyUserId = 'user_id';
  static const String keyUserToken = 'user_token';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyLastBackup = 'last_backup';

  // پیام‌های خطا
  static const String errorGeneral = 'خطایی رخ داده است. لطفاً دوباره تلاش کنید.';
  static const String errorNetwork = 'خطا در اتصال به اینترنت. لطفاً اتصال خود را بررسی کنید.';
  static const String errorInvalidEmail = 'ایمیل وارد شده معتبر نیست.';
  static const String errorInvalidPhone = 'شماره تلفن وارد شده معتبر نیست.';
  static const String errorPasswordTooShort = 'رمز عبور باید حداقل 6 کاراکتر باشد.';
  static const String errorUserNotFound = 'کاربر یافت نشد.';
  static const String errorInsufficientTokens = 'موجودی توکن کافی نیست.';

  // پیام‌های موفقیت
  static const String successLogin = 'ورود موفقیت‌آمیز';
  static const String successSignup = 'ثبت‌نام موفقیت‌آمیز';
  static const String successInvestment = 'سرمایه‌گذاری با موفقیت ثبت شد';
  static const String successTokenConversion = 'توکن‌ها با موفقیت تبدیل شدند';
  static const String successProfileUpdate = 'پروفایل با موفقیت به‌روزرسانی شد';
}

// lib/core/utils/validators.dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'ایمیل الزامی است';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return AppConstants.errorInvalidEmail;
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'شماره تلفن الزامی است';
    }
    
    // حذف کاراکترهای غیرعددی
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // بررسی طول شماره
    if (cleanPhone.length != 11) {
      return AppConstants.errorInvalidPhone;
    }
    
    // بررسی شروع با 09
    if (!cleanPhone.startsWith('09')) {
      return AppConstants.errorInvalidPhone;
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز عبور الزامی است';
    }
    
    if (value.length < 6) {
      return AppConstants.errorPasswordTooShort;
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName الزامی است';
    }
    return null;
  }

  static String? validateAmount(String? value, {double minAmount = 0}) {
    if (value == null || value.isEmpty) {
      return 'مبلغ الزامی است';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'مبلغ باید عدد باشد';
    }
    
    if (amount <= minAmount) {
      return 'مبلغ باید بیشتر از ${formatCurrency(minAmount)} باشد';
    }
    
    return null;
  }

  static String? validateTokenAmount(String? value, double availableTokens) {
    if (value == null || value.isEmpty) {
      return 'تعداد توکن الزامی است';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'تعداد توکن باید عدد باشد';
    }
    
    if (amount <= 0) {
      return 'تعداد توکن باید بیشتر از صفر باشد';
    }
    
    if (amount > availableTokens) {
      return 'موجودی توکن کافی نیست';
    }
    
    return null;
  }
}

// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class Formatters {
  static final _currencyFormatter = NumberFormat('#,###');
  static final _decimalFormatter = NumberFormat('#,###.##');
  static final _dateFormatter = DateFormat('yyyy/MM/dd');
  static final _timeFormatter = DateFormat('HH:mm');
  static final _dateTimeFormatter = DateFormat('yyyy/MM/dd HH:mm');

  static String formatCurrency(double amount, {bool showUnit = true}) {
    final formatted = _currencyFormatter.format(amount.round());
    final persian = formatted.toPersianDigit();
    return showUnit ? '$persian تومان' : persian;
  }

  static String formatNumber(double number) {
    final formatted = _decimalFormatter.format(number);
    return formatted.toPersianDigit();
  }

  static String formatTokens(double tokens) {
    final formatted = _decimalFormatter.format(tokens);
    return '${formatted.toPersianDigit()} توکن';
  }

  static String formatPercentage(double percentage) {
    final formatted = NumberFormat('#.##').format(percentage);
    return '${formatted.toPersianDigit()}%';
  }

  static String formatDate(DateTime date) {
    return _dateFormatter.format(date).toPersianDigit();
  }

  static String formatTime(DateTime time) {
    return _timeFormatter.format(time).toPersianDigit();
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime).toPersianDigit();
  }

  static String formatPhone(String phone) {
    // حذف کاراکترهای غیرعددی
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length == 11 && cleanPhone.startsWith('09')) {
      final formatted = '${cleanPhone.substring(0, 4)}-${cleanPhone.substring(4, 7)}-${cleanPhone.substring(7)}';
      return formatted.toPersianDigit();
    }
    
    return phone.toPersianDigit();
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays.toString().toPersianDigit()} روز پیش';
    } else if (difference.inHours > 0) {
      return '${difference.inHours.toString().toPersianDigit()} ساعت پیش';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes.toString().toPersianDigit()} دقیقه پیش';
    } else {
      return 'همین الان';
    }
  }

  static String formatInvestmentDuration(DateTime startDate, DateTime? endDate) {
    if (endDate == null) {
      return 'نامحدود';
    }
    
    final duration = endDate.difference(startDate);
    final days = duration.inDays;
    
    if (days >= 365) {
      final years = (days / 365).floor();
      final remainingDays = days % 365;
      if (remainingDays == 0) {
        return '${years.toString().toPersianDigit()} سال';
      } else {
        return '${years.toString().toPersianDigit()} سال و ${remainingDays.toString().toPersianDigit()} روز';
      }
    } else if (days >= 30) {
      final months = (days / 30).floor();
      final remainingDays = days % 30;
      if (remainingDays == 0) {
        return '${months.toString().toPersianDigit()} ماه';
      } else {
        return '${months.toString().toPersianDigit()} ماه و ${remainingDays.toString().toPersianDigit()} روز';
      }
    } else {
      return '${days.toString().toPersianDigit()} روز';
    }
  }
}

// تابع کمکی برای دسترسی آسان
String formatCurrency(double amount, {bool showUnit = true}) => 
    Formatters.formatCurrency(amount, showUnit: showUnit);

String formatTokens(double tokens) => Formatters.formatTokens(tokens);
String formatPercentage(double percentage) => Formatters.formatPercentage(percentage);
String formatDate(DateTime date) => Formatters.formatDate(date);
String formatRelativeTime(DateTime dateTime) => Formatters.formatRelativeTime(dateTime);

// lib/core/utils/uuid_generator.dart
import 'dart:math';

class UuidGenerator {
  static final Random _random = Random();
  
  static String generate() {
    // ایجاد UUID ساده برای استفاده در اپلیکیشن
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = _random.nextInt(999999);
    return '$timestamp-$randomPart';
  }

  static String generateShort() {
    // ایجاد ID کوتاه برای نمایش به کاربر
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String result = '';
    for (int i = 0; i < 8; i++) {
      result += chars[_random.nextInt(chars.length)];
    }
    return result;
  }
}

// lib/core/utils/preferences_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('PreferencesHelper not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // String methods
  static String? getString(String key) => prefs.getString(key);
  static Future<bool> setString(String key, String value) => prefs.setString(key, value);

  // Bool methods
  static bool getBool(String key, {bool defaultValue = false}) => 
      prefs.getBool(key) ?? defaultValue;
  static Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);

  // Int methods
  static int getInt(String key, {int defaultValue = 0}) => 
      prefs.getInt(key) ?? defaultValue;
  static Future<bool> setInt(String key, int value) => prefs.setInt(key, value);

  // Double methods
  static double getDouble(String key, {double defaultValue = 0.0}) =>
      prefs.getDouble(key) ?? defaultValue;
  static Future<bool> setDouble(String key, double value) => prefs.setDouble(key, value);

  // List methods
  static List<String>? getStringList(String key) => prefs.getStringList(key);
  static Future<bool> setStringList(String key, List<String> value) => 
      prefs.setStringList(key, value);

  // Remove methods
  static Future<bool> remove(String key) => prefs.remove(key);
  static Future<bool> clear() => prefs.clear();

  // Convenience methods for app-specific keys
  static String? get userId => getString(AppConstants.keyUserId);
  static Future<bool> setUserId(String value) => setString(AppConstants.keyUserId, value);

  static bool get isFirstLaunch => getBool(AppConstants.keyIsFirstLaunch, defaultValue: true);
  static Future<bool> setFirstLaunch(bool value) => setBool(AppConstants.keyIsFirstLaunch, value);

  static bool get notificationsEnabled => getBool(AppConstants.keyNotificationsEnabled, defaultValue: true);
  static Future<bool> setNotificationsEnabled(bool value) => setBool(AppConstants.keyNotificationsEnabled, value);

  static bool get biometricEnabled => getBool(AppConstants.keyBiometricEnabled, defaultValue: false);
  static Future<bool> setBiometricEnabled(bool value) => setBool(AppConstants.keyBiometricEnabled, value);
}

// lib/core/utils/calculator.dart
class InvestmentCalculator {
  /// محاسبه سود ساده
  static double calculateSimpleProfit({
    required double principal,
    required double rate,
    required int days,
  }) {
    return (principal * rate / 100) * (days / 365);
  }

  /// محاسبه سود مرکب
  static double calculateCompoundProfit({
    required double principal,
    required double rate,
    required int days,
    int compoundingFrequency = 12, // ماهانه
  }) {
    final years = days / 365.0;
    final rateDecimal = rate / 100;
    final amount = principal * pow(1 + rateDecimal / compoundingFrequency, compoundingFrequency * years);
    return amount - principal;
  }

  /// محاسبه توکن بر اساس سرمایه‌گذاری
  static double calculateTokensFromInvestment(double investmentAmount) {
    return (investmentAmount / 100000) * AppConstants.investmentTokenRate;
  }

  /// محاسبه ارزش ریالی توکن‌ها
  static double calculateTokenValue(double tokens, {double? customRate}) {
    final rate = customRate ?? AppConstants.defaultTokenConversionRate;
    return tokens * rate;
  }

  /// محاسبه سطح کاربر بر اساس تجربه
  static int calculateUserLevel(int experience) {
    for (int i = AppConstants.levelThresholds.length - 1; i >= 0; i--) {
      if (experience >= AppConstants.levelThresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  /// محاسبه درصد پیشرفت تا سطح بعد
  static double calculateLevelProgress(int experience) {
    final currentLevel = calculateUserLevel(experience);
    
    if (currentLevel >= AppConstants.levelThresholds.length) {
      return 100.0; // حداکثر سطح
    }
    
    final currentLevelThreshold = AppConstants.levelThresholds[currentLevel - 1];
    final nextLevelThreshold = AppConstants.levelThresholds[currentLevel];
    
    final progress = (experience - currentLevelThreshold) / 
                    (nextLevelThreshold - currentLevelThreshold);
    
    return (progress * 100).clamp(0.0, 100.0);
  }

  /// محاسبه ROI (Return on Investment)
  static double calculateROI(double profit, double investment) {
    if (investment == 0) return 0;
    return (profit / investment) * 100;
  }

  /// محاسبه درآمد روزانه میانگین
  static double calculateDailyAverageIncome(List<double> dailyProfits) {
    if (dailyProfits.isEmpty) return 0;
    final sum = dailyProfits.reduce((a, b) => a + b);
    return sum / dailyProfits.length;
  }
}

// lib/core/utils/date_helper.dart
import 'package:shamsi_date/shamsi_date.dart';

class DateHelper {
  /// تبدیل تاریخ میلادی به شمسی
  static String toPersianDate(DateTime dateTime) {
    final jalali = Jalali.fromDateTime(dateTime);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  /// تبدیل تاریخ شمسی به میلادی
  static DateTime fromPersianDate(String persianDate) {
    final parts = persianDate.split('/');
    if (parts.length != 3) throw ArgumentError('Invalid Persian date format');
    
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    
    final jalali = Jalali(year, month, day);
    return jalali.toDateTime();
  }

  /// دریافت نام ماه فارسی
  static String getPersianMonthName(int month) {
    const months = [
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
      'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
    ];
    return months[month - 1];
  }

  /// دریافت نام روز هفته فارسی
  static String getPersianWeekday(DateTime dateTime) {
    const weekdays = [
      'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه', 'شنبه', 'یکشنبه'
    ];
    return weekdays[dateTime.weekday - 1];
  }

  /// بررسی اینکه آیا تاریخ امروز است
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  /// بررسی اینکه آیا تاریخ دیروز است
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return dateTime.year == yesterday.year &&
           dateTime.month == yesterday.month &&
           dateTime.day == yesterday.day;
  }

  /// محاسبه روزهای باقی‌مانده تا تاریخ مشخص
  static int daysUntil(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  /// محاسبه روزهای کاری بین دو تاریخ (به جز جمعه)
  static int getWorkingDays(DateTime startDate, DateTime endDate) {
    int workingDays = 0;
    DateTime current = startDate;
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (current.weekday != DateTime.friday) {
        workingDays++;
      }
      current = current.add(Duration(days: 1));
    }
    
    return workingDays;
  }

  /// دریافت اولین روز ماه
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// دریافت آخرین روز ماه
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// فرمت کامل تاریخ و زمان فارسی
  static String formatPersianDateTime(DateTime dateTime) {
    final jalali = Jalali.fromDateTime(dateTime);
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '${getPersianWeekday(dateTime)} ${jalali.day} ${getPersianMonthName(jalali.month)} ${jalali.year} ساعت $time';
  }
}

// lib/core/utils/encryption_helper.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptionHelper {
  static const String _salt = 'SmartMoneyBell2024';

  /// هش کردن رمز عبور
  static String hashPassword(String password) {
    final bytes = utf8.encode(password + _salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// تولید توکن امنیتی
  static String generateSecurityToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = userId + timestamp + _salt;
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 32);
  }

  /// تولید کد تایید
  static String generateVerificationCode({int length = 6}) {
    final random = Random();
    String code = '';
    for (int i = 0; i < length; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  /// رمزنگاری ساده متن
  static String encodeString(String input) {
    final bytes = utf8.encode(input);
    return base64Encode(bytes);
  }

  /// رمزگشایی متن
  static String decodeString(String encoded) {
    final bytes = base64Decode(encoded);
    return utf8.decode(bytes);
  }

  /// بررسی قدرت رمز عبور
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.length < 6) return PasswordStrength.weak;
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int score = 0;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasDigits) score++;
    if (hasSpecialChars) score++;
    if (password.length >= 8) score++;
    
    if (score >= 4) return PasswordStrength.strong;
    if (score >= 2) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }
}

enum PasswordStrength { weak, medium, strong }

// lib/core/utils/device_info.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    Map<String, dynamic> info = {};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        info = {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'id': androidInfo.id,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        info = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
          'id': iosInfo.identifierForVendor,
        };
      }
    } catch (e) {
      Logger.error('Error getting device info', e);
    }

    return info;
  }

  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      Logger.error('Error getting device ID', e);
    }
    
    return 'unknown';
  }

  static Future<bool> isPhysicalDevice() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.isPhysicalDevice;
      }
    } catch (e) {
      Logger.error('Error checking if physical device', e);
    }
    
    return true;
  }
}

// lib/core/utils/network_helper.dart
import 'dart:io';

class NetworkHelper {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      Logger.error('Error checking internet connection', e);
      return false;
    }
  }

  static Future<bool> canReachServer(String host, {int port = 80, Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// lib/core/utils/error_handler.dart
class AppError {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppError: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

class ErrorHandler {
  static AppError handleError(dynamic error, [StackTrace? stackTrace]) {
    Logger.error('Error occurred', error, stackTrace);

    if (error is SocketException) {
      return AppError(
        message: AppConstants.errorNetwork,
        code: 'NETWORK_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return AppError(
        message: 'خطا در پردازش داده‌ها',
        code: 'FORMAT_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is AppError) {
      return error;
    }

    return AppError(
      message: AppConstants.errorGeneral,
      code: 'UNKNOWN_ERROR',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static void reportError(AppError error) {
    // در اینجا می‌توان خطا را به سرویس‌های گزارش‌دهی مانند Crashlytics ارسال کرد
    Logger.error('Reported error: ${error.message}', error.originalError, error.stackTrace);
  }
}

// استفاده از import های لازم
import 'dart:math';
import 'dart:io';
import 'dart:convert';