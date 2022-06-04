class OrderModel {
  List<Map> orderList = [];
  
  void createListFromDB(List<Map> list) {
    if (orderList.isEmpty) {
      orderList = list;
    }
  }

  List<Map> orderListShow() {
    return orderList;
  }
}
