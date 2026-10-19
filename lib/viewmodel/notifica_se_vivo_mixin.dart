import 'package:flutter/foundation.dart';

mixin NotificaSeVivoMixin on ChangeNotifier {
  bool _descartado = false;

  bool get descartado => _descartado;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  void notificarSeVivo() {
    if (!_descartado) {
      notifyListeners();
    }
  }
}
