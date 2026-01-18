import { AttractionInfo } from 'module_base';
import {
  GetAttractionDetailResp,
  GetBulletinDetailResp,
  GetBulletinListResp,
  GetHomeInfoResp,
} from 'network';
import { BulletinInfo } from '../model/BulletinInfo';

export function mapperAttractionInfo(attractionDetailResp: GetAttractionDetailResp) {
  let attractionInfo = new AttractionInfo();
  attractionInfo.attractionId = attractionDetailResp.attractionId;
  attractionInfo.labels = attractionDetailResp.labels;
  attractionInfo.detailImages = attractionDetailResp.detailImages;
  attractionInfo.brief = attractionDetailResp.brief;
  attractionInfo.name = attractionDetailResp.name;
  attractionInfo.location = attractionDetailResp.location;
  attractionInfo.longitude = attractionDetailResp.longitude;
  attractionInfo.latitude = attractionDetailResp.latitude;
  attractionInfo.banner = attractionDetailResp.banner;
  attractionInfo.introduction = attractionDetailResp.introduction;
  attractionInfo.consultPhone = attractionDetailResp.consultPhone;
  attractionInfo.audio = attractionDetailResp.audio;
  return attractionInfo;
}

export function mapperBulletinInfo(bulletinDetailResp: GetBulletinDetailResp) {
  let bulletinInfo = new BulletinInfo();
  bulletinInfo.id = bulletinDetailResp.id;
  bulletinInfo.title = bulletinDetailResp.title;
  bulletinInfo.detail = bulletinDetailResp.detail;
  bulletinInfo.releaseTime = bulletinDetailResp.releaseTime;
  bulletinInfo.banner = bulletinDetailResp.banner;
  bulletinInfo.detailImages = bulletinDetailResp.detailImages;
  return bulletinInfo;
}

export function mapperBulletinList(bulletinListResp: GetBulletinListResp) {
  let bulletinList: BulletinInfo[] = [];
  bulletinListResp.forEach(item => {
    let bulletinInfo = new BulletinInfo();
    bulletinInfo.id = item.id;
    bulletinInfo.title = item.title;
    bulletinInfo.releaseTime = item.releaseTime;
    bulletinList.push(bulletinInfo);
  });
  return bulletinList;
}

export function mapperHotAttraction(rollupInfo: GetHomeInfoResp) {
  let hotAttractionList: AttractionInfo[] = [];
  rollupInfo.hotAttractions.forEach(item => {
    let hotAttractionInfo = new AttractionInfo();
    hotAttractionInfo.attractionId = item.attractionId;
    hotAttractionInfo.name = item.name;
    hotAttractionInfo.banner = item.banner;
    hotAttractionInfo.detailImages = item.detailImages;
    hotAttractionInfo.labels = item.labels;
    hotAttractionList.push(hotAttractionInfo);
  });
  return hotAttractionList;
}