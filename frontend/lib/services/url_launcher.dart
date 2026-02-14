import 'package:url_launcher/url_launcher.dart';

class UrlManager {
  static Future<void> openLink() async {
    final Uri url = Uri.parse('https://rds.live/?post_type=canal&s=antena');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
