abstract class OutgoingEvent {}

class AddOutgoingEvent extends OutgoingEvent {
  final Map<String, dynamic> data;

  AddOutgoingEvent({
    required this.data,
  });
}

class GetOutgoingRecordsEvent extends OutgoingEvent {}