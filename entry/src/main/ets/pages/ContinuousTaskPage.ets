import { router } from '@kit.ArkUI';
import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct ContinuousTaskPage {
  @StorageLink('bgTaskRunning') isTaskRunning: boolean = false;
  @StorageLink('bgTaskProgress') progress: number = 0;
  @StorageLink('bgTaskStatus') statusText: string = '未启动';
  @StorageLink('bgTaskTimerId') timerId: number = -1;

  @Builder
  PageHeader() {
    Row() {
      Text('←').fontSize(20).fontColor('#94A3B8').margin({ right: 12 }).onClick(() => router.back())
      Column() {
        Text('长时任务 (Continuous Task)').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('标准第三方应用的后台保活方案').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('⏳').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  async startContinuousTask() {
    let context = getContext(this) as common.UIAbilityContext;

    // 配置通知栏点击后要拉起的页面 (这里直接拉回当前应用主入口)
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "com.example.myapplication2",
          abilityName: "EntryAbility"
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    try {
      this.statusText = '正在申请长时任务...';
      const agent = await wantAgent.getWantAgent(wantAgentInfo);
      
      // 开启长时任务（类型为 dataTransfer）
      await backgroundTaskManager.startBackgroundRunning(context, backgroundTaskManager.BackgroundMode.DATA_TRANSFER, agent);
      
      this.isTaskRunning = true;
      this.statusText = '后台长时任务运行中...';
      hilog.info(0x0000, 'ContinuousTask', 'startBackgroundRunning success');

      // 启动模拟下载进度
      this.progress = 0;
      this.timerId = setInterval(() => {
        this.progress += 5;
        hilog.info(0x0000, 'ContinuousTask', `模拟后台下载中... ${this.progress}%`);
        
        if (this.progress >= 100) {
          this.progress = 100;
          this.stopContinuousTask();
          this.statusText = '下载完成';
        }
      }, 2000);

    } catch (error) {
      hilog.error(0x0000, 'ContinuousTask', `startBackgroundRunning failed: ${JSON.stringify(error)}`);
      this.statusText = '启动失败: ' + error.message;
    }
  }

  async stopContinuousTask() {
    if (!this.isTaskRunning) return;
    
    let context = getContext(this) as common.UIAbilityContext;
    try {
      await backgroundTaskManager.stopBackgroundRunning(context);
      this.isTaskRunning = false;
      this.statusText = '任务已停止';
      clearInterval(this.timerId);
      hilog.info(0x0000, 'ContinuousTask', 'stopBackgroundRunning success');
    } catch (error) {
      hilog.error(0x0000, 'ContinuousTask', `stopBackgroundRunning failed: ${JSON.stringify(error)}`);
    }
  }

  build() {
    Column() {
      this.PageHeader()

      Column() {
        Text('系统会限制普通应用后台运行，但使用长时任务 (Continuous Task)，我们可以在通知栏展示提示的同时，保证后台任务（如下载、播放）不被轻易挂起。')
          .fontSize(13).fontColor('#94A3B8').lineHeight(20).margin({ bottom: 20 })

        Text(this.statusText)
          .fontSize(16).fontWeight(FontWeight.Bold)
          .fontColor(this.isTaskRunning ? '#10B981' : '#F59E0B')
          .margin({ bottom: 12 })

        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('100%').height(10)
          .color('#3B82F6').backgroundColor('#E2E8F0')
          .margin({ bottom: 24 })

        Row() {
          Button('▶ 开始后台下载任务')
            .backgroundColor('#3B82F6').width('48%')
            .enabled(!this.isTaskRunning)
            .onClick(() => this.startContinuousTask())

          Button('⏹ 停止任务')
            .backgroundColor('#EF4444').width('48%')
            .enabled(this.isTaskRunning)
            .onClick(() => this.stopContinuousTask())
        }
        .width('100%').justifyContent(FlexAlign.SpaceBetween)

        Text('测试方法：点击开始后，退回到系统桌面（Home键），您会在下拉通知栏看到一条系统强制通知，此时控制台也会继续输出下载日志，不会中断。')
          .fontSize(11).fontColor('#64748B').lineHeight(18).margin({ top: 30 })
          .padding(12).backgroundColor('#F8FAFC').borderRadius(8)
      }
      .width('100%').padding(20).backgroundColor('#FFFFFF').borderRadius(16)
      .margin({ top: 12 }).shadow({ radius: 20, color: 'rgba(0,0,0,0.03)', offsetY: 10 })
      
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }
}
