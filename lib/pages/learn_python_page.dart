import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ❌ import 'package:animate_do/animate_do.dart'; // Removido
import 'package:url_launcher/url_launcher.dart';

class LearnPythonPage extends StatefulWidget {
  const LearnPythonPage({super.key});

  @override
  State<LearnPythonPage> createState() => _LearnPythonPageState();
}

class _LearnPythonPageState extends State<LearnPythonPage>
    with TickerProviderStateMixin {
  // ✅ Controladores de animación
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Controlador para fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Controlador para bounce infinito
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Controlador para slide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animaciones
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();

    // Bounce infinito
    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _openTelegram() async {
    final Uri url =
        Uri.parse('https://t.me/rk13termux'); // ✅ Canal real de RK13
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _openAffiliate() async {
    // ✅ Cambiar por el enlace real cuando esté disponible
    final Uri url = Uri.parse('https://github.com/Rk13termux');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.redAccent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.redAccent, Colors.black],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ FadeInDown reemplazado por SlideTransition
                      SlideTransition(
                        position: _slideAnimation,
                        child: const FaIcon(
                          FontAwesomeIcons.python,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ FadeIn reemplazado por FadeTransition
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'Domina Python',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // ✅ FadeIn con delay reemplazado por TweenAnimationBuilder
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1300),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: const Text(
                              'De Cero a Experto',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Sección de unirse con animación
                  _buildAnimatedSection(
                    delay: 600,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade900, Colors.black],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '¡Únete a +1000 estudiantes!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _openTelegram,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0088cc),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                icon: const FaIcon(FontAwesomeIcons.telegram),
                                label: const Text(
                                  'Canal Privado',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _openAffiliate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                icon: const Icon(Icons.school,
                                    color: Colors.white),
                                label: const Text(
                                  'Aprende Gratis',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ Grid de características con animaciones escalonadas
                  _buildAnimatedSection(
                    delay: 800,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: const [
                        _FeatureCard(
                          icon: FontAwesomeIcons.rocket,
                          title: '19 Módulos',
                          subtitle: 'Contenido completo',
                          delay: 0,
                        ),
                        _FeatureCard(
                          icon: FontAwesomeIcons.laptop,
                          title: 'Proyectos Reales',
                          subtitle: 'Aprende haciendo',
                          delay: 200,
                        ),
                        _FeatureCard(
                          icon: FontAwesomeIcons.users,
                          title: 'Comunidad',
                          subtitle: 'Soporte 24/7',
                          delay: 400,
                        ),
                        _FeatureCard(
                          icon: FontAwesomeIcons.certificate,
                          title: 'Recursos',
                          subtitle: 'Scripts incluidos',
                          delay: 600,
                        ),
                      ],
                    ),
                  ),

                  // ✅ Call to action con bounce infinito
                  _buildAnimatedSection(
                    delay: 1200,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withAlpha(25),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.redAccent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '¿Listo para comenzar?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ✅ Bounce infinito reemplazado por ScaleTransition
                          AnimatedBuilder(
                            animation: _bounceAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _bounceAnimation.value,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 20,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                  ),
                                  onPressed: _openAffiliate,
                                  child: const Text(
                                    '¡Comienza Ahora!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ Recursos adicionales
                  _buildAnimatedSection(
                    delay: 1400,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF3489FE).withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📚 Recursos incluidos:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildResourceItem(
                              '🐍 Scripts de Python para Termux'),
                          _buildResourceItem(
                              '🔧 Herramientas de automatización'),
                          _buildResourceItem('💻 Ejemplos prácticos'),
                          _buildResourceItem('📖 Documentación completa'),
                          _buildResourceItem('🎯 Proyectos paso a paso'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Widget helper para secciones animadas
  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  // ✅ Widget para items de recursos
  Widget _buildResourceItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF3489FE),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ _FeatureCard con animación propia
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int delay;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Card(
              color: Colors.grey[900],
              elevation: 8,
              shadowColor: Colors.redAccent.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.redAccent.withOpacity(0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(icon, color: Colors.redAccent, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
