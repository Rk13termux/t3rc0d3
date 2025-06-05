class RepoModel {
  final String name;
  final String description;
  final String scriptFile;
  final String readmeAsset;
  final String githubUrl;
  final String category;
  final String iconAsset;

  const RepoModel({
    required this.name,
    required this.description,
    required this.scriptFile,
    required this.readmeAsset,
    required this.githubUrl,
    required this.category,
    required this.iconAsset,
  });

  // 🎯 Método para generar comando git clone automático
  String get gitCloneCommand {
    final sanitizedName = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\-_]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    return 'cd ~ && git clone $githubUrl $sanitizedName';
  }

  // 🎯 Directorio de destino limpio
  String get targetDirectory {
    final sanitizedName = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\-_]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    return '/data/data/com.termux/files/home/$sanitizedName';
  }

  // 🎯 Comando de instalación post-clonado (si aplica)
  String get postInstallCommand {
    final sanitizedName = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\-_]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    // Comandos específicos según el tipo de repositorio
    if (scriptFile.contains('python') ||
        description.toLowerCase().contains('python')) {
      return 'cd ~/$sanitizedName && pip install -r requirements.txt 2>/dev/null || echo "No requirements.txt found"';
    } else if (scriptFile.contains('node') ||
        description.toLowerCase().contains('node')) {
      return 'cd ~/$sanitizedName && npm install 2>/dev/null || echo "No package.json found"';
    } else if (scriptFile.contains('go') ||
        description.toLowerCase().contains('go ')) {
      return 'cd ~/$sanitizedName && go mod tidy 2>/dev/null || echo "No go.mod found"';
    } else if (scriptFile.contains('rust') ||
        description.toLowerCase().contains('rust')) {
      return 'cd ~/$sanitizedName && cargo build 2>/dev/null || echo "No Cargo.toml found"';
    } else {
      return 'cd ~/$sanitizedName && echo "Repositorio clonado exitosamente"';
    }
  }

  // 🎯 Comando completo con clonado e instalación
  String get fullInstallCommand {
    return '$gitCloneCommand && $postInstallCommand';
  }

  // 🎯 URL de GitHub limpia (para abrir en navegador)
  String get cleanGithubUrl {
    if (githubUrl.endsWith('.git')) {
      return githubUrl.substring(0, githubUrl.length - 4);
    }
    return githubUrl;
  }

  // 🎯 Obtener el usuario/organización del repositorio
  String get repoOwner {
    final uri = Uri.parse(githubUrl);
    final segments = uri.pathSegments;
    return segments.isNotEmpty ? segments[0] : 'unknown';
  }

  // 🎯 Obtener el nombre del repositorio
  String get repoName {
    final uri = Uri.parse(githubUrl);
    final segments = uri.pathSegments;
    if (segments.length >= 2) {
      String repoName = segments[1];
      if (repoName.endsWith('.git')) {
        repoName = repoName.substring(0, repoName.length - 4);
      }
      return repoName;
    }
    return 'unknown';
  }

  // 🎯 URL de la API de GitHub para obtener información adicional
  String get githubApiUrl {
    return 'https://api.github.com/repos/$repoOwner/$repoName';
  }

  // 🎯 URL de releases de GitHub
  String get githubReleasesUrl {
    return '$cleanGithubUrl/releases';
  }

  // 🎯 URL de issues de GitHub
  String get githubIssuesUrl {
    return '$cleanGithubUrl/issues';
  }

  // 🎯 Copiar al portapapeles
  Map<String, String> toClipboardData() {
    return {
      'name': name,
      'description': description,
      'githubUrl': cleanGithubUrl,
      'cloneCommand': gitCloneCommand,
      'installCommand': fullInstallCommand,
    };
  }

  // 🎯 Para debugging y logging
  @override
  String toString() {
    return 'RepoModel(name: $name, owner: $repoOwner, repo: $repoName, category: $category)';
  }

  // 🎯 Comparación para listas y sets
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepoModel &&
        other.name == name &&
        other.githubUrl == githubUrl;
  }

  @override
  int get hashCode => name.hashCode ^ githubUrl.hashCode;

  // 🎯 Copia con modificaciones
  RepoModel copyWith({
    String? name,
    String? description,
    String? scriptFile,
    String? readmeAsset,
    String? githubUrl,
    String? category,
    String? iconAsset,
  }) {
    return RepoModel(
      name: name ?? this.name,
      description: description ?? this.description,
      scriptFile: scriptFile ?? this.scriptFile,
      readmeAsset: readmeAsset ?? this.readmeAsset,
      githubUrl: githubUrl ?? this.githubUrl,
      category: category ?? this.category,
      iconAsset: iconAsset ?? this.iconAsset,
    );
  }

  // 🎯 Conversión a JSON para posible almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'scriptFile': scriptFile,
      'readmeAsset': readmeAsset,
      'githubUrl': githubUrl,
      'category': category,
      'iconAsset': iconAsset,
    };
  }

  // 🎯 Crear desde JSON
  factory RepoModel.fromJson(Map<String, dynamic> json) {
    return RepoModel(
      name: json['name'] as String,
      description: json['description'] as String,
      scriptFile: json['scriptFile'] as String,
      readmeAsset: json['readmeAsset'] as String,
      githubUrl: json['githubUrl'] as String,
      category: json['category'] as String,
      iconAsset: json['iconAsset'] as String,
    );
  }
}
