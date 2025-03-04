import 'package:flutter/material.dart';
import '../models/medicine.dart';

class MedicineListItem extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;

  const MedicineListItem({
    Key? key,
    required this.medicine,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.medication),
        ),
        title: Text(medicine.name),
        subtitle: Text(medicine.activeSubstance),
        trailing: Text(
          '${medicine.remainingQuantity} ${medicine.unit}',
        ),
        onTap: onTap,
      ),
    );
  }
} 