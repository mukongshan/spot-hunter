import { AxiosRequestHeaders } from '@ohos/axios';
import { RequestUrl } from '../constants/NetworkEnums';
import request from '../models/AxiosRequest';
import {
  AddressRequest,
  CreateTicketOrderRequest,
  GetOrderDetailRequest,
  PrepayResp,
  TouristRequest
} from '../types/AxiosRequestParam';
import { BaseResponse } from '../types/ResponseTypes';
import { GetAddressListResp } from '../types/responseTypes/GetAddressListResp';
import { GetAttractionDetailResp } from '../types/responseTypes/GetAttractionDetailResp';
import { GetAttractionsInfoResp } from '../types/responseTypes/GetAttractionListResp';
import { GetBulletinDetailResp } from '../types/responseTypes/GetBulletinDetailResp';
import { GetBulletinListResp } from '../types/responseTypes/GetBulletinListResp';
import { GetHomeInfoResp } from '../types/responseTypes/GetHomeRollUpInfoResp';
import { GetTicketDetailResp } from '../types/responseTypes/GetTicketDetailResp';
import { GetTicketListResp } from '../types/responseTypes/GetTicketListResp';
import { GetTouristListResp } from '../types/responseTypes/GetTouristListResp';

class HttpApi {
  // 公告相关接口
  public getBulletinList(): Promise<BaseResponse<GetBulletinListResp>> {
    return request.get({ url: RequestUrl.BULLETIN_GET_LIST, headers: {} as AxiosRequestHeaders });
  }

  public getBulletinDetail(bulletinId: number): Promise<BaseResponse<GetBulletinDetailResp>> {
    return request.post({
      url: RequestUrl.BULLETIN_GET_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: bulletinId
    });
  }

  // 首页相关接口
  public getHomeRollupInfo(): Promise<BaseResponse<GetHomeInfoResp>> {
    return request.get({ url: RequestUrl.HOME_GET_INFO, headers: {} as AxiosRequestHeaders });
  }

  // 景点相关接口
  public getAttractionList(): Promise<BaseResponse<GetAttractionsInfoResp>> {
    return request.get({ url: RequestUrl.ATTRACTION_GET_LIST, headers: {} as AxiosRequestHeaders, });
  }

  public getAttractionDetail(attractionId: number): Promise<BaseResponse<GetAttractionDetailResp>> {
    return request.post({
      url: RequestUrl.ATTRACTION_GET_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: attractionId
    });
  }

  // 门票相关接口
  public getTicketList(): Promise<BaseResponse<GetTicketListResp>> {
    return request.get({ url: RequestUrl.TICKET_GET_LIST, headers: {} as AxiosRequestHeaders });
  }

  public getTicketDetail(ticketId: number): Promise<BaseResponse<GetTicketDetailResp>> {
    return request.post({
      url: RequestUrl.TICKET_GET_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: ticketId
    });
  }

  // 游客管理相关接口(用于订单创建)
  public createTourist(data: TouristRequest): Promise<BaseResponse<undefined>> {
    return request.post({
      url: RequestUrl.TOURIST_CREATE,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public modifyTourist(data: TouristRequest): Promise<BaseResponse<undefined>> {
    return request.put({
      url: RequestUrl.TOURIST_MODIFY,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public deleteTourist(id: string): Promise<BaseResponse<undefined>> {
    return request.delete({
      url: RequestUrl.TOURIST_DELETE,
      headers: {} as AxiosRequestHeaders,
      data: id
    });
  }

  public getTouristList(touristsId?: string[]): Promise<BaseResponse<GetTouristListResp>> {
    return request.get({
      url: RequestUrl.TOURIST_GET_LIST,
      headers: {} as AxiosRequestHeaders,
      data: touristsId
    });
  }

  // 地址管理相关接口(用于订单创建)
  public createAddress(data: AddressRequest): Promise<BaseResponse<undefined>> {
    return request.post({
      url: RequestUrl.ADDRESS_CREATE,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public modifyAddress(data: AddressRequest): Promise<BaseResponse<undefined>> {
    return request.put({
      url: RequestUrl.ADDRESS_MODIFY,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public deleteAddress(id: string): Promise<BaseResponse<undefined>> {
    return request.delete({
      url: RequestUrl.ADDRESS_DELETE,
      headers: {} as AxiosRequestHeaders,
      data: id
    });
  }

  public getAddressList(): Promise<BaseResponse<GetAddressListResp>> {
    return request.get({
      url: RequestUrl.ADDRESS_GET_LIST,
      headers: {} as AxiosRequestHeaders,
    });
  }

  // 订单相关接口
  public createTicketOrder(data: CreateTicketOrderRequest): Promise<BaseResponse<PrepayResp>> {
    return request.post({
      url: RequestUrl.TICKET_ORDER_CREATE,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public modifyOrderDetail(data: GetOrderDetailRequest): Promise<BaseResponse<ESObject>> {
    return request.put({
      url: RequestUrl.ORDER_MODIFY,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public getOrderList(data: GetOrderDetailRequest): Promise<BaseResponse<ESObject>> {
    return request.get({
      url: RequestUrl.ORDER_LIST,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }

  public getOrderDetail(data: GetOrderDetailRequest): Promise<BaseResponse<ESObject>> {
    return request.post({
      url: RequestUrl.ORDER_DETAIL,
      headers: {} as AxiosRequestHeaders,
      data: data
    });
  }
}

const https = new HttpApi();

export { https };