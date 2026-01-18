import { AccountUtil, Constant } from 'common';
import { UserInfo } from 'types';
import { TitleBar } from 'uicomponents';
import { getManagementModuleInfo, ManagementInfo } from '../model/ManagementInfo';
import { getOrderTypeInfo, OrderTypeInfo } from '../model/OrderTypeInfo';
import { router } from '@kit.ArkUI';

@Builder
export function MineBuilder() {
  MineView();
}

@ComponentV2
export struct MineView {
  @Local userInfo: UserInfo = AccountUtil.getUserInfo();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local userRole: string = AppStorage.get<string>('userRole') || '';
  @Local userName: string = AppStorage.get<string>('userName') || '';

  @Builder
  HeaderBuilder() {
    Row({ space: 12 }) {
      Image(this.userInfo.avatar)
        .alt($r('app.media.default_avatar'))
        .size({ width: 72, height: 72 })
        .borderRadius(36);

      Column({ space: 4 }) {
        Text(this.userName !== '' ? this.userName : (this.userInfo.nickname ? this.userInfo.nickname : '华为用户'))
          .fontSize(18)
          .fontWeight(500);
        
        if (this.userRole === 'admin') {
          Text('管理员')
            .fontSize(12)
            .fontColor('#FF9500')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#FFF3E0')
            .borderRadius(4);
        } else if (this.userRole === 'user') {
          Text('普通用户')
            .fontSize(12)
            .fontColor('#007DFF')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#E3F2FD')
            .borderRadius(4);
        }
      }
      .alignItems(HorizontalAlign.Start);
    }
    .padding(12)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (this.userRole === '') {
        // 未登录，跳转到登录页
        this.mainPathStack.pushPathByName('Login', null);
      } else {
        this.mainPathStack.pushPathByName('EditPersonalInfo', null);
      }
    })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.Start);
  }

  @Builder
  FunctionBuilder() {
    List({ space: 12 }) {
      // 管理员专属功能
      if (this.userRole === 'admin') {
        ListItem() {
          Column() {
            Row() {
              Row({ space: 8 }) {
                Image($r('app.media.tourists_manage')).size({ width: 14, height: 14 });
                Text('景点管理').fontSize(12).opacity(0.9).fontColor('#FF9500');
              };

              Image($r('app.media.chevron_right')).size({ width: 14, height: 14 });
            }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

            Divider().margin({ top: 12 });
          }.onClick(() => {
            this.mainPathStack.pushPathByName('AdminManage', null);
          });
        };
      }

      ForEach(getManagementModuleInfo(this.mainPathStack), (item: ManagementInfo, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Row({ space: 8 }) {
                Image(item.icon).size({ width: 14, height: 14 });
                Text(item.title).fontSize(12).opacity(0.9);
              };

              Image($r('app.media.chevron_right')).size({ width: 14, height: 14 });
            }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

            if (index !== 2) {
              Divider().margin({ top: 12 });
            }
          }.onClick(item.click);
        };
      }, (item: ManagementInfo, index: number) => index + '__' + JSON.stringify(item));
      
      // 退出登录按钮
      if (this.userRole !== '' && this.userRole !== 'guest') {
        ListItem() {
          Column() {
            Row() {
              Row({ space: 8 }) {
                Image($r('app.media.tourists_manage')).size({ width: 14, height: 14 });
                Text('退出登录').fontSize(12).opacity(0.9).fontColor('#FF3B30');
              };

              Image($r('app.media.chevron_right')).size({ width: 14, height: 14 });
            }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
          }.onClick(() => {
            // 清除登录状态
            AppStorage.setOrCreate('userRole', '');
            AppStorage.setOrCreate('userName', '');
            // 使用 router 跳转回欢迎页
            router.replaceUrl({ url: 'pages/Welcome' });
          });
        };
      }
    }.padding(12).backgroundColor($r('sys.color.font_on_primary')).borderRadius(8);
  }

  @Builder
  OrderBuilder() {
    Column({ space: 16 }) {
      Text('我的订单').fontSize(14).fontWeight(500);

      Row({ space: 28 }) {
        ForEach(getOrderTypeInfo(this.mainPathStack), (item: OrderTypeInfo) => {
          Column({ space: 4 }) {
            Image(item.icon).size({ width: 18, height: 18 });
            Text(item.name).fontSize(12).margin({ top: 8 });
          }.onClick(item.click);
        }, (item: OrderTypeInfo) => item.type.toString());
      };
    }
    .padding(16)
    .backgroundColor($r('sys.color.font_on_primary'))
    .borderRadius(8)
    .width(Constant.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 22, bottom: 12 });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: false, title: '个人中心', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column() {
          this.HeaderBuilder();
          this.OrderBuilder();
          this.FunctionBuilder();
        }.padding(12);

      }.backgroundColor('#F1F3F5').height(Constant.FULL_PERCENT).linearGradient({
        direction: GradientDirection.Bottom, // 渐变方向
        repeating: false, // 渐变颜色是否重复
        colors: [['rgba(100, 187, 92, 0.9)', 0.0], ['rgba(100, 187, 92, 0)', 0.5],
          ['rgba(100, 187, 92, 0)', 1]], // 数组末尾元素占比小于1时满足重复着色效果
      });
    };
  }
}