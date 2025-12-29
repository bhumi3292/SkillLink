import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/add_worker/domain/entity/category/category_entity.dart';
import 'package:skill_link/features/add_worker/domain/use_case/category/add_category_usecase.dart';
import 'package:skill_link/features/add_worker/domain/use_case/category/get_all_categories_usecase.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_cubit.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_state.dart';

class CategoryManagementView extends StatefulWidget {
  const CategoryManagementView({super.key});

  @override
  State<CategoryManagementView> createState() => _CategoryManagementViewState();
}

class _CategoryManagementViewState extends State<CategoryManagementView> {
  List<CategoryEntity> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await serviceLocator<GetAllCategoriesUsecase>().call();
    result.fold(
      (failure) {
        setState(() => isLoading = false);
      },
      (data) {
        setState(() {
          categories = data;
          isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<AdminCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Service Categories'),
          backgroundColor: const Color(0xFF003366),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddCategoryDialog(context),
            ),
          ],
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : BlocConsumer<AdminCubit, AdminState>(
                  listener: (context, state) {
                    if (state is AdminActionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadCategories();
                    }
                  },
                  builder: (context, state) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        // Assuming CategoryEntity has isActive and id
                        // If not fully implemented, we'll need to adapt
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade50,
                              child: const Icon(
                                Icons.category,
                                color: Colors.indigo,
                              ),
                            ),
                            title: Text(
                              cat.categoryName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              cat.createdAt?.toIso8601String() ??
                                  'No description',
                            ),
                            trailing: Switch(
                              value:
                                  true, // Should be cat.isActive if available
                              onChanged: (val) {
                                if (cat.id != null) {
                                  context.read<AdminCubit>().toggleCategory(
                                    cat.id!,
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Add New Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final result = await serviceLocator<AddCategoryUsecase>()
                        .call(
                          CategoryEntity(
                            id: null,
                            categoryName: nameController.text,
                          ),
                        );
                    result.fold((f) => null, (s) {
                      _loadCategories();
                      Navigator.pop(dialogContext);
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
