import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_cubit.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_state.dart';

class UserDirectoryView extends StatelessWidget {
  const UserDirectoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<AdminCubit>()..fetchAllUsers(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Directory'),
          backgroundColor: const Color(0xFF1A237E),
        ),
        body: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state is AdminActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<dynamic> users = [];
            if (state is AdminUsersLoaded) {
              users = state.users;
            }

            if (users.isEmpty) {
              return const Center(child: Text('No users found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserCard(context, user);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, dynamic user) {
    final bool isSuspended = user['isSuspended'] ?? false;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user['fullName']?[0] ?? 'U'),
        ),
        title: Text(user['fullName'] ?? 'No Name'),
        subtitle: Text('${user['email']}\nRole: ${user['role']}'),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () {
            context.read<AdminCubit>().toggleUserSuspension(user['_id']);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSuspended ? Colors.green : Colors.red,
          ),
          child: Text(isSuspended ? 'Reinstate' : 'Suspend'),
        ),
      ),
    );
  }
}
