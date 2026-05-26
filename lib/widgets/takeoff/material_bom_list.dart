import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/ai_takeoff_service.dart';

class MaterialBomList extends StatelessWidget {
  final List<TakeoffItem> items;

  const MaterialBomList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generated Bill of Materials',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.white.withValues(alpha: 0.05),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final isCompliance = item.category == 'Compliance';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: isCompliance
                      ? Colors.amber.withValues(alpha: 0.2)
                      : const Color(0xFF00E6FF).withValues(alpha: 0.1),
                  child: Icon(
                    isCompliance ? Icons.verified_user_outlined : Icons.handyman_outlined,
                    color: isCompliance ? Colors.amber : const Color(0xFF00E6FF),
                    size: 20,
                  ),
                ),
                title: Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                subtitle: item.complianceReason != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item.complianceReason!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isCompliance ? Colors.amberAccent : Colors.white60,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : null,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Qty: ${item.quantity}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
