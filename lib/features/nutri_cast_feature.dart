class NutriCastFeature {
  static String getGiziStatus(double imt) {
    if (imt < 18.5) {
      return 'Kurus';
    } else if (imt >= 18.5 && imt < 25) {
      return 'Normal';
    } else if (imt >= 25 && imt < 30) {
      return 'Gemuk';
    } else {
      return 'Obesitas';
    }
  }
}
