enum UserType { jobseeker, employer }

class LockedUser {
  final String lockedId;
  final String userId;
  final UserType userType;
  final String reason;
  final DateTime lockedAt;

  LockedUser({
    required this.lockedId,
    required this.userId,
    required this.userType,
    required this.reason,
    required this.lockedAt,
  });

  factory LockedUser.fromJson(Map<String, dynamic> json) {
    return LockedUser(
      lockedId: json['_id'],
      userId: json['userId'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == json['userType'],
        orElse: () => UserType.jobseeker,
      ),
      reason: json['reason'],
      lockedAt: DateTime.parse(json['lockedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // '_id': lockedId,
      'userId': userId,
      // 'userType': userType.toString().split('.').last,
      'reason': reason,
      // 'lockedAt': lockedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'LockedUser(lockedId: $lockedId, userId: $userId, userType: $userType, reason: $reason, lockedAt: $lockedAt)';
  }

  LockedUser copyWith({
    String? lockedId,
    String? userId,
    UserType? userType,
    String? reason,
    DateTime? lockedAt,
  }) {
    return LockedUser(
      lockedId: lockedId ?? this.lockedId,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      reason: reason ?? this.reason,
      lockedAt: lockedAt ?? this.lockedAt,
    );
  }
}
