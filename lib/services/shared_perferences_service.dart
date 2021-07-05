import 'package:shared_preferences/shared_preferences.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

final _prefs = SharedPreferences.getInstance();

class PreferencesServiceKey {}

class SharedPreferencesService {
  static Future<void> setXmppAccount(
      {required String username,
      required String password,
      required int port}) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('xmppusername', username);
    prefs.setString('xmpppassword', password);
    prefs.setInt('xmppport', port);
  }

  static Future<XmppAccountSettings?> getXmppAccount() async {
    final SharedPreferences prefs = await _prefs;
    String? username = prefs.getString('xmppusername');
    String? password = prefs.getString('xmpppassword');
    int? port = prefs.getInt('xmppport');
    if (username == null || password == null || port == null) {
      return null;
    } else {
      Jid jid = Jid.fromFullJid(username);
      XmppAccountSettings xmppAccount = XmppAccountSettings(
        username,
        jid.local,
        jid.domain,
        password,
        port,
      );
      return xmppAccount;
    }
  }

  static Future<void> deleteXmppAccount() async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove('xmppusername');
    prefs.remove('xmpppassword');
    prefs.remove('xmppport');
  }

  static Future<String?> getValueWithKey({required String key}) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key.toString());
  }

  static Future<void> setValueWithKey(
      {required String key, required String value}) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(key.toString(), value);
  }

  static Future<void> removeKey({required String key}) async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove(key.toString());
  }
}
