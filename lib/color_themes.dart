import 'package:flutter/material.dart';



final ThemeData fitnessLogThemeData = ThemeData(
    //brightness: Brightness.dark,
    primaryColor: MaterialColor(CustomColors.darkBrown[800]!.value, CustomColors.darkBrown),
    colorScheme: ColorScheme.fromSwatch(
        primarySwatch:
        MaterialColor(CustomColors.darkBrown[800]!.value, CustomColors.darkBrown))
        .copyWith(secondary: CustomColors.beige[100],


    ),
  // brightness: colorScheme.brightness,
  // canvasColor: colorScheme.background,
  // scaffoldBackgroundColor: colorScheme.background,
  // bottomAppBarColor: colorScheme.surface,
  // cardColor: colorScheme.surface,
  // dividerColor: colorScheme.onSurface.withOpacity(0.12),
  // backgroundColor: colorScheme.background,
  // dialogBackgroundColor: colorScheme.background,
  // indicatorColor: onPrimarySurfaceColor,
  // errorColor: colorScheme.error,
  // textTheme: textTheme,
  // applyElevationOverlayColor: isDark,
  // useMaterial3: useMaterial3,

);

class CustomColors {
  CustomColors._(); // this basically makes it so you can instantiate this class
  // static const Map<int, Color> black = <int, Color> {
  //   50: Color(0x00e7e7e9),
  //   100: Color(0xffC4C3C7),
  //   200: Color(0xff9D9CA2),
  //   300: Color(0xff75747D),
  //   400: Color(0xff585661),
  //   500: Color(0xff3A3845),
  //   600: Color(0xff34323E),
  //   700: Color(0xff2C2B36),
  //   800: Color(0xff25242E),
  //   900: Color(0xff18171F),
  // };

  static const Map<int, Color> darkBlue = <int, Color> {
    50: Color(0xfffaf7ff),
    100: Color(0xfff2efff),
    200: Color(0xffe9e6f7),
    300: Color(0xffd8d6e6),
    400: Color(0xffb4b2c2),
    500: Color(0xff9492a1),
    600: Color(0xff6c6a78),
    700: Color(0xff595664),
    800: Color(0xff3a3845),
    900: Color(0xff1a1824),
  };

  static const Map<int, Color> beige = <int, Color> {
    50: Color(0xfffae8e1),
    100: Color(0xfff7cdac),
    200: Color(0xffefad77),
    300: Color(0xffe69140),
    400: Color(0xffde7d00),
    500: Color(0xffd76c00),
    600: Color(0xffcd6600),
    700: Color(0xffc15e00),
    800: Color(0xffb55600),
    900: Color(0xff9f4800),
  };

  static const Map<int, Color> lightBrown = <int, Color> {
    50: Color(0xffffe5c5),
    100: Color(0xffe7c1a2),
    200: Color(0xffc69c7b),
    300: Color(0xffa37753),
    400: Color(0xff8a5d35),
    500: Color(0xff704317),
    600: Color(0xff663a12),
    700: Color(0xff572e0a),
    800: Color(0xff4a2101),
    900: Color(0xff3c1300),
  };

  static const Map<int, Color> darkBrown = <int, Color> {
    50: Color(0xffebebeb),
    100: Color(0xffcdcdcd),
    200: Color(0xffb1aba9),
    300: Color(0xff968983),
    400: Color(0xff826f66),
    500: Color(0xff6e564a),
    600: Color(0xff634d43),
    700: Color(0xff534139),
    800: Color(0xff443530),
    900: Color(0xff352824),
  };
}