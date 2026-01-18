import { Constant } from 'common';
import { TitleBar, ViewDetailComponent } from 'uicomponents';
import { BulletinInfo } from '../model/BulletinInfo';
import { HomePageVM } from '../viewmodel/HomePageVM';

interface SimpleBulletin {
  id: number;
  title: string;
  content: string;
  releaseTime: string;
}

@Builder
export function BulletinsBuilder() {
  Bulletins();
}

@ComponentV2
export struct Bulletins {
  vm: HomePageVM = HomePageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local userRole: string = AppStorage.get<string>('userRole') || '';
  @Local adminBulletins: SimpleBulletin[] = AppStorage.get<SimpleBulletin[]>('adminBulletins') || [];
  @Local deletedBulletinIds: number[] = AppStorage.get<number[]>('deletedBulletinIds') || [];
  @Local showAddDialog: boolean = false;
  @Local showDeleteDialog: boolean = false;
  @Local editingBulletin: SimpleBulletin | null = null;
  @Local newBulletinTitle: string = '';
  @Local newBulletinContent: string = '';

  saveBulletins() {
    AppStorage.setOrCreate('adminBulletins', this.adminBulletins);
  }

  saveDeletedIds() {
    AppStorage.setOrCreate('deletedBulletinIds', this.deletedBulletinIds);
  }

  addBulletin() {
    if (!this.newBulletinTitle || !this.newBulletinContent) {
      return;
    }
    const newId = this.adminBulletins.length > 0 ?
      Math.max(...this.adminBulletins.map(b => b.id)) + 1 : 1000;
    const now = new Date();
    this.adminBulletins.push({
      id: newId,
      title: this.newBulletinTitle,
      content: this.newBulletinContent,
      releaseTime: `${now.getFullYear()}-${(now.getMonth() + 1).toString().padStart(2, '0')}-${now.getDate().toString().padStart(2, '0')}`
    });
    this.saveBulletins();
    this.showAddDialog = false;
    this.newBulletinTitle = '';
    this.newBulletinContent = '';
  }

  deleteBulletin() {
    if (!this.editingBulletin) return;
    
    // 如果是自定义公告,从列表删除
    const isCustom = this.adminBulletins.some(b => b.id === this.editingBulletin!.id);
    if (isCustom) {
      this.adminBulletins = this.adminBulletins.filter(b => b.id !== this.editingBulletin!.id);
      this.saveBulletins();
    } else {
      // 如果是系统公告,添加到删除列表
      if (!this.deletedBulletinIds.includes(this.editingBulletin.id)) {
        this.deletedBulletinIds.push(this.editingBulletin.id);
        this.saveDeletedIds();
      }
    }
    
    this.showDeleteDialog = false;
    this.editingBulletin = null;
  }

  @Builder
  BulletinCardBuilder(bulletin: BulletinInfo) {
    Row() {
      Column({ space: 18 }) {
        Text(bulletin.title)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(500)
          .fontSize(16);
        Text(`时间：${bulletin.releaseTime}`).fontSize(12).opacity(0.6);
      }.alignItems(HorizontalAlign.Start).layoutWeight(1);

      Row({ space: 8 }) {
        ViewDetailComponent();
        
        if (this.userRole === 'admin') {
          Button('删除')
            .fontSize(12)
            .height(32)
            .backgroundColor('#FF3B30')
            .onClick(() => {
              // 删除系统公告需要特殊处理,这里标记为已删除
              this.editingBulletin = {
                id: bulletin.id,
                title: bulletin.title,
                content: bulletin.detail || '',
                releaseTime: bulletin.releaseTime
              };
              this.showDeleteDialog = true;
            });
        }
      };
    }
    .width(Constant.FULL_PERCENT)
    .backgroundColor($r('sys.color.font_on_primary'))
    .borderRadius(8)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(12)
    .onClick(() => {
      this.mainPathStack.pushPathByName('BulletinDetail', bulletin.id);
    });
  }

  @Builder
  AdminBulletinCardBuilder(bulletin: SimpleBulletin) {
    Row() {
      Column({ space: 8 }) {
        Text(bulletin.title)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(500)
          .fontSize(16);
        Text(bulletin.content)
          .maxLines(2)
          .fontSize(12)
          .fontColor('#666');
        Text(`时间：${bulletin.releaseTime}`).fontSize(12).opacity(0.6);
      }.alignItems(HorizontalAlign.Start).layoutWeight(1);

      if (this.userRole === 'admin') {
        Button('删除')
          .fontSize(12)
          .height(32)
          .backgroundColor('#FF3B30')
          .onClick(() => {
            this.editingBulletin = {
              id: bulletin.id,
              title: bulletin.title,
              content: bulletin.content,
              releaseTime: bulletin.releaseTime
            };
            this.showDeleteDialog = true;
          });
      }
    }
    .width(Constant.FULL_PERCENT)
    .backgroundColor($r('sys.color.font_on_primary'))
    .borderRadius(8)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(12);
  }

  @Builder
  AddBulletinDialog() {
    Column({ space: 16 }) {
      Text('发布新公告')
        .fontSize(18)
        .fontWeight(700);

      TextInput({ placeholder: '公告标题 *', text: $$this.newBulletinTitle })
        .height(44);

      TextArea({ placeholder: '公告内容 *', text: $$this.newBulletinContent })
        .height(120);

      if (!this.newBulletinTitle || !this.newBulletinContent) {
        Text('请填写所有必填项')
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
            this.newBulletinTitle = '';
            this.newBulletinContent = '';
          });
        Button('发布')
          .layoutWeight(1)
          .backgroundColor('#64BB5C')
          .enabled(!(!this.newBulletinTitle || !this.newBulletinContent))
          .onClick(() => this.addBulletin());
      };
    }
    .padding(20)
    .backgroundColor('#FFF')
    .borderRadius(12)
    .constraintSize({ maxHeight: '70%' });
  }

  @Builder
  DeleteConfirmDialog() {
    if (this.editingBulletin) {
      Column({ space: 16 }) {
        Text('确认删除')
          .fontSize(18)
          .fontWeight(700);

        Text(`确定要删除公告"${this.editingBulletin.title}"吗?`)
          .fontSize(14)
          .fontColor('#666');

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .backgroundColor('#F0F0F0')
            .fontColor('#333')
            .onClick(() => {
              this.showDeleteDialog = false;
              this.editingBulletin = null;
            });
          Button('删除')
            .layoutWeight(1)
            .backgroundColor('#FF3B30')
            .onClick(() => this.deleteBulletin());
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
            isShowBack: true, title: '公告列表', clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          Scroll() {
            Column() {
              // 系统公告
              Text('系统公告')
                .fontSize(16)
                .fontWeight(700)
                .margin({ left: 12, top: 8, bottom: 8 });

              List({ space: 12 }) {
                LazyForEach(this.vm.bulletinList, (item: BulletinInfo) => {
                  // 过滤掉已删除的系统公告
                  if (!this.deletedBulletinIds.includes(item.id)) {
                    ListItem() {
                      this.BulletinCardBuilder(item);
                    };
                  }
                });
              }.padding({ left: 12, right: 12 });

              // 自定义公告
              if (this.adminBulletins.length > 0) {
                Row() {
                  Text('管理员公告')
                    .fontSize(16)
                    .fontWeight(700);

                  if (this.userRole === 'admin') {
                    Text(`(${this.adminBulletins.length})`)
                      .fontSize(14)
                      .fontColor('#999')
                      .margin({ left: 4 });
                  }
                }
                .margin({ left: 12, top: 16, bottom: 8 });

                List({ space: 12 }) {
                  ForEach(this.adminBulletins, (item: SimpleBulletin) => {
                    ListItem() {
                      this.AdminBulletinCardBuilder(item);
                    };
                  }, (item: SimpleBulletin) => item.id.toString());
                }.padding({ left: 12, right: 12 });
              }

              // 管理员添加按钮
              if (this.userRole === 'admin') {
                Button('+ 发布新公告')
                  .width('90%')
                  .height(44)
                  .margin({ top: 16, bottom: 16 })
                  .backgroundColor('#64BB5C')
                  .onClick(() => {
                    this.showAddDialog = true;
                  });
              }
            };
          }
          .height('90%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring);
        };

        // 对话框
        if (this.showAddDialog) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showAddDialog = false;
            });

          Column() {
            this.AddBulletinDialog();
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
    }.hideTitleBar(true).backgroundColor('#F1F3F5F2');
  }
}