// lib/core/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../utils/logger.dart';

class DatabaseService {
  static Database? _database;
  static const String dbName = 'smart_money_bell.db';
  static const int dbVersion = 1;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      String path = join(await getDatabasesPath(), dbName);
      Logger.info('Initializing database at: $path');
      
      return await openDatabase(
        path,
        version: dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      Logger.error('Database initialization failed', e);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      Logger.info('Creating database tables...');
      
      // جدول کاربران
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          phone TEXT,
          avatar TEXT,
          total_tokens REAL DEFAULT 0,
          total_profit REAL DEFAULT 0,
          level INTEGER DEFAULT 1,
          experience INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          is_active INTEGER DEFAULT 1
        )
      ''');

      // جدول سرمایه‌گذاری‌ها
      await db.execute('''
        CREATE TABLE investments (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          amount REAL NOT NULL,
          profit_rate REAL NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT,
          status TEXT DEFAULT 'active',
          type TEXT DEFAULT 'fixed',
          description TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // جدول تراکنش‌های توکن
      await db.execute('''
        CREATE TABLE token_transactions (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          amount REAL NOT NULL,
          type TEXT NOT NULL,
          source_id TEXT,
          target_id TEXT,
          description TEXT NOT NULL,
          created_at TEXT NOT NULL,
          metadata TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // جدول اعلان‌ها
      await db.execute('''
        CREATE TABLE notifications (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          type TEXT NOT NULL,
          is_read INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          read_at TEXT,
          action_data TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // جدول پاداش‌ها
      await db.execute('''
        CREATE TABLE rewards (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          type TEXT NOT NULL,
          value REAL NOT NULL,
          is_claimed INTEGER DEFAULT 0,
          available_at TEXT NOT NULL,
          expires_at TEXT,
          claimed_at TEXT,
          conditions TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // جدول تنظیمات
      await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // ایجاد ایندکس‌ها برای بهبود کارایی
      await _createIndexes(db);
      
      // درج داده‌های اولیه
      await _insertInitialData(db);
      
      Logger.info('Database tables created successfully');
    } catch (e) {
      Logger.error('Error creating database tables', e);
      rethrow;
    }
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_investments_user_id ON investments (user_id)');
    await db.execute('CREATE INDEX idx_investments_status ON investments (status)');
    await db.execute('CREATE INDEX idx_tokens_user_id ON token_transactions (user_id)');
    await db.execute('CREATE INDEX idx_tokens_type ON token_transactions (type)');
    await db.execute('CREATE INDEX idx_notifications_user_id ON notifications (user_id)');
    await db.execute('CREATE INDEX idx_notifications_read ON notifications (is_read)');
    await db.execute('CREATE INDEX idx_rewards_user_id ON rewards (user_id)');
    await db.execute('CREATE INDEX idx_rewards_claimed ON rewards (is_claimed)');
  }

  Future<void> _insertInitialData(Database db) async {
    // تنظیمات اولیه
    final initialSettings = [
      {'key': 'app_version', 'value': '1.0.0'},
      {'key': 'token_conversion_rate', 'value': '500'},
      {'key': 'daily_login_bonus', 'value': '10'},
      {'key': 'referral_bonus', 'value': '100'},
    ];

    for (var setting in initialSettings) {
      await db.insert('settings', {
        ...setting,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Logger.info('Upgrading database from $oldVersion to $newVersion');
    // منطق آپگرید دیتابیس در نسخه‌های آینده
  }

  Future<void> _onOpen(Database db) async {
    Logger.info('Database opened successfully');
    // فعال‌سازی foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // متدهای CRUD برای کاربران
  Future<int> insertUser(Map<String, dynamic> user) async {
    try {
      final db = await database;
      return await db.insert('users', user);
    } catch (e) {
      Logger.error('Error inserting user', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      Logger.error('Error getting user by id', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      Logger.error('Error getting user by email', e);
      rethrow;
    }
  }

  Future<int> updateUser(String id, Map<String, dynamic> user) async {
    try {
      final db = await database;
      user['updated_at'] = DateTime.now().toIso8601String();
      return await db.update(
        'users',
        user,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      Logger.error('Error updating user', e);
      rethrow;
    }
  }

  // متدهای CRUD برای سرمایه‌گذاری‌ها
  Future<int> insertInvestment(Map<String, dynamic> investment) async {
    try {
      final db = await database;
      return await db.insert('investments', investment);
    } catch (e) {
      Logger.error('Error inserting investment', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserInvestments(String userId) async {
    try {
      final db = await database;
      return await db.query(
        'investments',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
    } catch (e) {
      Logger.error('Error getting user investments', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getActiveInvestments(String userId) async {
    try {
      final db = await database;
      return await db.query(
        'investments',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, 'active'],
        orderBy: 'created_at DESC',
      );
    } catch (e) {
      Logger.error('Error getting active investments', e);
      rethrow;
    }
  }

  Future<int> updateInvestment(String id, Map<String, dynamic> investment) async {
    try {
      final db = await database;
      investment['updated_at'] = DateTime.now().toIso8601String();
      return await db.update(
        'investments',
        investment,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      Logger.error('Error updating investment', e);
      rethrow;
    }
  }

  // متدهای CRUD برای تراکنش‌های توکن
  Future<int> insertTokenTransaction(Map<String, dynamic> transaction) async {
    try {
      final db = await database;
      
      // اگر metadata وجود داشته باشد، آن را به JSON تبدیل کن
      if (transaction['metadata'] != null) {
        transaction['metadata'] = jsonEncode(transaction['metadata']);
      }
      
      return await db.insert('token_transactions', transaction);
    } catch (e) {
      Logger.error('Error inserting token transaction', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserTokenTransactions(String userId, {int? limit}) async {
    try {
      final db = await database;
      return await db.query(
        'token_transactions',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
        limit: limit,
      );
    } catch (e) {
      Logger.error('Error getting user token transactions', e);
      rethrow;
    }
  }

  Future<double> getUserTokenBalance(String userId) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT 
          COALESCE(SUM(CASE WHEN type IN ('earned', 'bonus', 'referral', 'received') THEN amount ELSE 0 END), 0) -
          COALESCE(SUM(CASE WHEN type IN ('converted', 'transferred', 'spent', 'expired') THEN amount ELSE 0 END), 0) as balance
        FROM token_transactions 
        WHERE user_id = ?
      ''', [userId]);
      
      return (result.first['balance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      Logger.error('Error calculating token balance', e);
      rethrow;
    }
  }

  // متدهای CRUD برای اعلان‌ها
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    try {
      final db = await database;
      
      // اگر action_data وجود داشته باشد، آن را به JSON تبدیل کن
      if (notification['action_data'] != null) {
        notification['action_data'] = jsonEncode(notification['action_data']);
      }
      
      return await db.insert('notifications', notification);
    } catch (e) {
      Logger.error('Error inserting notification', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId, {bool? unreadOnly}) async {
    try {
      final db = await database;
      String whereClause = 'user_id = ?';
      List<dynamic> whereArgs = [userId];
      
      if (unreadOnly == true) {
        whereClause += ' AND is_read = 0';
      }
      
      return await db.query(
        'notifications',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );
    } catch (e) {
      Logger.error('Error getting user notifications', e);
      rethrow;
    }
  }

  Future<int> markNotificationAsRead(String notificationId) async {
    try {
      final db = await database;
      return await db.update(
        'notifications',
        {
          'is_read': 1,
          'read_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      Logger.error('Error marking notification as read', e);
      rethrow;
    }
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0',
        [userId],
      );
      return result.first['count'] as int;
    } catch (e) {
      Logger.error('Error getting unread notification count', e);
      rethrow;
    }
  }

  // متدهای CRUD برای پاداش‌ها
  Future<int> insertReward(Map<String, dynamic> reward) async {
    try {
      final db = await database;
      
      // اگر conditions وجود داشته باشد، آن را به JSON تبدیل کن
      if (reward['conditions'] != null) {
        reward['conditions'] = jsonEncode(reward['conditions']);
      }
      
      return await db.insert('rewards', reward);
    } catch (e) {
      Logger.error('Error inserting reward', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserRewards(String userId, {bool? availableOnly}) async {
    try {
      final db = await database;
      String whereClause = 'user_id = ?';
      List<dynamic> whereArgs = [userId];
      
      if (availableOnly == true) {
        whereClause += ' AND is_claimed = 0 AND available_at <= ?';
        whereArgs.add(DateTime.now().toIso8601String());
      }
      
      return await db.query(
        'rewards',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'available_at DESC',
      );
    } catch (e) {
      Logger.error('Error getting user rewards', e);
      rethrow;
    }
  }

  Future<int> claimReward(String rewardId) async {
    try {
      final db = await database;
      return await db.update(
        'rewards',
        {
          'is_claimed': 1,
          'claimed_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND is_claimed = 0',
        whereArgs: [rewardId],
      );
    } catch (e) {
      Logger.error('Error claiming reward', e);
      rethrow;
    }
  }

  // متدهای کار با تنظیمات
  Future<String?> getSetting(String key) async {
    try {
      final db = await database;
      final result = await db.query(
        'settings',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      return result.isNotEmpty ? result.first['value'] as String : null;
    } catch (e) {
      Logger.error('Error getting setting', e);
      rethrow;
    }
  }

  Future<int> setSetting(String key, String value) async {
    try {
      final db = await database;
      final settingData = {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      return await db.insert(
        'settings',
        settingData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      Logger.error('Error setting value', e);
      rethrow;
    }
  }

  Future<Map<String, String>> getAllSettings() async {
    try {
      final db = await database;
      final result = await db.query('settings');
      
      return {
        for (var row in result) row['key'] as String: row['value'] as String
      };
    } catch (e) {
      Logger.error('Error getting all settings', e);
      rethrow;
    }
  }

  // متدهای تحلیلی و گزارش‌گیری
  Future<Map<String, dynamic>> getUserDashboardData(String userId) async {
    try {
      final db = await database;
      
      // اطلاعات کاربر
      final user = await getUserById(userId);
      if (user == null) throw Exception('User not found');
      
      // موجودی توکن
      final tokenBalance = await getUserTokenBalance(userId);
      
      // تعداد سرمایه‌گذاری‌های فعال
      final activeInvestments = await getActiveInvestments(userId);
      
      // محاسبه کل سود
      double totalProfit = 0;
      for (var investment in activeInvestments) {
        final amount = investment['amount'] as double;
        final rate = investment['profit_rate'] as double;
        final startDate = DateTime.parse(investment['start_date'] as String);
        final days = DateTime.now().difference(startDate).inDays;
        totalProfit += (amount * rate / 100) * (days / 365);
      }
      
      // تعداد اعلان‌های خوانده نشده
      final unreadNotifications = await getUnreadNotificationCount(userId);
      
      // پاداش‌های قابل دریافت
      final availableRewards = await getUserRewards(userId, availableOnly: true);
      
      return {
        'user': user,
        'token_balance': tokenBalance,
        'active_investments_count': activeInvestments.length,
        'total_profit': totalProfit,
        'unread_notifications': unreadNotifications,
        'available_rewards_count': availableRewards.length,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Logger.error('Error getting dashboard data', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getInvestmentStatistics(String userId) async {
    try {
      final db = await database;
      
      final result = await db.rawQuery('''
        SELECT 
          DATE(created_at) as date,
          COUNT(*) as investment_count,
          SUM(amount) as total_amount,
          AVG(profit_rate) as avg_profit_rate
        FROM investments 
        WHERE user_id = ? 
        GROUP BY DATE(created_at)
        ORDER BY date DESC
        LIMIT 30
      ''', [userId]);
      
      return result;
    } catch (e) {
      Logger.error('Error getting investment statistics', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTokenStatistics(String userId) async {
    try {
      final db = await database;
      
      final result = await db.rawQuery('''
        SELECT 
          DATE(created_at) as date,
          type,
          SUM(amount) as total_amount,
          COUNT(*) as transaction_count
        FROM token_transactions 
        WHERE user_id = ? 
        GROUP BY DATE(created_at), type
        ORDER BY date DESC
        LIMIT 50
      ''', [userId]);
      
      return result;
    } catch (e) {
      Logger.error('Error getting token statistics', e);
      rethrow;
    }
  }

  // متدهای پشتیبان‌گیری و بازیابی
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final db = await database;
      
      final userData = await getUserById(userId);
      final investments = await getUserInvestments(userId);
      final tokens = await getUserTokenTransactions(userId);
      final notifications = await getUserNotifications(userId);
      final rewards = await getUserRewards(userId);
      
      return {
        'export_date': DateTime.now().toIso8601String(),
        'user_id': userId,
        'user': userData,
        'investments': investments,
        'token_transactions': tokens,
        'notifications': notifications,
        'rewards': rewards,
      };
    } catch (e) {
      Logger.error('Error exporting user data', e);
      rethrow;
    }
  }

  Future<void> importUserData(Map<String, dynamic> data) async {
    try {
      final db = await database;
      
      await db.transaction((txn) async {
        // وارد کردن اطلاعات کاربر
        if (data['user'] != null) {
          await txn.insert('users', data['user'], conflictAlgorithm: ConflictAlgorithm.replace);
        }
        
        // وارد کردن سرمایه‌گذاری‌ها
        if (data['investments'] != null) {
          for (var investment in data['investments']) {
            await txn.insert('investments', investment, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
        
        // وارد کردن تراکنش‌های توکن
        if (data['token_transactions'] != null) {
          for (var transaction in data['token_transactions']) {
            await txn.insert('token_transactions', transaction, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
        
        // وارد کردن اعلان‌ها
        if (data['notifications'] != null) {
          for (var notification in data['notifications']) {
            await txn.insert('notifications', notification, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
        
        // وارد کردن پاداش‌ها
        if (data['rewards'] != null) {
          for (var reward in data['rewards']) {
            await txn.insert('rewards', reward, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      });
      
      Logger.info('User data imported successfully');
    } catch (e) {
      Logger.error('Error importing user data', e);
      rethrow;
    }
  }

  // متدهای پاکسازی و نگهداری
  Future<void> cleanupOldNotifications({int daysToKeep = 30}) async {
    try {
      final db = await database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final deletedCount = await db.delete(
        'notifications',
        where: 'created_at < ? AND is_read = 1',
        whereArgs: [cutoffDate.toIso8601String()],
      );
      
      Logger.info('Cleaned up $deletedCount old notifications');
    } catch (e) {
      Logger.error('Error cleaning up notifications', e);
      rethrow;
    }
  }

  Future<void> cleanupExpiredRewards() async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      
      final deletedCount = await db.delete(
        'rewards',
        where: 'expires_at < ? AND is_claimed = 0',
        whereArgs: [now],
      );
      
      Logger.info('Cleaned up $deletedCount expired rewards');
    } catch (e) {
      Logger.error('Error cleaning up rewards', e);
      rethrow;
    }
  }

  Future<void> optimizeDatabase() async {
    try {
      final db = await database;
      
      // تحلیل و بهینه‌سازی جداول
      await db.execute('ANALYZE');
      await db.execute('VACUUM');
      
      Logger.info('Database optimized successfully');
    } catch (e) {
      Logger.error('Error optimizing database', e);
      rethrow;
    }
  }

  // بستن دیتابیس
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      Logger.info('Database closed');
    }
  }

  // حذف کامل دیتابیس (برای تست)
  Future<void> deleteDatabase() async {
    try {
      String path = join(await getDatabasesPath(), dbName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
      Logger.info('Database deleted');
    } catch (e) {
      Logger.error('Error deleting database', e);
      rethrow;
    }
  }
}