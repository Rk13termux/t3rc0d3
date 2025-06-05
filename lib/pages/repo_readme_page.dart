import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/repo_model.dart';
import '../services/admob_service.dart';
import '../services/git_clone_service.dart';

const kPrimaryColor = Color(0xFF3489FE);
const kBackgroundColor = Color(0xFF262729);

class RepoReadmePage extends StatefulWidget {
  final String repoName;
  final String scriptFile;
  final String readmeAsset;
  final String githubUrl;

  const RepoReadmePage({
    super.key,
    required this.repoName,
    required this.scriptFile,
    required this.readmeAsset,
    required this.githubUrl,
  });

  @override
  State<RepoReadmePage> createState() => _RepoReadmePageState();
}

class _RepoReadmePageState extends State<RepoReadmePage>
    with TickerProviderStateMixin {
  String _readmeContent = '';
  bool _isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadReadmeContent();
    _showInitialAd();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  Future<void> _showInitialAd() async {
    // 🎯 Mostrar anuncio al ver repositorio
    await AdMobService.showAdForAction(
      adType: AdType.repoView,
      context: context,
      onAdCompleted: () {
        debugPrint('✅ Anuncio de repositorio completado');
      },
      onAdSkipped: () {
        debugPrint('⏭️ Anuncio de repositorio omitido');
      },
    );
  }

  Future<void> _loadReadmeContent() async {
    try {
      final content = await rootBundle.loadString(widget.readmeAsset);
      setState(() {
        _readmeContent = content;
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _readmeContent = _generateFallbackReadme();
        _isLoading = false;
      });
      _fadeController.forward();
      debugPrint('❌ Error cargando README: $e');
    }
  }

  String _generateFallbackReadme() {
    return '''
# ${widget.repoName}

## 📋 Descripción
Este repositorio contiene herramientas y recursos útiles para desarrollo y seguridad.

## 🚀 Instalación Rápida
Para instalar este repositorio en Termux, usa el comando de clonación que se genera automáticamente.

## 📖 Uso
1. Clona el repositorio
2. Lee la documentación incluida
3. Ejecuta los scripts según las instrucciones

## 🔗 Enlaces
- [Repositorio en GitHub](${widget.githubUrl})
- [Documentación oficial](${widget.githubUrl}/blob/main/README.md)

## ⚠️ Importante
Asegúrate de tener los permisos necesarios y usa estas herramientas de manera ética y responsable.

---
*README generado automáticamente por T3R-C0D3*
''';
  }

  Future<void> _generateCloneCommand() async {
    // 🎯 Mostrar anuncio antes de generar comando
    await AdMobService.showAdForAction(
      adType: AdType.cloneGenerated,
      context: context,
      onAdCompleted: () async {
        await _performCloneGeneration();
      },
      onAdSkipped: () async {
        await _performCloneGeneration();
      },
    );
  }

  Future<void> _performCloneGeneration() async {
    try {
      // Crear RepoModel temporal para usar con GitCloneService
      final repo = RepoModel(
        name: widget.repoName,
        description: 'Repositorio desde T3R-C0D3',
        scriptFile: widget.scriptFile,
        readmeAsset: widget.readmeAsset,
        githubUrl: widget.githubUrl,
        category: 'General',
        iconAsset: 'assets/icons/iconrepo.png',
      );

      final command = await GitCloneService.generateCloneCommand(repo);

      // Mostrar diálogo de éxito
      GitCloneService.showCloneSuccessDialog(context, repo, command);
    } catch (e) {
      _showErrorSnackBar('Error generando comando: $e');
    }
  }

  Future<void> _openInGitHub() async {
    // 🎯 Mostrar anuncio antes de ir a GitHub
    await AdMobService.showAdForAction(
      adType: AdType.githubRedirect,
      context: context,
      onAdCompleted: () async {
        await _performGitHubOpen();
      },
      onAdSkipped: () async {
        await _performGitHubOpen();
      },
    );
  }

  Future<void> _performGitHubOpen() async {
    final success = await GitCloneService.openGitHubRepo(widget.githubUrl);
    if (!success) {
      _showErrorSnackBar('No se pudo abrir GitHub');
    }
  }

  Future<void> _shareRepository() async {
    try {
      await Clipboard.setData(ClipboardData(
        text:
            '🔗 ${widget.repoName}\n\n${widget.githubUrl}\n\n📱 Compartido desde T3R-C0D3',
      ));

      _showSuccessSnackBar(
          'Información del repositorio copiada al portapapeles');
    } catch (e) {
      _showErrorSnackBar('Error al compartir: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.repoName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kPrimaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir',
            onPressed: _shareRepository,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
            )
          : Column(
              children: [
                // 🎯 Barra de acciones mejorada
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor.withOpacity(0.1),
                        kPrimaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.terminal,
                        label: 'Clonar',
                        color: Colors.green,
                        onPressed: _generateCloneCommand,
                      ),
                      _ActionButton(
                        icon: Icons.open_in_browser,
                        label: 'GitHub',
                        color: kPrimaryColor,
                        onPressed: _openInGitHub,
                      ),
                      _ActionButton(
                        icon: Icons.download,
                        label: 'Termux',
                        color: Colors.orange,
                        onPressed: () async {
                          final success = await GitCloneService.openTermuxApp();
                          if (!success) {
                            _showErrorSnackBar('Termux no está instalado');
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // 🎯 Contenido del README con animación
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header del repositorio
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.folder_special,
                                    color: kPrimaryColor,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.repoName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Script: ${widget.scriptFile}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            const Divider(color: kPrimaryColor, thickness: 1),
                            const SizedBox(height: 24),

                            // Contenido del README
                            SelectableText(
                              _readmeContent,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.6,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
    );
  }
}

// 🎯 Widget para botones de acción
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            elevation: 4,
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
