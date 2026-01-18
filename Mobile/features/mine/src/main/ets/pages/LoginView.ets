@Builder
export function LoginBuilder() {
  LoginView();
}

@ComponentV2
struct LoginView {
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local username: string = '';
  @Local password: string = '';
  @Local errorMsg: string = '';

  login() {
    if (this.username === '') {
      this.errorMsg = '请输入用户名';
      return;
    }
    if (this.password === '') {
      this.errorMsg = '请输入密码';
      return;
    }

    // 简单的假登录验证
    if (this.username === 'admin' && this.password === 'admin123') {
      // 管理员登录
      AppStorage.setOrCreate('userRole', 'admin');
      AppStorage.setOrCreate('userName', '管理员');
      this.errorMsg = '管理员登录成功';
      setTimeout(() => {
        this.mainPathStack.pop();
      }, 500);
    } else if (this.username === 'user' && this.password === 'user123') {
      // 普通用户登录
      AppStorage.setOrCreate('userRole', 'user');
      AppStorage.setOrCreate('userName', '普通用户');
      this.errorMsg = '登录成功';
      setTimeout(() => {
        this.mainPathStack.pop();
      }, 500);
    } else {
      this.errorMsg = '用户名或密码错误';
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text('景区管理系统')
          .fontSize(28)
          .fontWeight(600)
          .margin({ top: 60, bottom: 40 });

        Column({ space: 20 }) {
          Column() {
            Text('用户名')
              .fontSize(14)
              .width('100%')
              .margin({ bottom: 8 });
            TextInput({ placeholder: '请输入用户名', text: $$this.username })
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8);
          }
          .alignItems(HorizontalAlign.Start);

          Column() {
            Text('密码')
              .fontSize(14)
              .width('100%')
              .margin({ bottom: 8 });
            TextInput({ placeholder: '请输入密码', text: $$this.password })
              .height(44)
              .type(InputType.Password)
              .backgroundColor('#F5F5F5')
              .borderRadius(8);
          }
          .alignItems(HorizontalAlign.Start);

          if (this.errorMsg !== '') {
            Text(this.errorMsg)
              .fontSize(12)
              .fontColor(this.errorMsg === '登录成功' ? '#00AA00' : '#FF0000')
              .width('100%');
          }

          Button('登录')
            .width('100%')
            .height(44)
            .backgroundColor('#007DFF')
            .onClick(() => {
              this.login();
            });

          // 测试账号提示
          Column({ space: 8 }) {
            Text('━━━━━ 测试账号 ━━━━━')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 10, bottom: 10 });
            
            Row() {
              Column({ space: 6 }) {
                Text('👤 管理员账号')
                  .fontSize(13)
                  .fontWeight(500)
                  .fontColor('#FF9500')
                  .width('100%');
                Text('用户名: admin')
                  .fontSize(12)
                  .fontColor('#666666')
                  .width('100%');
                Text('密码: admin123')
                  .fontSize(12)
                  .fontColor('#666666')
                  .width('100%');
                
                Button('快速登录')
                  .fontSize(11)
                  .height(28)
                  .width('100%')
                  .margin({ top: 6 })
                  .backgroundColor('#FF9500')
                  .onClick(() => {
                    this.username = 'admin';
                    this.password = 'admin123';
                    this.login();
                  });
              }
              .width('48%')
              .padding(12)
              .backgroundColor('#FFF8E1')
              .borderRadius(8)
              .alignItems(HorizontalAlign.Start);

              Column({ space: 6 }) {
                Text('👥 普通用户账号')
                  .fontSize(13)
                  .fontWeight(500)
                  .fontColor('#007DFF')
                  .width('100%');
                Text('用户名: user')
                  .fontSize(12)
                  .fontColor('#666666')
                  .width('100%');
                Text('密码: user123')
                  .fontSize(12)
                  .fontColor('#666666')
                  .width('100%');
                
                Button('快速登录')
                  .fontSize(11)
                  .height(28)
                  .width('100%')
                  .margin({ top: 6 })
                  .backgroundColor('#007DFF')
                  .onClick(() => {
                    this.username = 'user';
                    this.password = 'user123';
                    this.login();
                  });
              }
              .width('48%')
              .padding(12)
              .backgroundColor('#E3F2FD')
              .borderRadius(8)
              .alignItems(HorizontalAlign.Start);
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween);
          }
          .width('100%')
          .margin({ top: 20 });
        }
        .width('80%')
        .padding(20);
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF');
    }
    .hideTitleBar(true);
  }
}
