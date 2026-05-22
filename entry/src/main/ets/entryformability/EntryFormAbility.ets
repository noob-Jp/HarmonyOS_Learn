import { FormExtensionAbility, formBindingData, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'EntryFormAbility';

class FormData {
  title: string = '';
  content: string = '';
  time: string = '';
}

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    hilog.info(0x0000, TAG, 'onAddForm');
    
    // 初始化卡片上要显示的数据
    // 这里的键值需要与卡片 UI (WidgetCard.ets) 中的 @LocalStorageProp 保持一致
    let formData = new FormData();
    formData.title = 'HarmonyOS 学习';
    formData.content = '今日任务：学习 FormExtensionAbility 桌面卡片';
    formData.time = new Date().toLocaleTimeString();
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string): void {
    hilog.info(0x0000, TAG, 'onCastToNormalForm');
  }

  onUpdateForm(formId: string): void {
    hilog.info(0x0000, TAG, 'onUpdateForm');
    // 在这里可以处理卡片定时刷新逻辑
  }

  onChangeFormVisibility(newStatus: Record<string, number>): void {
    hilog.info(0x0000, TAG, 'onChangeFormVisibility');
  }

  onFormEvent(formId: string, message: string): void {
    hilog.info(0x0000, TAG, `onFormEvent, message: ${message}`);
    // 当卡片内部触发了 message 事件（比如点了刷新按钮），就会回调到这里
  }

  onRemoveForm(formId: string): void {
    hilog.info(0x0000, TAG, 'onRemoveForm');
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }
}
