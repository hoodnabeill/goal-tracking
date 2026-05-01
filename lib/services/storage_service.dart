import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal.dart';

class StorageService {
  static const _goalsKey = 'progress_engine_goals';

  Future<List<Goal>> loadGoals() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedGoals = preferences.getString(_goalsKey);

    if (encodedGoals == null || encodedGoals.isEmpty) {
      return [];
    }

    final decodedGoals = jsonDecode(encodedGoals) as List<dynamic>;
    return decodedGoals
        .map((goal) => Goal.fromJson(goal as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveGoals(List<Goal> goals) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedGoals = jsonEncode(
      goals.map((goal) => goal.toJson()).toList(),
    );
    await preferences.setString(_goalsKey, encodedGoals);
  }
}
