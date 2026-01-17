import { MapComponent, map, mapCommon, site } from '@kit.MapKit';
import { AttractionInfo, AttractionUtil } from 'module_base';
import { LocationUtil } from 'common';

// 简单的景点数据接口（与管理端保持一致）
interface SimpleAttraction {
  id: number;
  name: string;
  latitude: number;
  longitude: number;
  description: string;
}

// 搜索结果接口（兼容景点和地图POI）
interface SearchResult {
  name: string;
  latitude: number;
  longitude: number;
  address?: string;
  type: 'attraction' | 'poi'; // 区分是景点还是地图POI
}

@Builder
export function GuideBuilder() {
  GuideView();
}

@ComponentV2
struct GuideView {
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local attractionList: AttractionInfo[] = AttractionUtil.getAttraction().attractions;
  @Local adminAttractions: SimpleAttraction[] = [];
  @Local allAttractions: (AttractionInfo | SimpleAttraction)[] = [];
  @Local latitude: number = LocationUtil.getLocationInfo().latitude || 22.92;
  @Local longitude: number = LocationUtil.getLocationInfo().longitude || 113.86;
  @Local searchText: string = '';
  @Local showSearchResult: boolean = false;
  @Local searchResults: SearchResult[] = [];
  @Local isSearching: boolean = false;
  
  private mapController?: map.MapComponentController;
  private mapOptions?: mapCommon.MapOptions;
  private callback?: (err: object, mapController: map.MapComponentController) => void;

  aboutToAppear() {
    this.initMapOptions();
    this.loadAllAttractions();
  }

  loadAllAttractions() {
    // 加载管理端添加的景点
    const stored = AppStorage.get<SimpleAttraction[]>('adminAttractions');
    if (stored && stored.length > 0) {
      this.adminAttractions = stored;
    }
    
    // 合并所有景点
    this.allAttractions = [...this.attractionList, ...this.adminAttractions];
    
    // 自动定位到第一个景区
    if (this.allAttractions.length > 0) {
      const firstAttraction = this.allAttractions[0];
      this.latitude = firstAttraction.latitude;
      this.longitude = firstAttraction.longitude;
    }
    
    // 如果地图已加载，重新绘制标注
    if (this.mapController) {
      this.mapController.clear();
      this.drawAttractions();
    }
  }

  onPageShow() {
    // 页面显示时重新加载景点（以获取管理端的更新）
    this.loadAllAttractions();
  }

  initMapOptions() {
    let location: mapCommon.CameraPosition = {
      target: {
        latitude: this.latitude,
        longitude: this.longitude,
      },
      zoom: 14,
    };

    this.mapOptions = {
      position: location,
      myLocationControlsEnabled: true,
      compassControlsEnabled: false,
      scaleControlsEnabled: true,
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController.setBuildingEnabled(true);
        this.mapController?.setMyLocationEnabled(true);
        this.mapController.setDayNightMode(mapCommon.DayNightMode.AUTO);
        this.mapController.setMinZoom(2);
        this.mapController.setMaxZoom(18);
        
        // 绘制景点标注
        this.drawAttractions();
      }
    };
  }

  async drawAttractions() {
    if (this.mapController && this.allAttractions.length > 0) {
      // 绘制所有景点（包括系统自带的和管理端添加的）
      for (let i = 0; i < this.allAttractions.length; i++) {
        let attraction = this.allAttractions[i];
        let pointAnnotationOptions: mapCommon.PointAnnotationParams = {
          position: {
            latitude: attraction.latitude,
            longitude: attraction.longitude,
          },
          repeatable: true,
          collisionRule: mapCommon.CollisionRule.NAME,
          titles: [{
            content: attraction.name,
            fontSize: 12,
            strokeColor: 0xFF000000,
            strokeWidth: 2,
            fontStyle: mapCommon.FontStyle.BOLD,
          }],
        };
        
        try {
          await this.mapController.addPointAnnotation(pointAnnotationOptions);
        } catch (error) {
          console.error(`添加景点标注失败: ${attraction.name}`, error);
        }
      }
    }
  }

  async handleSearch(text: string) {
    console.info('搜索文本:', text);
    this.searchText = text;
    if (text.trim() === '') {
      this.showSearchResult = false;
      this.searchResults = [];
      return;
    }
    
    this.isSearching = true;
    this.searchResults = [];
    
    // 1. 搜索本地景点
    const localResults: SearchResult[] = this.allAttractions
      .filter((item: AttractionInfo | SimpleAttraction) => 
        item.name.toLowerCase().includes(text.toLowerCase()))
      .map((item: AttractionInfo | SimpleAttraction): SearchResult => {
        return {
          name: item.name,
          latitude: item.latitude,
          longitude: item.longitude,
          type: 'attraction'
        };
      });
    
    // 2. 搜索地图POI
    try {
      const params: site.SearchByTextParams = {
        query: text,
        location: {
          latitude: this.latitude,
          longitude: this.longitude
        },
        radius: 10000, // 搜索半径10公里
        language: 'zh_CN',
      };
      
      const result = await site.searchByText(params);
      console.info('地图POI搜索结果:', result.sites?.length || 0);
      
      if (result.sites && result.sites.length > 0) {
        const poiResults: SearchResult[] = result.sites
          .filter((siteItem: site.Site) => siteItem.location !== undefined)
          .map((siteItem: site.Site): SearchResult => {
            return {
              name: siteItem.name || '未知地点',
              latitude: siteItem.location!.latitude,
              longitude: siteItem.location!.longitude,
              address: siteItem.formatAddress || '',
              type: 'poi'
            };
          });
        
        // 合并结果,本地景点优先
        this.searchResults = [...localResults, ...poiResults];
      } else {
        this.searchResults = localResults;
      }
    } catch (error) {
      console.error('地图POI搜索失败:', JSON.stringify(error));
      // 如果POI搜索失败，至少显示本地景点结果
      this.searchResults = localResults;
    }
    
    this.isSearching = false;
    this.showSearchResult = this.searchResults.length > 0;
    console.info('总搜索结果数量:', this.searchResults.length);
  }

  moveToLocation(result: SearchResult) {
    if (this.mapController) {
      let position: mapCommon.CameraPosition = {
        target: {
          latitude: result.latitude,
          longitude: result.longitude,
        },
        zoom: 16,
      };
      let cameraUpdate: map.CameraUpdate = map.newCameraPosition(position);
      this.mapController.animateCamera(cameraUpdate, 1000);
      this.showSearchResult = false;
      this.searchText = '';
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        MapComponent({
          mapOptions: this.mapOptions,
          mapCallback: this.callback,
        })
        .width('100%')
        .height('100%');

        // 搜索结果列表显示在底部搜索栏上方
        if (this.showSearchResult || this.isSearching) {
          Column() {
            if (this.isSearching) {
              Row() {
                Text('搜索中...')
                  .fontSize(14)
                  .fontColor('#666666')
                  .padding(12);
              }
              .width('100%')
              .justifyContent(FlexAlign.Center);
            } else {
              List() {
                ForEach(this.searchResults, (item: SearchResult) => {
                  ListItem() {
                    Column({ space: 4 }) {
                      Row() {
                        Text(item.name)
                          .fontSize(14)
                          .fontColor('#333333')
                          .fontWeight(500)
                          .maxLines(1);
                        
                        if (item.type === 'attraction') {
                          Text('景点')
                            .fontSize(10)
                            .fontColor('#007DFF')
                            .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                            .backgroundColor('#E3F2FD')
                            .borderRadius(4)
                            .margin({ left: 8 });
                        }
                      }
                      .width('100%');
                      
                      if (item.address) {
                        Text(item.address)
                          .fontSize(12)
                          .fontColor('#999999')
                          .maxLines(1);
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width('100%')
                    .padding(12)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(8)
                    .onClick(() => {
                      this.moveToLocation(item);
                    });
                  }
                  .margin({ bottom: 4 });
                }, (item: SearchResult, index: number) => {
                  return `${item.type}_${item.name}_${index}`;
                });
              }
              .width('100%')
              .height(200)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding(8);
            }
          }
          .width('90%')
          .margin({ bottom: 64, left: '5%', right: '5%' });
        }

        // 搜索栏固定在底部
        Row() {
          TextInput({ placeholder: '搜索景点...', text: $$this.searchText })
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#FFFFFF')
            .borderRadius({ topLeft: 22, bottomLeft: 22 })
            .padding({ left: 16, right: 8 })
            .onSubmit(() => {
              this.handleSearch(this.searchText);
            });

          Button({ type: ButtonType.Normal }) {
            Text('搜索')
              .fontSize(14)
              .fontColor('#FFFFFF');
          }
          .width(60)
          .height(44)
          .backgroundColor('#007DFF')
          .borderRadius({ topRight: 22, bottomRight: 22 })
          .onClick(() => {
            this.handleSearch(this.searchText);
          });
        }
        .width('90%')
        .margin({ bottom: 10, left: '5%', right: '5%' });
      }
      .width('100%')
      .height('100%');
    }
    .hideTitleBar(true)
    .onAppear(() => {
      this.onPageShow();
    });
  }
}
