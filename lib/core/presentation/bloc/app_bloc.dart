import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/presentation/bloc/app_event.dart';
import 'package:mpac_app/core/presentation/bloc/app_state.dart';

@Injectable()
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(InitialAppState());

  Locale currentLocale = const Locale("en");

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {}
}
