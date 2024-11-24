import 'package:flutter/material.dart';
import 'package:job_finder_app/models/jobseeker.dart';

class JobseekerBasicInfoScreen extends StatelessWidget {
  const JobseekerBasicInfoScreen({super.key, required this.basicInfoFuture});
  final Future<Jobseeker?> basicInfoFuture;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final basicInfoTitle = theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.black54);
    final basicInfoTitleIcon = Colors.black54;
    return FutureBuilder(
        future: basicInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: 420,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final jobseeker = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    //Ảnh đại diện
                    Column(
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(jobseeker.getImageUrl()),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Ảnh đại diện',
                          style: basicInfoTitle,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    //Thông tin cơ bản
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              text: TextSpan(
                                style: textTheme.bodyMedium,
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.person_3,
                                      size: 18,
                                      color:
                                          basicInfoTitleIcon, // Added color property
                                    ),
                                  ),
                                  WidgetSpan(child: const SizedBox(width: 5)),
                                  TextSpan(
                                      text: 'Họ tên', style: basicInfoTitle),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${jobseeker.firstName} ${jobseeker.lastName}',
                              style: textTheme.bodyMedium,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              text: TextSpan(
                                style: textTheme.bodyMedium,
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.email,
                                      size: 17,
                                      color:
                                          basicInfoTitleIcon, // Added color property
                                    ),
                                  ),
                                  WidgetSpan(child: const SizedBox(width: 5)),
                                  TextSpan(
                                      text: 'Email', style: basicInfoTitle),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              jobseeker.email,
                              style: textTheme.bodyMedium,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              text: TextSpan(
                                style: textTheme.bodyMedium,
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.phone,
                                      size: 17,
                                      color:
                                          basicInfoTitleIcon, // Added color property
                                    ),
                                  ),
                                  WidgetSpan(child: const SizedBox(width: 5)),
                                  TextSpan(
                                      text: 'Số điện thoại',
                                      style: basicInfoTitle),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              jobseeker.phone,
                              style: textTheme.bodyMedium,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              text: TextSpan(
                                style: textTheme.bodyMedium,
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.location_on,
                                      size: 17,
                                      color:
                                          basicInfoTitleIcon, // Added color property
                                    ),
                                  ),
                                  WidgetSpan(child: const SizedBox(width: 5)),
                                  TextSpan(
                                      text: 'Tỉnh/thành phố',
                                      style: basicInfoTitle),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              jobseeker.address,
                              style: textTheme.bodyMedium,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
