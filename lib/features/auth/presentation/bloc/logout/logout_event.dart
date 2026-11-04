import 'package:equatable/equatable.dart';

abstract class LogoutEvent extends Equatable {
  const LogoutEvent();

  @override
  List<Object?> get props => [];
}

class LogoutRequested extends LogoutEvent {
  final String uid;

  const LogoutRequested({
    required this.uid,
  });

  @override
  List<Object?> get props => [uid];
}