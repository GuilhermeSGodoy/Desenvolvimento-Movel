import 'dart:io';
import 'dart:convert';

class Task {
  bool? readFromInput;
  bool? showLineNumbers;
  List<String>? paths;

  Task(this.readFromInput, this.showLineNumbers, this.paths);

  Future<void> dcat(String Function(String txt) log) async {
    exitCode = 0;

    if (readFromInput ?? false) {
      await stdin.pipe(stdout);
    } else {
      for (final path in paths ?? []) {
        var lineNumber = 1;
        final lines = utf8.decoder
            .bind(File(path).openRead())
            .transform(const LineSplitter());
        try {
          await for (final line in lines) {
            if (showLineNumbers ?? false) {
              stdout.write('${lineNumber++} ');
            }
            stdout.writeln(line);
          }
        } catch (_) {
          await _handleError(path);
        }
      }
    }
  }

  Future<void> _handleError(String path) async {
    if (await FileSystemEntity.isDirectory(path)) {
      stderr.writeln('error: $path is a directory');
    } else {
      exitCode = 2;
    }
  }
}
