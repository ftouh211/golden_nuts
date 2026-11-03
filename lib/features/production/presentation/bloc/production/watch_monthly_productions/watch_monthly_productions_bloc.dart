import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';
import 'package:golds_nuts/features/production/domain/usecases/watch_monthly_productions_usecase.dart';

// ================= EVENTS =================

abstract class WatchMonthlyProductionsEvent {
  const WatchMonthlyProductionsEvent();
}

class WatchMonthlyProductionsRequested extends WatchMonthlyProductionsEvent {
  final DateTime month;
  final String? workerId;

  const WatchMonthlyProductionsRequested({required this.month, this.workerId});
}

class WatchMonthlyProductionsStopped extends WatchMonthlyProductionsEvent {
  const WatchMonthlyProductionsStopped();
}

// Internal events: تُستخدم داخل الـ Bloc فقط

class _ProductionsReceived extends WatchMonthlyProductionsEvent {
  final List<ProductionEntity> productions;

  const _ProductionsReceived(this.productions);
}

class _ProductionsFailed extends WatchMonthlyProductionsEvent {
  final String message;

  const _ProductionsFailed(this.message);
}

// ================= STATES =================

abstract class WatchMonthlyProductionsState {
  const WatchMonthlyProductionsState();
}

class WatchMonthlyProductionsInitial extends WatchMonthlyProductionsState {
  const WatchMonthlyProductionsInitial();
}

class WatchMonthlyProductionsLoading extends WatchMonthlyProductionsState {
  const WatchMonthlyProductionsLoading();
}

class WatchMonthlyProductionsSuccess extends WatchMonthlyProductionsState {
  final List<ProductionEntity> productions;

  const WatchMonthlyProductionsSuccess(this.productions);
}

class WatchMonthlyProductionsFailure extends WatchMonthlyProductionsState {
  final String message;

  const WatchMonthlyProductionsFailure(this.message);
}

// ================= BLOC =================

class WatchMonthlyProductionsBloc
    extends Bloc<WatchMonthlyProductionsEvent, WatchMonthlyProductionsState> {
  final WatchMonthlyProductionsUseCase watchMonthlyProductionsUseCase;

  StreamSubscription<Either<Failure, List<ProductionEntity>>>?
  _productionsSubscription;

  WatchMonthlyProductionsBloc({required this.watchMonthlyProductionsUseCase})
    : super(const WatchMonthlyProductionsInitial()) {
    on<WatchMonthlyProductionsRequested>(_onRequested);
    on<WatchMonthlyProductionsStopped>(_onStopped);

    // Register internal events
    on<_ProductionsReceived>(_onProductionsReceived);
    on<_ProductionsFailed>(_onProductionsFailed);
  }

  Future<void> _onRequested(
    WatchMonthlyProductionsRequested event,
    Emitter<WatchMonthlyProductionsState> emit,
  ) async {
    // Cancel previous subscription, if any.
    await _productionsSubscription?.cancel();

    emit(const WatchMonthlyProductionsLoading());

    _productionsSubscription =
        watchMonthlyProductionsUseCase(
          month: event.month,
          workerId: event.workerId,
        ).listen(
          (result) {
            result.fold(
              (failure) {
                add(_ProductionsFailed(failure.message));
              },
              (productions) {
                add(_ProductionsReceived(productions));
              },
            );
          },
          onError: (error) {
            add(_ProductionsFailed(error.toString()));
          },
        );
  }

  Future<void> _onStopped(
    WatchMonthlyProductionsStopped event,
    Emitter<WatchMonthlyProductionsState> emit,
  ) async {
    await _productionsSubscription?.cancel();
    _productionsSubscription = null;

    emit(const WatchMonthlyProductionsInitial());
  }

  void _onProductionsReceived(
    _ProductionsReceived event,
    Emitter<WatchMonthlyProductionsState> emit,
  ) {
    emit(WatchMonthlyProductionsSuccess(event.productions));
  }

  Future<void> _onProductionsFailed(
    _ProductionsFailed event,
    Emitter<WatchMonthlyProductionsState> emit,
  ) async {
    await _productionsSubscription?.cancel();
    _productionsSubscription = null;

    emit(WatchMonthlyProductionsFailure(event.message));
  }

  @override
  Future<void> close() async {
    await _productionsSubscription?.cancel();
    return super.close();
  }
}
