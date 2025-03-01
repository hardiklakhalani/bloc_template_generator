# BLoC Template Generator
[![Dart](https://github.com/hardiklakhalani/bloc_template_generator/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/hardiklakhalani/bloc_template_generator/actions/workflows/dart.yml)
## What it does?
BLoC Template Generator is a Dart-based CLI tool that generates a structured BLoC pattern boilerplate for Flutter applications, including networking code which uses [Dio](https://pub.dev/packages/dio). It simplifies BLoC creation by generating the necessary files and folder structure based on user input.

> This is purely made with Dart 3 (>=3.0.0 < 4.0.0) without any dependencies.

## How to use?
### **1️⃣ Install the tool globally**
Run the following command inside your project directory:
```sh
dart pub global activate bloc_template_generator
```
Ensure Dart's global bin path is added to your system's environment variables.

### **2️⃣ Generate a new BLoC template**
Run the CLI command with the necessary parameters:
```sh
bloc_template_generator <BlocName> [--states=state1,state2] [--events=event1,event2] [--url=backend_url]
```
- `<BlocName>`: The name of the BLoC (e.g., `Auth`, `Products`).
- `--states`: (Optional) Comma-separated list of custom states. Default states (`initial, loading, failure, success`) are included.
- `--events`: (Optional) Comma-separated list of custom events. Default example events (`ExampleGet, ExamplePost`) are included, and will be skipped if you add yours.
- `--url`: (Optional) Backend base URL for API calls. Example: `https://example.com`
- `--overwrite`: (Optional) Overwrite existing files.

## Example
```sh
bloc_template_generator Auth --states=authenticated,unauthenticated --events=login,logout --url=https://api.example.com
```
This will generate the following structure inside the `lib` directory:
```
lib/
 ├── bloc/
 │   ├── auth_bloc/
 │   │   ├── auth_bloc.dart
 │   │   ├── auth_event.dart
 │   │   ├── auth_state.dart
 ├── data/
 │   ├── data_provider/
 │   │   ├── auth_data_provider.dart
 │   ├── repository/
 │   │   ├── auth_repository.dart
 ├── presentation/
 │   ├── screens/
 │   │   ├── auth_example_screen.dart
```

## Todos
- [x] Basic BLoC boilerplate generation
- [ ] File conflicts handling

