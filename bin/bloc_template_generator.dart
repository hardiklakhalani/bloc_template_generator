import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    throw ProcessException(
      'bloc_template_generator',
      [],
      'Usage: bloc_template_generator <BlocName> [--states=state1,state2] [--events=event1,event2] [--url=backend_url]'
    );
  }

  final blocName = arguments[0];
  String? statesInput, eventsInput, baseUrl;
  final bool shouldOverwrite = arguments.contains('--overwrite');

  for (var arg in arguments.skip(1)) {
    if (arg.startsWith('--states=')) {
      statesInput = arg.split('=')[1];
    } else if (arg.startsWith('--events=')) {
      eventsInput = arg.split('=')[1];
    } else if (arg.startsWith('--url=')) {
      baseUrl = arg.split('=')[1];
    }
  }


  // Default states and events if none provided
  final defaultStates = ['Initial', 'Loading', 'Failure', 'Success'];
  final defaultEvents = ['ExampleGet', 'ExamplePost'];

  final states = (statesInput?.split(',').map(capitalize).toList() ?? []) + defaultStates;
  final events = eventsInput?.split(',').map(capitalize).toList() ?? defaultEvents;

  generateBlocFiles(blocName, states, events, baseUrl, shouldOverwrite);
}

void generateBlocFiles(String blocName, List<String> states, List<String> events, String? baseUrl, bool shouldOverwrite) {
  final blocDir = Directory('lib/bloc/${blocName.toLowerCase()}_bloc');
  final dataProviderDir = Directory('lib/data/data_provider');
  final repositoryDir = Directory('lib/data/repository');
  final presentationDir = Directory('lib/presentation/screens');
  final interceptorDir = Directory('lib/core/networking');

  for (var dir in [blocDir, dataProviderDir, repositoryDir, presentationDir, interceptorDir]) {
    if (!dir.existsSync()) dir.createSync(recursive: true);
  }

  final blocFile = File('${blocDir.path}/${blocName.toLowerCase()}_bloc.dart');
  final eventFile = File('${blocDir.path}/${blocName.toLowerCase()}_event.dart');
  final stateFile = File('${blocDir.path}/${blocName.toLowerCase()}_state.dart');
  final dataProviderFile = File('${dataProviderDir.path}/${blocName.toLowerCase()}_data_provider.dart');
  final repositoryFile = File('${repositoryDir.path}/${blocName.toLowerCase()}_repository.dart');
  final interceptorFile = File('${interceptorDir.path}/json_response_interceptor.dart');
  final screenFile = File('${presentationDir.path}/${blocName.toLowerCase()}_example_screen.dart');
  
  // Check for pre existing files, if they exist, ask the user to rerun the command with --overwrite flag
  if (blocFile.existsSync() || eventFile.existsSync() || stateFile.existsSync() || dataProviderFile.existsSync() || repositoryFile.existsSync() || interceptorFile.existsSync() || screenFile.existsSync()) {
    if (!shouldOverwrite) {
      throw ProcessException(
        'bloc_template_generator',
        [blocName],
        'One or more files for "$blocName" template already exist!\nTo overwrite, run the same command with the --overwrite flag'
      );
    }
  }

  // Write template files
  blocFile.writeAsStringSync(generateBlocTemplate(blocName, events));
  eventFile.writeAsStringSync(generateEventTemplate(blocName, events));
  stateFile.writeAsStringSync(generateStateTemplate(blocName, states));
  dataProviderFile.writeAsStringSync(generateDataProviderTemplate(blocName, baseUrl));
  repositoryFile.writeAsStringSync(generateRepositoryTemplate(blocName));
  screenFile.writeAsStringSync(generateScreenTemplate(blocName));
  interceptorFile.writeAsStringSync(generateInterceptorTemplate());

  print('✅ BLoC template for "$blocName" created successfully!');
}

String generateBlocTemplate(String blocName, List<String> events) => '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/${blocName.toLowerCase()}_repository.dart';

part '${blocName.toLowerCase()}_event.dart';
part '${blocName.toLowerCase()}_state.dart';

class ${blocName}Bloc extends Bloc<${blocName}Event, ${blocName}State> {
  final ${blocName}Repository ${blocName.toLowerCase()}Repository;

  ${blocName}Bloc(this.${blocName.toLowerCase()}Repository) : super(${blocName}Initial()) {
    ${events.map((e) => "on<$blocName$e>(_handle$e);").join("\n    ")}
  }

  ${events.map((e) => '''
  void _handle$e($blocName$e event, Emitter<${blocName}State> emit) async {
    emit(${blocName}Loading());
    try {
      final data = await ${blocName.toLowerCase()}Repository.fetchData();
      emit(${blocName}Success(data));
    } catch (e) {
      emit(${blocName}Failure(e.toString()));
    }
  }
  ''').join("\n")}
}
''';

String generateEventTemplate(String blocName, List<String> events) => '''
part of '${blocName.toLowerCase()}_bloc.dart';

sealed class ${blocName}Event {}

${events.map((e) => "class $blocName$e extends ${blocName}Event {}").join("\n")}
''';

String generateStateTemplate(String blocName, List<String> states) => '''
part of '${blocName.toLowerCase()}_bloc.dart';

sealed class ${blocName}State {}

${states.map((state) {
  final String StateName = '$blocName${capitalize(state)}';
  switch (state.toLowerCase()) {
    case 'success':
      return '''
final class $StateName extends ${blocName}State {
  final dynamic data;
  $StateName(this.data);
}\n
      ''';
    case 'failure':
      return '''
final class $StateName extends ${blocName}State {
  final String message;
  $StateName(this.message);
}\n
      ''';
    default:
  return "final class $StateName extends ${blocName}State {}\n";
  }
}).join("\n")}
''';

String generateDataProviderTemplate(String blocName, String? baseUrl) => '''
import 'package:dio/dio.dart';

import '../../core/networking/json_response_interceptor.dart';

class ${blocName}DataProvider {
  final _dio = Dio()
    ..options.baseUrl = "${baseUrl ?? 'https://example.com'}"
    ..options.contentType = "application/json"
    ..options.connectTimeout = const Duration(seconds: 30)
    ..interceptors.add(JsonResponseInterceptor());

  Future<String> fetchData() async {
    try {
      final res = await _dio.get('/');
      return res.data.toString();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
''';

String generateRepositoryTemplate(String blocName) => '''
import '../data_provider/${blocName.toLowerCase()}_data_provider.dart';

class ${blocName}Repository {
  final ${blocName}DataProvider ${blocName.toLowerCase()}DataProvider;

  ${blocName}Repository(this.${blocName.toLowerCase()}DataProvider);

  Future<dynamic> fetchData() async {
    return await ${blocName.toLowerCase()}DataProvider.fetchData();
  }
}
''';

String generateScreenTemplate(String blocName) => '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/${blocName.toLowerCase()}_bloc/${blocName.toLowerCase()}_bloc.dart';

class ${blocName}ExampleScreen extends StatelessWidget {
  const ${blocName}ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<${blocName}Bloc, ${blocName}State>(
        builder: (context, state) {
          if (state is ${blocName}Loading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ${blocName}Success) {
            return Text('Data loaded');
          } else if (state is ${blocName}Failure) {
            return Text('Error: \${(state as ${blocName}Failure).message}');
          }
          return SizedBox();
        },
      ),
    );
  }
}
''';

String generateInterceptorTemplate() => '''
import 'dart:convert';

import 'package:dio/dio.dart';

class JsonResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      response.data = json.encode(response.data);
    } catch (e) {
      handler.reject(DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: "Failed to encode response: \$e",
      ));
      return;
    }
    handler.next(response);
  }
}
''';

String capitalize(String input) {
  if (input.isEmpty) return '';
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}
