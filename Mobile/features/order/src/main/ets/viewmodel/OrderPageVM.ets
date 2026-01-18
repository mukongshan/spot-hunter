import { GetOrderDetailRequest, GetTicketOrderListResp, https } from 'network';
import { mapperTicketOrderList } from '../mapper/Index';
import { AppStorageV2 } from '@kit.ArkUI';
import { TICKET_ORDER_INFO_MAP } from '../model/TicketOrderInfo';
import { TicketOrderInfo, WindowSize } from 'types';
import { TICKET_ORDER_MODULE_INFO } from '../model/OrderModuleInfo';

@ObservedV2
export class OrderPageVM {
  @Trace isFromMine: boolean = false;
  @Trace orderType: number = 0;
  @Trace orderTabIndex: number = 0;
  @Trace isLoading: boolean = false;
  @Trace ticketOrderList: GetTicketOrderListResp =
    AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp',
      () => new GetTicketOrderListResp()) ?? [];
  @Trace windowSize: WindowSize = AppStorageV2.connect(WindowSize, 'WindowSize', () => new WindowSize())!;
  @Trace offsetX: number = 0;
  public static _instance: OrderPageVM;

  public static get instance() {
    if (!OrderPageVM._instance) {
      OrderPageVM._instance = new OrderPageVM();
    }
    return OrderPageVM._instance;
  }

  getOffsetX() {
    this.offsetX = this.windowSize.width * 0.5 - 48;
  }

  getOrderStatus(item: TicketOrderInfo) {
    return item.orderStatus;
  }

  getTicketStatus(item: TicketOrderInfo) {
    return TICKET_ORDER_INFO_MAP[item.orderStatus];
  }

  getTitle(index: number): ResourceStr {
    return TICKET_ORDER_MODULE_INFO[index].title;
  }

  getOrderList() {
    this.isLoading = true;
    let param = {
      category: 0, // 门票订单
      orderStatus: this.orderTabIndex,
    } as GetOrderDetailRequest;

    https.getOrderList(param).then((res: ESObject) => {
      this.ticketOrderList = mapperTicketOrderList(res.data);
      this.isLoading = false;
    });
  }
}