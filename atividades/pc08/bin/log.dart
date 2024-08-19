import 'package:args/args.dart';
import 'dcat.dart';

const lineNumber = 'line-number';
var logs = <String>[];

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addFlag(lineNumber, negatable: false, abbr: 'n');
  ArgResults argResults = parser.parse(arguments);
  final paths = argResults.rest;

  final readFromInput = paths.isEmpty;

  final task = Task(readFromInput, argResults[lineNumber], paths);

  await task.dcat(log);

  Iterable<String> upperCaseLogs = logs.map((t) => t.toUpperCase());
  print("All uppercase logs:");
  for (var e in upperCaseLogs) {
    print(e);
  }

  Iterable<LogItem> detailedLogs = logs.map((t) {
    var splitted = t.split(' : ');
    var datetime = splitted[0];
    var text = splitted[1];
    return LogItem(text, DateTime.parse(datetime));
  });

  for (var element in detailedLogs) {
    print(element.toString());
  }
}

String log(String txt) {
  String logTxt = "${DateTime.now().toString()} : $txt";
  logs.add(logTxt);
  return logTxt;
}

class LogItem {
  final String text;
  final DateTime date;
  LogItem(this.text, this.date);

  @override
  String toString() {
    return "Log item:\n"
        "   Text: $text\n"
        "   Time: ${date.minute}:${date.second}";
  }
}
