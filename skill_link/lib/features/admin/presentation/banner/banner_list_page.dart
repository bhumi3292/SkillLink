import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_cubit.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_state.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'banner_form_page.dart';
import 'package:skill_link/features/banner/data/models/banner_model.dart';

class AdminBannerListPage extends StatefulWidget {
  const AdminBannerListPage({super.key});

  @override
  State<AdminBannerListPage> createState() => _AdminBannerListPageState();
}

class _AdminBannerListPageState extends State<AdminBannerListPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().fetchAllBanners();
  }

  void _load() {
    context.read<AdminCubit>().fetchAllBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banners Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final adminCubit = context.read<AdminCubit>();
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BlocProvider.value(
                              value: adminCubit,
                              child: const AdminBannerFormPage(),
                            ),
                      ),
                    );
                    if (res == true) _load();
                  },
                  child: const Text('Create Banner'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _load, child: const Text('Refresh')),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                if (state is AdminBannerActionSuccess) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
                if (state is AdminError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AdminBannersLoaded) {
                  final banners = state.banners;
                  if (banners.isEmpty) {
                    return const Center(child: Text('No banners yet'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: banners.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final b = banners[idx] as Map<String, dynamic>;
                      final imageUrl =
                          (b['imageUrl'] as String).startsWith('http')
                              ? b['imageUrl'] as String
                              : '${ApiEndpoints.imageUrl}${b['imageUrl'] as String}';
                      final start =
                          DateTime.tryParse(b['startDate'] ?? '') ??
                          DateTime.now();
                      final end =
                          DateTime.tryParse(b['endDate'] ?? '') ??
                          DateTime.now();
                      final now = DateTime.now();
                      final status =
                          !end.isAfter(now)
                              ? 'Expired'
                              : ((b['isActive'] ?? true)
                                  ? 'Active'
                                  : 'Disabled');
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: SizedBox(
                            width: 80,
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                          title: Text(b['title'] ?? ''),
                          subtitle: Text(
                            '${start.toLocal()} → ${end.toLocal()}\n$status',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              final adminCubit = context.read<AdminCubit>();
                              if (v == 'edit') {
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => BlocProvider.value(
                                          value: adminCubit,
                                          child: AdminBannerFormPage(
                                            banner: BannerModel.fromJson(
                                              b,
                                            ),
                                          ),
                                        ),
                                  ),
                                );
                                if (res == true) _load();
                              } else if (v == 'delete') {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text('Confirm'),
                                        content: const Text(
                                          'Soft-delete this banner?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                );
                                if (ok == true) {
                                  context.read<AdminCubit>().deleteBanner(
                                    b['_id'] as String,
                                  );
                                }
                              }
                            },
                            itemBuilder:
                                (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
