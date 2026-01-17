import { GetBulletinListResp } from '../types/responseTypes/GetBulletinListResp';
import { BaseResponse } from '../types/ResponseTypes';
import { bulletinListMock } from './mockData/getBulletinList';
import { GetHomeInfoResp } from '../types/responseTypes/GetHomeRollUpInfoResp';
import { homeRollupInfoMock } from './mockData/getRollupInfo';
import { GetAttractionsInfoResp } from '../types/responseTypes/GetAttractionListResp';
import { attractionListMock } from './mockData/getAttractionList';
import { ticketListMock } from './mockData/getTicketList';
import { GetTicketListResp } from '../types/responseTypes/GetTicketListResp';
import { GetBulletinDetailResp } from '../types/responseTypes/GetBulletinDetailResp';
import { bulletinDetailList } from './mockData/getBulletinDetail';
import { attractionDetailsMock } from './mockData/getAttractionDetail';
import { GetAttractionDetailResp } from '../types/responseTypes/GetAttractionDetailResp';
import { GetTicketDetailResp } from '../types/responseTypes/GetTicketDetailResp';
import { ticketDetailListMock } from './mockData/getTicketDetail';
import {
  AddressRequest,
  CreateTicketOrderRequest,
  GetOrderDetailRequest,
  TouristRequest,
} from '../types/AxiosRequestParam';
import { GetTicketOrderListResp, TicketOrderListItem } from '../types/responseTypes/GetTicketOrderListResp';
import { AppStorageV2 } from '@kit.ArkUI';
import { GetTouristListResp, TouristListItem } from '../types/responseTypes/GetTouristListResp';
import { AddressListItem, GetAddressListResp } from '../types/responseTypes/GetAddressListResp';

class HttpApiMock {
  static addressListMock: GetAddressListResp =
    AppStorageV2.connect(GetAddressListResp, 'GetAddressListResp', () => new GetAddressListResp()) ?? [];
  static touristListMock: GetTouristListResp =
    AppStorageV2.connect(GetTouristListResp, 'GetTouristListResp', () => new GetTouristListResp()) ?? [];
  static ticketOrderListMock: GetTicketOrderListResp =
    AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => new GetTicketOrderListResp()) ?? [];

  public getBulletinList(): Promise<BaseResponse<GetBulletinListResp>> {
    return Promise.resolve(bulletinListMock);
  }

  public getBulletinDetail(bulletinId: number): Promise<BaseResponse<GetBulletinDetailResp>> {
    return Promise.resolve({
      code: 0,
      data: bulletinDetailList.find((item) => item.id === bulletinId),
    } as BaseResponse<GetBulletinDetailResp>);
  }

  public getHomeRollupInfo(): Promise<BaseResponse<GetHomeInfoResp>> {
    return Promise.resolve(homeRollupInfoMock);
  }

  public getAttractionList(): Promise<BaseResponse<GetAttractionsInfoResp>> {
    return Promise.resolve(attractionListMock);
  }

  public getAttractionDetail(attractionId: number): Promise<BaseResponse<GetAttractionDetailResp>> {
    return Promise.resolve({
      code: 0,
      data: attractionDetailsMock.find(item => item.attractionId === attractionId),
    } as BaseResponse<GetAttractionDetailResp>);
  }

  public getTicketList(): Promise<BaseResponse<GetTicketListResp>> {
    return Promise.resolve(ticketListMock);
  }

  public getTicketDetail(ticketId: number): Promise<BaseResponse<GetTicketDetailResp>> {
    return Promise.resolve({
      code: 0,
      data: ticketDetailListMock.find(item => item.ticketId === ticketId),
    } as BaseResponse<GetTicketDetailResp>);
  }

  public createTicketOrder(data: CreateTicketOrderRequest) {
    let ticketOrderList: GetTicketOrderListResp =
      AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => new GetTicketOrderListResp())!;
    let ticketOrder: TicketOrderListItem = {
      orderNo: data.orderNo,
      orderTime: data.orderTime,
      orderStatus: data.orderStatus,
      count: data.count,
      touristId: data.touristId,
      contactId: data.contactId,
      productName: data.productName,
      productPrice: data.productPrice,
      discount: 0,
      amount: data.productPrice * data.count,
      startTime: data.startTime,
      endTime: data.endTime,
    };

    if (ticketOrderList) {
      ticketOrderList.unshift(ticketOrder);
      AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => ticketOrderList);
    } else {
      AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => [ticketOrder]);
    }

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  static getTouristDetail(touristsId: string[]): GetTouristListResp {
    let touristList: GetTouristListResp = [];
    touristsId.forEach(item => {
      let list = HttpApiMock.touristListMock.filter((touristId) => touristId.id === item);
      touristList.push(...list);
    });
    return touristList;
  }

  public getOrderList(param: GetOrderDetailRequest): Promise<BaseResponse<ESObject>> {
    const resp: BaseResponse<ESObject> = {
      code: 0,
      data: HttpApiMock.getTicketOrderList(param.orderStatus ?? 0),
    };

    return Promise.resolve(resp);
  }

  public modifyOrderDetail(param: GetOrderDetailRequest): Promise<BaseResponse<undefined>> {
    HttpApiMock.modifyTicketOrderDetail(param.orderStatus ?? 0, param.orderNo ?? '');

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };

    return Promise.resolve(resp);
  }

  static modifyTicketOrderDetail(orderStatus: number, orderNo: string) {
    let list = HttpApiMock.ticketOrderListMock.filter(item => item.orderNo !== orderNo);
    let item = HttpApiMock.ticketOrderListMock.filter(item => item.orderNo === orderNo);
    item[0].orderStatus = orderStatus;
    list.unshift(item[0]);
    AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp', () => list)!;
  }

  public getOrderDetail(param: GetOrderDetailRequest): Promise<BaseResponse<ESObject>> {
    const resp: BaseResponse<ESObject> = {
      code: 0,
      data: HttpApiMock.getTicketOrderDetail(param.orderNo ?? ''),
    };
    return Promise.resolve(resp);
  }

  static getTicketOrderList(orderStatus: number): TicketOrderListItem[] {
    if (orderStatus === 0) {
      return HttpApiMock.ticketOrderListMock;
    } else {
      return HttpApiMock.ticketOrderListMock.filter((item: TicketOrderListItem) => item.orderStatus === orderStatus);
    }
  }

  static getTicketOrderDetail(orderNo: string): TicketOrderListItem[] {
    return HttpApiMock.ticketOrderListMock.filter((item: TicketOrderListItem) => item.orderNo === orderNo);
  }

  public modifyTourist(data: TouristRequest) {
    let tourist: TouristListItem = {
      id: data.id,
      name: data.name,
      phone: data.phone,
      cardType: data.cardType,
      cardNo: data.cardNo,
      isChecked: data.isChecked,
    };

    let index = HttpApiMock.touristListMock.findIndex(item => item.id === tourist.id);

    HttpApiMock.touristListMock.splice(index, 1, tourist);

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public deleteTourist(id: string) {
    let list = HttpApiMock.touristListMock.filter((item: TouristListItem) => item.id !== JSON.stringify(id));
    HttpApiMock.touristListMock = list;

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public createTourist(data: TouristRequest) {
    let tourist: TouristListItem = {
      id: data.id,
      name: data.name,
      phone: data.phone,
      cardType: data.cardType,
      cardNo: data.cardNo,
      isChecked: data.isChecked,
    };

    let isExist = HttpApiMock.touristListMock.some((item => item.id === tourist.id));

    if (HttpApiMock.touristListMock && !isExist) {
      HttpApiMock.touristListMock.push(tourist);
    } else {
      HttpApiMock.touristListMock = [tourist];
    }

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public createAddress(data: AddressRequest) {
    // 为默认地址，清空当前默认状态
    HttpApiMock.addressListMock.map((item) => {
      item.type = 0;
    });

    let address: AddressListItem = {
      id: data.id,
      name: data.name,
      phone: data.phone,
      district: data.district,
      detail: data.detail,
      type: data.type,
    };

    if (HttpApiMock.addressListMock) {
      HttpApiMock.addressListMock.push(address);
    } else {
      HttpApiMock.addressListMock = [address]
      AppStorageV2.connect(GetAddressListResp, 'GetAddressListResp', () => [address])!;
    }

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public modifyAddress(data: AddressRequest) {
    // 为默认地址，清空当前默认状态
    HttpApiMock.addressListMock.map((item) => {
      item.type = 0;
    });

    let address: AddressListItem = {
      id: data.id,
      name: data.name,
      phone: data.phone,
      district: data.district,
      detail: data.detail,
      type: data.type,
    };

    let index = HttpApiMock.addressListMock.indexOf(address);

    HttpApiMock.addressListMock.splice(index, 1, address);

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public deleteAddress(id: string) {
    let list = HttpApiMock.addressListMock.filter((item: AddressListItem) => item.id !== JSON.stringify(id));
    HttpApiMock.addressListMock = list;

    const resp: BaseResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  public getAddressList() {
    const resp: BaseResponse<GetAddressListResp> = {
      code: 0,
      data: HttpApiMock.addressListMock,
    };
    return Promise.resolve(resp);
  }

  public getTouristList(touristsId?: string[]) {
    const resp: BaseResponse<GetTouristListResp> = {
      code: 0,
      data: touristsId?.length ? HttpApiMock.getTouristDetail(touristsId) : HttpApiMock.touristListMock,
    };
    return Promise.resolve(resp);
  }
}

const httpsMock = new HttpApiMock();

export { httpsMock };
