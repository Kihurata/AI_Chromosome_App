import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/test_order.dart';
import '../../../logic/bloc/manager/manager_dashboard_cubit.dart';
import '../../../logic/bloc/manager/manager_dashboard_state.dart';
import '../../widgets/shared/cards/stats_card.dart';
import 'widgets/manager_order_card.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ManagerDashboardCubit>()..initialize(),
      child: const ManagerDashboardView(),
    );
  }
}

class ManagerDashboardView extends StatelessWidget {
  const ManagerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocBuilder<ManagerDashboardCubit, ManagerDashboardState>(
        builder: (context, state) {
          if (state is ManagerDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ManagerDashboardError) {
            return Center(child: Text(state.message));
          }

          if (state is ManagerDashboardLoaded) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildStats(state.stats),
                  const SizedBox(height: 32),
                  _buildMainContent(context, state),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điều phối Lab',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        Text(
          'Quản lý quy trình phân tích và duyệt kết quả real-time',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(ManagerStats stats) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Chờ phân công',
            value: stats.unassignedCount.toString(),
            icon: LucideIcons.userPlus,
            color: const Color(0xFF007BFF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            title: 'Đang xử lý',
            value: stats.ongoingCount.toString(),
            icon: LucideIcons.activity,
            color: const Color(0xFFFD7E14),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            title: 'Chờ phê duyệt',
            value: stats.waitingApprovalCount.toString(),
            icon: LucideIcons.clipboardCheck,
            color: const Color(0xFF6F42C1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            title: 'Hoàn thành',
            value: stats.completedCount.toString(),
            icon: LucideIcons.checkCircle2,
            color: const Color(0xFF28A745),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, ManagerDashboardLoaded state) {
    return Expanded(
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            _buildTabBar(context, state),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOrderList(context, state, TestOrderStatus.pending),
                  _buildOrderList(context, state, TestOrderStatus.analyzing),
                  _buildOrderList(context, state, TestOrderStatus.waitingApproval),
                  _buildOrderList(context, state, TestOrderStatus.completed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, ManagerDashboardLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: TabBar(
        labelColor: const Color(0xFF007BFF),
        unselectedLabelColor: const Color(0xFF6C757D),
        indicatorColor: const Color(0xFF007BFF),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Chờ phân công (${state.stats.unassignedCount})'),
          Tab(text: 'Đang làm (${state.stats.ongoingCount})'),
          Tab(text: 'Chờ duyệt (${state.stats.waitingApprovalCount})'),
          Tab(text: 'Đã xong (${state.stats.completedCount})'),
        ],
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context, 
    ManagerDashboardLoaded state, 
    TestOrderStatus status,
  ) {
    final orders = state.allOrders.where((o) => o.status == status).toList();

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Không có phiếu nào ở trạng thái này',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        final cubit = context.read<ManagerDashboardCubit>();
        return ManagerOrderCard(
          order: order,
          specialists: state.specialists,
          onAssign: (specId) => cubit.assignSpecialist(
            orderId: order.id,
            specialistId: specId,
          ),
          onApprove: () => cubit.approveOrder(order.id),
          onReject: (reason) => cubit.rejectOrder(order.id, reason),
        );
      },
    );
  }
}
