import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

const kPrimaryColor = Color(0xFF3489FE);
const kBackgroundColor = Color(0xFF262729);
const kTextColor = Colors.white;

class TermuxStartPage extends StatelessWidget {
  const TermuxStartPage({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 8,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.terminal, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              'Comienza con Termux',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        children: [
          const Center(
            child: CircleAvatar(
              backgroundColor: Colors.black,
              radius: 40,
              child: FaIcon(FontAwesomeIcons.terminal,
                  color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle('¿Qué es Termux?'),
          const _JustifiedText(
            'Termux es una aplicación gratuita y de código abierto lanzada en 2015 por Fredrik Fornwall. '
            'Permite tener un entorno Linux completo en Android, con acceso a Bash, gestor de paquetes, compiladores, lenguajes de programación y utilidades de red. '
            'Ideal para programadores, administradores de sistemas, pentesters y entusiastas de la automatización.',
          ),
          const _SectionDivider(),
          const _SectionTitle('¿Por qué es tan útil?'),
          const _JustifiedText(
            '• Ejecuta scripts Bash, Python, Node.js, Ruby, etc.\n'
            '• Instala distros Linux completas (Ubuntu, Debian, Arch) con proot-distro.\n'
            '• Monta servidores HTTP, SSH, FTP y más desde tu móvil.\n'
            '• Accede a herramientas de hacking ético y ciberseguridad.\n'
            '• Automatiza tareas y personaliza tu entorno móvil como si fuera una terminal real.\n'
            '• Compatible con Windows y Linux para compartir archivos y scripts.',
          ),
          const _SectionDivider(),
          const _SectionTitle('Descargar Termux'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _DownloadButton(
                  color: Colors.blue[700]!,
                  icon: FontAwesomeIcons.android,
                  label: 'F-Droid',
                  url: 'https://f-droid.org/packages/com.termux/',
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: _DownloadButton(
                  color: Colors.black,
                  icon: FontAwesomeIcons.github,
                  label: 'GitHub',
                  url: 'https://github.com/termux/termux-app',
                ),
              ),
            ],
          ),
          const _SectionDivider(),
          const _SectionTitle('Guía rápida para empezar'),
          const _JustifiedText('1. Instala Termux desde F-Droid o GitHub.'),
          const _JustifiedText('2. Abre Termux y actualiza los paquetes:'),
          const _CommandCode('pkg update && pkg upgrade'),
          const _JustifiedText('3. Instala utilidades básicas:'),
          const _CommandCode('pkg install git python nano'),
          const _JustifiedText('4. Instala distros Linux con proot-distro:'),
          const _CommandCode('pkg install proot-distro'),
          const _CommandCode('proot-distro list'),
          const _CommandCode('proot-distro install ubuntu'),
          const _CommandCode('proot-distro login ubuntu'),
          const _JustifiedText('5. Monta servidores:'),
          const _CommandCode('python -m http.server 8080', label: 'HTTP'),
          const _CommandCode('pkg install openssh', label: 'SSH'),
          const _CommandCode('pkg install nodejs', label: 'Node.js'),
          const _SectionDivider(),
          const _SectionTitle('Historia y autor'),
          const _JustifiedText(
            'Termux fue creado por Fredrik Fornwall en 2015. El proyecto es mantenido actualmente por la comunidad open source. '
            'Su objetivo es acercar la potencia de Linux y la terminal a cualquier usuario de Android, permitiendo programar, administrar sistemas y automatizar tareas desde el móvil.',
          ),
          const _SectionDivider(),
          const _SectionTitle('Preguntas frecuentes'),
          const _FaqItem(
            question: '¿Termux es seguro?',
            answer:
                'Sí, siempre que descargues desde fuentes oficiales. No requiere root y no accede a tus datos personales sin permiso.',
          ),
          const _FaqItem(
            question: '¿Puedo instalar Kali Linux o Parrot en Termux?',
            answer:
                'Puedes instalar distros como Ubuntu, Debian, Arch, Alpine, Fedora, entre otras, usando proot-distro. Kali y Parrot no están oficialmente soportadas, pero hay scripts de la comunidad.',
          ),
          const _FaqItem(
            question: '¿Qué limitaciones tiene respecto a un Linux real?',
            answer:
                'No tiene acceso a todos los dispositivos ni a funciones de bajo nivel (no root). Algunas herramientas pueden no funcionar igual que en un PC.',
          ),
          const _FaqItem(
            question: '¿Puedo programar y compilar en C/C++/Python?',
            answer:
                'Sí, puedes instalar compiladores y entornos de desarrollo para C, C++, Python, Node.js, Ruby, Go, Rust, etc.',
          ),
          const _FaqItem(
            question: '¿Cómo comparto archivos con Windows o Linux?',
            answer:
                'Puedes usar SSH, FTP, almacenamiento compartido o copiar archivos desde la carpeta de Termux a tu almacenamiento interno.',
          ),
          const _SectionDivider(),
          const _SectionTitle('Compatibilidad multiplataforma'),
          const _JustifiedText(
            'Esta app y sus recursos están pensados para usuarios de Termux, Linux y Windows. '
            'Podrás aprender, automatizar y compartir scripts o herramientas entre estos sistemas fácilmente.',
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: kPrimaryColor,
          fontSize: 21,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: Colors.white12,
        thickness: 1,
        height: 1,
      ),
    );
  }
}

class _JustifiedText extends StatelessWidget {
  final String text;
  const _JustifiedText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String url;
  const _DownloadButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 6,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        icon: FaIcon(icon, size: 22),
        label: Text(label),
        onPressed: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FaIcon(FontAwesomeIcons.circleQuestion,
              color: kPrimaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: const TextStyle(
                    color: Colors.white70, fontSize: 16, height: 1.5),
                children: [
                  TextSpan(
                    text: '$question\n',
                    style: const TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: answer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandCode extends StatelessWidget {
  final String command;
  final String? label;
  const _CommandCode(this.command, {this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 2),
              child: Text(
                '$label:',
                style: const TextStyle(
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      command,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.blue,
                        fontSize: 15.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.copy, color: Colors.white54, size: 20),
                    tooltip: 'Copiar',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: command));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Comando copiado'),
                          duration: Duration(milliseconds: 900),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
