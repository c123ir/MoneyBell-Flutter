// lib/core/services/gamification_service.dart
import '../models/achievement.dart';
import '../models/challenge.dart';
import '../models/leaderboard.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final DatabaseService _databaseService = DatabaseService();

  // محاسبه سطح کاربر بر اساس تجربه
  int calculateUserLevel(int experience) {
    for (int i = AppConstants.levelThresholds.length - 1; i >= 0; i--) {
      if (experience >= AppConstants.levelThresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  // محاسبه درصد پیشرفت تا سطح بعد
  double calculateLevelProgress(int experience) {
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

  // افزودن تجربه به کاربر
  Future<bool> addExperience(String userId, int points, String reason) async {
    try {
      final user = await _databaseService.getUserById(userId);
      if (user == null) return false;

      final currentExperience = user['experience'] as int? ?? 0;
      final newExperience = currentExperience + points;
      final oldLevel = calculateUserLevel(currentExperience);
      final newLevel = calculateUserLevel(newExperience);

      // به‌روزرسانی تجربه کاربر
      await _databaseService.updateUser(userId, {
        'experience': newExperience,
        'level': newLevel,
      });

      // ثبت لاگ تجربه
      await _logExperience(userId, points, reason);

      // بررسی ارتقای سطح
      if (newLevel > oldLevel) {
        await _handleLevelUp(userId, oldLevel, newLevel);
      }

      // بررسی دستاوردها
      await _checkAchievements(userId);

      Logger.info('Added $points experience to user $userId for: $reason');
      return true;
    } catch (e) {
      Logger.error('Error adding experience', e);
      return false;
    }
  }

  // مدیریت ارتقای سطح
  Future<void> _handleLevelUp(String userId, int oldLevel, int newLevel) async {
    try {
      // پاداش ارتقای سطح
      final bonus = newLevel * 50; // 50 توکن برای هر سطح
      
      await _databaseService.insertTokenTransaction({
        'id': _generateId(),
        'user_id': userId,
        'amount': bonus.toDouble(),
        'type': 'bonus',
        'source_id': null,
        'target_id': null,
        'description': 'پاداش ارتقای سطح از $oldLevel به $newLevel',
        'created_at': DateTime.now().toIso8601String(),
        'metadata': null,
      });

      // ایجاد اعلان
      await _databaseService.insertNotification({
        'id': _generateId(),
        'user_id': userId,
        'title': 'تبریک! ارتقای سطح',
        'message': 'شما به سطح $newLevel ارتقا یافتید و $bonus توکن دریافت کردید',
        'type': 'level_up',
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
        'read_at': null,
        'action_data': null,
      });

      Logger.info('User $userId leveled up from $oldLevel to $newLevel');
    } catch (e) {
      Logger.error('Error handling level up', e);
    }
  }

  // ثبت لاگ تجربه
  Future<void> _logExperience(String userId, int points, String reason) async {
    try {
      // ایجاد جدول experience_logs اگر وجود ندارد
      final db = await _databaseService.database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS experience_logs (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          points INTEGER NOT NULL,
          reason TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      await db.insert('experience_logs', {
        'id': _generateId(),
        'user_id': userId,
        'points': points,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Logger.error('Error logging experience', e);
    }
  }

  // بررسی دستاوردها
  Future<void> _checkAchievements(String userId) async {
    try {
      final achievements = await _getAvailableAchievements(userId);
      
      for (final achievement in achievements) {
        if (await _checkAchievementConditions(userId, achievement)) {
          await _unlockAchievement(userId, achievement);
        }
      }
    } catch (e) {
      Logger.error('Error checking achievements', e);
    }
  }

  // دریافت دستاوردهای قابل دسترسی
  Future<List<Achievement>> _getAvailableAchievements(String userId) async {
    // دستاوردهای پیش‌تعریف شده
    return [
      Achievement(
        id: 'first_investment',
        title: 'اولین سرمایه‌گذاری',
        description: 'اولین سرمایه‌گذاری خود را انجام دهید',
        icon: 'first_investment',
        points: 100,
        condition: AchievementCondition.firstInvestment,
      ),
      Achievement(
        id: 'token_collector',
        title: 'جمع‌آور توکن',
        description: '1000 توکن جمع‌آوری کنید',
        icon: 'token_collector',
        points: 200,
        condition: AchievementCondition.tokenCollector,
      ),
      Achievement(
        id: 'level_master',
        title: 'استاد سطح',
        description: 'به سطح 10 برسید',
        icon: 'level_master',
        points: 500,
        condition: AchievementCondition.levelMaster,
      ),
      Achievement(
        id: 'daily_login',
        title: 'حضور روزانه',
        description: '30 روز متوالی وارد شوید',
        icon: 'daily_login',
        points: 300,
        condition: AchievementCondition.dailyLogin,
      ),
    ];
  }

  // بررسی شرایط دستاورد
  Future<bool> _checkAchievementConditions(String userId, Achievement achievement) async {
    try {
      switch (achievement.condition) {
        case AchievementCondition.firstInvestment:
          final investments = await _databaseService.getUserInvestments(userId);
          return investments.isNotEmpty;

        case AchievementCondition.tokenCollector:
          final balance = await _databaseService.getUserTokenBalance(userId);
          return balance >= 1000;

        case AchievementCondition.levelMaster:
          final user = await _databaseService.getUserById(userId);
          final level = user?['level'] as int? ?? 1;
          return level >= 10;

        case AchievementCondition.dailyLogin:
          return await _checkDailyLoginStreak(userId) >= 30;

        default:
          return false;
      }
    } catch (e) {
      Logger.error('Error checking achievement conditions', e);
      return false;
    }
  }

  // بررسی حضور متوالی روزانه
  Future<int> _checkDailyLoginStreak(String userId) async {
    try {
      final db = await _databaseService.database;
      
      // ایجاد جدول login_logs اگر وجود ندارد
      await db.execute('''
        CREATE TABLE IF NOT EXISTS login_logs (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          login_date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      final result = await db.rawQuery('''
        SELECT COUNT(*) as streak FROM (
          SELECT DISTINCT DATE(created_at) as login_date
          FROM login_logs 
          WHERE user_id = ?
          ORDER BY login_date DESC
        ) WHERE login_date >= DATE('now', '-30 days')
      ''', [userId]);

      return result.first['streak'] as int? ?? 0;
    } catch (e) {
      Logger.error('Error checking daily login streak', e);
      return 0;
    }
  }

  // باز کردن دستاورد
  Future<void> _unlockAchievement(String userId, Achievement achievement) async {
    try {
      final db = await _databaseService.database;
      
      // ایجاد جدول achievements اگر وجود ندارد
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_achievements (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          achievement_id TEXT NOT NULL,
          unlocked_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      // بررسی اینکه آیا قبلاً باز شده یا نه
      final existing = await db.query(
        'user_achievements',
        where: 'user_id = ? AND achievement_id = ?',
        whereArgs: [userId, achievement.id],
      );

      if (existing.isNotEmpty) return;

      // باز کردن دستاورد
      await db.insert('user_achievements', {
        'id': _generateId(),
        'user_id': userId,
        'achievement_id': achievement.id,
        'unlocked_at': DateTime.now().toIso8601String(),
      });

      // اعطای امتیاز
      await addExperience(userId, achievement.points, 'دستاورد: ${achievement.title}');

      // ایجاد اعلان
      await _databaseService.insertNotification({
        'id': _generateId(),
        'user_id': userId,
        'title': 'دستاورد جدید!',
        'message': 'شما دستاورد "${achievement.title}" را باز کردید',
        'type': 'achievement',
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
        'read_at': null,
        'action_data': null,
      });

      Logger.info('Achievement ${achievement.id} unlocked for user $userId');
    } catch (e) {
      Logger.error('Error unlocking achievement', e);
    }
  }

  // ثبت ورود روزانه
  Future<void> logDailyLogin(String userId) async {
    try {
      final db = await _databaseService.database;
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // بررسی اینکه آیا امروز قبلاً ثبت شده یا نه
      final existing = await db.query(
        'login_logs',
        where: 'user_id = ? AND DATE(created_at) = ?',
        whereArgs: [userId, today],
      );

      if (existing.isEmpty) {
        await db.insert('login_logs', {
          'id': _generateId(),
          'user_id': userId,
          'login_date': today,
          'created_at': DateTime.now().toIso8601String(),
        });

        // پاداش ورود روزانه
        await _databaseService.insertTokenTransaction({
          'id': _generateId(),
          'user_id': userId,
          'amount': AppConstants.dailyLoginBonus.toDouble(),
          'type': 'bonus',
          'source_id': null,
          'target_id': null,
          'description': 'پاداش ورود روزانه',
          'created_at': DateTime.now().toIso8601String(),
          'metadata': null,
        });

        await addExperience(userId, 10, 'ورود روزانه');
      }
    } catch (e) {
      Logger.error('Error logging daily login', e);
    }
  }

  // دریافت جدول رتبه‌بندی
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50}) async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('''
        SELECT 
          id,
          name,
          level,
          experience,
          total_tokens,
          total_profit
        FROM users 
        WHERE is_active = 1
        ORDER BY experience DESC, level DESC
        LIMIT ?
      ''', [limit]);

      return result.asMap().entries.map((entry) {
        final index = entry.key;
        final row = entry.value;
        
        return LeaderboardEntry(
          rank: index + 1,
          userId: row['id'] as String,
          userName: row['name'] as String,
          level: row['level'] as int? ?? 1,
          experience: row['experience'] as int? ?? 0,
          totalTokens: (row['total_tokens'] as num?)?.toDouble() ?? 0.0,
          totalProfit: (row['total_profit'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      Logger.error('Error getting leaderboard', e);
      return [];
    }
  }

  // دریافت رتبه کاربر
  Future<int> getUserRank(String userId) async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) + 1 as rank
        FROM users 
        WHERE experience > (
          SELECT experience FROM users WHERE id = ?
        ) AND is_active = 1
      ''', [userId]);

      return result.first['rank'] as int? ?? 0;
    } catch (e) {
      Logger.error('Error getting user rank', e);
      return 0;
    }
  }

  // ایجاد چالش روزانه
  Future<Challenge> createDailyChallenge(String userId) async {
    final challenges = [
      Challenge(
        id: 'daily_login',
        title: 'ورود روزانه',
        description: 'امروز وارد اپلیکیشن شوید',
        type: ChallengeType.daily,
        targetValue: 1,
        currentValue: 0,
        reward: 50,
        expiresAt: DateTime.now().add(Duration(days: 1)),
      ),
      Challenge(
        id: 'token_earn',
        title: 'کسب توکن',
        description: '100 توکن کسب کنید',
        type: ChallengeType.daily,
        targetValue: 100,
        currentValue: 0,
        reward: 25,
        expiresAt: DateTime.now().add(Duration(days: 1)),
      ),
      Challenge(
        id: 'profit_check',
        title: 'بررسی سود',
        description: 'سود خود را بررسی کنید',
        type: ChallengeType.daily,
        targetValue: 1,
        currentValue: 0,
        reward: 30,
        expiresAt: DateTime.now().add(Duration(days: 1)),
      ),
    ];

    // انتخاب تصادفی یک چالش
    final random = DateTime.now().millisecondsSinceEpoch % challenges.length;
    return challenges[random];
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// lib/data/models/achievement.dart
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final AchievementCondition condition;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.condition,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      points: json['points'] as int,
      condition: AchievementCondition.values.firstWhere(
        (e) => e.toString().split('.').last == json['condition'],
        orElse: () => AchievementCondition.firstInvestment,
      ),
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null 
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'points': points,
      'condition': condition.toString().split('.').last,
      'is_unlocked': isUnlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }
}

enum AchievementCondition {
  firstInvestment,
  tokenCollector,
  levelMaster,
  dailyLogin,
  profitMaker,
  socialSharer,
  referralMaster,
}

// lib/data/models/challenge.dart
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final double targetValue;
  final double currentValue;
  final int reward;
  final DateTime expiresAt;
  final bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.reward,
    required this.expiresAt,
    this.isCompleted = false,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ChallengeType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ChallengeType.daily,
      ),
      targetValue: (json['target_value'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      reward: json['reward'] as int,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'target_value': targetValue,
      'current_value': currentValue,
      'reward': reward,
      'expires_at': expiresAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  Challenge copyWith({
    double? currentValue,
    bool? isCompleted,
  }) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      reward: reward,
      expiresAt: expiresAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum ChallengeType { daily, weekly, monthly, special }

// lib/data/models/leaderboard.dart
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String userName;
  final int level;
  final int experience;
  final double totalTokens;
  final double totalProfit;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.level,
    required this.experience,
    required this.totalTokens,
    required this.totalProfit,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      level: json['level'] as int,
      experience: json['experience'] as int,
      totalTokens: (json['total_tokens'] as num).toDouble(),
      totalProfit: (json['total_profit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'user_name': userName,
      'level': level,
      'experience': experience,
      'total_tokens': totalTokens,
      'total_profit': totalProfit,
    };
  }
}