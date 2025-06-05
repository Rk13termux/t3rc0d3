import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';
import '../models/repo_model.dart';
import '../widgets/clone_success_dialog.dart';
import '../main.dart';

class GitCloneService {
  // 🎯 Cache de comandos generados para evitar regeneración innecesaria
  static final Map<String, String> _commandCache = {};

  // 🎯 Historial de repositorios clonados
  static final List<String> _clonedRepos = [];

  // 🎯 Estadísticas de uso
  static int _totalClones = 0;
  static int _successfulOpens = 0;
  static int _failedOperations = 0;

  /// Genera comando de clonación optimizado para el repositorio
  static Future<String> generateCloneCommand(RepoModel repo) async {
    final cacheKey = '${repo.name}_${repo.githubUrl}';

    // Verificar cache primero
    if (_commandCache.containsKey(cacheKey)) {
      debugPrint('📦 Comando obtenido del cache para ${repo.name}');
      return _commandCache[cacheKey]!;
    }

    try {
      // Generar comando optimizado
      final command = _buildOptimizedCloneCommand(repo);

      // Guardar en cache
      _commandCache[cacheKey] = command;

      debugPrint('✅ Comando generado para ${repo.name}: $command');
      return command;
    } catch (e) {
      debugPrint('❌ Error generando comando para ${repo.name}: $e');
      _failedOperations++;
      rethrow;
    }
  }

  /// Construye comando de clonación optimizado
  static String _buildOptimizedCloneCommand(RepoModel repo) {
    final sanitizedName = _sanitizeRepoName(repo.name);
    const baseCommand = 'cd ~ && ';

    // Comando git clone con optimizaciones
    final cloneCommand =
        'git clone --depth=1 --single-branch ${repo.githubUrl} $sanitizedName';

    // Comando de verificación
    final verifyCommand =
        ' && echo "✅ ${repo.name} clonado exitosamente en ~/$sanitizedName"';

    // Comando de permisos (importante para Termux)
    final permissionsCommand = ' && chmod -R 755 ~/$sanitizedName';

    return baseCommand + cloneCommand + verifyCommand + permissionsCommand;
  }

  /// Sanitiza el nombre del repositorio para el sistema de archivos
  static String _sanitizeRepoName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\-_.]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .substring(0, name.length > 50 ? 50 : name.length); // Limitar longitud
  }

  /// Copia comando al portapapeles con feedback mejorado
  static Future<bool> copyCommandToClipboard(
    String command, {
    String? customMessage,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: command));
      debugPrint(
        '📋 Comando copiado al portapapeles: ${command.substring(0, 50)}...',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Error copiando al portapapeles: $e');
      _failedOperations++;
      return false;
    }
  }

  /// Abre la aplicación Termux con manejo de errores robusto
  static Future<bool> openTermuxApp() async {
    try {
      // Intentar abrir Termux directamente
      const intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: 'com.termux',
        category: 'android.intent.category.LAUNCHER',
      );

      // 🎯 CORRECCIÓN: launch() no retorna bool, usamos try-catch
      await intent.launch();

      // Si llegamos aquí, el intent se ejecutó sin errores
      _successfulOpens++;
      debugPrint('✅ Termux abierto exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error abriendo Termux: $e');
      return await _openTermuxAlternative();
    }
  }

  /// Método alternativo para abrir Termux
  static Future<bool> _openTermuxAlternative() async {
    try {
      // Intentar con URL scheme
      final uri = Uri.parse('termux://');
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        final result = await launchUrl(uri);
        if (result) {
          _successfulOpens++;
          debugPrint('✅ Termux abierto con URL scheme');
          return true;
        }
      }

      // Si falla, intentar abrir Play Store
      return await _openTermuxInPlayStore();
    } catch (e) {
      debugPrint('❌ Error en método alternativo de Termux: $e');
      _failedOperations++;
      return false;
    }
  }

  /// Abre Termux en Play Store si no está instalado
  static Future<bool> _openTermuxInPlayStore() async {
    try {
      final uri = Uri.parse('market://details?id=com.termux');
      final result = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (result) {
        debugPrint('📱 Play Store abierto para instalar Termux');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error abriendo Play Store: $e');
      _failedOperations++;
      return false;
    }
  }

  /// Abre repositorio en GitHub con múltiples fallbacks
  static Future<bool> openGitHubRepo(String githubUrl) async {
    try {
      final cleanUrl = _cleanGitHubUrl(githubUrl);
      final uri = Uri.parse(cleanUrl);

      // Verificar que sea una URL de GitHub válida
      if (!_isValidGitHubUrl(cleanUrl)) {
        debugPrint('❌ URL de GitHub inválida: $cleanUrl');
        _failedOperations++;
        return false;
      }

      // Intentar abrir en navegador externo
      final result = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (result) {
        _successfulOpens++;
        debugPrint('✅ GitHub abierto: $cleanUrl');
        return true;
      } else {
        // Fallback: intentar en navegador interno
        return await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      debugPrint('❌ Error abriendo GitHub: $e');
      _failedOperations++;
      return false;
    }
  }

  /// Limpia URL de GitHub removiendo .git y asegurando formato correcto
  static String _cleanGitHubUrl(String url) {
    String cleanUrl = url.trim();

    // Remover .git al final
    if (cleanUrl.endsWith('.git')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 4);
    }

    // Asegurar que use HTTPS
    if (cleanUrl.startsWith('git@github.com:')) {
      cleanUrl = cleanUrl
          .replaceFirst('git@github.com:', 'https://github.com/')
          .replaceAll('.git', '');
    }

    return cleanUrl;
  }

  /// Valida si la URL es de GitHub
  static bool _isValidGitHubUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host == 'github.com' && uri.pathSegments.length >= 2;
    } catch (e) {
      return false;
    }
  }

  /// Muestra diálogo de éxito con animación
  static void showCloneSuccessDialog(
    BuildContext context,
    RepoModel repo,
    String command,
  ) {
    _totalClones++;
    _clonedRepos.add(repo.name);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CloneSuccessDialog(
          repo: repo,
          command: command,
          onCopyCommand: () => copyCommandToClipboard(command),
          onOpenTermux: openTermuxApp,
          onOpenGitHub: () => openGitHubRepo(repo.githubUrl),
        );
      },
    );
  }

  /// Genera comando con instalación automática de dependencias
  static Future<String> generateFullInstallCommand(RepoModel repo) async {
    final cloneCommand = await generateCloneCommand(repo);
    final installCommand = _generateInstallCommand(repo);

    return '$cloneCommand && $installCommand';
  }

  /// Genera comando de instalación según el tipo de proyecto
  static String _generateInstallCommand(RepoModel repo) {
    final sanitizedName = _sanitizeRepoName(repo.name);
    final baseDir = '~/$sanitizedName';

    // Detectar tipo de proyecto
    final description = repo.description.toLowerCase();
    final name = repo.name.toLowerCase();

    if (description.contains('python') || name.contains('python')) {
      return _generatePythonInstallCommand(baseDir);
    } else if (description.contains('node') ||
        description.contains('javascript')) {
      return _generateNodeInstallCommand(baseDir);
    } else if (description.contains('go ') || name.contains('-go')) {
      return _generateGoInstallCommand(baseDir);
    } else if (description.contains('rust') || name.contains('rust')) {
      return _generateRustInstallCommand(baseDir);
    } else {
      return 'cd $baseDir && echo "📦 Repositorio listo para usar"';
    }
  }

  static String _generatePythonInstallCommand(String baseDir) {
    return '''cd $baseDir && (
      if [ -f requirements.txt ]; then
        echo "📦 Instalando dependencias de Python..." && pip install -r requirements.txt
      elif [ -f setup.py ]; then
        echo "📦 Instalando con setup.py..." && pip install -e .
      else
        echo "✅ Proyecto Python listo (sin dependencias específicas)"
      fi
    )''';
  }

  static String _generateNodeInstallCommand(String baseDir) {
    return '''cd $baseDir && (
      if [ -f package.json ]; then
        echo "📦 Instalando dependencias de Node.js..." && npm install
      else
        echo "✅ Proyecto Node.js listo (sin package.json)"
      fi
    )''';
  }

  static String _generateGoInstallCommand(String baseDir) {
    return '''cd $baseDir && (
      if [ -f go.mod ]; then
        echo "📦 Descargando módulos de Go..." && go mod download
      else
        echo "✅ Proyecto Go listo (sin go.mod)"
      fi
    )''';
  }

  static String _generateRustInstallCommand(String baseDir) {
    return '''cd $baseDir && (
      if [ -f Cargo.toml ]; then
        echo "📦 Compilando proyecto Rust..." && cargo build
      else
        echo "✅ Proyecto Rust listo (sin Cargo.toml)"
      fi
    )''';
  }

  // 🎯 Métodos de estadísticas y utilidades
  static Map<String, dynamic> getUsageStats() {
    return {
      'totalClones': _totalClones,
      'successfulOpens': _successfulOpens,
      'failedOperations': _failedOperations,
      'clonedRepos': List<String>.from(_clonedRepos),
      'cacheSize': _commandCache.length,
    };
  }

  static void clearCache() {
    _commandCache.clear();
    debugPrint('🧹 Cache de comandos limpiado');
  }

  static void clearHistory() {
    _clonedRepos.clear();
    _totalClones = 0;
    _successfulOpens = 0;
    _failedOperations = 0;
    debugPrint('🧹 Historial de clones limpiado');
  }

  /// Verifica si Termux está instalado
  static Future<bool> isTermuxInstalled() async {
    try {
      // 🎯 Método mejorado para verificar si Termux está instalado
      final uri = Uri.parse('termux://');
      return await canLaunchUrl(uri);
    } catch (e) {
      debugPrint('❌ Error verificando Termux: $e');
      return false;
    }
  }

  /// Método auxiliar para verificar conectividad antes de clonar
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('github.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Sin conexión a internet: $e');
      return false;
    }
  }

  /// Genera comandos con verificaciones de prerequisitos
  static Future<String> generateCloneCommandWithChecks(RepoModel repo) async {
    final baseCommand = await generateCloneCommand(repo);

    // Añadir verificaciones previas
    const prerequisiteChecks = '''
# Verificar conexión y herramientas
if ! command -v git &> /dev/null; then
    echo "❌ Git no está instalado. Instala con: pkg install git"
    exit 1
fi

if ! ping -c 1 github.com &> /dev/null; then
    echo "❌ Sin conexión a internet"
    exit 1
fi

echo "✅ Prerequisitos OK, clonando repositorio..."
''';

    return '$prerequisiteChecks\n$baseCommand';
  }
}
