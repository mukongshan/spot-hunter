import { router } from '@kit.ArkUI';

@Entry
@Component
struct Welcome {
  @State currentPage: number = 0;
  @State username: string = '';
  @State password: string = '';
  @State errorMsg: string = '';
  @State registerUsername: string = '';
  @State registerPassword: string = '';
  @State registerConfirmPassword: string = '';
  @State registerMsg: string = '';

  aboutToAppear() {
    AppStorage.setOrCreate('userRole', '');
    AppStorage.setOrCreate('userName', '');
  }

  login() {
    if (this.username === '' || this.password === '') {
      this.errorMsg = '请输入用户名和密码';
      return;
    }

    if (this.username === 'admin' && this.password === 'admin123') {
      AppStorage.setOrCreate('userRole', 'admin');
      AppStorage.setOrCreate('userName', '管理员');
      router.replaceUrl({ url: 'pages/Main' });
    } else if (this.username === 'user' && this.password === 'user123') {
      AppStorage.setOrCreate('userRole', 'user');
      AppStorage.setOrCreate('userName', '普通用户');
      router.replaceUrl({ url: 'pages/Main' });
    } else {
      this.errorMsg = '用户名或密码错误';
    }
  }

  register() {
    if (!this.registerUsername || !this.registerPassword || !this.registerConfirmPassword) {
      this.registerMsg = '请填写完整信息';
      return;
    }
    if (this.registerPassword !== this.registerConfirmPassword) {
      this.registerMsg = '两次密码不一致';
      return;
    }
    this.registerMsg = '注册功能暂未开放,请联系管理员';
  }

  build() {
    Column() {
      if (this.currentPage === 0) {
        // 欢迎页
        Column() {
          Column() {
            Text('🏞️')
              .fontSize(100)
              .margin({ bottom: 10 });
            Text('智慧景区')
              .fontSize(36)
              .fontWeight(700)
              .fontColor('#FFFFFF');
            Text('SMART SCENIC SPOTS')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.9)
              .margin({ top: 8 });
          }
          .margin({ top: 120 })
          .layoutWeight(1);

          Column({ space: 16 }) {
            Button('登  录')
              .width('85%')
              .height(54)
              .backgroundColor('#FFFFFF')
              .fontColor('#64BB5C')
              .fontSize(18)
              .onClick(() => { this.currentPage = 1; });

            Button('游客模式')
              .width('85%')
              .height(54)
              .backgroundColor('rgba(255,255,255,0.25)')
              .fontColor('#FFFFFF')
              .onClick(() => {
                AppStorage.setOrCreate('userRole', 'guest');
                router.replaceUrl({ url: 'pages/Main' });
              });

            Text('提示: admin/admin123 或 user/user123')
              .fontSize(11)
              .fontColor('#FFFFFF')
              .opacity(0.7)
              .margin({ top: 10 });
          }
          .padding({ bottom: 60 });
        }
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [['#64BB5C', 0], ['#3D9970', 0.5], ['#2E7D5E', 1]]
        });
      } else if (this.currentPage === 1) {
        // 登录页
        Column() {
          Text('← 返回')
            .fontSize(16)
            .margin({ left: 24, top: 30 })
            .alignSelf(ItemAlign.Start)
            .onClick(() => {
              this.currentPage = 0;
              this.errorMsg = '';
            });

          Column({ space: 30 }) {
            Text('欢迎回来')
              .fontSize(32)
              .fontWeight(700);

            Column({ space: 20 }) {
              TextInput({ placeholder: '用户名', text: $$this.username })
                .height(50)
                .backgroundColor('#F8F8F8');
              
              TextInput({ placeholder: '密码', text: $$this.password })
                .height(50)
                .type(InputType.Password)
                .backgroundColor('#F8F8F8');

              if (this.errorMsg) {
                Text(this.errorMsg)
                  .fontSize(13)
                  .fontColor('#FF3B30');
              }

              Button('登  录')
                .width('100%')
                .height(50)
                .backgroundColor('#64BB5C')
                .onClick(() => { this.login(); });

              Row() {
                Text('还没有账户? ').fontColor('#999');
                Text('立即注册')
                  .fontColor('#64BB5C')
                  .onClick(() => {
                    this.currentPage = 2;
                    this.errorMsg = '';
                  });
              }
            }
          }
          .width('85%')
          .margin({ top: 60 });
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FFF');
      } else {
        // 注册页
        Column() {
          Text('← 返回')
            .fontSize(16)
            .margin({ left: 24, top: 30 })
            .alignSelf(ItemAlign.Start)
            .onClick(() => {
              this.currentPage = 1;
              this.registerMsg = '';
            });

          Column({ space: 30 }) {
            Text('创建账户')
              .fontSize(32)
              .fontWeight(700);

            Column({ space: 20 }) {
              TextInput({ placeholder: '用户名', text: $$this.registerUsername })
                .height(50)
                .backgroundColor('#F8F8F8');
              
              TextInput({ placeholder: '密码', text: $$this.registerPassword })
                .height(50)
                .type(InputType.Password)
                .backgroundColor('#F8F8F8');
              
              TextInput({ placeholder: '确认密码', text: $$this.registerConfirmPassword })
                .height(50)
                .type(InputType.Password)
                .backgroundColor('#F8F8F8');

              if (this.registerMsg) {
                Text(this.registerMsg)
                  .fontSize(13)
                  .fontColor('#FF9500')
                  .padding(12)
                  .backgroundColor('#FFF8E1')
                  .borderRadius(8);
              }

              Button('注  册')
                .width('100%')
                .height(50)
                .backgroundColor('#64BB5C')
                .onClick(() => { this.register(); });

              Row() {
                Text('已有账户? ').fontColor('#999');
                Text('立即登录')
                  .fontColor('#64BB5C')
                  .onClick(() => {
                    this.currentPage = 1;
                    this.registerMsg = '';
                  });
              }
            }
          }
          .width('85%')
          .margin({ top: 60 });
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FFF');
      }
    }
    .width('100%')
    .height('100%');
  }
}
