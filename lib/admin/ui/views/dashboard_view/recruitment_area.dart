import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/recruitment_area_data.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class RecruitmentArea extends StatefulWidget {
  const RecruitmentArea({super.key, required this.recruitmentArea});

  final List<RecruitmentAreaData> recruitmentArea;

  @override
  State<RecruitmentArea> createState() => _RecruitmentAreaState();
}

class _RecruitmentAreaState extends State<RecruitmentArea> {
  final _panelController = PanelController();
  final _mapController = MapController();
  final _selectedAreaIndex =
      ValueNotifier(0); //Chưa chọn bất kỳ marker nào trên bản đồ

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
  }

  ListView _buildAdditionalInfo(String areName, int jobpostingCount,
      int companyCount, TextTheme textTheme) {
    Utils.logMessage('Area name: $areName');
    return ListView(
      children: [
        Text(
          'Khu vực: $areName',
          style: textTheme.titleMedium!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: RichText(
            text: TextSpan(children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  Icons.comment,
                  color: Colors.green,
                ),
              ),
              const WidgetSpan(
                  child: SizedBox(
                width: 5,
              )),
              TextSpan(
                text: 'Số lượng bài đăng: $jobpostingCount',
                style: textTheme.bodyMedium,
              )
            ]),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: RichText(
            text: TextSpan(children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  Icons.business_sharp,
                  color: Colors.blue,
                ),
              ),
              const WidgetSpan(
                  child: SizedBox(
                width: 5,
              )),
              TextSpan(
                text: 'Số lượng công ty: $companyCount',
                style: textTheme.bodyMedium,
              )
            ]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SlidingUpPanel(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      controller: _panelController,
      minHeight: 0,
      maxHeight: 170,
      padding: const EdgeInsets.all(10),
      panel: ValueListenableBuilder(
        valueListenable: _selectedAreaIndex,
        builder: (context, selectedIndex, child) {
          final RecruitmentAreaData data =
              widget.recruitmentArea[selectedIndex];
          return _buildAdditionalInfo(data.location.name, data.jobpostingCount,
              data.companyCount, textTheme);
        },
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(14.0583, 108.2772),
          initialZoom: 6.0,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          onTap: (tapPosition, point) {
            //Khi người dùng nhấn vào vùng khác thì ẩn bản đồ đi
            Utils.logMessage('Tapposition: $tapPosition');
            _panelController.close();
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: widget.recruitmentArea.asMap().entries.map((entry) {
              int index = entry.key;
              RecruitmentAreaData area = entry.value;
              final marker =
                  LatLng(area.location.latitude, area.location.longtitude);
              return Marker(
                width: 80.0,
                height: 80.0,
                point: marker,
                child: IconButton(
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                  onPressed: () {
                    _selectedAreaIndex.value = index;
                    Utils.logMessage('Index: $index');
                    _panelController.open();
                    _mapController.move(marker, 6.0, offset: Offset(-10, -230));
                  },
                ),
              );
            }).toList(),
          ),
          RichAttributionWidget(
            animationConfig: const ScaleRAWA(), // Or `FadeRAWA` as is default
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () =>
                    launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
