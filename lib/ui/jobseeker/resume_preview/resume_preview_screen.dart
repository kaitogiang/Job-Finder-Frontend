import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';

class ResumePreviewScreen extends StatelessWidget {
  const ResumePreviewScreen({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final baseUrl = dotenv.env['DATABASE_BASE_URL'];
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết CV',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          width: deviceSize.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.blueAccent.shade700,
                  Colors.blueAccent.shade400,
                  theme.primaryColor,
                ]),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                spreadRadius: 2,
                blurRadius: 2,
              ),
            ],
          ),
          child: PDF().cachedFromUrl(
            '$baseUrl$url',
            placeholder: (progress) => Center(child: Text('$progress %')),
            errorWidget: (error) {
              Utils.logMessage(error.toString());
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Image.asset('assets/images/oops.png'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('Cannot preview this resume, try it later'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
