// lib/data/models/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final double totalTokens;
  final double totalProfit;
  final int level;
  final int experience;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    this.totalTokens = 0.0,
    this.totalProfit = 0.0,
    this.level = 1,
    this.experience = 0,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatar: json['avatar'] as String?,
      totalTokens: (json['total_tokens'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'total_tokens': totalTokens,
      'total_profit': totalProfit,
      'level': level,
      'experience': experience,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    double? totalTokens,
    double? totalProfit,
    int? level,
    int? experience,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      totalTokens: totalTokens ?? this.totalTokens,
      totalProfit: totalProfit ?? this.totalProfit,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, level: $level)';
  }
}

// lib/data/models/investment.dart
class Investment {
  final String id;
  final String userId;
  final double amount;
  final double profitRate;
  final DateTime startDate;
  final DateTime? endDate;
  final InvestmentStatus status;
  final InvestmentType type;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Investment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.profitRate,
    required this.startDate,
    this.endDate,
    this.status = InvestmentStatus.active,
    this.type = InvestmentType.fixed,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      profitRate: (json['profit_rate'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'] as String) 
          : null,
      status: InvestmentStatus.fromString(json['status'] as String),
      type: InvestmentType.fromString(json['type'] as String),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'profit_rate': profitRate,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status.toString(),
      'type': type.toString(),
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  double calculateCurrentProfit() {
    final now = DateTime.now();
    final days = now.difference(startDate).inDays;
    return (amount * profitRate / 100) * (days / 365);
  }

  double calculateProjectedProfit() {
    if (endDate == null) return 0.0;
    final totalDays = endDate!.difference(startDate).inDays;
    return (amount * profitRate / 100) * (totalDays / 365);
  }

  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
  bool get isActive => status == InvestmentStatus.active && !isExpired;
}

enum InvestmentStatus {
  active,
  completed,
  cancelled,
  suspended;

  static InvestmentStatus fromString(String value) {
    return InvestmentStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => InvestmentStatus.active,
    );
  }

  @override
  String toString() => name;
}

enum InvestmentType {
  fixed,
  flexible,
  compound;

  static InvestmentType fromString(String value) {
    return InvestmentType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => InvestmentType.fixed,
    );
  }

  @override
  String toString() => name;
}

// lib/data/models/token_transaction.dart
class TokenTransaction {
  final String id;
  final String userId;
  final double amount;
  final TokenTransactionType type;
  final String? sourceId;
  final String? targetId;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  TokenTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.sourceId,
    this.targetId,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  factory TokenTransaction.fromJson(Map<String, dynamic> json) {
    return TokenTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TokenTransactionType.fromString(json['type'] as String),
      sourceId: json['source_id'] as String?,
      targetId: json['target_id'] as String?,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type.toString(),
      'source_id': sourceId,
      'target_id': targetId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  bool get isCredit => type.isCredit;
  bool get isDebit => type.isDebit;
}

enum TokenTransactionType {
  earned,        // کسب توکن از سرمایه‌گذاری
  bonus,         // پاداش
  referral,      // معرفی دوستان
  converted,     // تبدیل به وجه نقد
  transferred,   // انتقال به کاربر دیگر
  received,      // دریافت از کاربر دیگر
  spent,         // خرج کردن توکن
  expired;       // انقضای توکن

  static TokenTransactionType fromString(String value) {
    return TokenTransactionType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => TokenTransactionType.earned,
    );
  }

  bool get isCredit => [earned, bonus, referral, received].contains(this);
  bool get isDebit => [converted, transferred, spent, expired].contains(this);

  @override
  String toString() => name;
}

// lib/data/models/notification.dart
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? actionData;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.actionData,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.fromString(json['type'] as String),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String) 
          : null,
      actionData: json['action_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.toString(),
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'action_data': actionData,
    };
  }

  AppNotification copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      actionData: actionData,
    );
  }
}

enum NotificationType {
  investment,
  token,
  reward,
  system,
  reminder;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => NotificationType.system,
    );
  }

  @override
  String toString() => name;
}

// lib/data/models/reward.dart
class Reward {
  final String id;
  final String userId;
  final String title;
  final String description;
  final RewardType type;
  final double value;
  final bool isClaimed;
  final DateTime availableAt;
  final DateTime? expiresAt;
  final DateTime? claimedAt;
  final Map<String, dynamic>? conditions;

  Reward({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.isClaimed = false,
    required this.availableAt,
    this.expiresAt,
    this.claimedAt,
    this.conditions,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: RewardType.fromString(json['type'] as String),
      value: (json['value'] as num).toDouble(),
      isClaimed: json['is_claimed'] as bool? ?? false,
      availableAt: DateTime.parse(json['available_at'] as String),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String) 
          : null,
      claimedAt: json['claimed_at'] != null 
          ? DateTime.parse(json['claimed_at'] as String) 
          : null,
      conditions: json['conditions'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'type': type.toString(),
      'value': value,
      'is_claimed': isClaimed,
      'available_at': availableAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'claimed_at': claimedAt?.toIso8601String(),
      'conditions': conditions,
    };
  }

  bool get isAvailable => DateTime.now().isAfter(availableAt) && !isClaimed;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get canClaim => isAvailable && !isExpired;
}

enum RewardType {
  tokens,
  cashback,
  discount,
  bonus;

  static RewardType fromString(String value) {
    return RewardType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => RewardType.tokens,
    );
  }

  @override
  String toString() => name;
}