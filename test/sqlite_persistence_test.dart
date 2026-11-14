import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:practica_aula/data/mock_data.dart';
import 'package:practica_aula/models/attendance_model.dart';
import 'package:practica_aula/models/group_model.dart';
import 'package:practica_aula/models/session_model.dart';
import 'package:practica_aula/models/student_model.dart';
import 'package:practica_aula/providers/attendance_provider.dart';
import 'package:practica_aula/providers/group_provider.dart';
import 'package:practica_aula/providers/participation_provider.dart';
import 'package:practica_aula/providers/session_provider.dart';
import 'package:practica_aula/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test(
    'sections, sessions, attendance, and scores survive database reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'aula-puntos-db-',
      );
      final databasePath = path.join(directory.path, 'test.db');

      try {
        SharedPreferences.setMockInitialValues({});
        await LocalStorageService.init(databasePath: databasePath);
        expect(LocalStorageService.readAttendanceBySessionSync(), isEmpty);
        final group = GroupModel(
          id: 'group-persistence-test',
          name: 'Persistencia',
          program: 'Desarrollo',
          academicPeriod: '2026-II',
          subject: 'Pruebas',
          sectionCode: 'TEST-01',
        );
        final student = StudentModel(
          id: 'student-persistence-test',
          groupId: group.id,
          firstName: 'Ana',
          lastName: 'López',
          institutionalCode: 'TEST-01-001',
        );
        await GroupProvider().addGroup(group, initialStudents: [student]);

        final session = SessionModel(
          id: 'session-persistence-test',
          groupId: group.id,
          sessionNumber: 1,
          theme: 'Persistencia local',
          sessionType: 'Teoría',
          durationHours: 2,
          observations: 'Verificar SQLite',
          date: DateTime(2026, 11, 13),
        );
        await SessionProvider().addSession(session);
        await AttendanceProvider().setStatus(
          sessionId: session.id,
          studentId: student.id,
          status: AttendanceStatus.absent,
        );
        await ParticipationProvider().addPoints(
          studentId: student.id,
          sessionId: session.id,
          points: 4,
        );

        await LocalStorageService.init(databasePath: databasePath);

        final restoredGroup = GroupProvider().groups.firstWhere(
          (item) => item.id == group.id,
        );
        final restoredStudent = GroupProvider()
            .studentsForGroup(group.id)
            .single;
        final restoredSession = SessionProvider()
            .sessionsForGroup(group.id)
            .single;
        final restoredAttendance = AttendanceProvider().attendanceForSession(
          session.id,
        )[student.id];
        final restoredPoints = ParticipationProvider().totalPointsForStudent(
          studentId: student.id,
          sessionId: session.id,
        );

        expect(restoredGroup.name, group.name);
        expect(restoredStudent.institutionalCode, student.institutionalCode);
        expect(restoredSession.theme, session.theme);
        expect(restoredAttendance, AttendanceStatus.absent);
        expect(restoredPoints, 4);
      } finally {
        await LocalStorageService.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test('imports sections previously stored in SharedPreferences', () async {
    final directory = await Directory.systemTemp.createTemp(
      'aula-puntos-migration-',
    );
    final databasePath = path.join(directory.path, 'test.db');
    final group = GroupModel(
      id: 'legacy-group',
      name: 'Sección existente',
      program: 'Desarrollo',
      academicPeriod: '2026-II',
      subject: 'Programación',
      sectionCode: 'LEG-01',
    );
    final student = StudentModel(
      id: 'legacy-student',
      groupId: group.id,
      firstName: 'Luis',
      lastName: 'Pérez',
      institutionalCode: 'LEG-01-001',
    );

    try {
      SharedPreferences.setMockInitialValues({
        'senati_groups': jsonEncode([group.toJson()]),
        'senati_students_by_group': jsonEncode({
          group.id: [student.toJson()],
        }),
      });
      await LocalStorageService.init(databasePath: databasePath);

      expect((await LocalStorageService.readGroups()).single.name, group.name);
      expect(
        (await LocalStorageService.readStudentsByGroup())[group.id]?.single.id,
        student.id,
      );
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('senati_groups'), isNull);
    } finally {
      await LocalStorageService.close();
      await directory.delete(recursive: true);
    }
  });

  test('removes preset sample attendance but keeps changed statuses', () async {
    final directory = await Directory.systemTemp.createTemp(
      'aula-puntos-attendance-migration-',
    );
    final databasePath = path.join(directory.path, 'test.db');

    try {
      SharedPreferences.setMockInitialValues({});
      await LocalStorageService.init(databasePath: databasePath);
      await LocalStorageService.close();

      final database = await openDatabase(databasePath);
      final sampleAttendance = buildAttendanceBySession();
      const changedSessionId = 'session-g1-1';
      const changedStudentId = 'student-g1-1';
      for (final session in sampleAttendance.entries) {
        for (final student in session.value.entries) {
          await database.insert('attendance', {
            'sessionId': session.key,
            'studentId': student.key,
            'status':
                session.key == changedSessionId &&
                    student.key == changedStudentId
                ? AttendanceStatus.absent.name
                : student.value.name,
          });
        }
      }
      await database.execute('PRAGMA user_version = 2');
      await database.close();

      await LocalStorageService.init(databasePath: databasePath);

      expect(LocalStorageService.readAttendanceBySessionSync(), {
        changedSessionId: {changedStudentId: AttendanceStatus.absent},
      });
    } finally {
      await LocalStorageService.close();
      await directory.delete(recursive: true);
    }
  });
}
