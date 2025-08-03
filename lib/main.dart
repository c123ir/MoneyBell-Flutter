// فایل: lib/main.dart
// نسخه ساده برای تست اولیه

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const SmartMoneyBellApp());
}

class SmartMoneyBellApp extends StatelessWidget {
  const SmartMoneyBellApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // عنوان برنامه
      title: 'Smart Money Bell',
      
      // تنظیمات فارسی‌سازی
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'), // فارسی ایران
      ],
      locale: const Locale('fa', 'IR'),
      
      // جهت راست به چپ (در builder تنظیم می‌شود)
      
      // تم برنامه
      theme: ThemeData(
        // رنگ اصلی
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1976D2),
        
        // رنگ‌های ثانویه
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1976D2),
          secondary: Color(0xFF42A5F5),
          tertiary: Color(0xFF4CAF50),
          surface: Colors.white,
          background: Color(0xFFF5F5F5),
          error: Color(0xFFD32F2F),
        ),
        
        // تنظیمات AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        
        // تنظیمات کارت‌ها
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        
        // تنظیمات دکمه‌ها
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        
        // فونت فارسی (Vazir)
        fontFamily: 'Vazir',
      ),
      
      // صفحه اولیه
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: const MainNavigationPage(),
      ),
    );
  }
}

// صفحه اصلی با Navigation
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  
  // عناوین صفحات
  final List<String> _titles = [
    'داشبورد',
    'دستاوردها',
    'رتبه‌بندی',
    'چالش‌ها',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar با عنوان پویا
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          // دکمه اعلان‌ها
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('صفحه اعلان‌ها به زودی اضافه می‌شود'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          // دکمه تنظیمات
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('صفحه تنظیمات به زودی اضافه می‌شود'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      
      // محتوای صفحه بر اساس تب انتخاب شده
      body: _buildCurrentPage(),
      
      // منوی پایینی
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'داشبورد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'دستاوردها',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: 'رتبه‌بندی',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stars_outlined),
            activeIcon: Icon(Icons.stars),
            label: 'چالش‌ها',
          ),
        ],
      ),
      
      // دکمه شناور برای عملیات سریع
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // نمایش منوی عملیات سریع
          _showQuickActionsSheet(context);
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  
  // ساخت صفحه فعلی
  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildAchievements();
      case 2:
        return _buildLeaderboard();
      case 3:
        return _buildChallenges();
      default:
        return _buildDashboard();
    }
  }
  
  // صفحه داشبورد
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // کارت خوش‌آمدگویی
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'سلام! خوش آمدید',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'به Smart Money Bell',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // کارت‌های آمار
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'توکن‌ها',
                  '1,250',
                  Icons.token,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'سود کل',
                  '2,500,000',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'سرمایه‌گذاری',
                  '3',
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'امتیاز',
                  '4,750',
                  Icons.star,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // بخش فعالیت‌های اخیر
          const Text(
            'فعالیت‌های اخیر',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // لیست فعالیت‌ها
          _buildActivityItem(
            'دریافت توکن',
            '50 توکن دریافت شد',
            '2 ساعت پیش',
            Icons.add_circle,
            Colors.green,
          ),
          _buildActivityItem(
            'سرمایه‌گذاری جدید',
            '1,000,000 تومان',
            '1 روز پیش',
            Icons.account_balance,
            Colors.blue,
          ),
          _buildActivityItem(
            'دستاورد جدید',
            'سرمایه‌گذار فعال',
            '3 روز پیش',
            Icons.emoji_events,
            Colors.orange,
          ),
        ],
      ),
    );
  }
  
  // صفحه دستاوردها
  Widget _buildAchievements() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 64,
            color: Color(0xFF1976D2),
          ),
          SizedBox(height: 16),
          Text(
            'صفحه دستاوردها',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'این صفحه در مرحله بعدی تکمیل می‌شود',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  // صفحه رتبه‌بندی
  Widget _buildLeaderboard() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard,
            size: 64,
            color: Color(0xFF1976D2),
          ),
          SizedBox(height: 16),
          Text(
            'صفحه رتبه‌بندی',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'این صفحه در مرحله بعدی تکمیل می‌شود',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  // صفحه چالش‌ها
  Widget _buildChallenges() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.stars,
            size: 64,
            color: Color(0xFF1976D2),
          ),
          SizedBox(height: 16),
          Text(
            'صفحه چالش‌ها',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'این صفحه در مرحله بعدی تکمیل می‌شود',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  // ساخت کارت آمار
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('کلیک روی $title'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ساخت آیتم فعالیت
  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          time,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ),
    );
  }
  
  // نمایش منوی عملیات سریع
  void _showQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // عنوان
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'عملیات سریع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // گزینه‌های عملیات
            _buildQuickActionTile(
              icon: Icons.account_balance_wallet,
              title: 'سرمایه‌گذاری جدید',
              subtitle: 'ایجاد سرمایه‌گذاری جدید',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('صفحه سرمایه‌گذاری جدید به زودی اضافه می‌شود'),
                  ),
                );
              },
            ),
            _buildQuickActionTile(
              icon: Icons.swap_horiz,
              title: 'تبدیل توکن',
              subtitle: 'تبدیل توکن به وجه نقد یا خدمات',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('صفحه تبدیل توکن به زودی اضافه می‌شود'),
                  ),
                );
              },
            ),
            _buildQuickActionTile(
              icon: Icons.history,
              title: 'تاریخچه تراکنش',
              subtitle: 'مشاهده تمام تراکنش‌ها',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('صفحه تاریخچه به زودی اضافه می‌شود'),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  // ساخت آیتم عملیات سریع
  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1976D2),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }
}