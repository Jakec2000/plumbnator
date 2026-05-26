import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'job_item.dart';

/// Renders the recent active sites in a vertical list.
class JobFeed extends StatelessWidget {
  /// The list of jobs to display.
  final List<dynamic> jobs;

  /// Creates a [JobFeed].
  const JobFeed({
    super.key,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Active Sites',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...jobs.map<Widget>((job) => JobItem(job: job)),
      ],
    );
  }
}
