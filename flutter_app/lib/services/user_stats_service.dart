import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class UserStats {
  double progress; // 0.0 - 1.0
  int streakDays;
  int lessons;
  int points;
  String level; // A1, A2, B1, B2, etc.
  UserStats({
    required this.progress,
    required this.streakDays,
    required this.lessons,
    required this.points,
    required this.level,
  });
}

class UserStatsService {
  static final UserStatsService _instance = UserStatsService._internal();
  factory UserStatsService() => _instance;
  UserStatsService._internal();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  String _kProgress(String email) => 'stats.$email.progress';
  String _kStreak(String email) => 'stats.$email.streakDays';
  String _kLessons(String email) => 'stats.$email.lessons';
  String _kPoints(String email) => 'stats.$email.points';
  String _kLevel(String email) => 'stats.$email.level';

  Future<UserStats> getStats(String email) async {
    final p = await _prefs;
    var progress = p.getDouble(_kProgress(email));
    var streak = p.getInt(_kStreak(email));
    var lessons = p.getInt(_kLessons(email));
    var points = p.getInt(_kPoints(email));
    var level = p.getString(_kLevel(email));

    if (progress == null || streak == null || lessons == null || points == null || level == null) {
      // inicializar por defecto por usuario conocido
      switch (email) {
        case 'samuel@lexia.local':
          progress = 0.62;
          streak = 7;
          lessons = 24;
          points = 1240;
          level = 'B1';
          break;
        case 'saul@lexia.local':
          progress = 0.35;
          streak = 3;
          lessons = 12;
          points = 520;
          level = 'A2';
          break;
        case 'gael@lexia.local':
          progress = 0.81;
          streak = 10;
          lessons = 37;
          points = 1980;
          level = 'B2';
          break;
        default:
          progress = 0.0;
          streak = 0;
          lessons = 0;
          points = 0;
          level = 'A1';
      }
      await saveStats(email, UserStats(progress: progress, streakDays: streak, lessons: lessons, points: points, level: level));
    }

    return UserStats(
      progress: progress,
      streakDays: streak,
      lessons: lessons,
      points: points,
      level: level,
    );
  }

  Future<void> saveStats(String email, UserStats stats) async {
    final p = await _prefs;
    await p.setDouble(_kProgress(email), stats.progress);
    await p.setInt(_kStreak(email), stats.streakDays);
    await p.setInt(_kLessons(email), stats.lessons);
    await p.setInt(_kPoints(email), stats.points);
    await p.setString(_kLevel(email), stats.level);
  }
}
