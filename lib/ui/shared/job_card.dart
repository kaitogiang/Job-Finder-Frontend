import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/jobposting.dart';

class JobCard extends StatelessWidget {
  const JobCard(this.jobposting, {super.key});

  final Jobposting jobposting;

  @override
  Widget build(BuildContext context) {
    List<String> chipData = [];
    chipData.addAll(jobposting.level);
    chipData.add(jobposting.jobType);
    //todo Chuyển đổi chuỗi ngày sang đối tượng DateTime và sau đó chuyển định
    //todo dạng sang dd-MM-yyyy
    DateTime dateTime = DateTime.parse(jobposting.deadline);
    String formatedDate = DateFormat('dd-MM-yyyy').format(dateTime);

    return Card(
      borderOnForeground: true,
      surfaceTintColor: Colors.blue[100],
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: NetworkImage(jobposting.company!.avatarLink),
                        fit: BoxFit.cover)),
              ),
              title: Text(
                jobposting.title,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Text(jobposting.company!.companyName,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: ValueListenableBuilder(
                  valueListenable: jobposting.favorite,
                  builder: (context, isFavorite, child) {
                    return IconButton(
                      icon: Icon(
                        !isFavorite ? Icons.favorite_border : Icons.favorite,
                        color: Colors.blue[400],
                      ),
                      onPressed: () {
                        jobposting.isFavorite = !isFavorite;
                      },
                    );
                  }),
            ),
            ExtraLabel(
              icon: Icons.location_on,
              label: jobposting.workLocation,
            ),
            ExtraLabel(
              icon: Icons.attach_money_outlined,
              label: jobposting.salary,
            ),
            Wrap(
              spacing: 8,
              direction: Axis.horizontal,
              runSpacing: 0,
              children: List<Widget>.generate(
                chipData.length,
                (index) => ExtraInfoChip(label: chipData[index]),
              ),
            ),
            ExtraLabel(
              icon: Icons.timer,
              label: 'Hạn chót: $formatedDate',
            )
          ],
        ),
      ),
    );
  }
}

class ExtraInfoChip extends StatelessWidget {
  const ExtraInfoChip({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.blueAccent),
      ),
      backgroundColor: Colors.lightBlueAccent[50],
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue[200]!),
          borderRadius: BorderRadius.circular(10)),
    );
  }
}

class ExtraLabel extends StatelessWidget {
  const ExtraLabel({
    super.key,
    required this.icon,
    required this.label,
  });
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          color: Colors.grey.shade700,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.grey.shade700,
                ))
      ],
    );
  }
}
