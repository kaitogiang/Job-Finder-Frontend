import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/company.dart';

class CompanyDetailScreen extends StatefulWidget {
  const CompanyDetailScreen({super.key, required this.company});

  final Company? company;

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final basicInfoTitle = theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.black54);
    final titleCardStyle =
        textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);

    final imageScrollController = ScrollController();

    //Khởi tạo dữ liệu
    final description = widget.company?.description;
    final imageList = widget.company?.images
        .map((e) => '${dotenv.env['DATABASE_BASE_URL_WEB']}/${e.toString()}')
        .toList();
    final companyAvatar = widget.company?.avatarLink;
    final policy = widget.company?.policy;
    Utils.logMessage(
        'Rebuilt CompanyDetailScreen: ${widget.company?.companyName}');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text('Giới thiệu công ty', style: titleCardStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(description?['introduction'] ?? 'Chưa thiết lập',
                textAlign: TextAlign.justify, style: basicInfoTitle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text('Lĩnh vực kinh doanh', style: titleCardStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(description?['domain'] ?? 'Chưa thiết lập',
                style: basicInfoTitle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text('Quy mô công ty', style: titleCardStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(description?['companySize'] ?? 'Chưa thiết lập',
                style: basicInfoTitle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text('Hình ảnh công ty', style: titleCardStyle),
          ),
          imageList!.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text('Chưa thiết lập', style: basicInfoTitle),
                )
              : Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Scrollbar(
                    controller: imageScrollController,
                    trackVisibility: true,
                    thickness: 7,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 7,
                        bottom: 15,
                        // left: 15,
                        // right: 15,
                      ),
                      child: ListView.builder(
                        controller: imageScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: imageList.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(imageList[index]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text('Chính sách làm việc', style: titleCardStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(policy?['employmentPolicy'] ?? 'Chưa thiết lập',
                textAlign: TextAlign.justify, style: basicInfoTitle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text('Chính sách tuyển dụng', style: titleCardStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(policy?['recruitmentPolicy'] ?? 'Chưa thiết lập',
                textAlign: TextAlign.justify, style: basicInfoTitle),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text('Chính sách phúc lợi', style: titleCardStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(policy?['welfarePolicy'] ?? 'Chưa thiết lập',
                textAlign: TextAlign.justify, style: basicInfoTitle),
          ),
        ],
      ),
    );
  }
}
