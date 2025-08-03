// lib/presentation/pages/gamification/achievements_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../data/models/achievement.dart';
import '../../../core/services/gamification_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/constants.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final GamificationService _gamificationService = GamificationService();
  List<Achievement> achievements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => isLoading = true);
    
    try {
      // بارگذاری دستاوردها از سرویس
      final loadedAchievements = await _gamificationService._getAvailableAchievements('current_user_id');
      setState(() {
        achievements = loadedAchievements;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در بارگذاری دستاوردها'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              Colors.purple.shade400,
              Colors.purple.shade600,
              Colors.purple.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: isLoading
                    ? _buildLoadingView()
                    : _buildAchievementsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'دستاوردها',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildAchievementsList() {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: 20),
            Text(
              'هنوز دستاوردی ندارید',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'با استفاده از اپلیکیشن دستاوردهای جدید باز کنید',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement, index);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: null,
        borderRadius: AppConstants.largeBorderRadius,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: achievement.isUnlocked
              ? [
                  Colors.gold.withOpacity(0.2),
                  Colors.gold.withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
        ),
        borderGradient: LinearGradient(
          colors: achievement.isUnlocked
              ? [
                  Colors.gold.withOpacity(0.5),
                  Colors.gold.withOpacity(0.2),
                ]
              : [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? Colors.gold.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _getAchievementIcon(achievement.icon),
                  size: 30,
                  color: achievement.isUnlocked ? Colors.gold : Colors.white70,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          size: 16,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${achievement.points} امتیاز',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (achievement.isUnlocked)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'باز شده',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade200,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.lock_outline,
                  color: Colors.white.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.3);
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'first_investment':
        return Icons.rocket_launch;
      case 'token_collector':
        return Icons.monetization_on;
      case 'level_master':
        return Icons.emoji_events;
      case 'daily_login':
        return Icons.calendar_today;
      default:
        return Icons.star;
    }
  }
}

// lib/presentation/pages/gamification/leaderboard_page.dart
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  
  final GamificationService _gamificationService = GamificationService();
  List<LeaderboardEntry> leaderboard = [];
  int userRank = 0;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => isLoading = true);
    
    try {
      final entries = await _gamificationService.getLeaderboard();
      final rank = await _gamificationService.getUserRank('current_user_id');
      
      setState(() {
        leaderboard = entries;
        userRank = rank;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در بارگذاری جدول رتبه‌بندی'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              Colors.indigo.shade400,
              Colors.indigo.shade600,
              Colors.indigo.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabs(),
              _buildUserRankCard(),
              Expanded(
                child: isLoading
                    ? _buildLoadingView()
                    : _buildLeaderboardList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'جدول رتبه‌بندی',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: [
          Tab(text: 'تجربه'),
          Tab(text: 'توکن'),
          Tab(text: 'سود'),
        ],
      ),
    );
  }

  Widget _buildUserRankCard() {
    return Container(
      margin: EdgeInsets.all(AppConstants.defaultPadding),
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.shade600, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رتبه شما',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  userRank > 0 ? '#$userRank' : 'نامشخص',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    ).animate().scale(duration: 600.ms);
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    if (leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: 20),
            Text(
              'جدول رتبه‌بندی خالی است',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildRankingList(RankingType.experience),
        _buildRankingList(RankingType.tokens),
        _buildRankingList(RankingType.profit),
      ],
    );
  }

  Widget _buildRankingList(RankingType type) {
    // مرتب‌سازی بر اساس نوع رتبه‌بندی
    final sortedLeaderboard = List<LeaderboardEntry>.from(leaderboard);
    switch (type) {
      case RankingType.experience:
        sortedLeaderboard.sort((a, b) => b.experience.compareTo(a.experience));
        break;
      case RankingType.tokens:
        sortedLeaderboard.sort((a, b) => b.totalTokens.compareTo(a.totalTokens));
        break;
      case RankingType.profit:
        sortedLeaderboard.sort((a, b) => b.totalProfit.compareTo(a.totalProfit));
        break;
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      itemCount: sortedLeaderboard.length,
      itemBuilder: (context, index) {
        final entry = sortedLeaderboard[index];
        return _buildLeaderboardItem(entry, index + 1, type);
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int rank, RankingType type) {
    Color rankColor = Colors.white;
    IconData rankIcon = Icons.person;
    
    if (rank == 1) {
      rankColor = Colors.gold;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade300;
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = Colors.brown.shade300;
      rankIcon = Icons.emoji_events;
    }

    String value;
    switch (type) {
      case RankingType.experience:
        value = '${entry.experience} تجربه';
        break;
      case RankingType.tokens:
        value = formatTokens(entry.totalTokens);
        break;
      case RankingType.profit:
        value = formatCurrency(entry.totalProfit);
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: null,
        borderRadius: AppConstants.borderRadius,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: rank <= 3
                      ? Icon(rankIcon, color: rankColor, size: 20)
                      : Text(
                          '$rank',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'سطح ${entry.level}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: 50 * rank))
        .slideX(begin: 0.3);
  }
}

enum RankingType { experience, tokens, profit }

// lib/presentation/pages/gamification/challenges_page.dart
class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final GamificationService _gamificationService = GamificationService();
  List<Challenge> challenges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() => isLoading = true);
    
    try {
      // بارگذاری چالش‌های روزانه
      final dailyChallenge = await _gamificationService.createDailyChallenge('current_user_id');
      setState(() {
        challenges = [dailyChallenge];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در بارگذاری چالش‌ها'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              Colors.teal.shade400,
              Colors.teal.shade600,
              Colors.teal.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: isLoading
                    ? _buildLoadingView()
                    : _buildChallengesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'چالش‌های روزانه',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadChallenges,
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildChallengesList() {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: 20),
            Text(
              'چالشی موجود نیست',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadChallenges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal.shade600,
              ),
              child: Text('بارگذاری مجدد'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return _buildChallengeCard(challenge, index);
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge, int index) {
    final timeLeft = challenge.expiresAt.difference(DateTime.now());
    final hoursLeft = timeLeft.inHours;
    final minutesLeft = timeLeft.inMinutes % 60;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: null,
        borderRadius: AppConstants.largeBorderRadius,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: challenge.isCompleted
              ? [
                  Colors.green.withOpacity(0.2),
                  Colors.green.withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
        ),
        borderGradient: LinearGradient(
          colors: challenge.isCompleted
              ? [
                  Colors.green.withOpacity(0.5),
                  Colors.green.withOpacity(0.2),
                ]
              : [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
        ),
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
                      color: _getChallengeTypeColor(challenge.type).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getChallengeTypeIcon(challenge.type),
                      color: _getChallengeTypeColor(challenge.type),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          challenge.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (challenge.isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    ),
                ],
              ),
              SizedBox(height: 16),
              
              // نوار پیشرفت
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'پیشرفت: ${challenge.currentValue.toInt()}/${challenge.targetValue.toInt()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '${(challenge.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: challenge.progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      challenge.isCompleted ? Colors.green : Colors.orange,
                    ),
                    minHeight: 6,
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // اطلاعات پاداش و زمان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 16,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${challenge.reward} توکن',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (!challenge.isExpired && !challenge.isCompleted)
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.red.shade300,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '$hoursLeftس $minutesLeftد باقی‌مانده',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade300,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideY(begin: 0.3);
  }

  Color _getChallengeTypeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.daily:
        return Colors.blue;
      case ChallengeType.weekly:
        return Colors.purple;
      case ChallengeType.monthly:
        return Colors.orange;
      case ChallengeType.special:
        return Colors.pink;
    }
  }

  IconData _getChallengeTypeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.daily:
        return Icons.today;
      case ChallengeType.weekly:
        return Icons.date_range;
      case ChallengeType.monthly:
        return Icons.calendar_month;
      case ChallengeType.special:
        return Icons.star;
    }
  }
}