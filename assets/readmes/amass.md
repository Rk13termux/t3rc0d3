# 🔍 AMASS - Herramienta de Reconocimiento

![Amass Logo](https://raw.githubusercontent.com/OWASP/Amass/master/images/amass_logo.png)

## 📌 Información General

| Detalle | Descripción |
|---------|-------------|
| **Desarrollador** | OWASP Foundation |
| **Versión** | 3.23.3 |
| **GitHub** | [OWASP/Amass](https://github.com/OWASP/Amass) |
| **Documentación** | [Wiki Oficial](https://github.com/OWASP/Amass/blob/master/doc/user_guide.md) |
| **Tipo** | Herramienta de Reconocimiento |

## 💡 Descripción
Amass es una herramienta robusta diseñada para realizar mapeo de redes y descubrimiento de activos externos. Utiliza técnicas de reconocimiento y minería de datos para identificar subdominios y activos relacionados con un dominio objetivo.

## 🛠️ Características Principales
- Enumeración de subdominios
- Escaneo pasivo y activo
- Integración con múltiples fuentes de datos
- Generación de informes detallados
- Visualización de resultados

## 📚 Ejemplos de Uso

### Enumeración básica
```bash
amass enum -d dominio.com
```

### Enumeración pasiva
```bash
amass enum -passive -d dominio.com -o resultados.txt
```

### Escaneo avanzado
```bash
amass intel -addr 192.168.1.1/24
```

## 📊 Estructura de Salida
```plaintext
example.dominio.com      [A] 192.168.1.10
api.dominio.com         [CNAME] -> cdn.dominio.com
mail.dominio.com        [MX] -> mailserver.dominio.com
```

## ⚠️ Advertencias
- Usar responsablemente
- Algunas funciones requieren privilegios elevados
- Respetar políticas de uso de APIs de terceros

## 🤝 Contribución
Las contribuciones son bienvenidas. Por favor, revisa las guías de contribución en el repositorio oficial.

## 📜 Licencia
Apache License 2.0

