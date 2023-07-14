import 'package:built_value/built_value.dart';

part 'holder_state.g.dart';

abstract class HolderState implements Built<HolderState, HolderStateBuilder> {
  HolderState._();

  factory HolderState([Function(HolderStateBuilder b) updates]) = _$HolderState;

  int get currentPageIndex;

  factory HolderState.initial() {
    return HolderState((b) => b..currentPageIndex = 0);
  }
}
