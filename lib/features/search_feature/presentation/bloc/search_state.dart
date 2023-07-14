import 'package:built_value/built_value.dart';

part 'search_state.g.dart';

abstract class SearchState
    implements Built<SearchState, SearchStateBuilder> {
  SearchState._();

  factory SearchState([Function(SearchStateBuilder b) updates]) = _$SearchState;

  factory SearchState.initial() {
    return SearchState((b) => b);
  }
}
