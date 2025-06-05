import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import '../models/repo_model.dart';
import '../main.dart';

class CloneSuccessDialog extends StatefulWidget {
  final RepoModel repo;
  final String command;
  final VoidCallback onCopyCommand;
  final Future<bool> Function() onOpenTermux;
  final Future<bool> Function() onOpenGitHub;

  const CloneSuccessDialog({
    super.key,
    required this.repo,
    required this.command,
    required this.onCopyCommand,
    required this.onOpenTermux,
    required this.onOpenGitHub,
  });

  @override
  State<CloneSuccessDialog> createState() => _CloneSuccessDialogState();
}

class _CloneSuccessDialogState extends State<CloneSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _commandCopied = false;
  bool _termuxOpening = false;
  bool _githubOpening = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildDialogContent(),
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildCommandSection(),
          _buildActionButtons(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryColor.withOpacity(0.1), kBackgroundColor],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Icono de éxito animado
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Título principal
          const Text(
            '🎉 ¡Comando Generado!',
            style: TextStyle(
              color: kTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtítulo con nombre del repo
          Text(
            'Listo para clonar "${widget.repo.name}"',
            style: TextStyle(
              color: kPrimaryColor.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Descripción persuasiva
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Text(
              '📱 Abre Termux y pega el comando para comenzar',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta del comando
          const Row(
            children: [
              Icon(Icons.terminal, color: kPrimaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Comando de clonación:',
                style: TextStyle(
                  color: kTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Container del comando
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _commandCopied
                    ? Colors.green.withOpacity(0.5)
                    : kPrimaryColor.withOpacity(0.3),
                width: _commandCopied ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_commandCopied ? Colors.green : kPrimaryColor)
                      .withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comando
                SelectableText(
                  widget.command,
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Botón copiar integrado
                GestureDetector(
                  onTap: _copyCommand,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _commandCopied
                          ? Colors.green.withOpacity(0.2)
                          : kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _commandCopied ? Colors.green : kPrimaryColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _commandCopied ? Icons.check : Icons.copy,
                          color: _commandCopied ? Colors.green : kPrimaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _commandCopied ? 'Copiado!' : 'Copiar comando',
                          style: TextStyle(
                            color:
                                _commandCopied ? Colors.green : kPrimaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Título de acciones
          const Text(
            '🚀 Acciones rápidas:',
            style: TextStyle(
              color: kTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: FontAwesomeIcons.terminal,
                label: 'Termux',
                color: Colors.green,
                isLoading: _termuxOpening,
                onPressed: _openTermux,
                description: 'Abrir app',
              ),
              _buildActionButton(
                icon: FontAwesomeIcons.github,
                label: 'GitHub',
                color: Colors.white,
                isLoading: _githubOpening,
                onPressed: _openGitHub,
                description: 'Ver repo',
              ),
              _buildActionButton(
                icon: FontAwesomeIcons.shareNodes,
                label: 'Compartir',
                color: kPrimaryColor,
                onPressed: _shareRepo,
                description: 'Compartir',
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required String description,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 2,
                  )
                : FaIcon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            description,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kBackgroundColor, kBackgroundColor.withOpacity(0.9)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Info adicional
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: El repositorio se descargará en tu directorio home (~)',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botón cerrar
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: kPrimaryColor.withOpacity(0.3)),
                ),
              ),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de interacción
  void _copyCommand() async {
    await Clipboard.setData(ClipboardData(text: widget.command));
    widget.onCopyCommand();

    setState(() => _commandCopied = true);

    // Vibración táctil
    HapticFeedback.lightImpact();

    // Mostrar snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Comando copiado al portapapeles'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Resetear estado después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _commandCopied = false);
      }
    });
  }

  void _openTermux() async {
    setState(() => _termuxOpening = true);

    try {
      final success = await widget.onOpenTermux();

      if (!success && mounted) {
        _showErrorSnackbar('No se pudo abrir Termux. ¿Está instalado?');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error al abrir Termux');
      }
    } finally {
      if (mounted) {
        setState(() => _termuxOpening = false);
      }
    }
  }

  void _openGitHub() async {
    setState(() => _githubOpening = true);

    try {
      final success = await widget.onOpenGitHub();

      if (!success && mounted) {
        _showErrorSnackbar('No se pudo abrir GitHub');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error al abrir GitHub');
      }
    } finally {
      if (mounted) {
        setState(() => _githubOpening = false);
      }
    }
  }

  void _shareRepo() {
    final shareText = '''
🔥 Descarga ${widget.repo.name}

📝 ${widget.repo.description}

🔗 ${widget.repo.cleanGithubUrl}

⚡ Comando rápido para Termux:
${widget.command}

Compartido desde T3R-C0D3 📱
''';

    Clipboard.setData(ClipboardData(text: shareText));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Información del repo copiada para compartir'),
          backgroundColor: kPrimaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
