import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/specialist/sample_detail_cubit.dart';
import '../../../../logic/bloc/specialist/sample_detail_state.dart';
import '../../../../core/di/injection.dart';

class SampleDetailScreen extends StatefulWidget {
  final String sampleId;

  const SampleDetailScreen({super.key, required this.sampleId});

  @override
  State<SampleDetailScreen> createState() => _SampleDetailScreenState();
}

class _SampleDetailScreenState extends State<SampleDetailScreen> {
  final _noteController = TextEditingController();
  late final SampleDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<SampleDetailCubit>();
    _cubit.loadSample(widget.sampleId);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: BlocConsumer<SampleDetailCubit, SampleDetailState>(
          listener: (context, state) {
            if (state is SampleDetailSuccess) {
              _noteController.text = state.sample.notes ?? '';
            } else if (state is SampleDetailError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is SampleDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SampleDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _cubit.loadSample(widget.sampleId),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            if (state is SampleDetailSuccess) {
              final sample = state.sample;
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết Phiếu xét nghiệm',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mẫu bệnh phẩm (Samples)',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text('Loại mẫu: ${sample.sampleType}'),
                          const SizedBox(height: 8),
                          Text('Thời gian lấy: ${sample.collectedAt.toString().substring(0, 16)}'),
                          const SizedBox(height: 8),
                          Text('Trạng thái: ${sample.status.name.toUpperCase()}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ghi chú mẫu bệnh phẩm',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập ghi chú...',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _cubit.saveNote(widget.sampleId, _noteController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lưu ghi chú thành công')),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu ghi chú'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
