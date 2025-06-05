import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class ScriptInstaller {
  // 🎯 Directorio base para scripts en Termux
  static const String termuxScriptsPath =
      '/data/data/com.termux/files/home/scripts';
  static const String fallbackPath = '/storage/emulated/0/termuxcode';

  /// Verifica si la app tiene acceso al directorio de Termux
  static Future<bool> _canAccessTermuxDirectory() async {
    try {
      final termuxDir = Directory(termuxScriptsPath);
      return await termuxDir.exists();
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el directorio donde guardar los scripts
  static Future<Directory> _getScriptsDirectory() async {
    try {
      // Intentar primero el directorio de Termux
      if (await _canAccessTermuxDirectory()) {
        final termuxScriptsDir = Directory(termuxScriptsPath);
        if (!await termuxScriptsDir.exists()) {
          await termuxScriptsDir.create(recursive: true);
        }
        return termuxScriptsDir;
      }

      // Fallback al almacenamiento externo
      final externalDir = Directory(fallbackPath);
      if (!await externalDir.exists()) {
        await externalDir.create(recursive: true);
      }
      return externalDir;
    } catch (e) {
      // Último fallback - directorio de documentos de la app
      final appDocDir = await getApplicationDocumentsDirectory();
      final scriptsDir = Directory('${appDocDir.path}/scripts');
      if (!await scriptsDir.exists()) {
        await scriptsDir.create(recursive: true);
      }
      return scriptsDir;
    }
  }

  /// Guarda un script en el directorio apropiado
  static Future<String> saveScript(String scriptFile) async {
    try {
      final scriptsDir = await _getScriptsDirectory();
      final fullPath = '${scriptsDir.path}/$scriptFile';
      final file = File(fullPath);

      // Si ya existe, no lo sobrescribimos
      if (await file.exists()) {
        debugPrint('📄 Script ya existe: $fullPath');
        return fullPath;
      }

      // Cargar desde assets
      final assetPath = 'assets/scripts/$scriptFile';
      try {
        final byteData = await rootBundle.load(assetPath);
        await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

        // Hacer ejecutable en sistemas Unix
        if (Platform.isAndroid || Platform.isLinux) {
          await Process.run('chmod', ['+x', fullPath]).catchError((_) {
            debugPrint('⚠️ No se pudo hacer ejecutable: $fullPath');
          });
        }

        debugPrint('✅ Script guardado: $fullPath');
        return fullPath;
      } catch (assetError) {
        throw Exception('Asset no encontrado: $assetPath');
      }
    } catch (e) {
      debugPrint('❌ Error guardando script: $e');
      rethrow;
    }
  }

  /// Guarda múltiples scripts
  static Future<List<String>> saveMultipleScripts(
      List<String> scriptFiles) async {
    final savedPaths = <String>[];

    for (final scriptFile in scriptFiles) {
      try {
        final path = await saveScript(scriptFile);
        savedPaths.add(path);
      } catch (e) {
        debugPrint('❌ Error guardando $scriptFile: $e');
        // Continúa con los demás scripts
      }
    }

    return savedPaths;
  }

  /// Verifica si un script existe
  static Future<bool> scriptExists(String scriptFile) async {
    try {
      final scriptsDir = await _getScriptsDirectory();
      final file = File('${scriptsDir.path}/$scriptFile');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la ruta completa de un script
  static Future<String?> getScriptPath(String scriptFile) async {
    try {
      final scriptsDir = await _getScriptsDirectory();
      final fullPath = '${scriptsDir.path}/$scriptFile';
      final file = File(fullPath);

      if (await file.exists()) {
        return fullPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Lista todos los scripts guardados
  static Future<List<String>> listSavedScripts() async {
    try {
      final scriptsDir = await _getScriptsDirectory();
      final files = await scriptsDir.list().toList();

      return files
          .whereType<File>()
          .map((file) => file.path.split('/').last)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Elimina un script
  static Future<bool> deleteScript(String scriptFile) async {
    try {
      final scriptsDir = await _getScriptsDirectory();
      final file = File('${scriptsDir.path}/$scriptFile');

      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Script eliminado: $scriptFile');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error eliminando script: $e');
      return false;
    }
  }

  /// Genera comando de instalación para Termux
  static String generateTermuxInstallCommand(String scriptPath) {
    final scriptName = scriptPath.split('/').last;

    if (scriptPath.startsWith('/data/data/com.termux')) {
      // El script ya está en Termux
      return 'cd ~/scripts && chmod +x $scriptName && ./$scriptName';
    } else {
      // Necesita copiar desde almacenamiento externo
      return '''
cp "$scriptPath" ~/scripts/ && 
cd ~/scripts && 
chmod +x $scriptName && 
echo "Script $scriptName instalado en ~/scripts/"
''';
    }
  }

  /// Información sobre dónde se guardan los scripts
  static Future<Map<String, dynamic>> getStorageInfo() async {
    final scriptsDir = await _getScriptsDirectory();
    final isTermuxDir = scriptsDir.path.contains('/data/data/com.termux');

    return {
      'path': scriptsDir.path,
      'isTermuxDirectory': isTermuxDir,
      'recommendedCommand':
          isTermuxDir ? 'cd ~/scripts' : 'cp ${scriptsDir.path}/* ~/scripts/',
      'description': isTermuxDir
          ? 'Scripts guardados directamente en Termux'
          : 'Scripts guardados en almacenamiento externo (requieren copia a Termux)',
    };
  }

  /// Crea estructura de directorios necesaria
  static Future<void> setupDirectoryStructure() async {
    try {
      final scriptsDir = await _getScriptsDirectory();

      // Crear subdirectorios por categoría
      final categories = ['security', 'tools', 'utils', 'automation'];

      for (final category in categories) {
        final categoryDir = Directory('${scriptsDir.path}/$category');
        if (!await categoryDir.exists()) {
          await categoryDir.create(recursive: true);
          debugPrint('📁 Directorio creado: ${categoryDir.path}');
        }
      }

      // Crear archivo README
      final readmeFile = File('${scriptsDir.path}/README.txt');
      if (!await readmeFile.exists()) {
        await readmeFile.writeAsString('''
T3R-C0D3 Scripts Directory
==========================

Este directorio contiene scripts instalados por T3R-C0D3.

Estructura:
- security/: Scripts de seguridad y pentesting
- tools/: Herramientas de desarrollo
- utils/: Utilidades del sistema
- automation/: Scripts de automatización

Para usar en Termux:
1. Copia los scripts a ~/scripts/
2. Dale permisos: chmod +x script_name
3. Ejecuta: ./script_name

Generado por T3R-C0D3 v1.0.0
''');
      }
    } catch (e) {
      debugPrint('❌ Error configurando estructura: $e');
    }
  }
}
