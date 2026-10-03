class PersianDigits {
  const PersianDigits._();

  static String normalize(String input) {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(fa[i], '$i').replaceAll(ar[i], '$i');
    }
    return result;
  }

  static String toPersian(String input) {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    return input.replaceAllMapped(RegExp(r'[0-9]'), (m) => fa[int.parse(m.group(0)!)]);
  }
}
