import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:golds_nuts/features/notifications/domain/usecases/watch_notifications_use_case.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc
    extends Bloc<NotificationsEvent, NotificationsState> {
  final WatchNotificationsUseCase watchNotificationsUseCase;

  StreamSubscription? _notificationsSubscription;

  NotificationsBloc({
    required this.watchNotificationsUseCase,
  }) : super(const NotificationsInitial()) {
    on<WatchNotificationsEvent>(_onWatchNotifications);
    on<NotificationsUpdatedEvent>(_onNotificationsUpdated);
    on<NotificationsFailedEvent>(_onNotificationsFailed);
  }

  Future<void> _onWatchNotifications(
      WatchNotificationsEvent event,
      Emitter<NotificationsState> emit,
      ) async {
    emit(const NotificationsLoading());

    await _notificationsSubscription?.cancel();

    _notificationsSubscription = watchNotificationsUseCase(
      receiverId: event.receiverId,
    ).listen(
          (result) {
        result.fold(
              (failure) {
            add(
              NotificationsFailedEvent(
                message: failure.message,
              ),
            );
          },
              (notifications) {
            add(
              NotificationsUpdatedEvent(
                notifications: notifications,
              ),
            );
          },
        );
      },
      onError: (error) {
        add(
          const NotificationsFailedEvent(
            message: 'Something went wrong. Please try again.',
          ),
        );
      },
    );
  }

  void _onNotificationsUpdated(
      NotificationsUpdatedEvent event,
      Emitter<NotificationsState> emit,
      ) {
    emit(
      NotificationsLoaded(
        notifications: event.notifications,
      ),
    );
  }

  void _onNotificationsFailed(
      NotificationsFailedEvent event,
      Emitter<NotificationsState> emit,
      ) {
    emit(
      NotificationsError(
        message: event.message,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _notificationsSubscription?.cancel();
    return super.close();
  }
}