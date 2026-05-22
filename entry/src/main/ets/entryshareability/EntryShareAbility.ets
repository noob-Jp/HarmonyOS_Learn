import { ShareExtensionAbility, UIExtensionContentSession, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'EntryShareAbility';

export default class EntryShareAbility extends ShareExtensionAbility {
  onSessionCreate(want: Want, session: UIExtensionContentSession) {
    hilog.info(0x0000, TAG, 'onSessionCreate is called');
    
    // 解析 want 中的分享数据
    let sharedContent = '未知内容';
    if (want.parameters && want.parameters['ability.params.stream']) {
      // 假设收到了一个文本流或文件 URI 数组
      sharedContent = JSON.stringify(want.parameters['ability.params.stream']);
    } else if (want.parameters) {
      sharedContent = JSON.stringify(want.parameters);
    }

    // 将解析出的内容存入全局或传递给拉起的页面
    AppStorage.setOrCreate('sharedData', sharedContent);

    // 加载专门处理分享的 UI 页面
    session.loadContent('pages/SharePage');
  }

  onForeground() {
    hilog.info(0x0000, TAG, 'onForeground');
  }

  onBackground() {
    hilog.info(0x0000, TAG, 'onBackground');
  }

  onSessionDestroy(session: UIExtensionContentSession) {
    hilog.info(0x0000, TAG, 'onSessionDestroy');
  }
}
