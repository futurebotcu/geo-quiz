class Country {
  final String iso2;
  final String iso3;
  final String countryEN;
  final String countryTR;
  final String capitalEN;
  final String capitalTR;
  final String region;
  final String subregion;
  final String flag;
  final String slugCountry;
  final String slugCapital;
  final String? capitalImageUrl;
  final String? capitalAssetPath;
  final Map<String, dynamic>? capitalCredit;

  Country({
    required this.iso2,
    required this.iso3,
    required this.countryEN,
    required this.countryTR,
    required this.capitalEN,
    required this.capitalTR,
    required this.region,
    required this.subregion,
    required this.flag,
    required this.slugCountry,
    required this.slugCapital,
    this.capitalImageUrl,
    this.capitalAssetPath,
    this.capitalCredit,
  });

  factory Country.fromJson(Map<String, dynamic> j) => Country(
        iso2: j['iso2'] ?? '',
        iso3: j['iso3'] ?? '',
        countryEN: j['countryEN'] ?? '',
        countryTR: j['countryTR'] ?? '',
        capitalEN: j['capitalEN'] ?? '',
        capitalTR: j['capitalTR'] ?? '',
        region: j['region'] ?? '',
        subregion: j['subregion'] ?? '',
        flag: j['flag'] ?? '',
        slugCountry: j['slugCountry'] ?? '',
        slugCapital: j['slugCapital'] ?? '',
        capitalImageUrl: j['capitalImageUrl'],
        capitalAssetPath: j['capitalAssetPath'],
        capitalCredit: j['capitalCredit'],
      );

  Map<String, dynamic> toJson() => {
        'iso2': iso2,
        'iso3': iso3,
        'countryEN': countryEN,
        'countryTR': countryTR,
        'capitalEN': capitalEN,
        'capitalTR': capitalTR,
        'region': region,
        'subregion': subregion,
        'flag': flag,
        'slugCountry': slugCountry,
        'slugCapital': slugCapital,
        'capitalImageUrl': capitalImageUrl,
        'capitalAssetPath': capitalAssetPath,
        'capitalCredit': capitalCredit,
      };
}
