import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import '../models/repo_model.dart';
import '../services/admob_service.dart';
import '../services/git_clone_service.dart';
import '../widgets/clone_success_dialog.dart';
import '../main.dart';

class RepoCard extends StatefulWidget {
  final RepoModel repo;
  final VoidCallback? onRepoViewed;

  const RepoCard({super.key, required this.repo, this.onRepoViewed});

  @override
  State<RepoCard> createState() => _RepoCardState();
}

class _RepoCardState extends State<RepoCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _saveController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _saveAnimation;

  bool _isHovered = false;
  bool _isSaving = false;
  bool _isOpeningGitHub = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _saveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _saveAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _saveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _saveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverAnimation, _saveAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _hoverAnimation.value * _saveAnimation.value,
          child: _buildCard(),
        );
      },
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      onTapDown: (_) => _saveController.forward(),
      onTapUp: (_) => _saveController.reverse(),
      onTapCancel: () => _saveController.reverse(),
      child: MouseRegion(
        onEnter: (_) => _onHoverStart(),
        onExit: (_) => _onHoverEnd(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? kPrimaryColor.withOpacity(0.5)
                  : Colors.grey[800]!,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? kPrimaryColor.withOpacity(0.2)
                    : Colors.black.withOpacity(0.3),
                blurRadius: _isHovered ? 15 : 8,
                spreadRadius: _isHovered ? 2 : 1,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _handleRepoTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildDescription(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Icono del repositorio
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPrimaryColor.withOpacity(0.2),
                kPrimaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
          ),
          child: Icon(_getRepoIcon(), color: kPrimaryColor, size: 24),
        ),
        const SizedBox(width: 16),

        // Información del repositorio
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del repositorio
              Text(
                widget.repo.name,
                style: const TextStyle(
                  color: kTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Categoría y stats
              Row(
                children: [
                  // Badge de categoría
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getCategoryColor().withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      widget.repo.category,
                      style: TextStyle(
                        color: _getCategoryColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Usuario del repo
                  Text(
                    '@${widget.repo.repoOwner}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Badge de "NUEVO" (opcional)
        if (_isNewRepo())
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'NUEVO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.repo.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Tags o características
          Wrap(spacing: 8, runSpacing: 6, children: _buildFeatureTags()),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureTags() {
    final tags = <String>[];

    // Detectar tecnologías
    final desc = widget.repo.description.toLowerCase();
    if (desc.contains('python')) tags.add('Python');
    if (desc.contains('node') || desc.contains('javascript')) {
      tags.add('Node.js');
    }
    if (desc.contains('go ')) tags.add('Go');
    if (desc.contains('rust')) tags.add('Rust');
    if (desc.contains('security') || desc.contains('hack')) {
      tags.add('Security');
    }
    if (desc.contains('tool')) tags.add('Tool');

    return tags
        .take(3)
        .map(
          (tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: kPrimaryColor.withOpacity(0.9),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Botón principal "Guardar"
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _handleSaveRepo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: _isSaving ? 0 : 6,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: Colors.green.withOpacity(0.4),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.download_rounded, size: 20),
            label: Text(
              _isSaving ? 'Procesando...' : 'Guardar',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Botón GitHub
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: IconButton(
            onPressed: _isOpeningGitHub ? null : _handleGitHubOpen,
            icon: _isOpeningGitHub
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const FaIcon(
                    FontAwesomeIcons.github,
                    color: Colors.white,
                    size: 20,
                  ),
            tooltip: 'Ver en GitHub',
          ),
        ),
      ],
    );
  }

  // Métodos de interacción
  void _handleRepoTap() {
    // 🎯 Mostrar anuncio obligatorio antes de ver el repo
    AdMobService.showAdForAction(
      adType: AdType.repoView,
      context: context,
      onAdCompleted: () {
        widget.onRepoViewed?.call();
        _showRepoDetails();
      },
      onAdSkipped: () {
        // Si el anuncio falla, mostrar diálogo pidiendo ver anuncio
        _showAdRequiredDialog();
      },
    );
  }

  void _handleSaveRepo() async {
    setState(() => _isSaving = true);

    try {
      // 🎯 Mostrar anuncio de recompensa antes de generar comando
      final adShown = await AdMobService.showAdForAction(
        adType: AdType.cloneGenerated,
        context: context,
        onAdCompleted: () async {
          await _processRepoSave();
        },
        onAdSkipped: () {
          _showAdErrorDialog('Para generar el comando de clonación');
        },
      );
    } catch (e) {
      _showErrorSnackbar('Error al procesar el repositorio');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _handleGitHubOpen() async {
    setState(() => _isOpeningGitHub = true);

    try {
      // 🎯 Mostrar anuncio antes de ir a GitHub
      await AdMobService.showAdForAction(
        adType: AdType.githubRedirect,
        context: context,
        onAdCompleted: () async {
          await _openGitHubRepo();
        },
        onAdSkipped: () {
          _showAdErrorDialog('Para abrir GitHub');
        },
      );
    } catch (e) {
      _showErrorSnackbar('Error al abrir GitHub');
    } finally {
      if (mounted) {
        setState(() => _isOpeningGitHub = false);
      }
    }
  }

  // Métodos de procesamiento
  Future<void> _processRepoSave() async {
    try {
      final command = await GitCloneService.generateCloneCommand(widget.repo);

      if (mounted) {
        GitCloneService.showCloneSuccessDialog(context, widget.repo, command);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error generando comando de clonación');
      }
    }
  }

  Future<void> _openGitHubRepo() async {
    final success = await GitCloneService.openGitHubRepo(widget.repo.githubUrl);

    if (!success && mounted) {
      _showErrorSnackbar('No se pudo abrir GitHub');
    }
  }

  void _showRepoDetails() {
    // Aquí podrías mostrar una página de detalles del repositorio
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: kBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.repo.name,
                style: const TextStyle(
                  color: kTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.repo.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos de UI auxiliares
  void _onHoverStart() {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onHoverEnd() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  IconData _getRepoIcon() {
    final category = widget.repo.category.toLowerCase();
    if (category.contains('security')) return Icons.security;
    if (category.contains('tool')) return Icons.build;
    if (category.contains('script')) return Icons.code;
    if (category.contains('framework')) return Icons.widgets;
    return Icons.folder_open;
  }

  Color _getCategoryColor() {
    final category = widget.repo.category.toLowerCase();
    if (category.contains('security')) return Colors.red;
    if (category.contains('tool')) return Colors.orange;
    if (category.contains('script')) return Colors.green;
    if (category.contains('framework')) return Colors.purple;
    return kPrimaryColor;
  }

  bool _isNewRepo() {
    // Lógica para determinar si es un repo nuevo
    // Podría basarse en fecha, ID, etc.
    return false; // Por simplicidad
  }

  // Diálogos de error y confirmación
  void _showAdRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: kBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '📺 Anuncio requerido',
          style: TextStyle(color: kTextColor),
        ),
        content: const Text(
          'Para ver los detalles del repositorio, necesitas ver un anuncio. '
          'Esto nos ayuda a mantener la app gratuita.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleRepoTap(); // Reintentar
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: const Text(
              'Ver anuncio',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdErrorDialog(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '📺 Anuncio no disponible',
          style: TextStyle(color: kTextColor),
        ),
        content: Text(
          'No hay anuncios disponibles $action. '
          '¿Continuar de todas formas?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Proceder sin anuncio según la acción
              if (action.contains('comando')) {
                _processRepoSave();
              } else if (action.contains('GitHub')) {
                _openGitHubRepo();
              } else {
                _showRepoDetails();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: const Text(
              'Continuar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
