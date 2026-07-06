import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/model/todo.dart';

class HomeController extends AsyncNotifier<List<Todo>> {
  static final provider =
      AsyncNotifierProvider<HomeController, List<Todo>>(HomeController.new);

  @override
  Future<List<Todo>> build() => ref.watch(TodoRepository.provider).getTodos();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(TodoRepository.provider).getTodos(),
    );
  }
}
