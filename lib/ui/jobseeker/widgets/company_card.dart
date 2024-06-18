import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/company.dart';

class CompanyCard extends StatelessWidget {
  const CompanyCard({super.key, required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Card(
          elevation: 4,
          surfaceTintColor: Colors.blue[200],
          child: Column(
            children: [
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(company.avatarLink),
                ),
                title: Text(
                  company.companyName,
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.group),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          //? Hiển thị thông tin số lượng thành viên
                          child: Text(
                            '${company.description?["companySize"]} thành viên',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.domain),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          //? Hiển thị thông tin lĩnh vực hoạt động
                          child: Text(
                            '${company.description?["domain"]}',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right_sharp),
                  onPressed: () {
                    log('chuyển tới trang chi tiết công ty');
                  },
                ),
                contentPadding: const EdgeInsets.only(
                  left: 10,
                  top: 10,
                  bottom: 10,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      //? Hiển thị địa chỉ của công ty
                      child: Text(
                        company.companyAddress,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        //todo Hiển thị thao tác chọn
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                log('Chuyển đén công ty');
                context.pushNamed('company-detail', extra: company);
              },
            ),
          ),
        )
      ],
    );
  }
}
