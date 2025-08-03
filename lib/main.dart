import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  // تنظیمات اولیه قبل از اجرای برنامه
  WidgetsFlutterBinding.ensureInitialized();
  
  // تنظیم رنگ نوار بالا صفحه (Status Bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // شفاف
      statusBarIconBrightness: Brightness.dark, // آیکون‌های تیره
    ),
  );
  
  // شروع برنامه اصلی
  runApp(const SmartMoneyBellApp());
}

// کلاس اصلی برنامه - ریشه همه چیز
class SmartMoneyBellApp extends StatelessWidget {
  const SmartMoneyBellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Money Bell', // عنوان برنامه
      debugShowCheckedModeBanner: false, // حذف نوار Debug
      
      // تنظیمات فارسی‌سازی
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'), // فارسی ایران
        Locale('en', 'US'), // انگلیسی آمریکا
      ],
      locale: const Locale('fa', 'IR'), // زبان پیش‌فرض: فارسی
      
      // تنظیمات تم (رنگ‌بندی کلی برنامه)
      theme: ThemeData(
        // رنگ اصلی برنامه: آبی
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2), // آبی اصلی
          brightness: Brightness.light, // تم روشن
        ),
        useMaterial3: true, // استفاده از Material Design 3
        
        // فونت اصلی برنامه (فونت سیستم فارسی)
        fontFamily: 'Vazir', // اگر فایل فونت نداشتید، این خط را حذف کنید
        
        // تنظیمات AppBar (نوار بالای صفحات)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // پس‌زمینه شفاف
          elevation: 0, // بدون سایه
          centerTitle: true, // عنوان وسط
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Vazir', // فونت فارسی
          ),
        ),
        
        // تنظیمات متن‌ها
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Vazir',
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Vazir',
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontFamily: 'Vazir',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontFamily: 'Vazir',
          ),
        ),
        
        // تنظیمات کارت‌ها
        cardTheme: CardThemeData(
          elevation: 4, // سایه
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // گوشه‌های گرد
          ),
          color: Colors.white,
        ),
        
        // تنظیمات دکمه‌ها
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Vazir', // فونت فارسی برای دکمه‌ها
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      
      // صفحه اصلی برنامه
      home: const DashboardPage(),
    );
  }
}

// صفحه داشبورد اصلی
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // متغیرهای داده‌ای (در آینده از دیتابیس خوانده می‌شوند)
  double tokenBalance = 1250.0; // موجودی توکن
  double totalProfit = 2500000.0; // سود کل
  int activeInvestments = 3; // تعداد سرمایه‌گذاری فعال
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // نوار بالای صفحه
      appBar: AppBar(
        title: const Text(
          'داشبورد',
          textDirection: TextDirection.rtl, // راست‌چین
        ),
        actions: [
          // آیکون اعلان‌ها
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _showSnackBar('صفحه اعلان‌ها در حال توسعه است');
            },
          ),
          // آیکون تنظیمات
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              _showSnackBar('صفحه تنظیمات در حال توسعه است');
            },
          ),
        ],
      ),
      
      // محتوای اصلی صفحه
      body: SingleChildScrollView( // قابلیت اسکرول
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بخش خوش‌آمدگویی
            _buildWelcomeSection(),
            
            const SizedBox(height: 24), // فاصله
            
            // بخش آمار اصلی
            _buildStatsSection(),
            
            const SizedBox(height: 24),
            
            // بخش عملیات سریع
            _buildQuickActionsSection(),
            
            const SizedBox(height: 24),
            
            // بخش فعالیت‌های اخیر
            _buildRecentActivitiesSection(),
          ],
        ),
      ),
      
      // دکمه شناور
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showBottomSheet(); // نمایش منوی عملیات
        },
        icon: const Icon(Icons.add),
        label: const Text('عملیات جدید'),
      ),
    );
  }
  
  // بخش خوش‌آمدگویی
  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // گرادیان آبی زیبا
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1976D2), // آبی تیره
            Color(0xFF42A5F5), // آبی روشن
          ],
        ),
        borderRadius: BorderRadius.circular(16), // گوشه‌های گرد
        boxShadow: [ // سایه
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // آیکون و متن خوش‌آمدگویی
          Row(
            children: [
              Icon(
                Icons.waving_hand,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'خوش آمدید!',
                textDirection: TextDirection.rtl, // راست‌چین
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // متن توضیحی
          Text(
            'به Smart Money Bell خوش آمدید\nدستیار هوشمند سرمایه‌گذاری شما',
            textDirection: TextDirection.rtl, // راست‌چین
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  // بخش آمار اصلی
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان بخش
        const Text(
          'آمار کلی',
          textDirection: TextDirection.rtl, // راست‌چین
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // ردیف اول آمار
        Row(
          children: [
            // کارت موجودی توکن
            Expanded(
              child: _buildStatCard(
                title: 'موجودی توکن',
                value: tokenBalance.toInt().toString(),
                icon: Icons.token,
                color: Colors.orange,
                onTap: () => _showSnackBar('جزئیات توکن‌ها'),
              ),
            ),
            const SizedBox(width: 16),
            // کارت سود کل
            Expanded(
              child: _buildStatCard(
                title: 'سود کل',
                value: _formatMoney(totalProfit),
                icon: Icons.trending_up,
                color: Colors.green,
                onTap: () => _showSnackBar('جزئیات سود'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // ردیف دوم آمار
        Row(
          children: [
            // کارت سرمایه‌گذاری فعال
            Expanded(
              child: _buildStatCard(
                title: 'سرمایه‌گذاری فعال',
                value: activeInvestments.toString(),
                icon: Icons.account_balance,
                color: Colors.blue,
                onTap: () => _showSnackBar('لیست سرمایه‌گذاری‌ها'),
              ),
            ),
            const SizedBox(width: 16),
            // کارت امتیاز
            Expanded(
              child: _buildStatCard(
                title: 'امتیاز شما',
                value: '850',
                icon: Icons.star,
                color: Colors.purple,
                onTap: () => _showSnackBar('جزئیات امتیازات'),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // ساخت کارت آمار
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap, // کلیک روی کارت
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // آیکون با رنگ
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              // عنوان
              Text(
                title,
                textDirection: TextDirection.rtl, // راست‌چین
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              // مقدار
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // بخش عملیات سریع
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان بخش
        const Text(
          'عملیات سریع',
          textDirection: TextDirection.rtl, // راست‌چین
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // لیست دکمه‌های عملیات
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // دکمه سرمایه‌گذاری جدید
            _buildQuickActionButton(
              icon: Icons.add_circle_outline,
              title: 'سرمایه‌گذاری\nجدید',
              color: Colors.green,
              onTap: () => _showSnackBar('صفحه سرمایه‌گذاری جدید'),
            ),
            // دکمه تبدیل توکن
            _buildQuickActionButton(
              icon: Icons.swap_horiz,
              title: 'تبدیل\nتوکن',
              color: Colors.orange,
              onTap: () => _showSnackBar('صفحه تبدیل توکن'),
            ),
            // دکمه تاریخچه
            _buildQuickActionButton(
              icon: Icons.history,
              title: 'تاریخچه\nتراکنش',
              color: Colors.blue,
              onTap: () => _showSnackBar('صفحه تاریخچه'),
            ),
            // دکمه گزارش
            _buildQuickActionButton(
              icon: Icons.assessment,
              title: 'گزارش\nعملکرد',
              color: Colors.purple,
              onTap: () => _showSnackBar('صفحه گزارش‌ها'),
            ),
          ],
        ),
      ],
    );
  }
  
  // ساخت دکمه عملیات سریع
  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap, // کلیک روی دکمه
      child: Column(
        children: [
          // آیکون دایره‌ای
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          // متن عنوان
          Text(
            title,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl, // راست‌چین
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  // بخش فعالیت‌های اخیر
  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان بخش
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'فعالیت‌های اخیر',
              textDirection: TextDirection.rtl, // راست‌چین
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // دکمه مشاهده همه
            TextButton(
              onPressed: () => _showSnackBar('صفحه تمام فعالیت‌ها'),
              child: const Text(
                'مشاهده همه',
                textDirection: TextDirection.rtl, // راست‌چین
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // لیست فعالیت‌ها (داده‌های نمونه)
        _buildActivityItem(
          icon: Icons.add_circle,
          title: 'سرمایه‌گذاری جدید',
          subtitle: '5,000,000 تومان',
          time: '2 ساعت پیش',
          color: Colors.green,
        ),
        _buildActivityItem(
          icon: Icons.trending_up,
          title: 'دریافت سود',
          subtitle: '125,000 تومان',
          time: '1 روز پیش',
          color: Colors.blue,
        ),
        _buildActivityItem(
          icon: Icons.swap_horiz,
          title: 'تبدیل توکن',
          subtitle: '50 توکن به 250,000 تومان',
          time: '3 روز پیش',
          color: Colors.orange,
        ),
      ],
    );
  }
  
  // ساخت آیتم فعالیت
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        // آیکون سمت راست
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        // عنوان و زیرعنوان
        title: Text(
          title,
          textDirection: TextDirection.rtl, // راست‌چین
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          textDirection: TextDirection.rtl, // راست‌چین
        ),
        // زمان سمت چپ
        trailing: Text(
          time,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        // کلیک روی آیتم
        onTap: () => _showSnackBar('جزئیات: $title'),
      ),
    );
  }
  
  // نمایش منوی پایینی عملیات
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // دسته منو
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // عنوان
            const Text(
              'عملیات جدید',
              textDirection: TextDirection.rtl, // راست‌چین
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // گزینه‌های منو
            _buildBottomSheetItem(
              icon: Icons.add_circle,
              title: 'سرمایه‌گذاری جدید',
              subtitle: 'شروع یک سرمایه‌گذاری تازه',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('صفحه سرمایه‌گذاری جدید');
              },
            ),
            _buildBottomSheetItem(
              icon: Icons.swap_horiz,
              title: 'تبدیل توکن',
              subtitle: 'تبدیل توکن‌ها به وجه نقد',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('صفحه تبدیل توکن');
              },
            ),
            _buildBottomSheetItem(
              icon: Icons.send,
              title: 'انتقال توکن',
              subtitle: 'ارسال توکن به کاربران دیگر',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('صفحه انتقال توکن');
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  // ساخت آیتم منوی پایینی
  Widget _buildBottomSheetItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        textDirection: TextDirection.rtl, // راست‌چین
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        textDirection: TextDirection.rtl, // راست‌چین
      ),
      onTap: onTap,
    );
  }
  
  // نمایش پیام کوتاه (SnackBar)
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // مدت نمایش 2 ثانیه
        action: SnackBarAction(
          label: 'باشه',
          onPressed: () {}, // بستن پیام
        ),
      ),
    );
  }
  
  // فرمت کردن مبلغ پول (اضافه کردن کاما)
  String _formatMoney(double amount) {
    String formatted = amount.toInt().toString();
    // اضافه کردن کاما هر 3 رقم
    return formatted.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}