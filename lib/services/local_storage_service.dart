import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../data/mock_data.dart';
import '../models/attendance_model.dart';
import '../models/group_model.dart';
import '../models/participation_model.dart';
import '../models/session_model.dart';
import '../models/student_model.dart';

class LocalStorageService {
  static const String _databaseName = 'aula_puntos.db';
  static const int _databaseVersion = 3;
  static const String _legacyMigrationKey = 'sqlite_migration_v1_complete';
  static const String _legacyGroupsKey = 'senati_groups';
  static const String _legacyStudentsKey = 'senati_students_by_group';

  static Database? _database;
  static bool _ffiConfigured = false;
  static List<GroupModel> _groups = [];
  static Map<String, List<StudentModel>> _studentsByGroup = {};
  static Map<String, List<SessionModel>> _sessionsByGroup = {};
  static Map<String, Map<String, AttendanceStatus>> _attendanceBySession = {};
  static List<ParticipationModel> _participationRecords = [];

  static Future<void> init({
    bool inMemory = false,
    String? databasePath,
  }) async {
    await _database?.close();
    final preferences = await SharedPreferences.getInstance();
    final legacyData = await _readLegacyData(preferences);
    if (!_ffiConfigured &&
        !kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _ffiConfigured = true;
    }

    final options = OpenDatabaseOptions(
      version: _databaseVersion,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = OFF');
      },
      onCreate: _createSchema,
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await _removeUnchangedSampleAttendance(database);
        }
      },
    );

    if (inMemory) {
      _database = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: options,
      );
    } else if (kIsWeb) {
      final resolvedPath = databasePath ?? _databaseName;
      _database = await openDatabase(resolvedPath, options: options);
    } else {
      final resolvedPath =
          databasePath ?? path.join(await getDatabasesPath(), _databaseName);
      _database = await openDatabase(resolvedPath, options: options);
    }

    await _seedMockDataIfNeeded(legacyData);
    await _loadCache();
    if (legacyData != null) {
      await preferences.setBool(_legacyMigrationKey, true);
      await preferences.remove(_legacyGroupsKey);
      await preferences.remove(_legacyStudentsKey);
    }
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  static Future<void> _createSchema(Database database, int version) async {
    await database.execute('''
      CREATE TABLE academic_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        program TEXT NOT NULL,
        academicPeriod TEXT NOT NULL,
        subject TEXT NOT NULL,
        sectionCode TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        groupId TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        institutionalCode TEXT NOT NULL,
        avatar TEXT
      )
    ''');
    await database.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        groupId TEXT NOT NULL,
        sessionNumber INTEGER NOT NULL,
        theme TEXT NOT NULL,
        sessionType TEXT NOT NULL,
        durationHours REAL NOT NULL,
        observations TEXT NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE attendance (
        sessionId TEXT NOT NULL,
        studentId TEXT NOT NULL,
        status TEXT NOT NULL,
        PRIMARY KEY (sessionId, studentId)
      )
    ''');
    await database.execute('''
      CREATE TABLE participation (
        id TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        sessionId TEXT NOT NULL,
        activityId TEXT NOT NULL,
        points INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  static Database get _db {
    final database = _database;
    if (database == null) {
      throw StateError(
        'LocalStorageService.init() must complete before database access.',
      );
    }
    return database;
  }

  static Future<_LegacyData?> _readLegacyData(
    SharedPreferences preferences,
  ) async {
    if (preferences.getBool(_legacyMigrationKey) ?? false) {
      return null;
    }

    final groupPayload = preferences.getString(_legacyGroupsKey);
    final studentsPayload = preferences.getString(_legacyStudentsKey);
    if (groupPayload == null && studentsPayload == null) {
      return _LegacyData([], {});
    }

    final groups = groupPayload == null
        ? <GroupModel>[]
        : (jsonDecode(groupPayload) as List<dynamic>)
              .map(
                (entry) => GroupModel.fromJson(
                  Map<String, dynamic>.from(entry as Map),
                ),
              )
              .toList();
    final studentsByGroup = <String, List<StudentModel>>{};
    if (studentsPayload != null) {
      final decoded = jsonDecode(studentsPayload) as Map<String, dynamic>;
      decoded.forEach((groupId, students) {
        studentsByGroup[groupId] = (students as List<dynamic>)
            .map(
              (entry) => StudentModel.fromJson(
                Map<String, dynamic>.from(entry as Map),
              ),
            )
            .toList();
      });
    }
    return _LegacyData(groups, studentsByGroup);
  }

  static Future<void> _seedMockDataIfNeeded(_LegacyData? legacyData) async {
    await _db.transaction((transaction) async {
      if (await _rowCount(transaction, 'academic_groups') == 0) {
        final groups = legacyData?.groups.isNotEmpty == true
            ? legacyData!.groups
            : buildMockGroups();
        for (final group in groups) {
          await transaction.insert('academic_groups', _groupRow(group));
        }
      }

      if (await _rowCount(transaction, 'students') == 0) {
        final studentsByGroup = legacyData?.studentsByGroup.isNotEmpty == true
            ? legacyData!.studentsByGroup
            : buildStudentsByGroup();
        for (final students in studentsByGroup.values) {
          for (final student in students) {
            await transaction.insert('students', _studentRow(student));
          }
        }
      }

      if (await _rowCount(transaction, 'sessions') == 0) {
        for (final group in buildMockGroups()) {
          for (final session in buildSessionsForGroup(group.id)) {
            await transaction.insert('sessions', _sessionRow(session));
          }
        }
      }

      if (await _rowCount(transaction, 'participation') == 0) {
        for (final record in buildParticipationRecords()) {
          await transaction.insert('participation', _participationRow(record));
        }
      }
    });
  }

  static Future<void> _removeUnchangedSampleAttendance(
    DatabaseExecutor database,
  ) async {
    final actualRows = await database.query('attendance');
    final sampleAttendance = buildAttendanceBySession();
    for (final row in actualRows) {
      final sessionId = row['sessionId']! as String;
      final studentId = row['studentId']! as String;
      final status = row['status']! as String;
      if (sampleAttendance[sessionId]?[studentId]?.name == status) {
        await database.delete(
          'attendance',
          where: 'sessionId = ? AND studentId = ? AND status = ?',
          whereArgs: [sessionId, studentId, status],
        );
      }
    }
  }

  static Future<int> _rowCount(DatabaseExecutor database, String table) async {
    final rows = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM $table',
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  static Future<void> _loadCache() async {
    final groupRows = await _db.query(
      'academic_groups',
      orderBy: 'createdAt DESC',
    );
    _groups = groupRows.map(_groupFromRow).toList();

    final studentRows = await _db.query('students');
    _studentsByGroup = {
      for (final group in _groups) group.id: <StudentModel>[],
    };
    for (final row in studentRows) {
      final student = _studentFromRow(row);
      _studentsByGroup.putIfAbsent(student.groupId, () => <StudentModel>[]);
      _studentsByGroup[student.groupId]!.add(student);
    }

    final sessionRows = await _db.query('sessions', orderBy: 'date DESC');
    _sessionsByGroup = {};
    for (final row in sessionRows) {
      final session = _sessionFromRow(row);
      _sessionsByGroup.putIfAbsent(session.groupId, () => <SessionModel>[]);
      _sessionsByGroup[session.groupId]!.add(session);
    }

    final attendanceRows = await _db.query('attendance');
    _attendanceBySession = {};
    for (final row in attendanceRows) {
      final sessionId = row['sessionId']! as String;
      final studentId = row['studentId']! as String;
      final statusName = row['status']! as String;
      _attendanceBySession.putIfAbsent(
        sessionId,
        () => <String, AttendanceStatus>{},
      )[studentId] = AttendanceStatus.values.byName(
        statusName,
      );
    }

    final participationRows = await _db.query(
      'participation',
      orderBy: 'createdAt DESC',
    );
    _participationRecords = participationRows
        .map(_participationFromRow)
        .toList();
  }

  static List<GroupModel> readGroupsSync() => List.unmodifiable(_groups);

  static Map<String, List<StudentModel>> readStudentsByGroupSync() =>
      _studentsByGroup.map(
        (groupId, students) => MapEntry(groupId, List.unmodifiable(students)),
      );

  static Map<String, List<SessionModel>> readSessionsByGroupSync() =>
      _sessionsByGroup.map(
        (groupId, sessions) => MapEntry(groupId, List.unmodifiable(sessions)),
      );

  static Map<String, Map<String, AttendanceStatus>>
  readAttendanceBySessionSync() => _attendanceBySession.map(
    (sessionId, attendance) => MapEntry(
      sessionId,
      Map<String, AttendanceStatus>.unmodifiable(attendance),
    ),
  );

  static List<ParticipationModel> readParticipationRecordsSync() =>
      List.unmodifiable(_participationRecords);

  static Future<void> saveGroupsAndStudents(
    List<GroupModel> groups,
    Map<String, List<StudentModel>> studentsByGroup,
  ) async {
    await _db.transaction((transaction) async {
      for (final group in groups) {
        await transaction.insert(
          'academic_groups',
          _groupRow(group),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final entry in studentsByGroup.entries) {
        final existing = await transaction.query(
          'students',
          columns: ['id'],
          where: 'groupId = ?',
          whereArgs: [entry.key],
        );
        final desiredIds = entry.value.map((student) => student.id).toSet();
        for (final row in existing) {
          final studentId = row['id']! as String;
          if (!desiredIds.contains(studentId)) {
            await transaction.delete(
              'students',
              where: 'id = ?',
              whereArgs: [studentId],
            );
          }
        }
        for (final student in entry.value) {
          await transaction.insert(
            'students',
            _studentRow(student),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
    await _loadCache();
  }

  static Future<void> saveSession(SessionModel session) async {
    await _db.insert(
      'sessions',
      _sessionRow(session),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _sessionsByGroup.putIfAbsent(session.groupId, () => <SessionModel>[]);
    _sessionsByGroup[session.groupId]!.removeWhere(
      (item) => item.id == session.id,
    );
    _sessionsByGroup[session.groupId]!.insert(0, session);
  }

  static Future<void> saveAttendance({
    required String sessionId,
    required String studentId,
    required AttendanceStatus status,
  }) async {
    await _db.insert('attendance', {
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status.name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    _attendanceBySession.putIfAbsent(
      sessionId,
      () => <String, AttendanceStatus>{},
    )[studentId] = status;
  }

  static Future<void> saveParticipation(ParticipationModel record) async {
    await _db.insert(
      'participation',
      _participationRow(record),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _participationRecords.insert(0, record);
  }

  static Future<List<GroupModel>> readGroups() async {
    return (await _db.query(
      'academic_groups',
      orderBy: 'createdAt DESC',
    )).map(_groupFromRow).toList();
  }

  static Future<Map<String, List<StudentModel>>> readStudentsByGroup() async {
    final rows = await _db.query('students');
    final result = <String, List<StudentModel>>{};
    for (final row in rows) {
      final student = _studentFromRow(row);
      result.putIfAbsent(student.groupId, () => <StudentModel>[]);
      result[student.groupId]!.add(student);
    }
    return result;
  }

  static Map<String, Object?> _groupRow(GroupModel group) => {
    'id': group.id,
    'name': group.name,
    'program': group.program,
    'academicPeriod': group.academicPeriod,
    'subject': group.subject,
    'sectionCode': group.sectionCode,
    'createdAt': group.createdAt.toIso8601String(),
  };

  static GroupModel _groupFromRow(Map<String, Object?> row) => GroupModel(
    id: row['id']! as String,
    name: row['name']! as String,
    program: row['program']! as String,
    academicPeriod: row['academicPeriod']! as String,
    subject: row['subject']! as String,
    sectionCode: row['sectionCode']! as String,
    createdAt: DateTime.parse(row['createdAt']! as String),
  );

  static Map<String, Object?> _studentRow(StudentModel student) => {
    'id': student.id,
    'groupId': student.groupId,
    'firstName': student.firstName,
    'lastName': student.lastName,
    'institutionalCode': student.institutionalCode,
    'avatar': student.avatar,
  };

  static StudentModel _studentFromRow(Map<String, Object?> row) => StudentModel(
    id: row['id']! as String,
    groupId: row['groupId']! as String,
    firstName: row['firstName']! as String,
    lastName: row['lastName']! as String,
    institutionalCode: row['institutionalCode']! as String,
    avatar: row['avatar'] as String?,
  );

  static Map<String, Object?> _sessionRow(SessionModel session) => {
    'id': session.id,
    'groupId': session.groupId,
    'sessionNumber': session.sessionNumber,
    'theme': session.theme,
    'sessionType': session.sessionType,
    'durationHours': session.durationHours,
    'observations': session.observations,
    'date': session.date.toIso8601String(),
    'createdAt': session.createdAt.toIso8601String(),
  };

  static SessionModel _sessionFromRow(Map<String, Object?> row) => SessionModel(
    id: row['id']! as String,
    groupId: row['groupId']! as String,
    sessionNumber: row['sessionNumber']! as int,
    theme: row['theme']! as String,
    sessionType: row['sessionType']! as String,
    durationHours: (row['durationHours']! as num).toDouble(),
    observations: row['observations']! as String,
    date: DateTime.parse(row['date']! as String),
    createdAt: DateTime.parse(row['createdAt']! as String),
  );

  static Map<String, Object?> _participationRow(ParticipationModel record) => {
    'id': record.id,
    'studentId': record.studentId,
    'sessionId': record.sessionId,
    'activityId': record.activityId,
    'points': record.points,
    'createdAt': record.createdAt.toIso8601String(),
  };

  static ParticipationModel _participationFromRow(Map<String, Object?> row) =>
      ParticipationModel(
        id: row['id']! as String,
        studentId: row['studentId']! as String,
        sessionId: row['sessionId']! as String,
        activityId: row['activityId']! as String,
        points: row['points']! as int,
        createdAt: DateTime.parse(row['createdAt']! as String),
      );
}

class _LegacyData {
  const _LegacyData(this.groups, this.studentsByGroup);

  final List<GroupModel> groups;
  final Map<String, List<StudentModel>> studentsByGroup;
}
