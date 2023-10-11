import 'package:args/args.dart';

/// Copied directly from https://github.com/dart-lang/sdk/blob/96ae2c3cadea68bf904e6da83d70453786025d2a/pkg/analyzer_cli/lib/src/options.dart#L207

/// Return a list of command-line arguments containing all of the given [args]
/// that are defined by the given [parser]. An argument is considered to be
/// defined by the parser if
/// - it starts with '--' and the rest of the argument (minus any value
///   introduced by '=') is the name of a known option,
/// - it starts with '-' and the rest of the argument (minus any value
///   introduced by '=') is the name of a known abbreviation, or
/// - it starts with something other than '--' or '-'.
///
/// This function allows command-line tools to implement the
/// '--ignore-unrecognized-flags' option.
List<String> filterUnknownArguments(List<String> args, ArgParser parser) {
  final knownOptions = <String>{};
  final knownAbbreviations = <String>{};
  parser.options.forEach((String name, Option option) {
    knownOptions.add(name);
    final abbreviation = option.abbr;
    if (abbreviation != null) {
      knownAbbreviations.add(abbreviation);
    }
    if (option.negatable ?? false) {
      knownOptions.add('no-$name');
    }
  });

  String optionName(int prefixLength, String argument) {
    final equalsOffset = argument.lastIndexOf('=');
    if (equalsOffset < 0) {
      return argument.substring(prefixLength);
    }
    return argument.substring(prefixLength, equalsOffset);
  }

  final filtered = <String>[];
  for (var i = 0; i < args.length; i++) {
    final argument = args[i];
    if (argument.startsWith('--') && argument.length > 2) {
      if (knownOptions.contains(optionName(2, argument))) {
        filtered.add(argument);
      }
    } else if (argument.startsWith('-D') && argument.indexOf('=') > 0) {
      filtered.add(argument);
    }
    if (argument.startsWith('-') && argument.length > 1) {
      if (knownAbbreviations.contains(optionName(1, argument))) {
        filtered.add(argument);
      }
    } else {
      filtered.add(argument);
    }
  }
  return filtered;
}
