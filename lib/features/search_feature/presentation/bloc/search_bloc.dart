import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mpac_app/features/search_feature/presentation/bloc/search_event.dart';
import 'package:mpac_app/features/search_feature/presentation/bloc/search_state.dart';

@Injectable()
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchState.initial());
}
