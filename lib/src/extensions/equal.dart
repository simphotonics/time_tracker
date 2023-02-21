extension Equal<T extends Comparable> on List<T> {

  /// Returns `true` if `this[i] == other[i]` for
  /// each index `i`.
  /// ---
  ///
  /// * The lists must have the same length.
  /// * Note: Two empty list are equal.
  bool equal(List<T> other) {
    if (this == other) return true;
    if (length != other.length) return false;
    final it = iterator;
    final oit = other.iterator;
    while (it.moveNext() && oit.moveNext()) {
      if (it.current != oit.current) {
        return false;
      }
    }
    return true;
  }
}
