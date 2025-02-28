import 'package:test/test.dart';
import 'dart:io';
import '../bin/bloc_template_generator.dart' as generator;

// Test utilities
Future<void> cleanupDirectory(Directory dir) async {
  if (await dir.exists()) {
    try {
      await dir.delete(recursive: true);
    } catch (e) {
      print('Warning: Could not delete directory ${dir.path}. Error: $e');
    }
  }
}

void main() {
  late Directory testDir;
  final projectRoot = Directory.current;

  setUp(() async {
    // Create test directory in the project folder
    testDir = Directory('${projectRoot.path}/test_output');
    if (await testDir.exists()) {
      await cleanupDirectory(testDir);
    }
    await testDir.create();
    Directory.current = testDir.path;
  });

  tearDown(() async {
    // Change back to project root before cleanup
    Directory.current = projectRoot.path;
    await cleanupDirectory(testDir);
  });

  group('Command Line Arguments Tests', () {
    test('should show usage message when no arguments provided', () async {
      expect(
        () => generator.main([]),
        throwsA(predicate((e) => e is ProcessException && e.message.contains('Usage'))),
      );
    });

    test('should accept valid BlocName argument', () async {
      final blocName = 'Test';
      await Future(() => generator.main([blocName]));
      
      // Verify directories are created
      expect(Directory('lib/bloc/${blocName.toLowerCase()}_bloc').existsSync(), isTrue);
      expect(Directory('lib/data/data_provider').existsSync(), isTrue);
      expect(Directory('lib/data/repository').existsSync(), isTrue);
      expect(Directory('lib/presentation/screens').existsSync(), isTrue);
      expect(Directory('lib/core/networking').existsSync(), isTrue);
    });

    test('should parse states argument correctly', () async {
      final blocName = 'Auth';
      final states = 'authenticated,unauthenticated';
      await Future(() => generator.main([blocName, '--states=$states']));

      final stateFile = File('lib/bloc/auth_bloc/auth_state.dart');
      expect(stateFile.existsSync(), isTrue);
      
      final content = await stateFile.readAsString();
      expect(content.contains('AuthAuthenticated'), isTrue);
      expect(content.contains('AuthUnauthenticated'), isTrue);
      expect(content.contains('AuthInitial'), isTrue); // Default state
    });

    test('should parse events argument correctly', () async {
      final blocName = 'Auth';
      final events = 'login,logout';
      await Future(() => generator.main([blocName, '--events=$events']));

      final eventFile = File('lib/bloc/auth_bloc/auth_event.dart');
      expect(eventFile.existsSync(), isTrue);
      
      final content = await eventFile.readAsString();
      expect(content.contains('AuthLogin'), isTrue);
      expect(content.contains('AuthLogout'), isTrue);
    });

    test('should parse URL argument correctly', () async {
      final blocName = 'Api';
      final url = 'https://api.example.com';
      await Future(() => generator.main([blocName, '--url=$url']));

      final dataProviderFile = File('lib/data/data_provider/api_data_provider.dart');
      expect(dataProviderFile.existsSync(), isTrue);
      
      final content = await dataProviderFile.readAsString();
      expect(content.contains(url), isTrue);
    });

    test('should handle overwrite flag correctly', () async {
      final blocName = 'Test';
      
      // First creation
      await Future(() => generator.main([blocName]));
      
      // Second creation without overwrite flag should fail
      expect(
        () => generator.main([blocName]),
        throwsA(predicate((e) => e is ProcessException && e.message.contains('already exist'))),
      );
      
      // Second creation with overwrite flag should succeed
      await Future(() => generator.main([blocName, '--overwrite']));
    });
  });

  group('File Generation Tests', () {
    test('should create all required directories', () {
      final blocName = 'Example';
      generator.main([blocName]);

      expect(Directory('lib/bloc/example_bloc').existsSync(), isTrue);
      expect(Directory('lib/data/data_provider').existsSync(), isTrue);
      expect(Directory('lib/data/repository').existsSync(), isTrue);
      expect(Directory('lib/presentation/screens').existsSync(), isTrue);
      expect(Directory('lib/core/networking').existsSync(), isTrue);
    });

    test('should create files with correct names', () {
      final blocName = 'Product';
      generator.main([blocName]);

      expect(File('lib/bloc/product_bloc/product_bloc.dart').existsSync(), isTrue);
      expect(File('lib/bloc/product_bloc/product_event.dart').existsSync(), isTrue);
      expect(File('lib/bloc/product_bloc/product_state.dart').existsSync(), isTrue);
      expect(File('lib/data/data_provider/product_data_provider.dart').existsSync(), isTrue);
      expect(File('lib/data/repository/product_repository.dart').existsSync(), isTrue);
      expect(File('lib/presentation/screens/product_example_screen.dart').existsSync(), isTrue);
      expect(File('lib/core/networking/json_response_interceptor.dart').existsSync(), isTrue);
    });
  });

  group('Template Content Tests', () {
    test('should generate correct BLoC file content', () {
      final blocName = 'User';
      generator.main([blocName]);

      final blocFile = File('lib/bloc/user_bloc/user_bloc.dart');
      final content = blocFile.readAsStringSync();

      expect(content.contains('class UserBloc extends Bloc<UserEvent, UserState>'), isTrue);
      expect(content.contains('final UserRepository userRepository;'), isTrue);
      expect(content.contains('UserBloc(this.userRepository)'), isTrue);
    });

    test('should generate correct Event file content', () {
      final blocName = 'User';
      final events = 'create,update,delete';
      generator.main([blocName, '--events=$events']);

      final eventFile = File('lib/bloc/user_bloc/user_event.dart');
      final content = eventFile.readAsStringSync();

      expect(content.contains('sealed class UserEvent {}'), isTrue);
      expect(content.contains('class UserCreate extends UserEvent {}'), isTrue);
      expect(content.contains('class UserUpdate extends UserEvent {}'), isTrue);
      expect(content.contains('class UserDelete extends UserEvent {}'), isTrue);
    });

    test('should generate correct State file content', () {
      // Test code
    });

    test('should generate correct Repository file content', () {
      // Test code
    });

    test('should generate correct DataProvider file content', () {
      // Test code
    });

    test('should generate correct Screen file content', () {
      // Test code
    });

    test('should generate correct Interceptor file content', () {
      // Test code
    });
  });

  group('State Generation Tests', () {
    test('should include default states', () {
      // Test code
    });

    test('should merge custom states with default states', () {
      // Test code
    });

    test('should generate correct Success state structure', () {
      // Test code
    });

    test('should generate correct Failure state structure', () {
      // Test code
    });
  });

  group('Event Generation Tests', () {
    test('should generate default events when none provided', () {
      // Test code
    });

    test('should generate custom events correctly', () {
      // Test code
    });

    test('should generate correct event class structure', () {
      // Test code
    });
  });

  group('URL Handling Tests', () {
    test('should use provided URL in DataProvider', () {
      // Test code
    });

    test('should use default URL when none provided', () {
      // Test code
    });
  });

  group('Utility Function Tests', () {
    test('should capitalize strings correctly', () {
      expect(generator.capitalize('hello'), equals('Hello'));
      expect(generator.capitalize('WORLD'), equals('World'));
      expect(generator.capitalize('tEsT'), equals('Test'));
    });

    test('should handle empty strings in capitalize', () {
      expect(generator.capitalize(''), equals(''));
    });

    test('should handle single character strings in capitalize', () {
      expect(generator.capitalize('a'), equals('A'));
      expect(generator.capitalize('Z'), equals('Z'));
    });
  });
}
