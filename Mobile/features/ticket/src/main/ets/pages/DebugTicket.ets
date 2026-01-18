import { Constant } from 'common';
import { TitleBar } from 'uicomponents';

@Builder
export function DebugTicketBuilder() {
  DebugTicket();
}

@Entry
@ComponentV2
export struct DebugTicket {
  @Local count: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        TitleBar({
          isShowBack: true,
          title: 'DebugTicket 测试页',
          clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Text('如果你能看到这些文字，说明跳转和渲染是正常的。')
          .fontSize(16)
          .fontColor('#111')
          .margin({ top: 12 });

        Text(`计数: ${this.count}`)
          .fontSize(20)
          .fontWeight(700)
          .fontColor('#64BB5C');

        Row({ space: 12 }) {
          Button('点我 +1')
            .onClick(() => {
              this.count++;
            });

          Button('返回')
            .onClick(() => {
              this.mainPathStack.pop();
            });
        }

        // 放一个固定高度的列表，测试布局/渲染性能
        List({ space: 8 }) {
          ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], (i: number) => {
            ListItem() {
              Row() {
                Text(`Item #${i}`)
                  .fontSize(14)
                  .padding(12);
              }
              .width(Constant.FULL_PERCENT)
              .backgroundColor('#FFFFFF')
              .borderRadius(8);
            };
          }, (i: number) => i.toString());
        }
        .padding({ left: 12, right: 12 })
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }
      .width(Constant.FULL_PERCENT)
      .height(Constant.FULL_PERCENT)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#F1F3F5F2');
    }.hideTitleBar(true);
  }
}
