import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ❌ import 'package:animate_do/animate_do.dart'; // Removido
import 'learn_python_page.dart';
import 'donar_page.dart';
// import 'termux_start_page.dart'; // Comentado si no existe
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

const kPrimaryColor = Color(0xFF3489FE);
const kBackgroundColor = Color(0xFF262729);
const kTextColor = Colors.white;

class Rk13IntroPage extends StatefulWidget {
  const Rk13IntroPage({super.key});

  @override
  State<Rk13IntroPage> createState() => _Rk13IntroPageState();
}

class _Rk13IntroPageState extends State<Rk13IntroPage>
    with TickerProviderStateMixin {
  // ✅ Añadido para animaciones

  final ScrollController _iconScrollController = ScrollController();
  Timer? _scrollTimer;

  // ✅ Controladores de animación
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _fadeController;

  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAutoScroll();
    _startAnimations();
  }

  void _setupAnimations() {
    // Controlador para deslizar hacia abajo
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Controlador para bounce desde la izquierda
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Controlador para fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animaciones
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _bounceAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _bounceController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _fadeController.forward();
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (_iconScrollController.hasClients) {
        final max = _iconScrollController.position.maxScrollExtent;
        final current = _iconScrollController.offset;
        if (current < max) {
          _iconScrollController.jumpTo(current + 1.5);
        } else {
          _iconScrollController.jumpTo(0);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _iconScrollController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _launchFacebook() async {
    const url = 'https://www.facebook.com/share/15f5KqmACg/';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ✅ Banner animado con animaciones nativas
            SlideTransition(
              position: _slideAnimation,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/intro_banner.png',
                    width: w,
                    height: w * 0.45,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // ✅ Fallback si no existe la imagen
                      return Container(
                        width: w,
                        height: w * 0.45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              kPrimaryColor.withOpacity(0.8),
                              kBackgroundColor,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.terminal,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SlideTransition(
                        position: _bounceAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(55),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.terminal,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ✅ Mini galería con animación
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                height: 56,
                child: ListView(
                  controller: _iconScrollController,
                  scrollDirection: Axis.horizontal,
                  children: const [
                    SizedBox(width: 18),
                    _LangIcon(FontAwesomeIcons.python, Colors.yellow, 'Python'),
                    _LangIcon(FontAwesomeIcons.linux, Colors.white, 'Linux'),
                    _LangIcon(
                        FontAwesomeIcons.terminal, Colors.greenAccent, 'Bash'),
                    _LangIcon(FontAwesomeIcons.java, Colors.orange, 'Java'),
                    _LangIcon(
                        FontAwesomeIcons.html5, Colors.deepOrange, 'HTML5'),
                    _LangIcon(FontAwesomeIcons.js, Colors.amber, 'JavaScript'),
                    _LangIcon(FontAwesomeIcons.php, Colors.indigo, 'PHP'),
                    _LangIcon(FontAwesomeIcons.database, Colors.cyan, 'SQL'),
                    _LangIcon(FontAwesomeIcons.c, Colors.blue, 'C'),
                    _LangIcon(
                        FontAwesomeIcons.code, Colors.purpleAccent, 'C++'),
                    _LangIcon(
                        FontAwesomeIcons.gitAlt, Colors.deepOrange, 'Git'),
                    _LangIcon(FontAwesomeIcons.networkWired, Colors.tealAccent,
                        'Networking'),
                    _LangIcon(
                        FontAwesomeIcons.mask, Colors.redAccent, 'Hacking'),
                    _LangIcon(FontAwesomeIcons.userSecret, Colors.blueGrey,
                        'Pentest'),
                    _LangIcon(
                        FontAwesomeIcons.rust, Colors.orangeAccent, 'Rust'),
                    _LangIcon(FontAwesomeIcons.nodeJs, Colors.green, 'Node.js'),
                    _LangIcon(FontAwesomeIcons.gem, Colors.red, 'Ruby'),
                    _LangIcon(
                        FontAwesomeIcons.docker, Colors.blueAccent, 'Docker'),
                    _LangIcon(
                        FontAwesomeIcons.react, Colors.cyanAccent, 'React'),
                    _LangIcon(
                        FontAwesomeIcons.android, Colors.green, 'Android'),
                    _LangIcon(FontAwesomeIcons.apple, Colors.white, 'Apple'),
                    _LangIcon(
                        FontAwesomeIcons.linux, Colors.blue, 'Kali Linux'),
                    _LangIcon(FontAwesomeIcons.wifi, Colors.lightBlueAccent,
                        'Wireshark'),
                    _LangIcon(FontAwesomeIcons.key, Colors.white, 'SSH'),
                    _LangIcon(
                        FontAwesomeIcons.windows, Colors.blue, 'Powershell'),
                    SizedBox(width: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ✅ Sección de logos con animación
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LangIcon(
                        FontAwesomeIcons.terminal, Colors.white, 'Termux'),
                    SizedBox(width: 16),
                    _LangIcon(FontAwesomeIcons.linux, Colors.white, 'Linux'),
                    SizedBox(width: 16),
                    _LangIcon(
                        FontAwesomeIcons.windows, Colors.white, 'Windows'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Texto explicativo con animación
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Esta app y sus recursos están pensados para usuarios de Termux, Linux y Windows. '
                  'Podrás aprender, automatizar y compartir scripts o herramientas entre estos sistemas fácilmente.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ✅ Botón Termux (comentado si no existe la página)
            // FadeTransition(
            //   opacity: _fadeAnimation,
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 32),
            //     child: ElevatedButton.icon(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.green[700],
            //         foregroundColor: Colors.white,
            //         padding: const EdgeInsets.symmetric(vertical: 15),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         elevation: 8,
            //         textStyle: const TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 17,
            //         ),
            //       ),
            //       icon: const FaIcon(FontAwesomeIcons.terminal),
            //       label: const Text('Comienza con Termux'),
            //       onPressed: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(builder: (_) => const TermuxStartPage()),
            //         );
            //       },
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 18),

            // ✅ Slogan con animación
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: Text(
                  'Transforma tu móvil en una terminal Linux avanzada',
                  style: TextStyle(
                    color: kTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ✅ Tarjetas con animación escalonada
            _buildAnimatedCard(
              delay: 800,
              child: const _IntroCard(
                icon: FontAwesomeIcons.terminal,
                title: 'Automatiza, aprende y hackea',
                description:
                    'Instala herramientas, aprende Python y domina Termux desde tu móvil. Scripts, recursos y utilidades en un solo lugar.',
              ),
            ),
            const SizedBox(height: 12),

            _buildAnimatedCard(
              delay: 1000,
              child: const _IntroCard(
                icon: FontAwesomeIcons.shieldAlt,
                title: 'Seguridad y Potencia',
                description:
                    'Accede a más de 50 repositorios, scripts de hacking ético y personalización avanzada. Todo en gris mate y con estilo profesional.',
              ),
            ),
            const SizedBox(height: 18),

            // ✅ Botón principal con animación
            _buildAnimatedCard(
              delay: 1200,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Aprende Python Ahora'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LearnPythonPage()),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ✅ Frase motivacional
            _buildAnimatedCard(
              delay: 1400,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '"El conocimiento es la mejor arma" - Chema Alonso',
                  style: TextStyle(
                    color: Colors.white38,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ✅ Botón de donación
            _buildAnimatedCard(
              delay: 1600,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    side: const BorderSide(color: kPrimaryColor, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  icon: const Icon(Icons.favorite),
                  label: const Text('Donar y Apoyar'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DonarPage()),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Sección Facebook
            _buildAnimatedCard(
              delay: 1800,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Card(
                  color: kBackgroundColor,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: kPrimaryColor, width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 18),
                    child: Column(
                      children: [
                        const Text(
                          'Esta app pertenece a la página de Facebook:',
                          style: TextStyle(
                            color: kTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: kTextColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 18,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          icon: const FaIcon(FontAwesomeIcons.facebook,
                              color: Colors.white),
                          label: const Text('Facebook T3R-C0D3'),
                          onPressed: _launchFacebook,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ✅ Redes sociales
            _buildAnimatedCard(
              delay: 2000,
              child: const _SocialRow(),
            ),
            const SizedBox(height: 18),

            // ✅ Footer
            _buildAnimatedCard(
              delay: 2200,
              child: const Center(
                child: Text(
                  '© 2025 T3R-C0D3 - Todos los derechos reservados',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ✅ Widget helper para animaciones escalonadas
  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }
}

// ✅ Widget para iconos de lenguajes (sin cambios)
class _LangIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  const _LangIcon(this.icon, this.color, this.tooltip);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Tooltip(
        message: tooltip,
        child: CircleAvatar(
          backgroundColor: Colors.black,
          radius: 24,
          child: FaIcon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}

// ✅ Tarjeta de introducción (sin cambios)
class _IntroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _IntroCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Card(
        color: kBackgroundColor,
        elevation: 8,
        shadowColor: kPrimaryColor.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: kPrimaryColor, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Row(
            children: [
              FaIcon(icon, color: kPrimaryColor, size: 32),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Fila de redes sociales (sin cambios)
class _SocialRow extends StatelessWidget {
  const _SocialRow();

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.github, color: Colors.white),
          onPressed: () => _launch('https://github.com/Rk13termux'),
          tooltip: 'GitHub',
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.telegram, color: Colors.white),
          onPressed: () => _launch('https://t.me/rk13termux'),
          tooltip: 'Telegram',
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.youtube, color: Colors.white),
          onPressed: () => _launch('https://youtube.com/@rk13termux'),
          tooltip: 'YouTube',
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
          onPressed: () => _launch('https://instagram.com/rk13termux'),
          tooltip: 'Instagram',
        ),
      ],
    );
  }
}
