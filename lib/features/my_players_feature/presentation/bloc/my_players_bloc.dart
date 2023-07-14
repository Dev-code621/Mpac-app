import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mpac_app/features/my_players_feature/presentation/bloc/my_players_event.dart';
import 'package:mpac_app/features/my_players_feature/presentation/bloc/my_players_state.dart';

@Injectable()
class MyPlayersBloc extends Bloc<MyPlayersEvent, MyPlayersState>{
  MyPlayersBloc(): super(MyPlayersState.initial());
}