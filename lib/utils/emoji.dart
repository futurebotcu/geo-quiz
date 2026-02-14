String flagEmoji(String iso2) {
  final cc = iso2.toUpperCase();
  if (cc.length != 2) return '';
  return String.fromCharCodes([
    0x1F1E6 + (cc.codeUnitAt(0) - 65),
    0x1F1E6 + (cc.codeUnitAt(1) - 65),
  ]);
}
