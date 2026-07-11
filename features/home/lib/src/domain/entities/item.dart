/// 首頁列表項目。
class Item {
  /// 以已解析欄位建立。
  const Item({
    required this.id,
    required this.title,
    required this.description,
  });

  /// 項目識別碼。
  final String id;

  /// 標題。
  final String title;

  /// 描述。
  final String description;
}
