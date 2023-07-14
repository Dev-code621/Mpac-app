import 'package:built_value/built_value.dart';

part 'my_players_state.g.dart';

abstract class MyPlayersState
    implements Built<MyPlayersState, MyPlayersStateBuilder> {
  MyPlayersState._();

  factory MyPlayersState([Function(MyPlayersStateBuilder b) updates]) =
      _$MyPlayersState;

  factory MyPlayersState.initial() {
    return MyPlayersState((b) => b);
  }
}
