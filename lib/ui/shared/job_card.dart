import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key});
  @override
  Widget build(BuildContext context) {
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
                    image: const DecorationImage(
                        image: NetworkImage(
                            'https://carelinelive.com/wp-content/uploads/2022/09/ideas-working-alzheimers-disease.jpg'),
                        fit: BoxFit.cover)),
              ),
              title: Text(
                'Senior Java Developer sf asdfa ',
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Text('TNHH TeachBase asdfas ',
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Icon(Icons.favorite_border),
            ),
            ExtraLabel(
              icon: Icons.location_on,
              label: 'Thành phố Hồ Chí Minh',
            ),
            ExtraLabel(
              icon: Icons.attach_money_outlined,
              label: '100.000.000 VNĐ',
            ),
            const Wrap(
              spacing: 8,
              direction: Axis.horizontal,
              runSpacing: 0,
              children: [
                ExtraInfoChip(label: 'Fresher'),
                ExtraInfoChip(label: 'Middle'),
                ExtraInfoChip(label: 'Full-time'),
              ],
            ),
            ExtraLabel(
              icon: Icons.timer,
              label: 'Hạn chót: 31/7/2024',
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
