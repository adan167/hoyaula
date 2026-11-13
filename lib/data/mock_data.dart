import '../models/activity_model.dart';
import '../models/attendance_model.dart';
import '../models/group_model.dart';
import '../models/instructor_model.dart';
import '../models/participation_model.dart';
import '../models/session_model.dart';
import '../models/student_model.dart';

InstructorModel buildInstructor() {
  return InstructorModel(
    id: 'instructor-1',
    name: 'Diana Ramos',
    role: 'Instructor SENATI',
    academicControl: 'Control Académico',
    score: '98.5%',
    avatar: 'DR',
  );
}

List<GroupModel> buildMockGroups() {
  return [
    GroupModel(
      id: 'group-202601',
      name: 'Cohorte 2026-20',
      program: '2026-20',
      academicPeriod: '2026-20',
      subject: 'FORMACIÓN MONITORES EMPRESA',
      sectionCode: '2026-20-202601',
    ),
    GroupModel(
      id: 'group-202602',
      name: 'Cohorte 2026-21',
      program: '2026-21',
      academicPeriod: '2026-21',
      subject: 'DESARROLLO DE APLICACIONES',
      sectionCode: '2026-21-202602',
    ),
  ];
}

List<ActivityModel> buildActivities() {
  return [
    ActivityModel(id: 'activity-participation', name: 'Participación en clase'),
    ActivityModel(id: 'activity-lab', name: 'Laboratorio'),
    ActivityModel(id: 'activity-project', name: 'Proyecto'),
    ActivityModel(id: 'activity-exercise', name: 'Ejercicios'),
  ];
}

Map<String, List<StudentModel>> buildStudentsByGroup() {
  final studentsByGroup = <String, List<StudentModel>>{};
  final firstGroupStudents = [
    StudentModel(id: 'student-g1-1', groupId: 'group-202601', firstName: 'Ana', lastName: 'Rojas', institutionalCode: '202601-001'),
    StudentModel(id: 'student-g1-2', groupId: 'group-202601', firstName: 'Bruno', lastName: 'Castillo', institutionalCode: '202601-002'),
    StudentModel(id: 'student-g1-3', groupId: 'group-202601', firstName: 'Carla', lastName: 'Díaz', institutionalCode: '202601-003'),
    StudentModel(id: 'student-g1-4', groupId: 'group-202601', firstName: 'Diego', lastName: 'Fernández', institutionalCode: '202601-004'),
    StudentModel(id: 'student-g1-5', groupId: 'group-202601', firstName: 'Elena', lastName: 'García', institutionalCode: '202601-005'),
    StudentModel(id: 'student-g1-6', groupId: 'group-202601', firstName: 'Felipe', lastName: 'Huamán', institutionalCode: '202601-006'),
    StudentModel(id: 'student-g1-7', groupId: 'group-202601', firstName: 'Giselle', lastName: 'Ibarra', institutionalCode: '202601-007'),
    StudentModel(id: 'student-g1-8', groupId: 'group-202601', firstName: 'Hugo', lastName: 'Jaramillo', institutionalCode: '202601-008'),
    StudentModel(id: 'student-g1-9', groupId: 'group-202601', firstName: 'Isabel', lastName: 'Kuro', institutionalCode: '202601-009'),
    StudentModel(id: 'student-g1-10', groupId: 'group-202601', firstName: 'Javier', lastName: 'Luna', institutionalCode: '202601-010'),
  ];

  final secondGroupStudents = [
    StudentModel(id: 'student-g2-1', groupId: 'group-202602', firstName: 'Laura', lastName: 'Mendoza', institutionalCode: '202602-001'),
    StudentModel(id: 'student-g2-2', groupId: 'group-202602', firstName: 'Mateo', lastName: 'Núñez', institutionalCode: '202602-002'),
    StudentModel(id: 'student-g2-3', groupId: 'group-202602', firstName: 'Nora', lastName: 'Oliva', institutionalCode: '202602-003'),
    StudentModel(id: 'student-g2-4', groupId: 'group-202602', firstName: 'Oscar', lastName: 'Pérez', institutionalCode: '202602-004'),
    StudentModel(id: 'student-g2-5', groupId: 'group-202602', firstName: 'Paula', lastName: 'Quispe', institutionalCode: '202602-005'),
    StudentModel(id: 'student-g2-6', groupId: 'group-202602', firstName: 'Renato', lastName: 'Ríos', institutionalCode: '202602-006'),
    StudentModel(id: 'student-g2-7', groupId: 'group-202602', firstName: 'Sofía', lastName: 'Salazar', institutionalCode: '202602-007'),
    StudentModel(id: 'student-g2-8', groupId: 'group-202602', firstName: 'Tomás', lastName: 'Torres', institutionalCode: '202602-008'),
    StudentModel(id: 'student-g2-9', groupId: 'group-202602', firstName: 'Úrsula', lastName: 'Vargas', institutionalCode: '202602-009'),
    StudentModel(id: 'student-g2-10', groupId: 'group-202602', firstName: 'Víctor', lastName: 'Yupanqui', institutionalCode: '202602-010'),
  ];

  studentsByGroup['group-202601'] = firstGroupStudents;
  studentsByGroup['group-202602'] = secondGroupStudents;
  return studentsByGroup;
}

List<SessionModel> buildSessionsForGroup(String groupId) {
  final base = DateTime.now();
  if (groupId == 'group-202601') {
    return [
      SessionModel(
        id: 'session-g1-1',
        groupId: groupId,
        sessionNumber: 1,
        theme: 'Introducción al módulo de innovación',
        sessionType: 'Teoría',
        durationHours: 2,
        observations: 'Desarrollo de objetivos y metodologías.',
        date: base.subtract(const Duration(days: 18)),
      ),
      SessionModel(
        id: 'session-g1-2',
        groupId: groupId,
        sessionNumber: 2,
        theme: 'Práctica de planificación empresarial',
        sessionType: 'Práctica',
        durationHours: 3,
        observations: 'Trabajo en equipos y ejercicios guiados.',
        date: base.subtract(const Duration(days: 9)),
      ),
      SessionModel(
        id: 'session-g1-3',
        groupId: groupId,
        sessionNumber: 3,
        theme: 'Evaluación y laboratorio de indicadores',
        sessionType: 'Laboratorio',
        durationHours: 4,
        observations: 'Análisis del desempeño y cierre de sesión.',
        date: base.subtract(const Duration(days: 2)),
      ),
    ];
  }

  return [
    SessionModel(
      id: 'session-g2-1',
      groupId: groupId,
      sessionNumber: 1,
      theme: 'Conceptos básicos de programación',
      sessionType: 'Teoría',
      durationHours: 2.5,
      observations: 'Fundamentos iniciales y marco teórico.',
      date: base.subtract(const Duration(days: 17)),
    ),
    SessionModel(
      id: 'session-g2-2',
      groupId: groupId,
      sessionNumber: 2,
      theme: 'Desarrollo de caso práctico',
      sessionType: 'Práctica',
      durationHours: 3,
      observations: 'Casos simulados y revisión de resultados.',
      date: base.subtract(const Duration(days: 8)),
    ),
    SessionModel(
      id: 'session-g2-3',
      groupId: groupId,
      sessionNumber: 3,
      theme: 'Proyecto final y presentación',
      sessionType: 'Laboratorio',
      durationHours: 4,
      observations: 'Demostración y retroalimentación final.',
      date: base.subtract(const Duration(days: 1)),
    ),
  ];
}

Map<String, Map<String, AttendanceStatus>> buildAttendanceBySession() {
  final attendance = <String, Map<String, AttendanceStatus>>{};

  final firstSession = {
    'student-g1-1': AttendanceStatus.present,
    'student-g1-2': AttendanceStatus.tardy,
    'student-g1-3': AttendanceStatus.present,
    'student-g1-4': AttendanceStatus.absent,
    'student-g1-5': AttendanceStatus.justified,
    'student-g1-6': AttendanceStatus.present,
    'student-g1-7': AttendanceStatus.present,
    'student-g1-8': AttendanceStatus.tardy,
    'student-g1-9': AttendanceStatus.absent,
    'student-g1-10': AttendanceStatus.present,
  };

  final secondSession = {
    'student-g1-1': AttendanceStatus.present,
    'student-g1-2': AttendanceStatus.present,
    'student-g1-3': AttendanceStatus.tardy,
    'student-g1-4': AttendanceStatus.present,
    'student-g1-5': AttendanceStatus.absent,
    'student-g1-6': AttendanceStatus.justified,
    'student-g1-7': AttendanceStatus.present,
    'student-g1-8': AttendanceStatus.present,
    'student-g1-9': AttendanceStatus.tardy,
    'student-g1-10': AttendanceStatus.present,
  };

  final thirdSession = {
    'student-g1-1': AttendanceStatus.justified,
    'student-g1-2': AttendanceStatus.present,
    'student-g1-3': AttendanceStatus.present,
    'student-g1-4': AttendanceStatus.present,
    'student-g1-5': AttendanceStatus.absent,
    'student-g1-6': AttendanceStatus.present,
    'student-g1-7': AttendanceStatus.tardy,
    'student-g1-8': AttendanceStatus.present,
    'student-g1-9': AttendanceStatus.present,
    'student-g1-10': AttendanceStatus.present,
  };

  attendance['session-g1-1'] = firstSession;
  attendance['session-g1-2'] = secondSession;
  attendance['session-g1-3'] = thirdSession;

  final groupTwoSessionOne = {
    'student-g2-1': AttendanceStatus.present,
    'student-g2-2': AttendanceStatus.present,
    'student-g2-3': AttendanceStatus.tardy,
    'student-g2-4': AttendanceStatus.absent,
    'student-g2-5': AttendanceStatus.present,
    'student-g2-6': AttendanceStatus.justified,
    'student-g2-7': AttendanceStatus.present,
    'student-g2-8': AttendanceStatus.present,
    'student-g2-9': AttendanceStatus.tardy,
    'student-g2-10': AttendanceStatus.absent,
  };

  final groupTwoSessionTwo = {
    'student-g2-1': AttendanceStatus.present,
    'student-g2-2': AttendanceStatus.tardy,
    'student-g2-3': AttendanceStatus.present,
    'student-g2-4': AttendanceStatus.present,
    'student-g2-5': AttendanceStatus.absent,
    'student-g2-6': AttendanceStatus.present,
    'student-g2-7': AttendanceStatus.present,
    'student-g2-8': AttendanceStatus.justified,
    'student-g2-9': AttendanceStatus.present,
    'student-g2-10': AttendanceStatus.tardy,
  };

  final groupTwoSessionThree = {
    'student-g2-1': AttendanceStatus.present,
    'student-g2-2': AttendanceStatus.present,
    'student-g2-3': AttendanceStatus.present,
    'student-g2-4': AttendanceStatus.absent,
    'student-g2-5': AttendanceStatus.tardy,
    'student-g2-6': AttendanceStatus.present,
    'student-g2-7': AttendanceStatus.justified,
    'student-g2-8': AttendanceStatus.present,
    'student-g2-9': AttendanceStatus.present,
    'student-g2-10': AttendanceStatus.present,
  };

  attendance['session-g2-1'] = groupTwoSessionOne;
  attendance['session-g2-2'] = groupTwoSessionTwo;
  attendance['session-g2-3'] = groupTwoSessionThree;
  return attendance;
}

List<ParticipationModel> buildParticipationRecords() {
  return [
    ParticipationModel(id: 'p1', studentId: 'student-g1-1', sessionId: 'session-g1-1', activityId: 'activity-participation', points: 3, createdAt: DateTime.now().subtract(const Duration(days: 18))),
    ParticipationModel(id: 'p2', studentId: 'student-g1-2', sessionId: 'session-g1-1', activityId: 'activity-participation', points: 2, createdAt: DateTime.now().subtract(const Duration(days: 18))),
    ParticipationModel(id: 'p3', studentId: 'student-g1-3', sessionId: 'session-g1-1', activityId: 'activity-participation', points: 1, createdAt: DateTime.now().subtract(const Duration(days: 18))),
    ParticipationModel(id: 'p4', studentId: 'student-g1-4', sessionId: 'session-g1-2', activityId: 'activity-lab', points: 3, createdAt: DateTime.now().subtract(const Duration(days: 9))),
    ParticipationModel(id: 'p5', studentId: 'student-g1-5', sessionId: 'session-g1-2', activityId: 'activity-project', points: 2, createdAt: DateTime.now().subtract(const Duration(days: 9))),
    ParticipationModel(id: 'p6', studentId: 'student-g1-6', sessionId: 'session-g1-2', activityId: 'activity-project', points: 3, createdAt: DateTime.now().subtract(const Duration(days: 9))),
    ParticipationModel(id: 'p7', studentId: 'student-g1-7', sessionId: 'session-g1-3', activityId: 'activity-exercise', points: 2, createdAt: DateTime.now().subtract(const Duration(days: 2))),
    ParticipationModel(id: 'p8', studentId: 'student-g1-8', sessionId: 'session-g1-3', activityId: 'activity-exercise', points: 1, createdAt: DateTime.now().subtract(const Duration(days: 2))),
    ParticipationModel(id: 'p9', studentId: 'student-g2-1', sessionId: 'session-g2-1', activityId: 'activity-participation', points: 3, createdAt: DateTime.now().subtract(const Duration(days: 17))),
    ParticipationModel(id: 'p10', studentId: 'student-g2-2', sessionId: 'session-g2-1', activityId: 'activity-participation', points: 2, createdAt: DateTime.now().subtract(const Duration(days: 17))),
    ParticipationModel(id: 'p11', studentId: 'student-g2-3', sessionId: 'session-g2-2', activityId: 'activity-lab', points: 3, createdAt: DateTime.now().subtract(const Duration(days: 8))),
    ParticipationModel(id: 'p12', studentId: 'student-g2-4', sessionId: 'session-g2-2', activityId: 'activity-lab', points: 2, createdAt: DateTime.now().subtract(const Duration(days: 8))),
    ParticipationModel(id: 'p13', studentId: 'student-g2-5', sessionId: 'session-g2-3', activityId: 'activity-project', points: 3, createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ParticipationModel(id: 'p14', studentId: 'student-g2-6', sessionId: 'session-g2-3', activityId: 'activity-project', points: 1, createdAt: DateTime.now().subtract(const Duration(days: 1))),
  ];
}
