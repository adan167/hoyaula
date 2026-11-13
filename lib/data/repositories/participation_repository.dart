import '../../models/participation_model.dart';
import '../mock_data.dart';

class ParticipationRepository {
  List<ParticipationModel> getParticipationRecords() {
    return buildParticipationRecords();
  }
}
