class Assets {
  static const String logo = "assets/icon/logo.png";
  static const String close = "assets/icon/barrier_closed.png";
  static const String open = "assets/icon/barrier_open.png";
}

class Api {
  static const String url =
      "https://lnxstgweb.tn.gov.in/tnrb_visitmgmt/api/qr_insert.php";
  static Uri apiUrl = Uri(
    scheme: 'https',
    host: 'lnxstgweb.tn.gov.in',
    path: '/tnrb_visitmgmt/api/qr_insert.php',
  );
}
