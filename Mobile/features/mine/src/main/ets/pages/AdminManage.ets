// 简单的景点数据接口
interface SimpleAttraction {
  id: number;
  name: string;
  latitude: number;
  longitude: number;
  description: string;
}

@Builder
export function AdminManageBuilder() {
  AdminManageView();
}

@ComponentV2
struct AdminManageView {
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local attractionList: SimpleAttraction[] = [];
  @Local showAddDialog: boolean = false;
  @Local showEditDialog: boolean = false;
  @Local showDeleteDialog: boolean = false;
  @Local newAttractionName: string = '';
  @Local newAttractionLat: string = '22.92';
  @Local newAttractionLon: string = '113.86';
  @Local newAttractionDesc: string = '';
  @Local editingIndex: number = -1;
  @Local deletingIndex: number = -1;

  aboutToAppear() {
    // 检查是否是管理员
    const role = AppStorage.get<string>('userRole');
    if (role !== 'admin') {
      this.mainPathStack.pop();
      return;
    }
    
    // 从本地存储加载景点列表
    this.loadAttractions();
  }

  loadAttractions() {
    const stored = AppStorage.get<SimpleAttraction[]>('adminAttractions');
    if (stored && stored.length > 0) {
      this.attractionList = stored;
    } else {
      // 初始化一些示例数据
      this.attractionList = [
        { id: 1, name: '松山湖', latitude: 22.92, longitude: 113.86, description: '美丽的湖景' },
        { id: 2, name: '科技园', latitude: 22.93, longitude: 113.87, description: '科技创新园区' },
      ];
      this.saveAttractions();
    }
  }

  saveAttractions() {
    AppStorage.setOrCreate('adminAttractions', this.attractionList);
  }

  showDeleteConfirm(index: number) {
    this.deletingIndex = index;
    this.showDeleteDialog = true;
  }

  deleteAttraction() {
    if (this.deletingIndex >= 0 && this.deletingIndex < this.attractionList.length) {
      this.attractionList.splice(this.deletingIndex, 1);
      this.saveAttractions();
    }
    this.showDeleteDialog = false;
    this.deletingIndex = -1;
  }

  showEditForm(index: number) {
    this.editingIndex = index;
    const attraction = this.attractionList[index];
    this.newAttractionName = attraction.name;
    this.newAttractionLat = attraction.latitude.toString();
    this.newAttractionLon = attraction.longitude.toString();
    this.newAttractionDesc = attraction.description;
    this.showEditDialog = true;
  }

  updateAttraction() {
    if (this.newAttractionName === '' || this.newAttractionLat === '' || this.newAttractionLon === '') {
      return;
    }

    const lat = parseFloat(this.newAttractionLat);
    const lon = parseFloat(this.newAttractionLon);
    
    if (isNaN(lat) || isNaN(lon)) {
      return;
    }

    if (this.editingIndex >= 0 && this.editingIndex < this.attractionList.length) {
      this.attractionList[this.editingIndex] = {
        id: this.attractionList[this.editingIndex].id,
        name: this.newAttractionName,
        latitude: lat,
        longitude: lon,
        description: this.newAttractionDesc || '景点'
      };
      this.saveAttractions();
    }
    
    // 重置表单
    this.resetForm();
    this.showEditDialog = false;
    this.editingIndex = -1;
  }

  resetForm() {
    this.newAttractionName = '';
    this.newAttractionLat = '22.92';
    this.newAttractionLon = '113.86';
    this.newAttractionDesc = '';
  }

  addAttraction() {
    if (this.newAttractionName === '' || this.newAttractionLat === '' || this.newAttractionLon === '') {
      return;
    }

    const lat = parseFloat(this.newAttractionLat);
    const lon = parseFloat(this.newAttractionLon);
    
    if (isNaN(lat) || isNaN(lon)) {
      return;
    }

    const newAttraction: SimpleAttraction = {
      id: Date.now(),
      name: this.newAttractionName,
      latitude: lat,
      longitude: lon,
      description: this.newAttractionDesc || '新增景点'
    };
    
    this.attractionList.push(newAttraction);
    this.saveAttractions();
    
    // 重置表单
    this.resetForm();
    this.showAddDialog = false;
  }

  @Builder
  AddAttractionDialog() {
    Column({ space: 16 }) {
      Text('添加景点')
        .fontSize(18)
        .fontWeight(600);

      Column({ space: 12 }) {
        TextInput({ placeholder: '景点名称', text: $$this.newAttractionName })
          .height(40);
        TextInput({ placeholder: '纬度 (如: 22.92)', text: $$this.newAttractionLat })
          .height(40)
          .type(InputType.Number);
        TextInput({ placeholder: '经度 (如: 113.86)', text: $$this.newAttractionLon })
          .height(40)
          .type(InputType.Number);
        TextInput({ placeholder: '景点描述', text: $$this.newAttractionDesc })
          .height(40);
      }

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.showAddDialog = false;
            this.resetForm();
          });
        Button('添加')
          .layoutWeight(1)
          .backgroundColor('#007DFF')
          .onClick(() => {
            this.addAttraction();
          });
      }
    }
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12);
  }

  @Builder
  EditAttractionDialog() {
    Column({ space: 16 }) {
      Text('编辑景点')
        .fontSize(18)
        .fontWeight(600);

      Column({ space: 12 }) {
        TextInput({ placeholder: '景点名称', text: $$this.newAttractionName })
          .height(40);
        TextInput({ placeholder: '纬度 (如: 22.92)', text: $$this.newAttractionLat })
          .height(40)
          .type(InputType.Number);
        TextInput({ placeholder: '经度 (如: 113.86)', text: $$this.newAttractionLon })
          .height(40)
          .type(InputType.Number);
        TextInput({ placeholder: '景点描述', text: $$this.newAttractionDesc })
          .height(40);
      }

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.showEditDialog = false;
            this.resetForm();
            this.editingIndex = -1;
          });
        Button('保存')
          .layoutWeight(1)
          .backgroundColor('#007DFF')
          .onClick(() => {
            this.updateAttraction();
          });
      }
    }
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12);
  }

  @Builder
  DeleteConfirmDialog() {
    Column({ space: 20 }) {
      Text('确认删除')
        .fontSize(18)
        .fontWeight(600);

      if (this.deletingIndex >= 0 && this.deletingIndex < this.attractionList.length) {
        Column({ space: 8 }) {
          Text('确定要删除以下景点吗?')
            .fontSize(14)
            .fontColor('#666666');
          Text(this.attractionList[this.deletingIndex].name)
            .fontSize(16)
            .fontWeight(500)
            .fontColor('#FF3B30');
        }
      }

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.showDeleteDialog = false;
            this.deletingIndex = -1;
          });
        Button('删除')
          .layoutWeight(1)
          .backgroundColor('#FF3B30')
          .onClick(() => {
            this.deleteAttraction();
          });
      }
    }
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12);
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部栏
        Row() {
          Text('← 返回')
            .fontSize(16)
            .fontColor('#007DFF')
            .onClick(() => {
              this.mainPathStack.pop();
            });

          Text('景点管理')
            .fontSize(18)
            .fontWeight(600)
            .layoutWeight(1)
            .textAlign(TextAlign.Center);

          Text('添加')
            .fontSize(16)
            .fontColor('#007DFF')
            .onClick(() => {
              this.showAddDialog = true;
            });
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#E0E0E0' });

        // 提示信息
        Column({ space: 8 }) {
          Text(`当前共有 ${this.attractionList.length} 个景点`)
            .fontSize(14)
            .fontWeight(500)
            .fontColor('#333333');
          Text('点击"编辑"修改景点信息,点击"删除"移除景点')
            .fontSize(12)
            .fontColor('#999999');
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .backgroundColor('#FFF8E1')
        .margin({ top: 1 });

        // 景点列表或空状态
        if (this.attractionList.length > 0) {
          List() {
            ForEach(this.attractionList, (item: SimpleAttraction, index: number) => {
              ListItem() {
                Row() {
                  Column({ space: 4 }) {
                    Text(item.name)
                      .fontSize(16)
                      .fontWeight(500);
                    Text(`经纬度: ${item.latitude.toFixed(4)}, ${item.longitude.toFixed(4)}`)
                      .fontSize(12)
                      .fontColor('#666666');
                    Text(item.description)
                      .fontSize(12)
                      .fontColor('#999999')
                      .maxLines(1);
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1);

                  Row({ space: 8 }) {
                    Button('编辑')
                      .height(32)
                      .fontSize(14)
                      .backgroundColor('#007DFF')
                      .onClick(() => {
                        this.showEditForm(index);
                      });
                    Button('删除')
                      .height(32)
                      .fontSize(14)
                      .backgroundColor('#FF3B30')
                      .onClick(() => {
                        this.showDeleteConfirm(index);
                      });
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(8);
              }
              .margin({ top: 8 });
            }, (item: SimpleAttraction) => item.id.toString());
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .padding({ left: 12, right: 12, top: 8 });
        } else {
          // 空状态
          Column({ space: 16 }) {
            Text('📍')
              .fontSize(64);
            Text('暂无景点')
              .fontSize(18)
              .fontWeight(500)
              .fontColor('#333333');
            Text('点击右上角"添加"按钮添加第一个景点')
              .fontSize(14)
              .fontColor('#999999');
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5');
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5');
    }
    .hideTitleBar(true)
    .bindContentCover($$this.showAddDialog, this.AddAttractionDialog(), {
      modalTransition: ModalTransition.DEFAULT
    })
    .bindContentCover($$this.showEditDialog, this.EditAttractionDialog(), {
      modalTransition: ModalTransition.DEFAULT
    })
    .bindContentCover($$this.showDeleteDialog, this.DeleteConfirmDialog(), {
      modalTransition: ModalTransition.DEFAULT
    });
  }
}
