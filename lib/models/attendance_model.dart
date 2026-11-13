enum AttendanceStatus { present, tardy, absent, justified }

extension AttendanceStatusExtension on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Presente';
      case AttendanceStatus.tardy:
        return 'Tardanza';
      case AttendanceStatus.absent:
        return 'Falta';
      case AttendanceStatus.justified:
        return 'Justificado';
    }
  }

  String get shortLabel {
    switch (this) {
      case AttendanceStatus.present:
        return 'P';
      case AttendanceStatus.tardy:
        return 'T';
      case AttendanceStatus.absent:
        return 'F';
      case AttendanceStatus.justified:
        return 'J';
    }
  }
}
