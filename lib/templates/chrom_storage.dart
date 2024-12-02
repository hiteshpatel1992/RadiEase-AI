import 'dart:html';

void saveToLocalStorage(String key, String value) {
  window.localStorage[key] = value;
}

String? getFromLocalStorage(String key) {
  return window.localStorage[key];
}

void removeFromLocalStorage(String key) {
  window.localStorage.remove(key);
}

void clearLocalStorage() {
  window.localStorage.clear();
}
