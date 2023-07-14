class PaginationController {
  int offset = 0;
  int limit = 15;

  int moveToNext() => offset += 15;
}
