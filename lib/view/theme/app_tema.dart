import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';

abstract final class AppTema {
  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(
      seedColor: AppCores.acao,
      primary: AppCores.acao,
      onPrimary: AppCores.sobreAcao,
      primaryContainer: AppCores.acaoForte,
      onPrimaryContainer: AppCores.sobreAcao,
      secondary: AppCores.acento,
      onSecondary: AppCores.sobreAcento,
      secondaryContainer: AppCores.indicadorCasca,
      onSecondaryContainer: AppCores.textoPrimario,
      error: AppCores.erro,
      onError: AppCores.sobreAcao,
      surface: AppCores.superficie,
      onSurface: AppCores.textoPrimario,
      surfaceDim: AppCores.fundo,
      surfaceBright: AppCores.superficie,
      surfaceContainerLowest: AppCores.superficie,
      surfaceContainerLow: AppCores.fundo,
      surfaceContainer: AppCores.fundo,
      surfaceContainerHigh: AppCores.fundoCampoInativo,
      surfaceContainerHighest: AppCores.fundoCampoInativo,
      onSurfaceVariant: AppCores.textoSecundario,
      outline: AppCores.bordaCampo,
      outlineVariant: AppCores.borda,
      shadow: AppCores.sombra,
    );

    return ThemeData(
      colorScheme: esquema,
      scaffoldBackgroundColor: AppCores.fundo,
      canvasColor: AppCores.superficie,
      dividerColor: AppCores.borda,
      textTheme: _textos,
      appBarTheme: _appBar,
      navigationBarTheme: _navegacao,
      tabBarTheme: _abas,
      cardTheme: _cartao,
      dialogTheme: _dialogo,
      snackBarTheme: _snackBar,
      inputDecorationTheme: _campo,
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: _campo,
        textStyle: _textos.bodyMedium,
        menuStyle: _estiloDeMenu,
      ),
      menuTheme: MenuThemeData(style: _estiloDeMenu),
      popupMenuTheme: _popup,
      progressIndicatorTheme: _progresso,
      elevatedButtonTheme: _botaoElevado,
      filledButtonTheme: _botaoPreenchido,
      textButtonTheme: _botaoTexto,
      outlinedButtonTheme: _botaoContornado,
      iconButtonTheme: _botaoIcone,
      floatingActionButtonTheme: _botaoFlutuante,
      segmentedButtonTheme: _segmentado,
      chipTheme: _chip,
      listTileTheme: _listTile,
      dividerTheme: _divisor,
      checkboxTheme: _checkbox,
      bottomSheetTheme: _painelInferior,
      expansionTileTheme: _expansivel,
      datePickerTheme: _seletorDeData,
      timePickerTheme: _seletorDeHora,
      iconTheme: const IconThemeData(color: AppCores.textoSecundario),
      primaryIconTheme: const IconThemeData(color: AppCores.sobreCasca),
    );
  }

  static const _textos = TextTheme(
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );

  static const barraDeStatusSobreEscuro = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static const barraDeStatusSobreClaro = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static const _appBar = AppBarThemeData(
    backgroundColor: AppCores.casca,
    foregroundColor: AppCores.sobreCasca,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppCores.sombraChrome,
    elevation: 3,
    scrolledUnderElevation: 3,
    centerTitle: false,
    systemOverlayStyle: barraDeStatusSobreClaro,
    titleTextStyle: TextStyle(
      color: AppCores.sobreCasca,
      fontSize: 23,
      fontWeight: FontWeight.w700,
    ),
  );

  static final _navegacao = NavigationBarThemeData(
    backgroundColor: AppCores.casca,
    surfaceTintColor: Colors.transparent,
    indicatorColor: AppCores.indicadorCasca,
    indicatorShape: const StadiumBorder(),
    shadowColor: AppCores.sombraChrome,
    elevation: 3,
    height: 70,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    labelTextStyle: WidgetStateProperty.resolveWith((estados) {
      final selecionado = estados.contains(WidgetState.selected);
      return TextStyle(
        fontSize: 13,
        fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
        color: selecionado ? AppCores.sobreCasca : AppCores.sobreCascaInativo,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((estados) {
      final selecionado = estados.contains(WidgetState.selected);
      return IconThemeData(
        size: selecionado ? 30 : 26,
        color: selecionado ? AppCores.sobreCasca : AppCores.sobreCascaInativo,
      );
    }),
  );

  static const _abas = TabBarThemeData(
    labelColor: AppCores.acao,
    unselectedLabelColor: AppCores.textoSecundario,
    indicatorColor: AppCores.acao,
    indicatorSize: TabBarIndicatorSize.label,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: AppCores.acao, width: 3),
      borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
    ),
    dividerColor: Colors.transparent,
    labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );

  static final _cartao = CardThemeData(
    color: AppCores.superficie,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppCores.sombra,
    elevation: 1,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppEstilos.raioCartao),
    ),
  );

  static final _dialogo = DialogThemeData(
    backgroundColor: AppCores.superficie,
    surfaceTintColor: Colors.transparent,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppEstilos.raioDialogo),
    ),
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppCores.textoPrimario,
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      height: 1.4,
      color: AppCores.textoSecundario,
    ),
  );

  static final _snackBar = SnackBarThemeData(
    backgroundColor: AppCores.textoPrimario,
    contentTextStyle: const TextStyle(fontSize: 14, color: AppCores.superficie),
    actionTextColor: AppCores.superficie,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppEstilos.raioCampo),
    ),
  );

  static final _campo = InputDecorationThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    fillColor: AppCores.fundoCampoInativo,
    hintStyle: const TextStyle(color: AppCores.textoTerciario, fontSize: 14),
    labelStyle: const TextStyle(color: AppCores.textoSecundario, fontSize: 14),
    floatingLabelStyle: const TextStyle(color: AppCores.acao, fontSize: 14),
    errorStyle: const TextStyle(color: AppCores.erro, fontSize: 12),
    errorMaxLines: 3,
    suffixIconColor: AppCores.textoSecundario,
    prefixIconColor: AppCores.textoSecundario,
    border: _contorno(AppCores.bordaCampo),
    enabledBorder: _contorno(AppCores.bordaCampo),
    disabledBorder: _contorno(AppCores.borda),
    focusedBorder: _contorno(AppCores.acao, largura: 2),
    errorBorder: _contorno(AppCores.erro),
    focusedErrorBorder: _contorno(AppCores.erro, largura: 2),
  );

  static OutlineInputBorder _contorno(Color cor, {double largura = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppEstilos.raioCampo),
      borderSide: BorderSide(color: cor, width: largura),
    );
  }

  static final _estiloDeMenu = MenuStyle(
    backgroundColor: const WidgetStatePropertyAll(AppCores.superficie),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEstilos.raioCampo),
      ),
    ),
  );

  static final _popup = PopupMenuThemeData(
    color: AppCores.superficie,
    surfaceTintColor: Colors.transparent,
    elevation: 3,
    textStyle: const TextStyle(fontSize: 14, color: AppCores.textoPrimario),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppEstilos.raioCampo),
    ),
  );

  static const _progresso = ProgressIndicatorThemeData(
    color: AppCores.acao,
    circularTrackColor: Colors.transparent,
    linearTrackColor: AppCores.borda,
  );

  static final _formaDeBotao = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppEstilos.raioCampo),
  );

  static const _textoDeBotao =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  static final _botaoElevado = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppCores.acao,
      foregroundColor: AppCores.sobreAcao,
      disabledBackgroundColor: AppCores.fundoCampoInativo,
      disabledForegroundColor: AppCores.textoTerciario,
      elevation: 0,
      minimumSize: const Size.fromHeight(48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: _textoDeBotao,
      shape: _formaDeBotao,
    ),
  );

  static final _botaoPreenchido = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppCores.acao,
      foregroundColor: AppCores.sobreAcao,
      disabledBackgroundColor: AppCores.fundoCampoInativo,
      disabledForegroundColor: AppCores.textoTerciario,
      minimumSize: const Size(64, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: _textoDeBotao,
      shape: _formaDeBotao,
    ),
  );

  static final _botaoTexto = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppCores.acao,
      disabledForegroundColor: AppCores.textoTerciario,
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      shape: _formaDeBotao,
    ),
  );

  static final _botaoContornado = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppCores.acao,
      disabledForegroundColor: AppCores.textoTerciario,
      side: const BorderSide(color: AppCores.bordaCampo),
      minimumSize: const Size(64, 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      shape: _formaDeBotao,
    ),
  );

  static final _botaoIcone = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppCores.textoSecundario,
      minimumSize: const Size(48, 48),
    ),
  );

  static final _botaoFlutuante = FloatingActionButtonThemeData(
    backgroundColor: AppCores.acao,
    foregroundColor: AppCores.sobreAcao,
    elevation: 3,
    extendedTextStyle:
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppEstilos.raioCartao),
    ),
  );

  static final _segmentado = SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((estados) {
        return estados.contains(WidgetState.selected)
            ? AppCores.acao
            : AppCores.superficie;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((estados) {
        return estados.contains(WidgetState.selected)
            ? AppCores.sobreAcao
            : AppCores.textoSecundario;
      }),
      side: const WidgetStatePropertyAll(
        BorderSide(color: AppCores.bordaCampo),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
      tapTargetSize: MaterialTapTargetSize.padded,
    ),
  );

  static final _chip = ChipThemeData(
    backgroundColor: AppCores.acao.withValues(alpha: 0.12),
    selectedColor: AppCores.acao,
    disabledColor: AppCores.fundoCampoInativo,
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppCores.acaoForte,
    ),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static const _listTile = ListTileThemeData(
    iconColor: AppCores.textoSecundario,
    textColor: AppCores.textoPrimario,
    titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    subtitleTextStyle: TextStyle(fontSize: 14, color: AppCores.textoSecundario),
  );

  static const _divisor = DividerThemeData(
    color: AppCores.borda,
    thickness: 1,
    space: 1,
  );

  static final _checkbox = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((estados) {
      return estados.contains(WidgetState.selected)
          ? AppCores.acao
          : Colors.transparent;
    }),
    checkColor: const WidgetStatePropertyAll(AppCores.sobreAcao),
    side: const BorderSide(color: AppCores.bordaCampo, width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  static const _painelInferior = BottomSheetThemeData(
    backgroundColor: AppCores.superficie,
    modalBackgroundColor: AppCores.superficie,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppEstilos.raioPainel),
      ),
    ),
  );

  static const _expansivel = ExpansionTileThemeData(
    iconColor: AppCores.acao,
    textColor: AppCores.textoPrimario,
    collapsedIconColor: AppCores.textoSecundario,
    collapsedTextColor: AppCores.textoPrimario,
    backgroundColor: Colors.transparent,
    collapsedBackgroundColor: Colors.transparent,
    shape: Border(),
    collapsedShape: Border(),
  );

  static Color _tintaDeDia(Set<WidgetState> estados) {
    if (estados.contains(WidgetState.selected)) return AppCores.sobreAcao;
    if (estados.contains(WidgetState.disabled)) return AppCores.textoInativo;
    return AppCores.textoPrimario;
  }

  static Color _fundoDeDia(Set<WidgetState> estados) {
    return estados.contains(WidgetState.selected)
        ? AppCores.acao
        : Colors.transparent;
  }

  static final _seletorDeData = DatePickerThemeData(
    backgroundColor: AppCores.superficie,
    surfaceTintColor: Colors.transparent,
    headerBackgroundColor: AppCores.acao,
    headerForegroundColor: AppCores.sobreAcao,
    todayForegroundColor: WidgetStateProperty.resolveWith((estados) {
      if (estados.contains(WidgetState.selected)) return AppCores.sobreAcao;
      if (estados.contains(WidgetState.disabled)) return AppCores.textoInativo;
      return AppCores.acao;
    }),
    todayBackgroundColor: WidgetStateProperty.resolveWith(_fundoDeDia),
    todayBorder: const BorderSide(color: Colors.transparent, width: 1.5),
    dayForegroundColor: WidgetStateProperty.resolveWith(_tintaDeDia),
    dayBackgroundColor: WidgetStateProperty.resolveWith(_fundoDeDia),
    yearForegroundColor: WidgetStateProperty.resolveWith(_tintaDeDia),
    yearBackgroundColor: WidgetStateProperty.resolveWith(_fundoDeDia),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppEstilos.raioDialogo),
    ),
  );

  static final _seletorDeHora = TimePickerThemeData(
    backgroundColor: AppCores.superficie,
    dialHandColor: AppCores.acao,
    dialBackgroundColor: AppCores.fundo,
    hourMinuteColor: WidgetStateColor.resolveWith((estados) {
      return estados.contains(WidgetState.selected)
          ? AppCores.acao
          : AppCores.fundoCampoInativo;
    }),
    hourMinuteTextColor: WidgetStateColor.resolveWith((estados) {
      return estados.contains(WidgetState.selected)
          ? AppCores.sobreAcao
          : AppCores.textoPrimario;
    }),
    dayPeriodColor: WidgetStateColor.resolveWith((estados) {
      return estados.contains(WidgetState.selected)
          ? AppCores.acao
          : AppCores.superficie;
    }),
    dayPeriodTextColor: WidgetStateColor.resolveWith((estados) {
      return estados.contains(WidgetState.selected)
          ? AppCores.sobreAcao
          : AppCores.textoPrimario;
    }),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppEstilos.raioDialogo),
    ),
  );
}
