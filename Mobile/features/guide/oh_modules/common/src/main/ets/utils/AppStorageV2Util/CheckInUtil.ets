import { PersistenceV2 } from '@kit.ArkUI';

/**
 * 景点打卡数据（按景点ID记录次数与最近一次时间）。
 * 说明：
 * - 需求是“再次点击会再次打卡”，所以这里不做去重/锁定。
 * - 使用 PersistenceV2 持久化；若在 Previewer/不支持环境下 connect 失败，会自动降级为内存态。
 */
@ObservedV2
export class CheckInStore {
  // key: attractionId(string)
  counts: Record<string, number> = {};
  // key: attractionId(string) -> epoch ms
  lastTimes: Record<string, number> = {};
}

@ObservedV2
export class CheckInResult {
  count: number = 0;
  time: number = 0;
}

export class CheckInUtil {
  private static _inMemory: boolean = false;
  private static store: CheckInStore = new CheckInStore();

  private static ensureReady(): void {
    if (CheckInUtil._inMemory) {
      return;
    }
    try {
      // 持久化 key 单独使用，避免和其它模块冲突
      CheckInUtil.store = PersistenceV2.connect(CheckInStore, 'CheckInStore', () => new CheckInStore())!;
      CheckInUtil._inMemory = false;
    } catch (e) {
      // Previewer 或不支持环境：内存态
      CheckInUtil._inMemory = true;
      CheckInUtil.store = CheckInUtil.store ?? new CheckInStore();
    }
  }

  static checkIn(attractionId: number): CheckInResult {
    CheckInUtil.ensureReady();
    const key = attractionId.toString();

    const nextCount = (CheckInUtil.store.counts[key] ?? 0) + 1;
    const now = Date.now();

    CheckInUtil.store.counts[key] = nextCount;
    CheckInUtil.store.lastTimes[key] = now;

    const result = new CheckInResult();
    result.count = nextCount;
    result.time = now;
    return result;
  }

  static getCount(attractionId: number): number {
    CheckInUtil.ensureReady();
    return CheckInUtil.store.counts[attractionId.toString()] ?? 0;
  }

  static getLastTime(attractionId: number): number {
    CheckInUtil.ensureReady();
    return CheckInUtil.store.lastTimes[attractionId.toString()] ?? 0;
  }
}
