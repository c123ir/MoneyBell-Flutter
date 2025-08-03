// فایل مدل‌های داده - برای آینده
// این فایل را در lib/models/models.dart ذخیره کنید

// کلاس کاربر
class User {
  final String id; // شناسه یکتا
  final String name; // نام کاربر
  final String email; // ایمیل
  final String phone; // شماره تلفن
  final double tokenBalance; // موجودی توکن
  final double totalProfit; // سود کل
  final int level; // سطح کاربر
  final DateTime createdAt; // تاریخ عضویت

  // سازنده کلاس (Constructor)
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.tokenBalance,
    required this.totalProfit,
    required this.level,
    required this.createdAt,
  });

  // تبدیل به Map برای ذخیره در دیتابیس
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token_balance': tokenBalance,
      'total_profit': totalProfit,
      'level': level,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ساخت کاربر از Map (خواندن از دیتابیس)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      tokenBalance: map['token_balance'].toDouble(),
      totalProfit: map['total_profit'].toDouble(),
      level: map['level'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// کلاس سرمایه‌گذاری
class Investment {
  final String id; // شناسه یکتا
  final String userId; // شناسه کاربر
  final double amount; // مبلغ سرمایه‌گذاری
  final double profitRate; // نرخ سود (درصد)
  final DateTime startDate; // تاریخ شروع
  final DateTime? endDate; // تاریخ پایان (اختیاری)
  final InvestmentStatus status; // وضعیت
  final InvestmentType type; // نوع سرمایه‌گذاری

  Investment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.profitRate,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.type,
  });

  // محاسبه سود فعلی
  double calculateCurrentProfit() {
    final now = DateTime.now();
    final daysPassed = now.difference(startDate).inDays;
    return (amount * profitRate / 100) * (daysPassed / 365);
  }

  // تبدیل به Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'profit_rate': profitRate,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status.name,
      'type': type.name,
    };
  }

  // ساخت از Map
  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id'],
      userId: map['user_id'],
      amount: map['amount'].toDouble(),
      profitRate: map['profit_rate'].toDouble(),
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      status: InvestmentStatus.values.byName(map['status']),
      type: InvestmentType.values.byName(map['type']),
    );
  }
}

// انواع وضعیت سرمایه‌گذاری
enum InvestmentStatus {
  active, // فعال
  completed, // تکمیل شده
  cancelled, // لغو شده
  pending, // در انتظار
}

// انواع سرمایه‌گذاری
enum InvestmentType {
  fixed, // ثابت
  flexible, // انعطاف‌پذیر
  compound, // مرکب
}

// کلاس تراکنش توکن
class TokenTransaction {
  final String id; // شناسه یکتا
  final String userId; // شناسه کاربر
  final double amount; // مقدار توکن
  final TokenTransactionType type; // نوع تراکنش
  final String description; // توضیحات
  final DateTime createdAt; // تاریخ ایجاد

  TokenTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  // تبدیل به Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type.name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ساخت از Map
  factory TokenTransaction.fromMap(Map<String, dynamic> map) {
    return TokenTransaction(
      id: map['id'],
      userId: map['user_id'],
      amount: map['amount'].toDouble(),
      type: TokenTransactionType.values.byName(map['type']),
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// انواع تراکنش توکن
enum TokenTransactionType {
  earned, // کسب شده
  spent, // خرج شده
  converted, // تبدیل شده
  transferred, // انتقال یافته
  bonus, // پاداش
}

// کلاس فعالیت اخیر
class RecentActivity {
  final String id; // شناسه یکتا
  final String userId; // شناسه کاربر
  final String title; // عنوان
  final String description; // توضیحات
  final String icon; // نام آیکون
  final String color; // رنگ (hex)
  final DateTime createdAt; // تاریخ ایجاد

  RecentActivity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.createdAt,
  });

  // تبدیل به Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ساخت از Map
  factory RecentActivity.fromMap(Map<String, dynamic> map) {
    return RecentActivity(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      icon: map['icon'],
      color: map['color'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // محاسبه زمان گذشته (برای نمایش "2 ساعت پیش")
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} روز پیش';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعت پیش';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقیقه پیش';
    } else {
      return 'همین الان';
    }
  }
}

// کلاس اعلان
class Notification {
  final String id; // شناسه یکتا
  final String userId; // شناسه کاربر
  final String title; // عنوان
  final String body; // متن اعلان
  final NotificationType type; // نوع اعلان
  final bool isRead; // خوانده شده یا نه
  final DateTime createdAt; // تاریخ ایجاد

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  // تبدیل به Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'is_read': isRead ? 1 : 0, // SQLite boolean
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ساخت از Map
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      body: map['body'],
      type: NotificationType.values.byName(map['type']),
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // کپی با تغییرات
  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// انواع اعلان
enum NotificationType {
  info, // اطلاعاتی
  warning, // هشدار
  success, // موفقیت
  profit, // سود
  investment, // سرمایه‌گذاری
  token, // توکن
}

// کلاس تنظیمات کاربر
class UserSettings {
  final String userId; // شناسه کاربر
  final bool notificationsEnabled; // اعلان‌ها فعال
  final bool biometricEnabled; // احراز هویت بیومتریک
  final String theme; // تم (روشن/تیره)
  final String language; // زبان
  final bool soundEnabled; // صدا فعال
  final DateTime updatedAt; // آخرین بروزرسانی

  UserSettings({
    required this.userId,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.theme = 'light',
    this.language = 'fa',
    this.soundEnabled = true,
    required this.updatedAt,
  });

  // تبدیل به Map
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'theme': theme,
      'language': language,
      'sound_enabled': soundEnabled ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ساخت از Map
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      userId: map['user_id'],
      notificationsEnabled: map['notifications_enabled'] == 1,
      biometricEnabled: map['biometric_enabled'] == 1,
      theme: map['theme'],
      language: map['language'],
      soundEnabled: map['sound_enabled'] == 1,
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // کپی با تغییرات
  UserSettings copyWith({
    String? userId,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    String? theme,
    String? language,
    bool? soundEnabled,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// کلاس آمار داشبورد
class DashboardStats {
  final double tokenBalance; // موجودی توکن
  final double totalProfit; // سود کل
  final int activeInvestments; // سرمایه‌گذاری فعال
  final int userLevel; // سطح کاربر
  final double monthlyProfit; // سود ماهانه
  final int totalTransactions; // کل تراکنش‌ها
  final DateTime lastUpdated; // آخرین بروزرسانی

  DashboardStats({
    required this.tokenBalance,
    required this.totalProfit,
    required this.activeInvestments,
    required this.userLevel,
    required this.monthlyProfit,
    required this.totalTransactions,
    required this.lastUpdated,
  });

  // محاسبه رشد سود (درصد)
  double calculateProfitGrowth(double previousProfit) {
    if (previousProfit == 0) return 0;
    return ((totalProfit - previousProfit) / previousProfit) * 100;
  }

  // آیا داده‌ها جدید هستند؟ (کمتر از 5 دقیقه)
  bool get isDataFresh {
    return DateTime.now().difference(lastUpdated).inMinutes < 5;
  }

  // تبدیل به Map
  Map<String, dynamic> toMap() {
    return {
      'token_balance': tokenBalance,
      'total_profit': totalProfit,
      'active_investments': activeInvestments,
      'user_level': userLevel,
      'monthly_profit': monthlyProfit,
      'total_transactions': totalTransactions,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // ساخت از Map
  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      tokenBalance: map['token_balance'].toDouble(),
      totalProfit: map['total_profit'].toDouble(),
      activeInvestments: map['active_investments'],
      userLevel: map['user_level'],
      monthlyProfit: map['monthly_profit'].toDouble(),
      totalTransactions: map['total_transactions'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }
}

// کلاس کمکی برای تنظیمات
class AppConstants {
  // رنگ‌های اصلی برنامه
  static const Map<String, int> colors = {
    'primary': 0xFF1976D2, // آبی اصلی
    'secondary': 0xFF388E3C, // سبز
    'accent': 0xFFFF9800, // نارنجی
    'success': 0xFF4CAF50, // سبز موفقیت
    'warning': 0xFFFF9800, // نارنجی هشدار
    'error': 0xFFF44336, // قرمز خطا
    'purple': 0xFF9C27B0, // بنفش
  };

  // نرخ‌های تبدیل
  static const Map<String, double> rates = {
    'token_to_money': 5000.0, // هر توکن = 5000 تومان
    'investment_to_token': 0.01, // هر 100 تومان سرمایه = 1 توکن
    'daily_interest': 0.1, // سود روزانه 0.1 درصد
  };

  // متن‌های ثابت
  static const Map<String, String> messages = {
    'welcome': 'به Smart Money Bell خوش آمدید',
    'loading': 'در حال بارگذاری...',
    'error': 'خطایی رخ داده است',
    'success': 'عملیات با موفقیت انجام شد',
    'confirm': 'آیا مطمئن هستید؟',
    'cancel': 'لغو',
    'ok': 'تأیید',
  };

  // تنظیمات برنامه
  static const Map<String, dynamic> settings = {
    'app_version': '1.0.0',
    'min_investment': 100000, // حداقل سرمایه‌گذاری (تومان)
    'max_investment': 50000000, // حداکثر سرمایه‌گذاری (تومان)
    'min_token_conversion': 10, // حداقل توکن برای تبدیل
    'support_phone': '02133445566',
    'support_email': 'support@smartmoneybell.com',
  };
}