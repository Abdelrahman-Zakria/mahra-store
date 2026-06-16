import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../../domain/entities/order_entity.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Management'),
        centerTitle: true,
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoaded) {
            if (state.recentOrders.isEmpty) {
              return const Center(child: Text('No orders found'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppDimens.md),
              itemCount: state.recentOrders.length,
              itemBuilder: (context, index) {
                final order = state.recentOrders[index];
                return _OrderCard(order: order);
              },
            );
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
        title: Row(
          children: [
            Text('Order #${order.id.substring(0, 8)}', style: AppTextStyles.titleLarge),
            const Spacer(),
            _StatusChip(status: order.status),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${order.createdAt.toString().split('.')[0]} • \$${order.totalAmount.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall,
          ),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Info Section
                _SectionTitle(title: 'Customer Details', icon: Icons.person_outline),
                _InfoRow(label: 'Name', value: order.fullName ?? 'Guest'),
                _InfoRow(label: 'Phone', value: order.phone ?? 'N/A'),
                _InfoRow(label: 'Address', value: order.address ?? 'N/A'),
                const SizedBox(height: AppDimens.md),

                // Payment Info Section
                _SectionTitle(title: 'Payment Information', icon: Icons.payment_outlined),
                _InfoRow(label: 'Method', value: order.paymentMethod?.toUpperCase() ?? 'COD'),
                if (order.paymentImageUrl != null) ...[
                  const SizedBox(height: AppDimens.sm),
                  const Text('Payment Proof:', style: AppTextStyles.bodySmall),
                  const SizedBox(height: AppDimens.xs),
                  _PaymentImageThumb(imageUrl: order.paymentImageUrl!),
                ],
                const SizedBox(height: AppDimens.md),

                // Order Items Section
                _SectionTitle(title: 'Order Items', icon: Icons.shopping_bag_outlined),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('${item.quantity}x ', style: AppTextStyles.labelLarge.copyWith(color: AppColors.gold)),
                      Expanded(child: Text(item.productName, style: AppTextStyles.bodyMedium)),
                      Text('\$${(item.quantity * item.priceAtPurchase).toStringAsFixed(2)}', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                )),
                const Divider(height: AppDimens.lg),

                // Actions Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showStatusPicker(context, order),
                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                        label: const Text('Update Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.charcoal,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    OutlinedButton(
                      onPressed: () => _confirmDelete(context, order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context, OrderEntity order) {
    final List<String> statuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
    final adminCubit = context.read<AdminCubit>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
      ),
      builder: (modalContext) => BlocProvider.value(
        value: adminCubit,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppDimens.md),
                child: Text('Update Order Status', style: AppTextStyles.titleLarge),
              ),
              const Divider(height: 1),
              ...statuses.map((s) => ListTile(
                title: Text(s.toUpperCase(), style: AppTextStyles.labelLarge),
                leading: _StatusDot(status: s),
                onTap: () {
                  adminCubit.updateStatus(order.id, s);
                  Navigator.pop(modalContext);
                },
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String orderId) {
    final adminCubit = context.read<AdminCubit>();
    showDialog(
      context: context,
      builder: (diagContext) => BlocProvider.value(
        value: adminCubit,
        child: AlertDialog(
          title: const Text('Delete Order'),
          content: const Text('Are you sure you want to permanently delete this order?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(diagContext), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                adminCubit.deleteOrder(orderId);
                Navigator.pop(diagContext);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.slate),
          const SizedBox(width: 8),
          Text(title.toUpperCase(), style: AppTextStyles.labelLarge.copyWith(color: AppColors.slate, fontSize: 11, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text('$label:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'confirmed': color = Colors.blue; break;
      case 'processing': color = Colors.indigo; break;
      case 'shipped': color = Colors.purple; break;
      case 'delivered': color = AppColors.success; break;
      case 'cancelled': color = AppColors.error; break;
      default: color = AppColors.slate;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusCircle),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'confirmed': color = Colors.blue; break;
      case 'processing': color = Colors.indigo; break;
      case 'shipped': color = Colors.purple; break;
      case 'delivered': color = AppColors.success; break;
      case 'cancelled': color = AppColors.error; break;
      default: color = AppColors.slate;
    }
    return Icon(Icons.circle, size: 12, color: color);
  }
}

class _PaymentImageThumb extends StatelessWidget {
  final String imageUrl;
  const _PaymentImageThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(AppDimens.md),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton.filled(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(child: Text('Error loading image')),
        ),
      ),
    );
  }
}
