import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/domain/entities/category_entity.dart';
import '../../../home/data/models/product_model.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoaded) {
            return ListView.builder(
              itemCount: state.inventory.length,
              itemBuilder: (context, index) {
                final product = state.inventory[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: product.imagePath.startsWith('http')
                        ? NetworkImage(product.imagePath)
                        : AssetImage(product.imagePath) as ImageProvider,
                  ),
                  title: Text(product.name),
                  subtitle: Text('${l10n.salePrice}: ${product.price} EGP | ${l10n.stock}: ${product.stockQuantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showProductDialog(context, product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => context.read<AdminCubit>().deleteProduct(product.id),
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

  void _showProductDialog(BuildContext context, {ProductEntity? product}) {
    showDialog(
      context: context,
      builder: (diagContext) {
        final state = context.read<AdminCubit>().state as AdminLoaded;
        return _ProductDialog(
          product: product, 
          adminCubit: context.read<AdminCubit>(),
          categories: state.categories,
        );
      },
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final ProductEntity? product;
  final AdminCubit adminCubit;
  final List<CategoryEntity> categories;

  const _ProductDialog({this.product, required this.adminCubit, required this.categories});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController originalPriceController;
  late TextEditingController descController;
  late TextEditingController stockController;
  String? selectedCategoryId;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product?.name ?? '');
    priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    originalPriceController = TextEditingController(text: widget.product?.originalPrice?.toString() ?? '');
    descController = TextEditingController(text: widget.product?.description ?? '');
    stockController = TextEditingController(text: widget.product?.stockQuantity.toString() ?? '50');
    selectedCategoryId = widget.product?.category;
    
    // If only one category exists and none selected, auto-select it
    if (selectedCategoryId == null && widget.categories.isNotEmpty) {
      selectedCategoryId = widget.categories.first.id;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.product == null ? l10n.addProduct : l10n.editProduct),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: kIsWeb ? NetworkImage(_imageFile!.path) : FileImage(File(_imageFile!.path)) as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : (widget.product != null && widget.product!.imagePath.isNotEmpty
                          ? DecorationImage(
                              image: widget.product!.imagePath.startsWith('http')
                                  ? NetworkImage(widget.product!.imagePath)
                                  : AssetImage(widget.product!.imagePath) as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null),
                ),
                child: (_imageFile == null && (widget.product == null || widget.product!.imagePath.isEmpty))
                    ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            if (_imageFile == null && widget.product == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l10n.imageIsRequired, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
            Row(
              children: [
                Expanded(child: TextField(controller: priceController, decoration: InputDecoration(labelText: l10n.salePrice), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: originalPriceController, decoration: InputDecoration(labelText: l10n.originalPrice), keyboardType: TextInputType.number)),
              ],
            ),
            TextField(controller: descController, decoration: InputDecoration(labelText: l10n.description), maxLines: 3),
            TextField(controller: stockController, decoration: InputDecoration(labelText: l10n.stock), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategoryId,
              items: widget.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (val) => setState(() => selectedCategoryId = val),
              decoration: InputDecoration(labelText: l10n.category),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: () async {
            if (widget.product == null && _imageFile == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectImage)));
              return;
            }

            if (nameController.text.isEmpty || priceController.text.isEmpty || selectedCategoryId == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fillAllFields)));
              return;
            }

            Uint8List? bytes;
            String? ext;
            if (_imageFile != null) {
              bytes = await _imageFile!.readAsBytes();
              ext = _imageFile!.name.split('.').last;
            }

            final price = double.tryParse(priceController.text) ?? 0.0;
            final originalPrice = double.tryParse(originalPriceController.text);

            final newProduct = ProductModel(
              id: widget.product?.id ?? '',
              name: nameController.text,
              description: descController.text,
              price: price,
              originalPrice: originalPrice,
              imagePath: widget.product?.imagePath ?? '',
              category: selectedCategoryId!,
              isFeatured: widget.product?.isFeatured ?? false,
              isNew: widget.product?.isNew ?? true,
              stockQuantity: int.tryParse(stockController.text) ?? 0,
            );

            widget.adminCubit.saveProduct(
              newProduct,
              isNew: widget.product == null,
              imageBytes: bytes,
              imageExt: ext,
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
