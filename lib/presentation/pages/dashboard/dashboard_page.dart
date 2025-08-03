// lib/presentation/pages/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/constants.dart';
import '../../widgets/animated_counter.dart';
import '../../widgets/investment_card.dart';
import '../../widgets/token_balance_card.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/recent_activities.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> 
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // نمونه داده‌ها
  double totalTokens = 1250.5;
  double totalProfit = 2850000;
  double totalInvestment = 50000000;
  int userLevel = 5;
  double levelProgress = 75.0;
  int unreadNotifications = 3;

  final List<double> chartData = [10, 15, 8, 20, 25, 18, 30];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    // شبیه‌سازی بارگذاری داده‌ها
    await Future.delayed(Duration(milliseconds: 500));
    
    // اینجا داده‌ها از دیتابیس بارگذاری می‌شوند
    setState(() {
      // داده‌ها بارگذاری شدند
    });
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('داده‌ها به‌روزرسانی شدند'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: EdgeInsets.all(AppConstants.defaultPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildWelcomeSection(),
                      SizedBox(height: 20),
                      _buildStatsCards(),
                      SizedBox(height: 20),
                      _buildChartSection(),
                      SizedBox(height: 20),
                      _buildQuickActions(),
                      SizedBox(height: 20),
                      _buildRecentActivities(),
                      SizedBox(height: 20),
                      _buildLevelProgress(),
                      SizedBox(height: 100), // فضای اضافی برای navigation bar
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Text(
            'داشبورد هوشمند',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                icon: Icon(Icons.notifications_outlined, color: Colors.white),
              ),
              if (unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$unreadNotifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سلام، کاربر عزیز!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'امروز روز خوبی برای سرمایه‌گذاری است',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.wb_sunny,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3);
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: TokenBalanceCard(
            tokens: totalTokens,
            onTap: () => Navigator.pushNamed(context, '/tokens'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildProfitCard(),
        ),
      ],
    );
  }

  Widget _buildProfitCard() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 120,
      borderRadius: AppConstants.largeBorderRadius,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.green.withOpacity(0.1),
          Colors.green.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.green.withOpacity(0.5),
          Colors.green.withOpacity(0.2),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 30,
              color: Colors.green.shade600,
            ),
            SizedBox(height: 8),
            Text(
              'سود کل',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            AnimatedCounter(
              value: totalProfit,
              formatter: (value) => formatCurrency(value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).scale();
  }

  Widget _buildChartSection() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'روند سرمایه‌گذاری',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/analytics'),
                child: Text('جزئیات بیشتر'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue.shade400,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.shade100.withOpacity(0.3),
                    ),
                  ),
                ],
                minX: 0,
                maxX: chartData.length.toDouble() - 1,
                minY: 0,
                maxY: chartData.reduce((a, b) => a > b ? a : b) + 5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildQuickActions() {
    return QuickActionsWidget(
      actions: [
        QuickAction(
          icon: Icons.add_circle,
          label: 'سرمایه‌گذاری جدید',
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, '/new-investment'),
        ),
        QuickAction(
          icon: Icons.swap_horiz,
          label: 'تبدیل توکن',
          color: Colors.orange,
          onTap: () => Navigator.pushNamed(context, '/convert-tokens'),
        ),
        QuickAction(
          icon: Icons.history,
          label: 'تاریخچه',
          color: Colors.purple,
          onTap: () => Navigator.pushNamed(context, '/history'),
        ),
        QuickAction(
          icon: Icons.card_giftcard,
          label: 'پاداش‌ها',
          color: Colors.green,
          onTap: () => Navigator.pushNamed(context, '/rewards'),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'فعالیت‌های اخیر',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/activities'),
                child: Text('مشاهده همه'),
              ),
            ],
          ),
          SizedBox(height: 16),
          RecentActivitiesWidget(
            activities: [
              Activity(
                icon: Icons.add_circle,
                title: 'دریافت توکن',
                subtitle: '50 توکن از سرمایه‌گذاری شما',
                time: DateTime.now().subtract(Duration(hours: 2)),
                color: Colors.green,
              ),
              Activity(
                icon: Icons.swap_horiz,
                title: 'تبدیل توکن',
                subtitle: '100 توکن به 50,000 تومان',
                time: DateTime.now().subtract(Duration(hours: 5)),
                color: Colors.orange,
              ),
              Activity(
                icon: Icons.star,
                title: 'دریافت پاداش',
                subtitle: 'پاداش وفاداری هفتگی',
                time: DateTime.now().subtract(Duration(days: 1)),
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildLevelProgress() {
    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سطح $userLevel',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${levelProgress.toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: levelProgress / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
          SizedBox(height: 12),
          Text(
            'تا رسیدن به سطح ${userLevel + 1}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 600.ms).scale();
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _showQuickActionsModal();
      },
      icon: Icon(Icons.add),
      label: Text('عملیات سریع'),
      backgroundColor: Colors.blue.shade600,
      elevation: 8,
    ).animate().scale(delay: 1000.ms, duration: 400.ms);
  }

  void _showQuickActionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsModal(),
    );
  }
}

// lib/presentation/widgets/animated_counter.dart
class AnimatedCounter extends StatefulWidget {
  final double value;
  final String Function(double) formatter;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  _AnimatedCounterState createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          widget.formatter(_animation.value),
          style: widget.style,
        );
      },
    );
  }
}

// lib/presentation/widgets/token_balance_card.dart
class TokenBalanceCard extends StatelessWidget {
  final double tokens;
  final VoidCallback onTap;

  const TokenBalanceCard({
    super.key,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 120,
        borderRadius: AppConstants.largeBorderRadius,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.5),
            Colors.orange.withOpacity(0.2),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on,
                size: 30,
                color: Colors.orange.shade600,
              ),
              SizedBox(height: 8),
              Text(
                'توکن‌های شما',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              AnimatedCounter(
                value: tokens,
                formatter: (value) => formatTokens(value),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale();
  }
}

// lib/presentation/widgets/quick_actions.dart
class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class QuickActionsWidget extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsWidget({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عملیات سریع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return GestureDetector(
                onTap: action.onTap,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: action.color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        action.icon,
                        color: action.color,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          action.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate()
                  .fadeIn(delay: Duration(milliseconds: 100 * index))
                  .slideY(begin: 0.3);
            },
          ),
        ],
      ),
    );
  }
}

// lib/presentation/widgets/recent_activities.dart
class Activity {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime time;
  final Color color;

  Activity({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
}

class RecentActivitiesWidget extends StatelessWidget {
  final List<Activity> activities;

  const RecentActivitiesWidget({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: activities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(bottom: index < activities.length - 1 ? 16 : 0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activity.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  activity.icon,
                  color: activity.color,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      activity.subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatRelativeTime(activity.time),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ).animate()
            .fadeIn(delay: Duration(milliseconds: 100 * index))
            .slideX(begin: 0.3);
      }).toList(),
    );
  }
}

// lib/presentation/widgets/quick_actions_modal.dart
class QuickActionsModal extends StatelessWidget {
  const QuickActionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.largeBorderRadius),
          topRight: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'عملیات سریع',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildModalAction(
                  context,
                  Icons.add_circle,
                  'سرمایه‌گذاری',
                  Colors.blue,
                  () => Navigator.pushNamed(context, '/new-investment'),
                ),
                _buildModalAction(
                  context,
                  Icons.swap_horiz,
                  'تبدیل توکن',
                  Colors.orange,
                  () => Navigator.pushNamed(context, '/convert-tokens'),
                ),
                _buildModalAction(
                  context,
                  Icons.send,
                  'انتقال توکن',
                  Colors.green,
                  () => Navigator.pushNamed(context, '/transfer-tokens'),
                ),
                _buildModalAction(
                  context,
                  Icons.qr_code_scanner,
                  'اسکن QR',
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/qr-scanner'),
                ),
                _buildModalAction(
                  context,
                  Icons.card_giftcard,
                  'پاداش‌ها',
                  Colors.pink,
                  () => Navigator.pushNamed(context, '/rewards'),
                ),
                _buildModalAction(
                  context,
                  Icons.support_agent,
                  'پشتیبانی',
                  Colors.teal,
                  () => Navigator.pushNamed(context, '/support'),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    ).animate().slideY(begin: 1.0, duration: 300.ms);
  }

  Widget _buildModalAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}