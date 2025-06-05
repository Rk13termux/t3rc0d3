// 📁 lib/utils/file_helper.dart

import 'dart:io';
import 'package:flutter/services.dart';

Future<String> guardarYCopiarScript(String repoName, String assetPath) async {
  final contenido = await rootBundle.loadString(assetPath);
  const dir = '/storage/emulated/0/Download';
  final scriptName = 'rk13_${repoName.toLowerCase()}';
  final downloadPath = '$dir/$scriptName.sh';

  final scriptFile = File(downloadPath);
  await scriptFile.writeAsString('''#!/data/data/com.termux/files/usr/bin/bash
$contenido
echo "\u2705 Instalaci\u00f3n $repoName finalizada" >> $dir/rk13_logs.txt
''');

  final bootPath =
      '/data/data/com.termux/files/home/.termux/boot/start_$scriptName.sh';

  await Process.run('sh', [
    '-c',
    '''
cp "$downloadPath" "$bootPath"
chmod +x "$bootPath"
'''
  ]);

  return bootPath;
}
