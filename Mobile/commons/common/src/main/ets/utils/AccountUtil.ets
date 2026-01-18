import { AppStorageV2, PersistenceV2, promptAction } from '@kit.ArkUI';
import { functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { HuaweiAccountInfo, UserInfo } from 'types';
import { Logger } from './Logger';

@ObservedV2
export class AccountUtil {
  // Previewer 不支持 PersistentStorage / AccountKit 的完整能力，使用内存态兜底，避免预览白屏。
  private static _inPreview: boolean = true;
  private static userInfo: UserInfo = new UserInfo();
  private static accountInfo: HuaweiAccountInfo = new HuaweiAccountInfo();
  public static functionalController: functionalButtonComponentManager.FunctionalButtonController =
    new functionalButtonComponentManager.FunctionalButtonController();

  private static ensureStorageReady(): void {
    if (!AccountUtil._inPreview) {
      return;
    }
    try {
      // 如果能正常 connect，说明不是 Previewer 或者环境支持存储
      AccountUtil.userInfo = AppStorageV2.connect(UserInfo, 'userInfo', () => new UserInfo())!;
      AccountUtil.accountInfo = PersistenceV2.connect(HuaweiAccountInfo, 'accountInfo', () => new HuaweiAccountInfo())!;
      AccountUtil._inPreview = false;
    } catch (e) {
      // 仍然保持 preview in-memory
      AccountUtil._inPreview = true;
    }
  }

  public static async initLogin() {
    AccountUtil.ensureStorageReady();
    // Previewer 下跳过华为账号静默登录，避免 unionID undefined 导致的异常与预览白屏
    if (AccountUtil._inPreview) {
      AccountUtil.setNickName();
      return;
    }
    if (AccountUtil.accountInfo.unionID?.length === 0) {
      AccountUtil.silentLogin();
    } else {
      // 存在union设置nickname
      AccountUtil.setNickName();
    }
  }

  private static silentLogin() {
    try {
      const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      loginRequest.forceLogin = false;
      loginRequest.state = util.generateRandomUUID();
      const controller = new authentication.AuthenticationController();
      controller.executeRequest(loginRequest).then((response: authentication.LoginWithHuaweiIDResponse) => {
        const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse;
        const state = loginWithHuaweiIDResponse.state;
        if (state && loginRequest.state !== state) {
          return;
        }
        const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
        const unionID = loginWithHuaweiIDCredential.unionID;
        AccountUtil.setNickName();
        AccountUtil.accountInfo.unionID = unionID;
        AppStorageV2.connect(HuaweiAccountInfo, 'accountInfo', () => new HuaweiAccountInfo())!;
      }).catch((error: BusinessError) => {
        if (error.code === 1001502001) {
          promptAction.showToast({ message: '请先登录华为账号' });
        }
        AccountUtil.dealAllError(error);
      });
    } catch (error) {
      AccountUtil.dealAllError(error);
    }
  }

  public static setNickName() {
    AccountUtil.userInfo.nickname = '华为用户';
    if (!AccountUtil._inPreview) {
      AppStorageV2.connect(UserInfo, 'userInfo', () => new UserInfo())!;
    }
  }

  public static getUserInfo(): UserInfo {
    return AccountUtil.userInfo;
  }

  public static getAccountInfo(): HuaweiAccountInfo {
    return AccountUtil.accountInfo;
  }

  private static dealAllError(error: BusinessError): void {
    Logger.error(`Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }
}