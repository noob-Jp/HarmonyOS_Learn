import { AbilityStage, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x1000;
const TAG = 'MyAbilityStage';

/**
 * AbilityStage 组件管理器
 * - 知识点：每个 HAP 模块对应一个 AbilityStage 实例
 * - onCreate: HAP 首次加载时触发，用于模块级初始化
 * - onAcceptWant: specified 启动模式时决定使用哪个 UIAbility 实例
 * - onConfigurationUpdate: 系统配置变更（语言/深色模式）时触发
 * - onMemoryLevel: 内存压力事件
 */
export default class MyAbilityStage extends AbilityStage {
  // 模块加载时间戳（跨组件共享）
  private static loadTime: number = 0;

  /**
   * HAP 模块首次加载时调用
   * 时机：该 HAP 下的第一个 UIAbility 即将创建之前
   */
  onCreate(): void {
    MyAbilityStage.loadTime = Date.now();
    hilog.info(DOMAIN, TAG, '========================================');
    hilog.info(DOMAIN, TAG, 'AbilityStage onCreate - 模块首次加载');
    hilog.info(DOMAIN, TAG, `模块名称: ${this.context.currentHapModuleInfo.name}`);
    hilog.info(DOMAIN, TAG, `HAP包名: ${this.context.currentHapModuleInfo.name}`);
    hilog.info(DOMAIN, TAG, `加载时间: ${new Date(MyAbilityStage.loadTime).toISOString()}`);
    hilog.info(DOMAIN, TAG, '========================================');

    // 将模块加载信息写入 AppStorage，供所有页面访问
    AppStorage.setOrCreate('stageLoadTime', MyAbilityStage.loadTime);
    AppStorage.setOrCreate('stageOnCreateCalled', true);
    AppStorage.setOrCreate('moduleName', this.context.currentHapModuleInfo.name);
  }

  /**
   * specified 启动模式的实例键值决策
   * 返回的 key 决定复用哪个 UIAbility 实例
   * @param want 启动参数
   * @returns 实例标识 key
   */
  onAcceptWant(want: Want): string {
    hilog.info(DOMAIN, TAG, `onAcceptWant - abilityName: ${want.abilityName}`);
    // 根据 want 参数决定实例 key，实现指定实例复用
    if (want.parameters && want.parameters['instanceKey']) {
      const key = String(want.parameters['instanceKey']);
      hilog.info(DOMAIN, TAG, `指定实例 key: ${key}`);
      AppStorage.setOrCreate('lastAcceptWantKey', key);
      return key;
    }
    return 'default';
  }

  /**
   * 系统配置变更回调（语言、深色模式、屏幕方向等）
   */
  onConfigurationUpdate(config: Record<string, Object>): void {
    hilog.info(DOMAIN, TAG, `onConfigurationUpdate: ${JSON.stringify(config)}`);
    AppStorage.setOrCreate('lastConfigUpdate', JSON.stringify(config));
  }

  /**
   * 内存压力回调
   * 级别：MEMORY_LEVEL_MODERATE=0, MEMORY_LEVEL_LOW=1, MEMORY_LEVEL_CRITICAL=2
   */
  onMemoryLevel(level: number): void {
    const levelNames = ['正常', '低内存', '严重不足'];
    hilog.warn(DOMAIN, TAG, `onMemoryLevel: ${levelNames[level] ?? level}`);
    AppStorage.setOrCreate('memoryLevel', levelNames[level] ?? String(level));
  }

  static getLoadTime(): number {
    return MyAbilityStage.loadTime;
  }
}
