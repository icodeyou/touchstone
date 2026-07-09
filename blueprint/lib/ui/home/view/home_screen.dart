import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
import 'package:touchstone/core/app/i18n/translations.g.dart';
import 'package:touchstone/data/repository/preferences_repository.dart';
import 'package:touchstone/domain/model/todo.dart';
import 'package:touchstone/ui/home/controller/home_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showWelcomeDialog());
  }

  Future<void> _showWelcomeDialog() async {
    final preferences = ref.read(PreferencesRepository.provider);
    if (!mounted || preferences.welcomeMessageSeen) {
      return;
    }
    final confirmed = await Notif.showPopup(
      context: context,
      title: t.welcomeDialog.title,
      content: AppText.m(t.welcomeDialog.message),
      confirmButtonText: t.welcomeDialog.ok,
    );
    if (confirmed) {
      preferences.markWelcomeMessageSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosState = ref.watch(HomeController.provider);

    return Scaffold(
      appBar: AppBar(
        title: AppText.l(t.homeScreen.todosTitle, bold: true),
      ),
      body: todosState.when(
        data: (todos) => todos.isEmpty
            ? Center(child: AppText.m(t.homeScreen.emptyTodos))
            : _TodoList(todos: todos),
        error: (error, stackTrace) => _ErrorView(
          onRetry: () => ref.read(HomeController.provider.notifier).refresh(),
        ),
        loading: () => const Center(child: AppLoader.regular()),
      ),
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({required this.todos});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: todos.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final todo = todos[index];
        final isCompleted = todo.status == TodoStatus.completed;
        return ListTile(
          contentPadding: ThemeSizes.sym(h: ThemeSizes.m, v: ThemeSizes.xxs),
          title: AppText.m(todo.title),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color:
                isCompleted ? ThemeColors.statusSuccess : ThemeColors.grey40,
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.m(t.homeScreen.loadError),
          const AppGap.m(),
          AppButton.primary(onPressed: onRetry, label: t.common.retry),
        ],
      ),
    );
  }
}
