
import 'package:equatable/equatable.dart';

abstract class GetWorkersEvent extends Equatable {
  const GetWorkersEvent();

  @override
  List<Object?> get props => [];
}

class GetWorkersRequested extends GetWorkersEvent {
  const GetWorkersRequested();
}
