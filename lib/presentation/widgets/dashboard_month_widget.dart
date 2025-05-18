import 'package:flutter/material.dart';

class DashboardMonthWidget extends StatelessWidget {
  const DashboardMonthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final now = DateTime.now();

    Color _getMonthColor(int month) {
      if (month < now.month) {
        return Colors.blue.shade100;
      } else if (month == now.month) {
        return Colors.blue.shade600;
      } else {
        return Colors.grey.shade200;
      }
    }

    TextStyle _getTextStyle(int month) {
      if (month == now.month) {
        return const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );
      } else if (month < now.month) {
        return TextStyle(
          color: Colors.blue.shade900,
          fontWeight: FontWeight.w600,
        );
      } else {
        return TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.normal,
        );
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      itemCount: 12,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final month = index + 1;
        return Material(
          color: _getMonthColor(month),
          borderRadius: BorderRadius.circular(10),
          elevation: month == now.month ? 4 : 0,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border:
                  month == now.month
                      ? Border.all(color: Colors.blue.shade800, width: 2)
                      : null,
            ),
            child: Text(months[index], style: _getTextStyle(month)),
          ),
        );
      },
    );
  }
}
