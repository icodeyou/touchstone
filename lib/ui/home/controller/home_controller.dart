import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/model/todo.dart';

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, List<Todo>>(HomeController.new);

class HomeController extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() => ref.watch(todoRepositoryProvider).getTodos();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(todoRepositoryProvider).getTodos(),
    );
  }
}
