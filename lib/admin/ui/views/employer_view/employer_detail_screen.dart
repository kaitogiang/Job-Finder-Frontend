import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/company_detail_tabs/company_detail_screen.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/company_detail_tabs/company_jobposting_screen.dart';
import 'package:job_finder_app/models/company.dart';
import 'package:job_finder_app/models/jobposting.dart';

class EmployerDetailScreen extends StatefulWidget {
  const EmployerDetailScreen(
      {super.key,
      required this.companyFuture,
      required this.jobpostingsFuture});

  final Future<Company?> companyFuture;
  final Future<List<Jobposting>?> jobpostingsFuture;

  @override
  State<EmployerDetailScreen> createState() => _EmployerDetailScreenState();
}

class _EmployerDetailScreenState extends State<EmployerDetailScreen> {
  late Future<List<dynamic>>
      _combinedFuture; //gán ở đầu như vậy để caching future lại để tránh
  //FutureBuild được nạp lại khi hàm build được gọi.
  /*
    FutureBuilder được thiết kế để khởi chạy duy nhất một lần và caching lại future để
    tránh việc bị rebuild lại.
    Tuy nhiên, nếu mỗi lần hàm build được gọi lại và truyền future mới vào FutureBuilder thì
    FutureBuilder sẽ được gọi lại do nó không lưu lại caching của lần trước.
    Do đó, ngoài hàm build phải tạo một biến để lưu giữ lại kết quả của future khi nó thành công.
    như vậy được gọi là caching future. Do đó mỗi lần hàm build được gọi là future truyền vào 
    FutureBuilder là giống nhau nên nó sẽ không chạy.
   */

  @override
  void initState() {
    super.initState();
    _combinedFuture =
        Future.wait([widget.companyFuture, widget.jobpostingsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final basicInfoTitle = theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.black54);
    final basicInfoTitleIcon = Colors.black54;
    final titleCardStyle =
        textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);
    Utils.logMessage('Rebuilt EmployerDetailScreen');
    return FutureBuilder<List<dynamic>>(
        future: _combinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 850,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return const SizedBox(
              width: 850,
              child: Center(
                child: Text('Lỗi không thể tải được dữ liệu'),
              ),
            );
          }

          //Nạp dữ liệu
          final company = snapshot.data?[0] as Company?;
          final jobpostings = snapshot.data?[1] as List<Jobposting>?;
          return SizedBox(
            width: 850,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          //Ảnh đại diện của công ty
                          Container(
                            alignment: Alignment.center,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(company?.avatarLink ??
                                      'https://png.pngtree.com/png-clipart/20230917/original/pngtree-no-image-available-icon-flatvector-illustration-blank-avatar-modern-vector-png-image_12323065.png'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            company?.companyName ?? 'Lỗi tên công ty',
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge!.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thông tin cơ bản',
                                    style: titleCardStyle,
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: RichText(
                                      text: TextSpan(
                                        style: textTheme.bodyMedium,
                                        children: [
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Icon(
                                              Icons.email,
                                              size: 17,
                                              color:
                                                  basicInfoTitleIcon, // Added color property
                                            ),
                                          ),
                                          WidgetSpan(
                                              child: const SizedBox(width: 5)),
                                          TextSpan(
                                              text: 'Email',
                                              style: basicInfoTitle),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      company?.companyEmail ?? 'Lỗi email',
                                      style: textTheme.bodyMedium,
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
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Icon(
                                              Icons.phone,
                                              size: 17,
                                              color:
                                                  basicInfoTitleIcon, // Added color property
                                            ),
                                          ),
                                          WidgetSpan(
                                              child: const SizedBox(width: 5)),
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
                                      company?.companyPhone ??
                                          'Lỗi số điện thoại',
                                      style: textTheme.bodyMedium,
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
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Icon(
                                              Icons.location_on,
                                              size: 17,
                                              color:
                                                  basicInfoTitleIcon, // Added color property
                                            ),
                                          ),
                                          WidgetSpan(
                                              child: const SizedBox(width: 5)),
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
                                      company?.companyAddress ?? 'Lỗi địa chỉ',
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: <Widget>[
                              Tab(
                                icon: Icon(Icons.info),
                                text: 'Thông tin chi tiết',
                              ),
                              Tab(
                                icon: Icon(Icons.comment),
                                text: 'Bài tuyển dụng',
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: <Widget>[
                                CompanyDetailScreen(company: company),
                                CompanyJobpostingScreen(
                                    companyJobpostings: jobpostings,
                                    company: company,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
