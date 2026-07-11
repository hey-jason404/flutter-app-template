/// 項目詳情頁的事件(sealed;命名採「主詞+過去式」)。
sealed class ItemDetailEvent {
  /// 基底建構子,僅供子類 super 呼叫。
  const ItemDetailEvent();
}

/// 請求載入指定 [id] 的項目詳情。
final class ItemDetailRequested extends ItemDetailEvent {
  /// 以項目識別碼建立請求事件。
  const ItemDetailRequested(this.id);

  /// 項目識別碼。
  final String id;
}
