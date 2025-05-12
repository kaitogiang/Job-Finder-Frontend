import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:provider/provider.dart';

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
                leading: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: NetworkImage(company.avatarLink),
                          fit: BoxFit.cover)),
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
                          //? Display the number of members
                          child: Text(
                            '${company.description?["companySize"]} members',
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
                          //? Display the field of operation
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
                    log('Navigate to company details page');
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
                      //? Display the company's address
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
        //todo Display the selection action
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                //Record the action
                final jobseekerId =
                    context.read<JobseekerManager>().jobseeker.id;
                context
                    .read<JobseekerManager>()
                    .observeViewCompanyAction(jobseekerId, company.id);
                log('Navigate to the company');
                context.pushNamed('company-detail', extra: company);
              },
            ),
          ),
        )
      ],
    );
  }
}
