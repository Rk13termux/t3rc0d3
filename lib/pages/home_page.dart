import 'package:flutter/material.dart';
import '../models/repo_model.dart';
import '../services/admob_service.dart';
import 'repo_readme_page.dart';

const kPrimaryColor = Color(0xFF3489FE);
const kBackgroundColor = Color(0xFF262729);

final List<RepoModel> repos = [
  // ... existing repos ...
  // (mantén todos los repositorios que ya tienes definidos)
  // --- Aprendizaje y Recursos ---
  const RepoModel(
    name: "freeCodeCamp",
    description: "Plataforma gratuita para aprender a programar.",
    scriptFile: "freecodecamp.sh",
    readmeAsset: "assets/readmes/freecodecamp.md",
    githubUrl: "https://github.com/freeCodeCamp/freeCodeCamp",
    category: "Aprendizaje y Recursos",
    iconAsset: "assets/icons/iconrepo.png",
  ),
  // ... todos los demás repositorios que ya tienes ...
  // (copia todos los repos del archivo original aquí)
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _preloadAds();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  Future<void> _preloadAds() async {
    // Precargar anuncios para mejor experiencia
    await AdMobService.preloadAds();
  }

  Map<String, List<RepoModel>> get reposPorCategoria {
    final map = <String, List<RepoModel>>{};
    final filteredRepos = repos.where((repo) {
      return _searchQuery.isEmpty ||
          repo.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          repo.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          repo.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    for (final repo in filteredRepos) {
      map.putIfAbsent(repo.category, () => []).add(repo);
    }
    return map;
  }

  Future<void> _navigateToRepo(RepoModel repo) async {
    // 🎯 Mostrar anuncio antes de navegar al repositorio
    await AdMobService.showAdForAction(
      adType: AdType.repoView,
      context: context,
      onAdCompleted: () {
        _performNavigation(repo);
      },
      onAdSkipped: () {
        _performNavigation(repo);
      },
    );
  }

  void _performNavigation(RepoModel repo) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RepoReadmePage(
          repoName: repo.name,
          scriptFile: repo.scriptFile,
          readmeAsset: repo.readmeAsset,
          githubUrl: repo.githubUrl,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = reposPorCategoria.keys.toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          // 🎯 Barra de búsqueda mejorada
          _buildSearchBar(),

          // 🎯 Estadísticas rápidas
          _buildStatsHeader(),

          // 🎯 Lista de repositorios con animaciones
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categorias.length,
                  itemBuilder: (context, catIndex) {
                    final categoria = categorias[catIndex];
                    final lista = reposPorCategoria[categoria]!;

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          catIndex * 0.1,
                          1.0,
                          curve: Curves.easeOutQuart,
                        ),
                      )),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            catIndex * 0.1,
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: _buildCategorySection(categoria, lista),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Buscar repositorios...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => setState(() => _searchQuery = ""),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final totalRepos = repos.length;
    final filteredRepos =
        reposPorCategoria.values.expand((list) => list).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(0.1),
            kPrimaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$filteredRepos de $totalRepos',
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'repositorios disponibles',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.code,
              color: kPrimaryColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String categoria, List<RepoModel> lista) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de categoría
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kPrimaryColor.withOpacity(0.2),
                kPrimaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(categoria),
                color: kPrimaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  categoria,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${lista.length}',
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de repositorios
        ...lista.asMap().entries.map((entry) {
          final repo = entry.value;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (entry.key * 50)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(50 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Card(
                      color: Colors.grey[900],
                      elevation: 6,
                      shadowColor: kPrimaryColor.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: kPrimaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            repo.iconAsset,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.folder_special,
                                color: kPrimaryColor,
                                size: 24,
                              );
                            },
                          ),
                        ),
                        title: Text(
                          repo.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            repo.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: kPrimaryColor,
                              size: 18,
                            ),
                            tooltip: 'Ver repositorio',
                            onPressed: () => _navigateToRepo(repo),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case 'Aprendizaje y Recursos':
        return Icons.school;
      case 'Herramientas y Utilidades':
        return Icons.build;
      case 'Seguridad y Pentesting':
        return Icons.security;
      case 'Terminal y Personalización':
        return Icons.terminal;
      case 'Chat, Mensajería y Red':
        return Icons.network_check;
      default:
        return Icons.folder;
    }
  }
}
