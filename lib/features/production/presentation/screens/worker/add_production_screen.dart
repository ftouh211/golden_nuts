import 'package:flutter/material.dart';
import 'package:golds_nuts/features/production/presentation/screens/widget/production_entry_form.dart';

class AddProductionScreen extends StatelessWidget {
  final String workerId;
  final String workerName;
  final bool canSelectDate;

  const AddProductionScreen({
    super.key,
    required this.workerId,
    required this.workerName,
    this.canSelectDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Production')),
      body: ProductionEntryForm(
        workerId: workerId,
        workerName: workerName,
        canSelectDate: canSelectDate,
        onSuccess: () {
          Navigator.pop(context, true);
        },
      ),
    );
  }
}
