import { AppStorageV2 } from '@kit.ArkUI';
import { https, GetHomeInfoResp, mapperAttractionsInfo } from 'network';
import { AttractionUtil, LazyDataSource, LocationUtil, Logger } from 'common';
import { AttractionInfo, RealTimeInfo, ToiletInfo } from 'module_base';
import { ContactInfo } from 'types';
import { ParkInfo } from '../model/HomeRollupInfo';
import { RealTimeItem } from '../model/Index';
import { BulletinInfo } from '../model/BulletinInfo';
import { mapperBulletinList } from '../mapper/Index';
import { ParkingSlotInfo } from '../model/ParkingSlotInfo';

@ObservedV2
export class HomePageVM {
  @Trace isLoading: boolean = true;
  @Trace parkingSlotList: LazyDataSource<ParkingSlotInfo> = new LazyDataSource();
  @Trace toiletList: LazyDataSource<ToiletInfo> = new LazyDataSource();
  @Trace bulletinList: LazyDataSource<BulletinInfo> = new LazyDataSource();
  @Trace hotAttractionList: LazyDataSource<AttractionInfo> = new LazyDataSource();
  @Trace attractionList: LazyDataSource<AttractionInfo> = new LazyDataSource();
  @Trace attractionListBanner: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Trace rollUpInfo: GetHomeInfoResp | null = null;
  @Trace realTimeInfos: RealTimeInfo[] = [];
  @Trace scenicImages: LazyDataSource<ResourceStr> = new LazyDataSource();
  public static _instance: HomePageVM;
  private contactInfo: ContactInfo = AppStorageV2.connect(ContactInfo, 'contactInfo', () => new ContactInfo())!;

  getParkingSpace(): number {
    let count = 0;
    this.rollUpInfo?.parks.forEach((item: ParkInfo) => {
      count += item.spaces;
    });
    return count;
  }

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  public constructor() {
    this.getRollupInfo();
    this.getAttractionList();
  }

  getAttractionList() {
    https.getAttractionList().then((res) => {
      // 将景点信息在本地缓存
      let attractions = mapperAttractionsInfo(res.data)
      AttractionUtil.setAttraction(attractions);
      this.attractionListBanner.pushArrayData(attractions.banners);
      this.attractionList.pushArrayData(attractions.attractions);
      this.hotAttractionList.pushArrayData(attractions.attractions.filter((item) => item.isHot === 1));
    });
  }

  getRollupInfo() {
    https.getHomeRollupInfo().then((res) => {
      this.rollUpInfo = res.data;
      this.scenicImages.pushArrayData(this.rollUpInfo.detailImages);
      this.realTimeInfos =
        [{ icon: $r('app.media.visitor'), item: RealTimeItem.CURRENT_VISITOR, count: this.rollUpInfo.currentVisitors },
          { icon: $r('app.media.parking'), item: RealTimeItem.PARKING_SPACE, count: this.getParkingSpace() }];
      this.contactInfo.consult = this.rollUpInfo.consultPhone;
      this.contactInfo.rescue = this.rollUpInfo.rescuePhone;
      this.contactInfo.complain = this.rollUpInfo.complaintPhone;
      LocationUtil.setLocationInfo(this.rollUpInfo.longitude, this.rollUpInfo.latitude);
    });
  }

  getBulletinList() {
    https.getBulletinList().then((res) => {
      this.bulletinList.pushArrayData(mapperBulletinList(res.data));
      this.isLoading = false;
      Logger.info('bulletin list is ' + this.bulletinList.totalCount());
    });
  }
}