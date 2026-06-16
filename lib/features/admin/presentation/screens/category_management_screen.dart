import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../../../home/domain/entities/category_entity.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoaded) {
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.color,
                    child: Icon(category.icon, color: Colors.white),
                  ),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showCategoryDialog(context, category: category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => context.read<AdminCubit>().deleteCategory(category.id),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryEntity? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final iconController = TextEditingController(text: 'grid_view_rounded'); // Default
    final colorController = TextEditingController(text: '#1A1A1A'); // Default

    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: iconController, decoration: const InputDecoration(labelText: 'Icon Name (e.g. backpack_rounded)')),
            TextField(controller: colorController, decoration: const InputDecoration(labelText: 'Color Hex (e.g. #FF0000)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(diagContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AdminCubit>().saveCategory(
                nameController.text,
                iconController.text,
                colorController.text,
                id: category?.id,
              );
              Navigator.pop(diagContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
