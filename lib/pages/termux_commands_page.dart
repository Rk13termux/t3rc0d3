import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Cambiar por esta dependencia nativa
// ❌ Remover: 'package:clipboard/clipboard.dart'
// ❌ Remover: 'package:animate_do/animate_do.dart'

class TermuxCommandsPage extends StatefulWidget {
  const TermuxCommandsPage({super.key});

  @override
  State<TermuxCommandsPage> createState() => _TermuxCommandsPageState();
}

class _TermuxCommandsPageState extends State<TermuxCommandsPage>
    with TickerProviderStateMixin {
  // ✅ Añadir para animaciones

  late AnimationController _animationController;

  final Map<String, List<Map<String, String>>> comandosPorCategoria = const {
    "Sistema y Navegación": [
      {"comando": "ls", "descripcion": "Listar archivos y carpetas."},
      {"comando": "cd", "descripcion": "Cambiar de directorio."},
      {"comando": "pwd", "descripcion": "Mostrar directorio actual."},
      {"comando": "mkdir", "descripcion": "Crear directorio."},
      {"comando": "rmdir", "descripcion": "Eliminar directorio vacío."},
      {"comando": "rm", "descripcion": "Eliminar archivo."},
      {"comando": "cp", "descripcion": "Copiar archivo."},
      {"comando": "mv", "descripcion": "Mover/renombrar archivo."},
      {"comando": "find", "descripcion": "Buscar archivos."},
      {"comando": "chmod", "descripcion": "Cambiar permisos."},
    ],
    "Gestión de Paquetes": [
      {"comando": "pkg update", "descripcion": "Actualizar repositorios."},
      {
        "comando": "pkg upgrade",
        "descripcion": "Actualizar paquetes instalados."
      },
      {
        "comando": "pkg install <paquete>",
        "descripcion": "Instalar un paquete."
      },
      {
        "comando": "pkg uninstall <paquete>",
        "descripcion": "Desinstalar paquete."
      },
      {"comando": "pkg search <nombre>", "descripcion": "Buscar un paquete."},
      {
        "comando": "pkg list-installed",
        "descripcion": "Listar paquetes instalados."
      },
      {
        "comando": "pkg show <paquete>",
        "descripcion": "Mostrar info del paquete."
      },
    ],
    "Git y Control de Versiones": [
      {"comando": "git clone <url>", "descripcion": "Clonar un repositorio."},
      {"comando": "git status", "descripcion": "Ver estado del repositorio."},
      {"comando": "git pull", "descripcion": "Actualizar repositorio local."},
      {"comando": "git push", "descripcion": "Subir cambios al repositorio."},
      {"comando": "git add .", "descripcion": "Añadir todos los cambios."},
      {
        "comando": "git commit -m 'mensaje'",
        "descripcion": "Confirmar cambios."
      },
      {"comando": "git branch", "descripcion": "Listar ramas."},
      {"comando": "git checkout <rama>", "descripcion": "Cambiar de rama."},
    ],
    "Lenguajes y Herramientas": [
      {
        "comando": "python <archivo.py>",
        "descripcion": "Ejecutar script Python."
      },
      {
        "comando": "node <archivo.js>",
        "descripcion": "Ejecutar script JavaScript."
      },
      {"comando": "php <archivo.php>", "descripcion": "Ejecutar script PHP."},
      {
        "comando": "gcc <archivo.c> -o programa",
        "descripcion": "Compilar programa en C."
      },
      {
        "comando": "javac <archivo.java>",
        "descripcion": "Compilar programa Java."
      },
      {
        "comando": "go run <archivo.go>",
        "descripcion": "Ejecutar programa Go."
      },
    ],
    "Red y Conectividad": [
      {"comando": "ping <host>", "descripcion": "Hacer ping a un host."},
      {"comando": "wget <url>", "descripcion": "Descargar archivo desde URL."},
      {"comando": "curl <url>", "descripcion": "Realizar petición HTTP."},
      {"comando": "ssh <usuario>@<host>", "descripcion": "Conectar por SSH."},
      {
        "comando": "scp <archivo> <destino>",
        "descripcion": "Copiar archivo por SSH."
      },
      {"comando": "netstat", "descripcion": "Ver conexiones de red."},
    ],
    "Multimedia y Archivos": [
      {
        "comando": "ffmpeg -i input.mp4 output.mp3",
        "descripcion": "Convertir video a audio."
      },
      {"comando": "imagemagick convert", "descripcion": "Editar imágenes."},
      {
        "comando": "zip -r archivo.zip carpeta/",
        "descripcion": "Crear archivo ZIP."
      },
      {"comando": "unzip archivo.zip", "descripcion": "Extraer archivo ZIP."},
      {
        "comando": "tar -czf archivo.tar.gz carpeta/",
        "descripcion": "Crear tarball comprimido."
      },
      {"comando": "tar -xzf archivo.tar.gz", "descripcion": "Extraer tarball."},
    ],
  };

  String _search = "";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ Método corregido usando Clipboard nativo de Flutter
  void copiarAlPortapapeles(BuildContext context, String texto) async {
    try {
      await Clipboard.setData(ClipboardData(text: texto));

      if (mounted) {
        // ✅ Usar SnackBar nativo en lugar de overlay personalizado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Comando "$texto" copiado',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Vibración táctil
      HapticFeedback.lightImpact();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al copiar comando'),
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

  @override
  Widget build(BuildContext context) {
    final categorias = comandosPorCategoria.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF262729), // ✅ Usar colores del tema
      appBar: AppBar(
        title: const Text(
          'Comandos Termux',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF262729),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3489FE)),
        actions: [
          // ✅ Botón de información adicional
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Ayuda',
            onPressed: () => _mostrarAyuda(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Campo de búsqueda mejorado
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3489FE).withOpacity(0.3),
              ),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar comando o descripción...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF3489FE),
                ),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => setState(() => _search = ""),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) =>
                  setState(() => _search = value.trim().toLowerCase()),
            ),
          ),

          // ✅ Lista de comandos con animaciones nativas
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categorias.length,
                  itemBuilder: (context, catIndex) {
                    final categoria = categorias[catIndex];
                    final lista = comandosPorCategoria[categoria]!
                        .where((cmd) =>
                            cmd['comando']!.toLowerCase().contains(_search) ||
                            cmd['descripcion']!.toLowerCase().contains(_search))
                        .toList();

                    if (lista.isEmpty) return const SizedBox.shrink();

                    // ✅ Animación personalizada usando AnimatedBuilder
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

  // ✅ Widget separado para cada sección de categoría
  Widget _buildCategorySection(
      String categoria, List<Map<String, String>> comandos) {
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
                const Color(0xFF3489FE).withOpacity(0.2),
                const Color(0xFF3489FE).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF3489FE).withOpacity(0.3),
            ),
          ),
          child: Text(
            categoria,
            style: const TextStyle(
              color: Color(0xFF3489FE),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Lista de comandos
        ...comandos.asMap().entries.map((entry) {
          final i = entry.key;
          final cmd = entry.value;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Card(
              color: Colors.grey[900],
              elevation: 4,
              shadowColor: const Color(0xFF3489FE).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: const Color(0xFF3489FE).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  cmd['comando']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'monospace',
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    cmd['descripcion']!,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3489FE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF3489FE),
                    ),
                    tooltip: "Copiar comando",
                    onPressed: () =>
                        copiarAlPortapapeles(context, cmd['comando']!),
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }

  // ✅ Diálogo de ayuda
  void _mostrarAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262729),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '💡 Consejos de uso',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '• Toca el icono 📋 para copiar cualquier comando\n\n'
                  '• Usa la búsqueda para encontrar comandos específicos\n\n'
                  '• Los comandos se copian automáticamente al portapapeles\n\n'
                  '• Reemplaza <texto> por valores reales\n\n'
                  '• Ejemplo: pkg install python\n\n'
                  '• Para ayuda específica usa: man <comando>',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: Color(0xFF3489FE),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
