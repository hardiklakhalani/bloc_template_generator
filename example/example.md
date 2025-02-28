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
