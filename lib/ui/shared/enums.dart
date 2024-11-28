enum ApplicationStatus {
  accepted,
  rejected,
  pending,
}

enum BehaviourType {
  viewJobPost('view_job_post'),
  saveJobPost('save_job_post'),
  searchJobPost('search_job_post'),
  searchCompany('search_company'),
  viewCompany('view_company'),
  filterJobPost('filter_job_post');

  final String value;

  const BehaviourType(this.value);
}
