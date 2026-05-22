import { EmbeddedUIExtensionAbility, UIExtensionContentSession } from '@kit.AbilityKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'EntryEmbeddedAbility';

export default class EntryEmbeddedAbility extends EmbeddedUIExtensionAbility {
  onSessionCreate(want: Want, session: UIExtensionContentSession) {
    hilog.info(0x0000, TAG, 'onSessionCreate is called');

    // 将 session 存储在全局或直接传给页面，这里我们使用 AppStorage
    AppStorage.setOrCreate('embeddedSession', session);

    // 加载专门为嵌入式设计的 UI 页面
    session.loadContent('pages/EmbeddedPage');
  }

  onSessionDestroy(session: UIExtensionContentSession) {
    hilog.info(0x0000, TAG, 'onSessionDestroy is called');
  }

  onForeground() {
    hilog.info(0x0000, TAG, 'onForeground is called');
  }

  onBackground() {
    hilog.info(0x0000, TAG, 'onBackground is called');
  }
}
