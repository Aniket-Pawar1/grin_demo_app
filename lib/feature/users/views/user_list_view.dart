import 'package:flutter/material.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_list_viewmodel.dart';
import 'widgets/user_card.dart';

class UserListView extends StatefulWidget {
  final AuthViewModel authViewModel;

  const UserListView({super.key, required this.authViewModel});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  late final UserListViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = UserListViewModel();
    _viewModel.addListener(_handleViewModelUpdate);
    _viewModel.fetchInitialUsers();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelUpdate);
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleViewModelUpdate() {
    if (mounted && _viewModel.users.isNotEmpty && _viewModel.hasMore && !_viewModel.isLoadingMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fillViewportIfNeeded());
    }
  }

  void _fillViewportIfNeeded() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 50 && _viewModel.hasMore && !_viewModel.isLoadingMore) {
      _viewModel.fetchNextPage();
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= (position.maxScrollExtent - 100)) {
      if (_viewModel.hasMore && !_viewModel.isLoadingMore) {
        _viewModel.fetchNextPage();
      }
    }
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.authViewModel.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Users Directory',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: Colors.red,),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isInitialLoading) {
            return _buildInitialLoading();
          }

          if (_viewModel.errorMessage != null && _viewModel.users.isEmpty) {
            return _buildErrorState(theme, colorScheme);
          }

          if (_viewModel.isEmpty) {
            return _buildEmptyState(colorScheme);
          }

          return _buildUserList(theme, colorScheme);
        },
      ),
    );
  }

  Widget _buildInitialLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading users...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load users',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _viewModel.fetchInitialUsers,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          const Text('No users found'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _viewModel.refreshUsers,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(ThemeData theme, ColorScheme colorScheme) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >= (scrollInfo.metrics.maxScrollExtent - 100)) {
          if (_viewModel.hasMore && !_viewModel.isLoadingMore) {
            _viewModel.fetchNextPage();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _viewModel.refreshUsers,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: _viewModel.users.length + 1,
          itemBuilder: (context, index) {
            if (index < _viewModel.users.length) {
              return UserCard(user: _viewModel.users[index]);
            }
            return _buildFooter(theme, colorScheme);
          },
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: _viewModel.isLoadingMore
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  SizedBox(width: 12),
                  Text('Loading more users...'),
                ],
              )
            : _viewModel.hasMore
                ? const SizedBox(height: 16)
                : Text(
                    'All ${_viewModel.totalUsers} users loaded',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
      ),
    );
  }
}
