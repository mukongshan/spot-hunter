import { Constant, Logger } from 'common';
import { TitleBar } from 'uicomponents';
import { TicketInfo } from '../model/TicketInfo';
import { TicketVM } from '../viewmodel/TicketVM';

interface SimpleTicket {
  id: number;
  name: string;
  price: number;
  description: string;
  attractionId: number;
  attractionName: string;
  attractionImage: string;
}

interface SimpleAttraction {
  id: number;
  name: string;
  location: string;
  description: string;
  imageUri: string;
  latitude: number;
  longitude: number;
}

@Builder
export function TicketsBuilder() {
  Tickets();
}

@ComponentV2
export struct Tickets {
  vm: TicketVM = TicketVM.instance;
  @Local isLoading: boolean = true;
  @Local isFromMain: boolean = false;
  @Local errorText: string = '';
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local userRole: string = AppStorage.get<string>('userRole') || '';
  @Local adminTickets: SimpleTicket[] = AppStorage.get<SimpleTicket[]>('adminTickets') || [];
  @Local adminAttractions: SimpleAttraction[] = AppStorage.get<SimpleAttraction[]>('adminAttractions') || [];
  @Local deletedTicketIds: number[] = AppStorage.get<number[]>('deletedTicketIds') || [];
  @Local showAddDialog: boolean = false;
  @Local showDeleteDialog: boolean = false;
  @Local showAttractionPicker: boolean = false;
  @Local editingTicket: SimpleTicket | null = null;
  @Local newTicketName: string = '';
  @Local newTicketPrice: string = '';
  @Local newTicketDescription: string = '';
  @Local selectedAttraction: SimpleAttraction | null = null;

  saveTickets() {
    AppStorage.setOrCreate('adminTickets', this.adminTickets);
  }

  saveDeletedIds() {
    AppStorage.setOrCreate('deletedTicketIds', this.deletedTicketIds);
  }

  addTicket() {
    const price = parseFloat(this.newTicketPrice);
    if (!this.newTicketName || !this.newTicketPrice || !this.newTicketDescription || 
        isNaN(price) || !this.selectedAttraction) {
      return;
    }
    const newId = this.adminTickets.length > 0 ?
      Math.max(...this.adminTickets.map(t => t.id)) + 1 : 1000;
    this.adminTickets.push({
      id: newId,
      name: this.newTicketName,
      price: price,
      description: this.newTicketDescription,
      attractionId: this.selectedAttraction.id,
      attractionName: this.selectedAttraction.name,
      attractionImage: this.selectedAttraction.imageUri
    });
    this.saveTickets();
    this.showAddDialog = false;
    this.newTicketName = '';
    this.newTicketPrice = '';
    this.newTicketDescription = '';
    this.selectedAttraction = null;
  }

  selectAttraction(attraction: SimpleAttraction) {
    this.selectedAttraction = attraction;
    this.showAttractionPicker = false;
  }

  deleteTicket() {
    if (!this.editingTicket) return;
    
    // 如果是自定义门票,从列表删除
    const isCustom = this.adminTickets.some(t => t.id === this.editingTicket!.id);
    if (isCustom) {
      this.adminTickets = this.adminTickets.filter(t => t.id !== this.editingTicket!.id);
      this.saveTickets();
    } else {
      // 如果是系统门票,添加到删除列表
      if (!this.deletedTicketIds.includes(this.editingTicket.id)) {
        this.deletedTicketIds.push(this.editingTicket.id);
        this.saveDeletedIds();
      }
    }
    
    this.showDeleteDialog = false;
    this.editingTicket = null;
  }

  loadTickets() {
    this.isLoading = true;
    this.errorText = '';
    this.vm.getTicketList().then(() => {
      this.isLoading = false;
    }).catch((err: object) => {
      Logger.error('[Tickets] loadTickets failed', JSON.stringify(err));
      this.errorText = '门票列表加载失败（Preview 可能吞异常）。请看 Log 窗口或重启预览器。';
      this.isLoading = false;
    });
  }

  @Builder
  TicketItemBuilder(ticket: TicketInfo) {
    Row({ space: 8 }) {
      // banner 为空时用占位，避免空资源导致渲染异常
      Image(ticket.banner)
        .borderRadius(8)
        .width('20%')
        .height(90)
        .backgroundColor('#E6E8EB');
      Column() {
        Text(ticket.ticketName).fontSize(16).fontWeight(500);
        Row({ space: 8 }) {
          ForEach(ticket.labels ?? [], (item: string) => {
            Text(item)
              .fontSize(10)
              .border({ width: 1, radius: 4, color: '#F6933B' })
              .padding(4);
          }, (item: string) => item);
        };

        Text('实名制购票请携带身份证方便入园').fontSize(12).opacity(0.6);

        Row() {
          Text() {
            Span('￥').fontSize(12).fontColor('#E84026');
            Span(`${(ticket.ticketType[Math.max(0, Math.min(ticket.basicTicketTypeId, ticket.ticketType.length - 1))]?.discountPrice ?? 0).toFixed(2)}`)
              .fontWeight(500)
              .fontColor('#E84026')
              .fontSize(18);
            Span('起').fontSize(12).opacity(0.6);
          }.layoutWeight(1);

          if (this.userRole === 'admin') {
            Button('删除')
              .fontSize(12)
              .height(32)
              .backgroundColor('#FF3B30')
              .onClick(() => {
                this.editingTicket = {
                  id: ticket.ticketId,
                  name: ticket.ticketName,
                  price: ticket.ticketType[0]?.discountPrice ?? 0,
                  description: '',
                  attractionId: 0,
                  attractionName: '',
                  attractionImage: ''
                };
                this.showDeleteDialog = true;
              });
          }
        }
        .width(Constant.FULL_PERCENT);
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('80%')
      .height(Constant.FULL_PERCENT);
    }
    .onClick(() => {
      this.mainPathStack.pushPathByName('TicketDetail', ticket.ticketId);
    })
    .backgroundColor($r('sys.color.font_on_primary'))
    .padding(16)
    .borderRadius(8)
    .height(120)
    .width(Constant.FULL_PERCENT);
  }

  @Builder
  AdminTicketItemBuilder(ticket: SimpleTicket) {
    Row({ space: 8 }) {
      // 显示景区图片
      if (ticket.attractionImage) {
        Image(ticket.attractionImage)
          .borderRadius(8)
          .width('20%')
          .height(90)
          .backgroundColor('#E6E8EB')
          .objectFit(ImageFit.Cover);
      }

      Column({ space: 8 }) {
        Text(ticket.name).fontSize(16).fontWeight(500);
        Text(`关联景区: ${ticket.attractionName}`).fontSize(11).fontColor('#64BB5C');
        Text(ticket.description).fontSize(12).fontColor('#666').maxLines(2);
        
        Row() {
          Text() {
            Span('￥').fontSize(12).fontColor('#E84026');
            Span(ticket.price.toFixed(2))
              .fontWeight(500)
              .fontColor('#E84026')
              .fontSize(18);
          }.layoutWeight(1);

          if (this.userRole === 'admin') {
            Button('删除')
              .fontSize(12)
              .height(32)
              .backgroundColor('#FF3B30')
              .onClick(() => {
                this.editingTicket = {
                  id: ticket.id,
                  name: ticket.name,
                  price: ticket.price,
                  description: ticket.description,
                  attractionId: ticket.attractionId,
                  attractionName: ticket.attractionName,
                  attractionImage: ticket.attractionImage
                };
                this.showDeleteDialog = true;
              });
          }
        }
        .width(Constant.FULL_PERCENT);
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);
    }
    .backgroundColor($r('sys.color.font_on_primary'))
    .padding(16)
    .borderRadius(8)
    .height(120)
    .width(Constant.FULL_PERCENT);
  }

  @Builder
  AddTicketDialog() {
    Column({ space: 16 }) {
      Text('添加新门票')
        .fontSize(18)
        .fontWeight(700);

      TextInput({ placeholder: '门票名称 *', text: $$this.newTicketName })
        .height(44);

      // 景区选择
      Column({ space: 8 }) {
        Text('关联景区 *').fontSize(14).fontColor('#333').alignSelf(ItemAlign.Start);
        Button(this.selectedAttraction ? this.selectedAttraction.name : '选择景区')
          .width('100%')
          .backgroundColor('#E3F2FD')
          .fontColor('#007DFF')
          .onClick(() => {
            this.showAttractionPicker = true;
          });
        if (this.selectedAttraction && this.selectedAttraction.imageUri) {
          Image(this.selectedAttraction.imageUri)
            .width('100%')
            .height(100)
            .borderRadius(8)
            .objectFit(ImageFit.Cover);
        }
      }
      .alignItems(HorizontalAlign.Start);

      TextInput({ placeholder: '门票价格 * (元)', text: $$this.newTicketPrice })
        .height(44)
        .type(InputType.Number);

      TextArea({ placeholder: '门票描述 *', text: $$this.newTicketDescription })
        .height(88);

      if (!this.newTicketName || !this.newTicketPrice || !this.newTicketDescription || !this.selectedAttraction) {
        Text('请填写所有必填项并选择景区')
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
            this.newTicketName = '';
            this.newTicketPrice = '';
            this.newTicketDescription = '';
            this.selectedAttraction = null;
          });
        Button('添加')
          .layoutWeight(1)
          .backgroundColor('#64BB5C')
          .enabled(!(!this.newTicketName || !this.newTicketPrice || !this.newTicketDescription || !this.selectedAttraction))
          .onClick(() => this.addTicket());
      };
    }
    .padding(20)
    .backgroundColor('#FFF')
    .borderRadius(12)
    .constraintSize({ maxHeight: '70%' });
  }

  @Builder
  AttractionPickerDialog() {
    Column({ space: 16 }) {
      Text('选择景区')
        .fontSize(18)
        .fontWeight(700);

      Text('选择要关联的景区')
        .fontSize(12)
        .fontColor('#666');

      if (this.adminAttractions.length === 0) {
        Column() {
          Text('暂无自定义景区')
            .fontSize(14)
            .fontColor('#999');
          Text('请先在景点列表中添加景区')
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 4 });
        }
        .height(150)
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.adminAttractions, (attraction: SimpleAttraction) => {
              Row({ space: 12 }) {
                if (attraction.imageUri) {
                  Image(attraction.imageUri)
                    .width(60)
                    .height(60)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover);
                }
                Column({ space: 4 }) {
                  Text(attraction.name)
                    .fontSize(14)
                    .fontWeight(500);
                  Text(attraction.location)
                    .fontSize(12)
                    .fontColor('#666')
                    .maxLines(1);
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onClick(() => this.selectAttraction(attraction));
            }, (attraction: SimpleAttraction) => attraction.id.toString());
          };
        }
        .height(250)
        .scrollBar(BarState.Auto);
      }

      Button('取消')
        .width('100%')
        .backgroundColor('#F0F0F0')
        .fontColor('#333')
        .onClick(() => {
          this.showAttractionPicker = false;
        });
    }
    .padding(20)
    .backgroundColor('#FFF')
    .borderRadius(12)
    .constraintSize({ maxHeight: '70%' });
  }

  @Builder
  DeleteConfirmDialog() {
    if (this.editingTicket) {
      Column({ space: 16 }) {
        Text('确认删除')
          .fontSize(18)
          .fontWeight(700);

        Text(`确定要删除门票"${this.editingTicket.name}"吗?`)
          .fontSize(14)
          .fontColor('#666');

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .backgroundColor('#F0F0F0')
            .fontColor('#333')
            .onClick(() => {
              this.showDeleteDialog = false;
              this.editingTicket = null;
            });
          Button('删除')
            .layoutWeight(1)
            .backgroundColor('#FF3B30')
            .onClick(() => this.deleteTicket());
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
            isShowBack: this.isFromMain,
            title: '门票列表',
            clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          if (this.errorText.length) {
            Text(this.errorText)
              .fontSize(13)
              .fontColor('#E84026')
              .margin({ top: 8, left: 12, right: 12 });
          }

          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .width(48)
                .height(48)
                .color('#64BB5C');
              Text('加载中...').fontSize(14).margin({ top: 12 });
            }
            .width(Constant.FULL_PERCENT)
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center);
          } else {
            Scroll() {
              Column() {
                // 系统门票
                if (this.vm.ticketList.totalCount() > 0) {
                  Text('系统门票')
                    .fontSize(16)
                    .fontWeight(700)
                    .margin({ left: 12, top: 8, bottom: 8 });

                  List({ space: 12 }) {
                    LazyForEach(this.vm.ticketList, (item: TicketInfo) => {
                      // 过滤已删除的系统门票
                      if (!this.deletedTicketIds.includes(item.ticketId)) {
                        ListItem() {
                          this.TicketItemBuilder(item);
                        }
                      }
                    }, (item: TicketInfo) => item.ticketId.toString());
                  }.padding({ left: 12, right: 12 });
                }

                // 自定义门票
                if (this.adminTickets.length > 0) {
                  Row() {
                    Text('自定义门票')
                      .fontSize(16)
                      .fontWeight(700);

                    if (this.userRole === 'admin') {
                      Text(`(${this.adminTickets.length})`)
                        .fontSize(14)
                        .fontColor('#999')
                        .margin({ left: 4 });
                    }
                  }
                  .margin({ left: 12, top: 16, bottom: 8 });

                  List({ space: 12 }) {
                    ForEach(this.adminTickets, (item: SimpleTicket) => {
                      ListItem() {
                        this.AdminTicketItemBuilder(item);
                      };
                    }, (item: SimpleTicket) => item.id.toString());
                  }.padding({ left: 12, right: 12 });
                }

                // 管理员添加按钮
                if (this.userRole === 'admin') {
                  Button('+ 添加新门票')
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
            .scrollBar(BarState.Off)
            .layoutWeight(1)
            .edgeEffect(EdgeEffect.Spring);
          }
        }
        .width(Constant.FULL_PERCENT)
        .height(Constant.FULL_PERCENT);

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
            this.AddTicketDialog();
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

        if (this.showAttractionPicker) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showAttractionPicker = false;
            });

          Column() {
            this.AttractionPickerDialog();
          }
          .width('85%')
          .justifyContent(FlexAlign.Center);
        }
      }
      .width('100%')
      .height('100%');
    }.backgroundColor('#F1F3F5F2').hideTitleBar(true).onReady((context: NavDestinationContext) => {
      if (context.pathInfo.param as boolean) {
        this.isFromMain = true;
      }
      // 在页面准备好后加载数据
      this.loadTickets();
    });
  }
}