import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0001;
const TAG = 'EntryAbility';

/**
 * UIAbility - 应用的核心交互组件
 *
 * 知识点覆盖：
 * 1. UIAbility 生命周期：onCreate → onWindowStageCreate → onForeground → onBackground → onWindowStageDestroy → onDestroy
 * 2. WindowStage：每个 UIAbility 绑定一个 WindowStage，通过 loadContent 加载页面
 * 3. 启动参数：通过 Want 接收启动参数
 * 4. 系统配置：通过 ApplicationContext 设置颜色模式
 * 5. 跨端迁移：onContinue 回调
 */
export default class EntryAbility extends UIAbility {
  // 记录 Ability 创建时间，跨页面共享
  private createTime: number = 0;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.createTime = Date.now();

    // 设置颜色模式
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }

    hilog.info(DOMAIN, TAG, '======= UIAbility 生命周期 =======');
    hilog.info(DOMAIN, TAG, '[1/6] onCreate - UIAbility 实例被创建');
    hilog.info(DOMAIN, TAG, `Want.abilityName: ${want.abilityName}`);
    hilog.info(DOMAIN, TAG, `Want.bundleName: ${want.bundleName}`);
    hilog.info(DOMAIN, TAG, `LaunchParam.launchReason: ${launchParam.launchReason}`);

    // 初始化 AppStorage 全局状态（供所有页面读取）
    AppStorage.setOrCreate('lifecycleState', 'onCreate');
    AppStorage.setOrCreate('lifecycleLogs', ['[onCreate] UIAbility 实例创建完成']);
    AppStorage.setOrCreate('abilityCreateTime', this.createTime);
    AppStorage.setOrCreate('wantBundleName', want.bundleName ?? '');
    AppStorage.setOrCreate('wantAbilityName', want.abilityName ?? '');
    AppStorage.setOrCreate('wantAction', want.action ?? '');
    AppStorage.setOrCreate('wantParameters', want.parameters ? JSON.stringify(want.parameters) : '{}');
    AppStorage.setOrCreate('launchReason', launchParam.launchReason);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '[6/6] onDestroy - UIAbility 实例被销毁');
    this.appendLog('[onDestroy] UIAbility 实例已销毁');
    AppStorage.setOrCreate('lifecycleState', 'onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, '[2/6] onWindowStageCreate - 主窗口创建完成');
    this.appendLog('[onWindowStageCreate] WindowStage 主窗口已创建');
    AppStorage.setOrCreate('lifecycleState', 'onWindowStageCreate');
    AppStorage.setOrCreate('windowStageCreated', true);

    // 加载主页面
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Index 页面加载成功');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, '[5/6] onWindowStageDestroy - 主窗口即将销毁');
    this.appendLog('[onWindowStageDestroy] WindowStage 即将销毁');
    AppStorage.setOrCreate('lifecycleState', 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, '[3/6] onForeground - UIAbility 切换到前台');
    this.appendLog('[onForeground] 应用进入前台可见状态');
    AppStorage.setOrCreate('lifecycleState', 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, '[4/6] onBackground - UIAbility 切换到后台');
    this.appendLog('[onBackground] 应用进入后台不可见状态');
    AppStorage.setOrCreate('lifecycleState', 'onBackground');
  }

  /**
   * 跨端迁移回调（多端协同）
   * 当用户从一台设备迁移到另一台设备时触发
   */
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(DOMAIN, TAG, 'onContinue - 跨端迁移回调触发');
    // 保存迁移数据
    wantParam['migrationData'] = JSON.stringify({
      timestamp: Date.now(),
      state: 'migrating'
    });
    return AbilityConstant.OnContinueResult.AGREE;
  }

  private appendLog(msg: string): void {
    const logs = AppStorage.get<string[]>('lifecycleLogs') ?? [];
    const timestamp = new Date().toLocaleTimeString();
    logs.push(`[${timestamp}] ${msg}`);
    // 只保留最近20条
    if (logs.length > 20) {
      logs.shift();
    }
    AppStorage.setOrCreate('lifecycleLogs', [...logs]);
  }
}