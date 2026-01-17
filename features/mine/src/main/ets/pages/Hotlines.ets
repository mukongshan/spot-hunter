import { Constant } from 'common';
import { TitleBar } from 'uicomponents';
import { hotlines, HotlineInfo } from '../model/HotlineInfo';

@Builder
export function HotlinesBuilder() {
  Hotlines();
}

@ComponentV2
export struct Hotlines {
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  HotlineItem(item: HotlineInfo) {
    Column() {
      Row() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium);
        Blank();
        Text(item.phone)
          .fontSize(14)
          .fontColor('#666666');
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(8);
    }
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        TitleBar({
          isShowBack: true, title: '服务热线', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column({ space: 12 }) {
          ForEach(hotlines, (item: HotlineInfo) => {
            this.HotlineItem(item);
          }, (item: HotlineInfo, index: number) => `${item.title}_${index}`);
        }.padding({ left: 12, right: 12 });
      }.height(Constant.FULL_PERCENT).backgroundColor('#F1F3F5F2');
    }.hideTitleBar(true);
  }
}