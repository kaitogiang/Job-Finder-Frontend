import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/employer/company_manager.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/company_card.dart';
import 'package:provider/provider.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        context.read<CompanyManager>().search("");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Danh sách các công ty',
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
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Text(
                    'Nhập vào tên công ty, lĩnh vực, hoặc vị trí bên dưới',
                    style: textTheme.titleMedium!.copyWith(
                      color: theme.indicatorColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      constraints: BoxConstraints.tightFor(height: 60),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      hintText: 'Tìm kiếm lĩnh vực của bạn',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (value) async {
                    if (value.isEmpty) {
                      return;
                    }
                    //Ghi nhận hành động
                    final jobseekerId =
                        context.read<JobseekerManager>().jobseeker.id;
                    context
                        .read<JobseekerManager>()
                        .observeSearchCompanyAction(jobseekerId, value);
                    context.read<CompanyManager>().search(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder(
          future: context.read<CompanyManager>().fetchAllCompanies(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<CompanyManager>().fetchAllCompanies(),
              child: Consumer<CompanyManager>(
                  builder: (context, companyManager, child) {
                final companyList = companyManager.searchResults;
                return companyList.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView.builder(
                          itemCount: companyList.length,
                          itemBuilder: (context, index) {
                            return CompanyCard(company: companyList[index]);
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          'Chưa có công ty nào',
                          style: textTheme.bodyLarge,
                        ),
                      );
              }),
            );
          }),
    );
  }
}
