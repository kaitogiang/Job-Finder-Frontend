import 'package:flutter/material.dart';
import 'package:job_finder_app/models/company.dart';
import 'package:job_finder_app/models/employer.dart';

enum EmployerAccountStatus { active, inactive }

class EmployerAccountScreen extends StatefulWidget {
  const EmployerAccountScreen(
      {super.key,
      required this.employerFuture,
      required this.companyFuture,
      required this.isLockedFuture});

  final Future<Employer?> employerFuture;
  final Future<Company?> companyFuture;
  final Future<bool> isLockedFuture;

  @override
  State<EmployerAccountScreen> createState() => _EmployerAccountScreenState();
}

class _EmployerAccountScreenState extends State<EmployerAccountScreen> {
  //Caching lại Future để ngăn việc tải lại

  late Future<List<dynamic>> _combinedFuture;

  @override
  void initState() {
    super.initState();
    _combinedFuture = Future.wait(
        [widget.employerFuture, widget.companyFuture, widget.isLockedFuture]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final basicInfoTitle = theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.black54);
    final titleCardStyle =
        textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);

    return FutureBuilder(
        future: _combinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
                width: 600,
                height: 400,
                child: const Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return SizedBox(
                width: 600,
                height: 400,
                child: const Center(child: Text('Error')));
          }
          final employer = snapshot.data![0] as Employer;
          final company = snapshot.data![1] as Company;
          final isLocked = snapshot.data![2] as bool;
          final status = isLocked
              ? EmployerAccountStatus.inactive
              : EmployerAccountStatus.active;
          return SizedBox(
            width: 600,
            height: 400,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 110,
                            backgroundImage: NetworkImage(
                              employer.getImageUrl(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('Ảnh đại diện tài khoản', style: basicInfoTitle),
                          const SizedBox(height: 10),
                          Text('Trạng thái', style: titleCardStyle),
                          status == EmployerAccountStatus.active
                              ? Text('Đang hoạt động',
                                  style: basicInfoTitle.copyWith(
                                      color: Colors.green))
                              : Text(
                                  'Đã bị khóa',
                                  style: basicInfoTitle.copyWith(
                                      color: Colors.red),
                                ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text('Tên công ty', style: titleCardStyle),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(company.companyName,
                                textAlign: TextAlign.justify,
                                style: basicInfoTitle),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child:
                                Text('Tên người dùng', style: titleCardStyle),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                                '${employer.firstName} ${employer.lastName}',
                                textAlign: TextAlign.justify,
                                style: basicInfoTitle),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child:
                                Text('Email đăng nhập', style: titleCardStyle),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(employer.email,
                                textAlign: TextAlign.justify,
                                style: basicInfoTitle),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text('Số điện thoại', style: titleCardStyle),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(employer.phone,
                                textAlign: TextAlign.justify,
                                style: basicInfoTitle),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text('Vai trò', style: titleCardStyle),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(employer.role,
                                textAlign: TextAlign.justify,
                                style: basicInfoTitle),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child:
                                Text('Tỉnh/thành phố', style: titleCardStyle),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(employer.address,
                                textAlign: TextAlign.justify,
                                style: basicInfoTitle),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
