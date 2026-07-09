import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
import 'package:touchstone/core/app/i18n/translations.g.dart';
import 'package:touchstone/core/theme/app_colors.dart';
import 'package:touchstone/data/local/app_preferences.dart';
import 'package:touchstone/domain/model/todo.dart';
import 'package:touchstone/ui/home/controller/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _showWelcomeDialog(BuildContext context, WidgetRef ref) async {
    final preferences = ref.read(AppPreferences.provider);
    if (await preferences.welcomeMessageSeen) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final confirmed = await Notif.showPopup(
      context: context,
      title: t.welcomeDialog.title,
      content: AppText.m(t.welcomeDialog.message),
      confirmButtonText: t.common.ok,
    );
    if (confirmed) {
      await preferences.markWelcomeMessageSeen();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosState = ref.watch(HomeController.provider);

    return Init(
      onInitPostFrame: () => _showWelcomeDialog(context, ref),
      child: Scaffold(
        appBar: AppBar(title: AppText.l(t.homeScreen.todosTitle, bold: true)),
        body: Padding(
          padding: ThemeSizes.m.asInsets,
          child: Column(
            children: [
              const _CreateTodoField(),
              const AppGap.m(),
              Expanded(
                child: todosState.when(
                  data: (todos) => todos.isEmpty
                      ? Center(child: AppText.m(t.homeScreen.emptyTodos))
                      : _TodoList(todos: todos),
                  error: (error, stackTrace) => _ErrorView(
                    onRetry: () =>
                        ref.read(HomeController.provider.notifier).refresh(),
                  ),
                  loading: () => const Center(child: AppLoader.regular()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateTodoField extends ConsumerStatefulWidget {
  const _CreateTodoField();

  @override
  ConsumerState<_CreateTodoField> createState() => _CreateTodoFieldState();
}

class _CreateTodoFieldState extends ConsumerState<_CreateTodoField> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = t.homeScreen.createTodoEmptyError);
      return;
    }
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
    await ref
        .read(myMutationControllerProvider(hashCode).notifier)
        .action<void>(
          mutation: () =>
              ref.read(HomeController.provider.notifier).createTodo(title),
          onSuccess: (_) => _onCreateSuccess(),
        );
  }

  void _onCreateSuccess() {
    final hasError = ref.read(HomeController.provider).hasError;
    if (!mounted) {
      return;
    }
    if (hasError) {
      Notif.showToast(
        context: context,
        title: t.common.error,
        message: t.homeScreen.loadError,
        type: ToastType.error,
      );
    } else {
      _controller.clear();
      Notif.showToast(
        context: context,
        title: t.common.success,
        message: t.homeScreen.todoCreated,
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(myMutationControllerProvider(hashCode)) ==
        MutationState.loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          enabled: !isLoading,
          onChanged: (_) {
            if (_errorText != null) {
              setState(() => _errorText = null);
            }
          },
          decoration: InputDecoration(
            hintText: t.homeScreen.createTodoHint,
            errorText: _errorText,
            border: OutlineInputBorder(
              borderRadius: ThemeRadius.m.asBorderRadius,
              borderSide: BorderSide(color: ThemeColors.secondary(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: ThemeRadius.m.asBorderRadius,
              borderSide: BorderSide(color: ThemeColors.secondary(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ThemeRadius.m.asBorderRadius,
              borderSide: BorderSide(
                color: ThemeColors.secondary(context),
                width: 2,
              ),
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const AppGap.s(),
        if (isLoading)
          Center(
            child: CircularProgressIndicator(
              color: ThemeColors.secondary(context),
            ),
          )
        else
          AppButton(
            buttonType: ButtonType.primary,
            expand: true,
            label: t.homeScreen.addItem,
            color: ThemeColors.secondary(context),
            fontColor: ThemeColors.onSecondary(context),
            onPressed: _submit,
          ),
      ],
    );
  }
}

class _TodoList extends ConsumerWidget {
  const _TodoList({required this.todos});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount: todos.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final todo = todos[index];
        final isCompleted = todo.status == TodoStatus.completed;
        final mutationState = ref.watch(myMutationControllerProvider(todo.id));
        return ListTile(
          contentPadding: ThemeSizes.sym(h: ThemeSizes.m, v: ThemeSizes.xxs),
          title: AppText.m(
            todo.title,
            color: isCompleted ? AppColors.grey : null,
            textDecoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
          onTap: mutationState == MutationState.loading
              ? null
              : () => _onTodoTap(context, ref, todo),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? ThemeColors.statusSuccess : ThemeColors.grey40,
          ),
        );
      },
    );
  }

  void _onTodoTap(BuildContext context, WidgetRef ref, Todo todo) {
    ref
        .read(myMutationControllerProvider(todo.id).notifier)
        .action<void>(
          mutation: () =>
              ref.read(HomeController.provider.notifier).toggleTodo(todo),
          onError: () {
            if (!context.mounted) {
              return;
            }
            Notif.showToast(
              context: context,
              title: t.common.error,
              message: t.homeScreen.todoUpdateError,
              type: ToastType.error,
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
