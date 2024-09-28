import 'dart:developer';

import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  //to generate token only once for an app run
  static Future<String?> get getToken async => _token ?? await _getAccessToken();

  // to get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      final client = await clientViaServiceAccount(
        // To get Admin Json File: Go to Firebase > Project Settings > Service Accounts
        // > Click on 'Generate new private key' Btn & Json file will be downloaded

        // Paste Your Generated Json File Content
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
  "project_id": "chatingapp-42fb4",
  "private_key_id": "f59e55301bc84f47cfc0d9b4913d63623297f986",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDdC4arhDXgWxyU\nTt+ou63CwO3QdH9iGvvN4owQpIxHnff8pY1q1Etc3dwVbG1YGHj/TkIWB9wdA4Ob\nLuXNgLVGAEBGRDNNqaW80NXWClOYzyHUUmn5JV6YU/I+zHOfJ6a5uQdFQwkk3tuW\nVXW63bdWqHLIvQJawq7X9rh+vu8vC8rQydC+Y+b+7oKPE0aDikwt1A+hJK6YZbyb\nff8qOfqr4JPDeWKZZQTqsHsz9LLOL3ryxDl7dF5Zk+A4lDmUP0GJsYxhJgPD/XiX\n/Et+5Blg/X5qSL3gtHI+siCDk68ILb7U9/eCvQOmws79HlNcmaLxjOE0VEQDj+0P\nG3XdvK9vAgMBAAECggEAM6GZlz6OhxVBG7NAst0DvVXrNqG/j17WKkUcilalHaVc\nY3sYCTgFUm/QFID7GXS97oSNEzBKzcwgVYMi0lmZ/fvZB5CumxlhSTVOfWx0EmFv\neXS2pCeCbPpOvzRqXWaZnxAFDryVyjLz/61+jmNzi55VEWZ0wlZvGKrcdV6L5+Te\nBO2OG5cp6o96TQwk3kLezebfa6XXe/MaHoiFok17HvXzz/kjO5SpxFHJ06JCU9Xn\n6TH7Z4NAPpW7SoJFXwuCpCEAlEHNliBqZh8dq/V/inKDuCSX+yoP6fZRKuqUG7cz\nqGOOK4lUtTu4BWcxtxxmMOYnU9bSCFiFfQGIA47qAQKBgQD4BzyBALltLrFGZs/y\nLlOfebNejOPFpjJS15wkyOHtV9hu3d338uHpsNVwGU509j1bNmG14NDlCr83P8FC\nw3m4mhlun+eLhfqrMHTOlwPzu6NG9lzvDqmOe9b5DisqbWs3+nX3BmuNfKteqP3H\nsHqYUrU6gXTgC/dqrD9q+10brwKBgQDkJkXiwLjECTV2AtQwGnxcBIFUhhWlBQV9\nZ4aKh44C0ZJ/5//WIrwChqgI8JJ5rYgaRAMubJJacIME4Q0HhExL3ld8Uhg+Lh+w\n/9HPRETUXyWrVYvhjfph69MB+lREA6jqzHkyM9B8z5P5Chbtf5oaYrMfrND6J/vQ\noCZpHlPYQQKBgB5ZLFMQlp/AbdqSa/FTL9I8nvD7xkcB7fhq/2UU22giLo5qQWW8\nZ14j0An2Xr46/wjxH4WUq5rK9Ni6yVf0+SjYWjJKCJfu3dwigrhgjBA/rlvZe0eZ\nALA5gPVagXegidUApXyDYZefYIylmt/bPTT0Mc6l1novnKeFygC6HwtrAoGBALry\nFY/RRVT1CsZxWPc1rLMlyee9mxzF+ZKhcuAuZRIwMa/3JW6MtawINMZmgk+L/xsu\nocC3nFDZIrKryiZfpLkCLoOjLVQ+LR+272+7y/6NHGvBREaFNSZpu1RCkCvPJ+mF\ntMWLKYor+V82gkUHqvl16LrKu85PVwrDP9Yg0KlBAoGBAJJ/AZ+KZQptppguYV6Q\nlPnvPz5eZxm7CUBKZDlkULgL9WNe3BKrhR/Wya2LfPpEF74SHwJusvLkZS6Raqbw\n0qfy5yUT/c25IR6WrlX2s6aPzDWmCbETBFXiE13XYORCVIJ+DLtHFJyv+JAdtlsd\npjKrfJocLOc4yiQbnWb8xdNh\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-dym3o@chatingapp-42fb4.iam.gserviceaccount.com",
  "client_id": "105476829342600791327",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-dym3o%40chatingapp-42fb4.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
        }),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}
