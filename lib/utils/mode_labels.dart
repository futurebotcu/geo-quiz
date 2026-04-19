import '../core/models.dart';
import '../l10n/app_localizations.dart';

String localizedModeName(S s, QuizMode mode) {
  switch (mode) {
    case QuizMode.foodCountry:
      return s.modeFoodCountry;
    case QuizMode.capitalPhoto:
    case QuizMode.capitalFromImage:
      return s.modeCapitalPhoto;
    case QuizMode.flagCountry:
      return s.modeFlagCountry;
    case QuizMode.capitalCountry:
      return s.modeCapitalCountry;
    case QuizMode.mixed:
      return s.modeMixed;
  }
}

String localizedModeSubtitle(S s, QuizMode mode) {
  switch (mode) {
    case QuizMode.foodCountry:
      return s.modeFoodCountryDesc;
    case QuizMode.capitalPhoto:
    case QuizMode.capitalFromImage:
      return s.modeCapitalPhotoDesc;
    case QuizMode.flagCountry:
      return s.modeFlagCountryDesc;
    case QuizMode.capitalCountry:
      return s.modeCapitalCountryDesc;
    case QuizMode.mixed:
      return s.modeMixedDesc;
  }
}
