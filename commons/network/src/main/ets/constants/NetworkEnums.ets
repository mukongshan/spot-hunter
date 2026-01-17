export enum RequestUrl {
  // 公告相关
  BULLETIN_GET_LIST = '/api/notice/list',
  BULLETIN_GET_DETAIL = '/api/notice',
  // 首页相关
  HOME_GET_INFO = '/api/home',
  // 景点相关
  ATTRACTION_GET_LIST = '/api/scenic/list',
  ATTRACTION_GET_DETAIL = '/api/scenic',
  // 门票相关
  TICKET_GET_LIST = '/api/ticket/list',
  TICKET_GET_DETAIL = '/api/ticket',
  // 游客管理
  TOURIST_CREATE = '/api/tourist/create',
  TOURIST_MODIFY = '/api/tourist',
  TOURIST_DELETE = '/api/tourist',
  TOURIST_GET_LIST = '/api/tourist/list',
  // 地址管理
  ADDRESS_CREATE = '/api/address/create',
  ADDRESS_GET_LIST = '/api/address/list',
  ADDRESS_MODIFY = '/api/address',
  ADDRESS_DELETE = '/api/address',
  // 订单相关
  TICKET_ORDER_CREATE = '/api/order/create',
  ORDER_LIST = '/api/order/my',
  ORDER_DETAIL = '/api/order',
  ORDER_MODIFY = '/api/order',
  ORDER_CANCEL = '/api/order/cancel',
  ORDER_REFUND = '/api/order/refund',
}

export enum AppStorageKey {
  TICKET_LIST = 'ticketList',
}