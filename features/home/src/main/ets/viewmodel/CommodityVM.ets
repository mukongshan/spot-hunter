import { LazyDataSource, Logger } from 'common';
// import { https } from 'network';  // 已删除Commodity相关API
import { mapperCommodityList } from '../mapper/Index';
import { CommodityInfo } from '../model/CommodityInfo';

@ObservedV2
export class CommodityVM {
  public static _instance: CommodityVM;
  @Trace type: number = 0;
  @Trace commodityList: LazyDataSource<CommodityInfo> = new LazyDataSource();

  public static get instance() {
    if (!CommodityVM._instance) {
      CommodityVM._instance = new CommodityVM();
    }
    return CommodityVM._instance;
  }

  getCommodityList() {
    // TODO: Commodity功能已移除,此文件应删除
    // https.getCommodityList(this.type).then((res: BaseResponse<GetCommodityListResp>) => {
    //   this.commodityList.pushArrayData(mapperCommodityList(res.data));
    //   Logger.info('commodity count is' + this.commodityList.totalCount());
    // });
  }
}