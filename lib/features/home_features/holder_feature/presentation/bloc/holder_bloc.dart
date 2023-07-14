import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_event.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_state.dart';

@Injectable()
class HolderBloc extends Bloc<HolderEvent, HolderState> {
  HolderBloc(): super(HolderState.initial());

  void onChangePageIndex(int index){
    add(ChangePageIndex(index));
  }

  @override
  Stream<HolderState> mapEventToState(HolderEvent event) async* {
    if(event is ChangePageIndex){
      yield state.rebuild((p0) => p0..currentPageIndex = event.index);
    }
  }
}