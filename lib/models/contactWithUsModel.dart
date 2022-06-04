class ContactWithUs {
  List<Map> contactWithUsList = [];

  void createListFromDB(List<Map> list) {
    if (contactWithUsList.isEmpty) {
      contactWithUsList = list;
    }
  }

  List<Map> contactWithUsListShow() {
    return contactWithUsList;
  }
}
