abstract class HolderEvent {}

class ChangePageIndex extends HolderEvent {
  final int index;

  ChangePageIndex(this.index);
}