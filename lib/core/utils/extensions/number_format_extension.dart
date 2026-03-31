
extension IntX on int {

  String get compact => _formatCount();

  String _formatCount () {
    if (this < 1000) return toString();

    if (this < 1000000) {
      final value = this / 1000;
      return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}K';
    }

    final value = this / 1000000;
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}M';
  }
}