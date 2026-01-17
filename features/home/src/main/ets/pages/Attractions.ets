import { LazyDataSource } from 'common';
import { AttractionInfo } from 'module_base';
import { SwiperComponent, TitleBar } from 'uicomponents';
import { HomePageVM } from '../viewmodel/HomePageVM';
import { picker } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { map, mapCommon, site } from '@kit.MapKit';

interface SimpleAttraction {
  id: number;
  name: string;
  location: string;
  description: string;
  imageUri: string;
  latitude: number;
  longitude: number;
}

interface POISearchResult {
  name: string;
  address: string;
  latitude: number;
  longitude: number;
}

@Builder
export function AttractionsBuilder() {
  Attractions();
}

@ComponentV2
export struct Attractions {
  vm: HomePageVM = HomePageVM.instance;
  @Local banners: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local userRole: string = AppStorage.get<string>('userRole') || '';
  @Local adminAttractions: SimpleAttraction[] = AppStorage.get<SimpleAttraction[]>('adminAttractions') || [];
  @Local showAddDialog: boolean = false;
  @Local showEditDialog: boolean = false;
  @Local showDeleteDialog: boolean = false;
  @Local showLocationPicker: boolean = false;
  @Local editingAttraction: SimpleAttraction | null = null;
  @Local newAttractionName: string = '';
  @Local newAttractionLocation: string = '';
  @Local newAttractionDescription: string = '';
  @Local newAttractionImageUri: string = '';
  @Local newAttractionLatitude: number = 0;
  @Local newAttractionLongitude: number = 0;
  @Local locationSearchQuery: string = '';
  @Local searchResults: POISearchResult[] = [];
  @Local isSearching: boolean = false;

  saveAttractions() {
    AppStorage.setOrCreate('adminAttractions', this.adminAttractions);
  }

  async selectImage() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      const photoViewPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);
      if (photoSelectResult.photoUris.length > 0) {
        this.newAttractionImageUri = photoSelectResult.photoUris[0];
      }
    } catch (err) {
      console.error('选择图片失败:', JSON.stringify(err));
    }
  }

  async searchLocation() {
    if (!this.locationSearchQuery.trim()) {
      return;
    }
    this.isSearching = true;
    try {
      const params: site.SearchByTextParams = {
        query: this.locationSearchQuery,
        location: { latitude: 22.543096, longitude: 114.057865 },
        radius: 50000,
        language: 'zh-CN',
        pageSize: 10,
        pageIndex: 1
      };
      
      const results = await site.searchByText(params);
      this.searchResults = [];
      if (results && results.sites) {
        results.sites.forEach((siteItem: site.Site) => {
          if (siteItem.location) {
            this.searchResults.push({
              name: siteItem.name || '',
              address: siteItem.formatAddress || '',
              latitude: siteItem.location.latitude,
              longitude: siteItem.location.longitude
            });
          }
        });
      }
    } catch (err) {
      console.error('搜索位置失败:', JSON.stringify(err));
    }
    this.isSearching = false;
  }

  selectLocation(result: POISearchResult) {
    this.newAttractionLocation = result.address || result.name;
    this.newAttractionLatitude = result.latitude;
    this.newAttractionLongitude = result.longitude;
    this.showLocationPicker = false;
    this.locationSearchQuery = '';
    this.searchResults = [];
  }

  addAttraction() {
    if (!this.newAttractionName || !this.newAttractionLocation || 
        !this.newAttractionDescription || !this.newAttractionImageUri ||
        this.newAttractionLatitude === 0 || this.newAttractionLongitude === 0) {
      return;
    }
    const newId = this.adminAttractions.length > 0 ?
      Math.max(...this.adminAttractions.map(a => a.id)) + 1 : 1;
    this.adminAttractions.push({
      id: newId,
      name: this.newAttractionName,
      location: this.newAttractionLocation,
      description: this.newAttractionDescription,
      imageUri: this.newAttractionImageUri,
      latitude: this.newAttractionLatitude,
      longitude: this.newAttractionLongitude
    });
    this.saveAttractions();
    this.showAddDialog = false;
    this.resetAddForm();
  }

  resetAddForm() {
    this.newAttractionName = '';
    this.newAttractionLocation = '';
    this.newAttractionDescription = '';
    this.newAttractionImageUri = '';
    this.newAttractionLatitude = 0;
    this.newAttractionLongitude = 0;
  }

  editAttraction() {
    if (!this.editingAttraction) return;
    const index = this.adminAttractions.findIndex(a => a.id === this.editingAttraction!.id);
    if (index !== -1) {
      this.adminAttractions[index] = {
        id: this.editingAttraction.id,
        name: this.editingAttraction.name,
        location: this.editingAttraction.location,
        description: this.editingAttraction.description,
        imageUri: this.editingAttraction.imageUri,
        latitude: this.editingAttraction.latitude,
        longitude: this.editingAttraction.longitude
      };
      this.saveAttractions();
    }
    this.showEditDialog = false;
    this.editingAttraction = null;
  }

  deleteAttraction() {
    if (!this.editingAttraction) return;
    this.adminAttractions = this.adminAttractions.filter(a => a.id !== this.editingAttraction!.id);
    this.saveAttractions();
    this.showDeleteDialog = false;
    this.editingAttraction = null;
  }

  @Builder
  AttractionItemBuilder(attraction: AttractionInfo) {
    Row() {
      Image(attraction.banner).size({ width: 96, height: 96 }).borderRadius(8);
      Column() {
        Text(attraction.name).fontWeight(500);
        Row() {
          ForEach(attraction.labels, (item: string) => {
            Text(item)
              .fontSize(10)
              .border({ width: 1, radius: 4, color: '#2EB78A' })
              .padding(2)
              .fontColor('#2EB78A')
              .margin({ right: 4 });
          }, (item: string) => item);
        }.margin({ top: 4, bottom: 8 });

        Row() {
          ForEach(attraction.detailImages, (item: ResourceStr) => {
            Image(item).size({ height: 48, width: 48 }).borderRadius(8).margin({ right: 8 });
          }, (item: ResourceStr) => item.toString());
        };
      }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween).margin({ left: 8 });
    }.onClick(() => {
      this.mainPathStack.pushPathByName('AttractionDetail', attraction.attractionId);
    });
  }

  @Builder
  AdminAttractionItemBuilder(attraction: SimpleAttraction) {
    Row() {
      if (attraction.imageUri) {
        Image(attraction.imageUri)
          .size({ width: 80, height: 80 })
          .borderRadius(8)
          .margin({ right: 12 });
      }

      Column({ space: 4 }) {
        Text(attraction.name).fontSize(16).fontWeight(500);
        Text(attraction.location).fontSize(12).fontColor('#666').maxLines(1);
        Text(attraction.description).fontSize(12).fontColor('#999').maxLines(2);
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

      if (this.userRole === 'admin') {
        Row({ space: 8 }) {
          Button('编辑')
            .fontSize(12)
            .height(32)
            .backgroundColor('#007DFF')
            .onClick(() => {
              this.editingAttraction = {
                id: attraction.id,
                name: attraction.name,
                location: attraction.location,
                description: attraction.description,
                imageUri: attraction.imageUri,
                latitude: attraction.latitude,
                longitude: attraction.longitude
              };
              this.showEditDialog = true;
            });
          Button('删除')
            .fontSize(12)
            .height(32)
            .backgroundColor('#FF3B30')
            .onClick(() => {
              this.editingAttraction = {
                id: attraction.id,
                name: attraction.name,
                location: attraction.location,
                description: attraction.description,
                imageUri: attraction.imageUri,
                latitude: attraction.latitude,
                longitude: attraction.longitude
              };
              this.showDeleteDialog = true;
            });
        };
      }
    }
    .padding(12)
    .backgroundColor('#FFF')
    .borderRadius(8)
    .width('100%');
  }

  @Builder
  AddAttractionDialog() {
    Column({ space: 16 }) {
      Text('添加新景点')
        .fontSize(18)
        .fontWeight(700);

      // 图片上传
      Column({ space: 8 }) {
        Text('景点图片 *').fontSize(14).fontColor('#333').alignSelf(ItemAlign.Start);
        if (this.newAttractionImageUri) {
          Image(this.newAttractionImageUri)
            .width('100%')
            .height(150)
            .borderRadius(8)
            .objectFit(ImageFit.Cover);
        }
        Button(this.newAttractionImageUri ? '更换图片' : '上传图片')
          .width('100%')
          .backgroundColor('#E8F5E9')
          .fontColor('#64BB5C')
          .onClick(() => this.selectImage());
      }
      .alignItems(HorizontalAlign.Start);

      TextInput({ placeholder: '景点名称 *', text: $$this.newAttractionName })
        .height(44);

      // 位置选择
      Column({ space: 8 }) {
        Text('景点位置 *').fontSize(14).fontColor('#333').alignSelf(ItemAlign.Start);
        Button(this.newAttractionLocation || '选择地图位置')
          .width('100%')
          .backgroundColor('#E3F2FD')
          .fontColor('#007DFF')
          .onClick(() => {
            this.showLocationPicker = true;
          });
        if (this.newAttractionLocation) {
          Text(this.newAttractionLocation)
            .fontSize(12)
            .fontColor('#666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
      }
      .alignItems(HorizontalAlign.Start);

      TextArea({ placeholder: '景点描述 *', text: $$this.newAttractionDescription })
        .height(88);

      if (!this.newAttractionName || !this.newAttractionLocation || 
          !this.newAttractionDescription || !this.newAttractionImageUri) {
        Text('请填写所有必填项并上传图片')
          .fontSize(12)
          .fontColor('#FF9500')
          .padding(8)
          .backgroundColor('#FFF8E1')
          .borderRadius(4);
      }

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F0F0F0')
          .fontColor('#333')
          .onClick(() => {
            this.showAddDialog = false;
            this.resetAddForm();
          });
        Button('添加')
          .layoutWeight(1)
          .backgroundColor('#64BB5C')
          .enabled(!(!this.newAttractionName || !this.newAttractionLocation || 
            !this.newAttractionDescription || !this.newAttractionImageUri))
          .onClick(() => this.addAttraction());
      };
    }
    .padding(20)
    .backgroundColor('#FFF')
    .borderRadius(12)
    .constraintSize({ maxHeight: '80%' });
  }

  @Builder
  LocationPickerDialog() {
    Column({ space: 16 }) {
      Text('选择景点位置')
        .fontSize(18)
        .fontWeight(700);

      Text('搜索地图上的真实位置')
        .fontSize(12)
        .fontColor('#666');

      Row({ space: 8 }) {
        TextInput({ placeholder: '输入位置关键词搜索', text: $$this.locationSearchQuery })
          .layoutWeight(1)
          .height(44);
        Button('搜索')
          .height(44)
          .backgroundColor('#64BB5C')
          .onClick(() => this.searchLocation());
      };

      if (this.isSearching) {
        Row() {
          Text('搜索中...').fontSize(14).fontColor('#999');
        }
        .height(100)
        .justifyContent(FlexAlign.Center);
      } else if (this.searchResults.length > 0) {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.searchResults, (result: POISearchResult) => {
              Column({ space: 4 }) {
                Text(result.name)
                  .fontSize(14)
                  .fontWeight(500);
                Text(result.address)
                  .fontSize(12)
                  .fontColor('#666')
                  .maxLines(2);
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .alignItems(HorizontalAlign.Start)
              .onClick(() => this.selectLocation(result));
            }, (result: POISearchResult) => result.name + result.address);
          };
        }
        .height(250)
        .scrollBar(BarState.Auto);
      } else if (this.locationSearchQuery) {
        Row() {
          Text('未找到相关位置,请重新搜索').fontSize(14).fontColor('#999');
        }
        .height(100)
        .justifyContent(FlexAlign.Center);
      }

      Button('取消')
        .width('100%')
        .backgroundColor('#F0F0F0')
        .fontColor('#333')
        .onClick(() => {
          this.showLocationPicker = false;
          this.locationSearchQuery = '';
          this.searchResults = [];
        });
    }
    .padding(20)
    .backgroundColor('#FFF')
    .borderRadius(12)
    .constraintSize({ maxHeight: '70%' });
  }

  @Builder
  EditAttractionDialog() {
    if (this.editingAttraction) {
      Column({ space: 16 }) {
        Text('编辑景点')
          .fontSize(18)
          .fontWeight(700);

        // 图片显示和更换
        Column({ space: 8 }) {
          Text('景点图片').fontSize(14).fontColor('#333').alignSelf(ItemAlign.Start);
          if (this.editingAttraction.imageUri) {
            Image(this.editingAttraction.imageUri)
              .width('100%')
              .height(150)
              .borderRadius(8)
              .objectFit(ImageFit.Cover);
          }
          Button('更换图片')
            .width('100%')
            .backgroundColor('#E8F5E9')
            .fontColor('#64BB5C')
            .onClick(async () => {
              try {
                const photoSelectOptions = new picker.PhotoSelectOptions();
                photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
                photoSelectOptions.maxSelectNumber = 1;
                const photoViewPicker = new picker.PhotoViewPicker();
                const photoSelectResult = await photoViewPicker.select(photoSelectOptions);
                if (photoSelectResult.photoUris.length > 0 && this.editingAttraction) {
                  this.editingAttraction.imageUri = photoSelectResult.photoUris[0];
                }
              } catch (err) {
                console.error('选择图片失败:', JSON.stringify(err));
              }
            });
        }
        .alignItems(HorizontalAlign.Start);

        TextInput({ placeholder: '景点名称', text: $$this.editingAttraction.name })
          .height(44);

        // 位置显示(编辑时不允许修改位置,避免复杂性)
        Column({ space: 4 }) {
          Text('景点位置').fontSize(14).fontColor('#333').alignSelf(ItemAlign.Start);
          Text(this.editingAttraction.location)
            .width('100%')
            .padding(12)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .fontSize(14)
            .fontColor('#666');
          Text('提示: 位置信息不可修改')
            .fontSize(11)
            .fontColor('#999');
        }
        .alignItems(HorizontalAlign.Start);

        TextArea({ placeholder: '景点描述', text: $$this.editingAttraction.description })
          .height(88);

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .backgroundColor('#F0F0F0')
            .fontColor('#333')
            .onClick(() => {
              this.showEditDialog = false;
              this.editingAttraction = null;
            });
          Button('保存')
            .layoutWeight(1)
            .backgroundColor('#64BB5C')
            .onClick(() => this.editAttraction());
        };
      }
      .padding(20)
      .backgroundColor('#FFF')
      .borderRadius(12)
      .constraintSize({ maxHeight: '80%' });
    }
  }

  @Builder
  DeleteConfirmDialog() {
    if (this.editingAttraction) {
      Column({ space: 16 }) {
        Text('确认删除')
          .fontSize(18)
          .fontWeight(700);

        Text(`确定要删除景点"${this.editingAttraction.name}"吗?`)
          .fontSize(14)
          .fontColor('#666');

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .backgroundColor('#F0F0F0')
            .fontColor('#333')
            .onClick(() => {
              this.showDeleteDialog = false;
              this.editingAttraction = null;
            });
          Button('删除')
            .layoutWeight(1)
            .backgroundColor('#FF3B30')
            .onClick(() => this.deleteAttraction());
        };
      }
      .padding(20)
      .backgroundColor('#FFF')
      .borderRadius(12);
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          TitleBar({
            isShowBack: true, title: '景点列表', clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          Scroll() {
            Column() {
              SwiperComponent(this.vm.attractionListBanner);

              Column() {
                // 系统默认景点
                Text('系统景点')
                  .fontSize(16)
                  .fontWeight(700)
                  .margin({ bottom: 8 });
                
                List({ space: 12 }) {
                  LazyForEach(this.vm.attractionList, (item: AttractionInfo) => {
                    this.AttractionItemBuilder(item);
                  });
                };

                // 管理员添加的景点
                if (this.adminAttractions.length > 0) {
                  Row() {
                    Text('自定义景点')
                      .fontSize(16)
                      .fontWeight(700);
                    
                    if (this.userRole === 'admin') {
                      Text(`(${this.adminAttractions.length})`)
                        .fontSize(14)
                        .fontColor('#999')
                        .margin({ left: 4 });
                    }
                  }
                  .margin({ top: 24, bottom: 8 });

                  List({ space: 12 }) {
                    ForEach(this.adminAttractions, (item: SimpleAttraction) => {
                      this.AdminAttractionItemBuilder(item);
                    }, (item: SimpleAttraction) => item.id.toString());
                  };
                }

                // 管理员添加新景点按钮
                if (this.userRole === 'admin') {
                  Button('+ 添加新景点')
                    .width('100%')
                    .height(44)
                    .margin({ top: 16 })
                    .backgroundColor('#64BB5C')
                    .onClick(() => {
                      this.showAddDialog = true;
                    });
                }
              }.padding(12);
            };
          }.height('90%').align(Alignment.Top).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring);
        };

        // 对话框
        if (this.showAddDialog && !this.showLocationPicker) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showAddDialog = false;
            });
          
          Column() {
            this.AddAttractionDialog();
          }
          .width('85%')
          .justifyContent(FlexAlign.Center);
        }

        if (this.showLocationPicker) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showLocationPicker = false;
            });
          
          Column() {
            this.LocationPickerDialog();
          }
          .width('85%')
          .justifyContent(FlexAlign.Center);
        }

        if (this.showEditDialog) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showEditDialog = false;
            });
          
          Column() {
            this.EditAttractionDialog();
          }
          .width('85%')
          .justifyContent(FlexAlign.Center);
        }

        if (this.showDeleteDialog) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showDeleteDialog = false;
            });
          
          Column() {
            this.DeleteConfirmDialog();
          }
          .width('85%')
          .justifyContent(FlexAlign.Center);
        }
      }
      .width('100%')
      .height('100%');
    }.hideTitleBar(true);
  }
}