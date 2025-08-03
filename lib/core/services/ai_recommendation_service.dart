// lib/core/services/ai_recommendation_service.dart
import 'dart:math';
import '../models/recommendation.dart';
import '../models/user_behavior.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class AIRecommendationService {
  static final AIRecommendationService _instance = AIRecommendationService._internal();
  factory AIRecommendationService() => _instance;
  AIRecommendationService._internal();

  final DatabaseService _databaseService = DatabaseService();

  // تولید پیشنهادات شخصی‌سازی شده
  Future<List<Recommendation>> generatePersonalizedRecommendations(String userId) async {
    try {
      final userBehavior = await _analyzeUserBehavior(userId);
      final recommendations = <Recommendation>[];

      // پیشنهادات بر اساس الگوی سرمایه‌گذاری
      recommendations.addAll(await _generateInvestmentRecommendations(userId, userBehavior));
      
      // پیشنهادات بر اساس استفاده از توکن
      recommendations.addAll(await _generateTokenRecommendations(userId, userBehavior));
      
      // پیشنهادات بر اساس سطح فعالیت
      recommendations.addAll(await _generateActivityRecommendations(userId, userBehavior));
      
      // پیشنهادات بر اساس زمان
      recommendations.addAll(await _generateTimeBased Recommendations(userId, userBehavior));

      // مرتب‌سازی بر اساس اولویت و امتیاز
      recommendations.sort((a, b) => b.priority.compareTo(a.priority));
      
      // محدود کردن به 10 پیشنهاد برتر
      return recommendations.take(10).toList();
    } catch (e) {
      Logger.error('Error generating recommendations', e);
      return [];
    }
  }

  // تحلیل رفتار کاربر
  Future<UserBehavior> _analyzeUserBehavior(String userId) async {
    try {
      final user = await _databaseService.getUserById(userId);
      final investments = await _databaseService.getUserInvestments(userId);
      final tokenTransactions = await _databaseService.getUserTokenTransactions(userId, limit: 100);
      
      // محاسبه میانگین سرمایه‌گذاری
      double avgInvestmentAmount = 0;
      if (investments.isNotEmpty) {
        final totalAmount = investments.fold<double>(0, (sum, inv) => sum + (inv['amount'] as double));
        avgInvestmentAmount = totalAmount / investments.length;
      }

      // تحلیل الگوی استفاده از توکن
      final tokenUsagePattern = _analyzeTokenUsage(tokenTransactions);
      
      // محاسبه فعالیت روزانه
      final dailyActivity = await _calculateDailyActivity(userId);
      
      // تعیین نوع سرمایه‌گذار
      final investorType = _determineInvestorType(user, investments, tokenTransactions);

      return UserBehavior(
        userId: userId,
        investorType: investorType,
        avgInvestmentAmount: avgInvestmentAmount,
        tokenUsagePattern: tokenUsagePattern,
        dailyActivity: dailyActivity,
        lastActiveDate: DateTime.now(),
        riskTolerance: _calculateRiskTolerance(investments),
        preferredInvestmentDuration: _calculatePreferredDuration(investments),
      );
    } catch (e) {
      Logger.error('Error analyzing user behavior', e);
      return UserBehavior.defaultBehavior(userId);
    }
  }

  // تولید پیشنهادات سرمایه‌گذاری
  Future<List<Recommendation>> _generateInvestmentRecommendations(
    String userId,
    UserBehavior behavior,
  ) async {
    final recommendations = <Recommendation>[];

    // پیشنهاد بر اساس نوع سرمایه‌گذار
    switch (behavior.investorType) {
      case InvestorType.conservative:
        recommendations.add(Recommendation(
          id: 'conservative_investment',
          title: 'سرمایه‌گذاری محافظه‌کارانه',
          description: 'بر اساس تحلیل رفتار شما، سرمایه‌گذاری با ریسک کم مناسب شماست',
          type: RecommendationType.investment,
          priority: 8,
          actionUrl: '/investments/conservative',
          metadata: {'risk_level': 'low', 'expected_return': '8-12%'},
        ));
        break;
        
      case InvestorType.moderate:
        recommendations.add(Recommendation(
          id: 'balanced_portfolio',
          title: 'پورتفولیو متعادل',
          description: 'ترکیبی از سرمایه‌گذاری‌های کم‌ریسک و پرسود برای شما مناسب است',
          type: RecommendationType.investment,
          priority: 9,
          actionUrl: '/investments/balanced',
          metadata: {'risk_level': 'medium', 'expected_return': '12-18%'},
        ));
        break;
        
      case InvestorType.aggressive:
        recommendations.add(Recommendation(
          id: 'high_yield_investment',
          title: 'سرمایه‌گذاری پرسود',
          description: 'با توجه به تمایل شما به ریسک، گزینه‌های پرسود را بررسی کنید',
          type: RecommendationType.investment,
          priority: 10,
          actionUrl: '/investments/high-yield',
          metadata: {'risk_level': 'high', 'expected_return': '18-25%'},
        ));
        break;
    }

    // پیشنهاد افزایش سرمایه‌گذاری
    if (behavior.avgInvestmentAmount > 0) {
      final suggestedAmount = behavior.avgInvestmentAmount * 1.2;
      recommendations.add(Recommendation(
        id: 'increase_investment',
        title: 'افزایش سرمایه‌گذاری',
        description: 'با افزایش ${(suggestedAmount - behavior.avgInvestmentAmount).toInt()} تومانی، سود بیشتری کسب کنید',
        type: RecommendationType.investment,
        priority: 7,
        actionUrl: '/investments/new',
        metadata: {'suggested_amount': suggestedAmount},
      ));
    }

    return recommendations;
  }

  // تولید پیشنهادات توکن
  Future<List<Recommendation>> _generateTokenRecommendations(
    String userId,
    UserBehavior behavior,
  ) async {
    final recommendations = <Recommendation>[];
    final tokenBalance = await _databaseService.getUserTokenBalance(userId);

    if (tokenBalance > 1000) {
      recommendations.add(Recommendation(
        id: 'convert_tokens',
        title: 'تبدیل توکن‌ها',
        description: 'شما ${tokenBalance.toInt()} توکن دارید. آن‌ها را به وجه نقد تبدیل کنید',
        type: RecommendationType.token,
        priority: 8,
        actionUrl: '/tokens/convert',
        metadata: {'token_amount': tokenBalance, 'cash_value': tokenBalance * 500},
      ));
    }

    if (behavior.tokenUsagePattern == TokenUsagePattern.saver) {
      recommendations.add(Recommendation(
        id: 'token_investment',
        title: 'سرمایه‌گذاری با توکن',
        description: 'به جای نگهداری، توکن‌هایتان را سرمایه‌گذاری کنید',
        type: RecommendationType.token,
        priority: 6,
        actionUrl: '/tokens/invest',
        metadata: {'min_tokens': 500},
      ));
    }

    return recommendations;
  }

  // تولید پیشنهادات فعالیت
  Future<List<Recommendation>> _generateActivityRecommendations(
    String userId,
    UserBehavior behavior,
  ) async {
    final recommendations = <Recommendation>[];

    if (behavior.dailyActivity < 0.3) {
      recommendations.add(Recommendation(
        id: 'increase_activity',
        title: 'افزایش فعالیت',
        description: 'با فعالیت بیشتر در اپلیکیشن، توکن‌های بیشتری کسب کنید',
        type: RecommendationType.activity,
        priority: 5,
        actionUrl: '/challenges',
        metadata: {'target_activity': 0.7},
      ));
    }

    final daysSinceLastLogin = DateTime.now().difference(behavior.lastActiveDate).inDays;
    if (daysSinceLastLogin > 7) {
      recommendations.add(Recommendation(
        id: 'return_bonus',
        title: 'پاداش بازگشت',
        description: 'به خاطر غیبت‌تان، پاداش ویژه‌ای برای شما در نظر گرفته‌ایم',
        type: RecommendationType.bonus,
        priority: 9,
        actionUrl: '/rewards/return-bonus',
        metadata: {'bonus_amount': daysSinceLastLogin * 10},
      ));
    }

    return recommendations;
  }

  // تولید پیشنهادات بر اساس زمان
  Future<List<Recommendation>> _generateTimeBasedRecommendations(
    String userId,
    UserBehavior behavior,
  ) async {
    final recommendations = <Recommendation>[];
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday;

    // پیشنهادات صبحگاهی
    if (hour >= 6 && hour <= 10) {
      recommendations.add(Recommendation(
        id: 'morning_check',
        title: 'بررسی صبحگاهی',
        description: 'صبح بخیر! سود امروز خود را بررسی کنید',
        type: RecommendationType.daily,
        priority: 6,
        actionUrl: '/dashboard',
        metadata: {'time_of_day': 'morning'},
      ));
    }

    // پیشنهادات آخر هفته
    if (dayOfWeek >= 6) {
      recommendations.add(Recommendation(
        id: 'weekend_planning',
        title: 'برنامه‌ریزی آخر هفته',
        description: 'زمان مناسبی برای بررسی و برنامه‌ریزی سرمایه‌گذاری‌هاست',
        type: RecommendationType.planning,
        priority: 7,
        actionUrl: '/investments/plan',
        metadata: {'weekend': true},
      ));
    }

    // پیشنهادات ماهانه
    if (now.day <= 5) {
      recommendations.add(Recommendation(
        id: 'monthly_review',
        title: 'بررسی ماهانه',
        description: 'شروع ماه جدید، زمان بررسی عملکرد ماه گذشته',
        type: RecommendationType.review,
        priority: 8,
        actionUrl: '/analytics/monthly',
        metadata: {'period': 'monthly'},
      ));
    }

    return recommendations;
  }

  // تحلیل الگوی استفاده از توکن
  TokenUsagePattern _analyzeTokenUsage(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) return TokenUsagePattern.inactive;

    int earnCount = 0;
    int spendCount = 0;

    for (final transaction in transactions) {
      final type = transaction['type'] as String;
      if (['earned', 'bonus', 'referral', 'received'].contains(type)) {
        earnCount++;
      } else if (['converted', 'transferred', 'spent'].contains(type)) {
        spendCount++;
      }
    }

    if (spendCount == 0) return TokenUsagePattern.saver;
    if (spendCount > earnCount) return TokenUsagePattern.spender;
    return TokenUsagePattern.balanced;
  }

  // محاسبه فعالیت روزانه
  Future<double> _calculateDailyActivity(String userId) async {
    try {
      final db = await _databaseService.database;
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30)).toIso8601String();
      
      final result = await db.rawQuery('''
        SELECT COUNT(DISTINCT DATE(created_at)) as active_days
        FROM (
          SELECT created_at FROM token_transactions WHERE user_id = ? AND created_at > ?
          UNION
          SELECT created_at FROM investments WHERE user_id = ? AND created_at > ?
        )
      ''', [userId, thirtyDaysAgo, userId, thirtyDaysAgo]);

      final activeDays = result.first['active_days'] as int? ?? 0;
      return activeDays / 30.0;
    } catch (e) {
      Logger.error('Error calculating daily activity', e);
      return 0.0;
    }
  }

  // تعیین نوع سرمایه‌گذار
  InvestorType _determineInvestorType(
    Map<String, dynamic>? user,
    List<Map<String, dynamic>> investments,
    List<Map<String, dynamic>> tokenTransactions,
  ) {
    if (investments.isEmpty) return InvestorType.conservative;

    // تحلیل مبالغ سرمایه‌گذاری
    final amounts = investments.map((inv) => inv['amount'] as double).toList();
    final avgAmount = amounts.fold(0.0, (sum, amount) => sum + amount) / amounts.length;
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);

    // تحلیل تنوع سرمایه‌گذاری
    final investmentTypes = investments.map((inv) => inv['type'] as String).toSet();
    
    // تحلیل فرکانس معاملات
    final recentInvestments = investments.where((inv) {
      final date = DateTime.parse(inv['created_at'] as String);
      return DateTime.now().difference(date).inDays <= 30;
    }).length;

    // الگوریتم تصمیم‌گیری
    int aggressiveScore = 0;
    
    if (avgAmount > 10000000) aggressiveScore += 2; // بالای 10 میلیون
    if (maxAmount > 50000000) aggressiveScore += 2; // بالای 50 میلیون
    if (investmentTypes.length > 2) aggressiveScore += 1;
    if (recentInvestments > 3) aggressiveScore += 1;

    if (aggressiveScore >= 4) return InvestorType.aggressive;
    if (aggressiveScore >= 2) return InvestorType.moderate;
    return InvestorType.conservative;
  }

  // محاسبه تحمل ریسک
  RiskTolerance _calculateRiskTolerance(List<Map<String, dynamic>> investments) {
    if (investments.isEmpty) return RiskTolerance.low;

    final profitRates = investments.map((inv) => inv['profit_rate'] as double).toList();
    final avgProfitRate = profitRates.fold(0.0, (sum, rate) => sum + rate) / profitRates.length;

    if (avgProfitRate > 20) return RiskTolerance.high;
    if (avgProfitRate > 12) return RiskTolerance.medium;
    return RiskTolerance.low;
  }

  // محاسبه مدت زمان ترجیحی سرمایه‌گذاری
  Duration _calculatePreferredDuration(List<Map<String, dynamic>> investments) {
    if (investments.isEmpty) return Duration(days: 365);

    final durations = investments.where((inv) => inv['end_date'] != null).map((inv) {
      final start = DateTime.parse(inv['start_date'] as String);
      final end = DateTime.parse(inv['end_date'] as String);
      return end.difference(start);
    }).toList();

    if (durations.isEmpty) return Duration(days: 365);

    final avgDuration = durations.fold(Duration.zero, (sum, duration) => sum + duration) ~/ durations.length;
    return avgDuration;
  }

  // ثبت تعامل کاربر با پیشنهاد
  Future<void> recordRecommendationInteraction(
    String userId,
    String recommendationId,
    RecommendationAction action,
  ) async {
    try {
      final db = await _databaseService.database;
      
      // ایجاد جدول تعاملات اگر وجود ندارد
      await db.execute('''
        CREATE TABLE IF NOT EXISTS recommendation_interactions (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          recommendation_id TEXT NOT NULL,
          action TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      await db.insert('recommendation_interactions', {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': userId,
        'recommendation_id': recommendationId,
        'action': action.toString().split('.').last,
        'created_at': DateTime.now().toIso8601String(),
      });

      Logger.info('Recorded recommendation interaction: $recommendationId -> $action');
    } catch (e) {
      Logger.error('Error recording recommendation interaction', e);
    }
  }

  // تحلیل اثربخشی پیشنهادات
  Future<Map<String, double>> analyzeRecommendationEffectiveness() async {
    try {
      final db = await _databaseService.database;
      
      final result = await db.rawQuery('''
        SELECT 
          recommendation_id,
          COUNT(*) as total_views,
          SUM(CASE WHEN action = 'clicked' THEN 1 ELSE 0 END) as clicks,
          SUM(CASE WHEN action = 'dismissed' THEN 1 ELSE 0 END) as dismissals
        FROM recommendation_interactions 
        WHERE created_at > DATE('now', '-30 days')
        GROUP BY recommendation_id
      ''');

      final effectiveness = <String, double>{};
      
      for (final row in result) {
        final id = row['recommendation_id'] as String;
        final totalViews = row['total_views'] as int;
        final clicks = row['clicks'] as int;
        
        if (totalViews > 0) {
          effectiveness[id] = clicks / totalViews;
        }
      }

      return effectiveness;
    } catch (e) {
      Logger.error('Error analyzing recommendation effectiveness', e);
      return {};
    }
  }
}

// lib/data/models/recommendation.dart
class Recommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationType type;
  final int priority;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? expiresAt;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    this.actionUrl,
    this.metadata,
    DateTime? createdAt,
    this.expiresAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: RecommendationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => RecommendationType.general,
      ),
      priority: json['priority'] as int,
      actionUrl: json['action_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'priority': priority,
      'action_url': actionUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

enum RecommendationType {
  investment,
  token,
  activity,
  bonus,
  daily,
  planning,
  review,
  general,
}

enum RecommendationAction {
  viewed,
  clicked,
  dismissed,
  completed,
}

// lib/data/models/user_behavior.dart
class UserBehavior {
  final String userId;
  final InvestorType investorType;
  final double avgInvestmentAmount;
  final TokenUsagePattern tokenUsagePattern;
  final double dailyActivity;
  final DateTime lastActiveDate;
  final RiskTolerance riskTolerance;
  final Duration preferredInvestmentDuration;

  UserBehavior({
    required this.userId,
    required this.investorType,
    required this.avgInvestmentAmount,
    required this.tokenUsagePattern,
    required this.dailyActivity,
    required this.lastActiveDate,
    required this.riskTolerance,
    required this.preferredInvestmentDuration,
  });

  factory UserBehavior.defaultBehavior(String userId) {
    return UserBehavior(
      userId: userId,
      investorType: InvestorType.conservative,
      avgInvestmentAmount: 0,
      tokenUsagePattern: TokenUsagePattern.inactive,
      dailyActivity: 0,
      lastActiveDate: DateTime.now(),
      riskTolerance: RiskTolerance.low,
      preferredInvestmentDuration: Duration(days: 365),
    );
  }

  factory UserBehavior.fromJson(Map<String, dynamic> json) {
    return UserBehavior(
      userId: json['user_id'] as String,
      investorType: InvestorType.values.firstWhere(
        (e) => e.toString().split('.').last == json['investor_type'],
        orElse: () => InvestorType.conservative,
      ),
      avgInvestmentAmount: (json['avg_investment_amount'] as num).toDouble(),
      tokenUsagePattern: TokenUsagePattern.values.firstWhere(
        (e) => e.toString().split('.').last == json['token_usage_pattern'],
        orElse: () => TokenUsagePattern.inactive,
      ),
      dailyActivity: (json['daily_activity'] as num).toDouble(),
      lastActiveDate: DateTime.parse(json['last_active_date'] as String),
      riskTolerance: RiskTolerance.values.firstWhere(
        (e) => e.toString().split('.').last == json['risk_tolerance'],
        orElse: () => RiskTolerance.low,
      ),
      preferredInvestmentDuration: Duration(
        days: json['preferred_investment_duration_days'] as int,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'investor_type': investorType.toString().split('.').last,
      'avg_investment_amount': avgInvestmentAmount,
      'token_usage_pattern': tokenUsagePattern.toString().split('.').last,
      'daily_activity': dailyActivity,
      'last_active_date': lastActiveDate.toIso8601String(),
      'risk_tolerance': riskTolerance.toString().split('.').last,
      'preferred_investment_duration_days': preferredInvestmentDuration.inDays,
    };
  }
}

enum InvestorType { conservative, moderate, aggressive }
enum TokenUsagePattern { inactive, saver, spender, balanced }
enum RiskTolerance { low, medium, high }

// lib/presentation/widgets/recommendation_card.dart
class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const RecommendationCard({
    Key? key,
    required this.recommendation,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: null,
        borderRadius: AppConstants.largeBorderRadius,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            _getTypeColor().withOpacity(0.1),
            _getTypeColor().withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            _getTypeColor().withOpacity(0.3),
            _getTypeColor().withOpacity(0.1),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          child: Padding(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(),
                        color: _getTypeColor(),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    if (onDismiss != null)
                      IconButton(
                        onPressed: onDismiss,
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  recommendation.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getPriorityText(),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getPriorityColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (recommendation.type) {
      case RecommendationType.investment:
        return Colors.blue;
      case RecommendationType.token:
        return Colors.orange;
      case RecommendationType.activity:
        return Colors.green;
      case RecommendationType.bonus:
        return Colors.purple;
      case RecommendationType.daily:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (recommendation.type) {
      case RecommendationType.investment:
        return Icons.trending_up;
      case RecommendationType.token:
        return Icons.monetization_on;
      case RecommendationType.activity:
        return Icons.local_activity;
      case RecommendationType.bonus:
        return Icons.card_giftcard;
      case RecommendationType.daily:
        return Icons.today;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getPriorityColor() {
    if (recommendation.priority >= 8) return Colors.red;
    if (recommendation.priority >= 6) return Colors.orange;
    return Colors.green;
  }

  String _getPriorityText() {
    if (recommendation.priority >= 8) return 'اولویت بالا';
    if (recommendation.priority >= 6) return 'اولویت متوسط';
    return 'اولویت کم';
  }
}