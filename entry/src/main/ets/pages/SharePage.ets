import { UIExtensionContentSession } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct SharePage {
  // 从 AppStorage 获取 ShareExtensionAbility 传递过来的数据
  @StorageLink('sharedData') sharedData: string = '没有接收到数据';

  private session: UIExtensionContentSession | undefined = undefined;

  aboutToAppear() {
    // 实际开发中可以通过 context 获取 session
    hilog.info(0x0000, 'SharePage', 'SharePage is opened');
  }

  build() {
    Column() {
      Text('接收系统分享')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E293B')
        .margin({ bottom: 20 })

      Text('我们的应用被其他应用（如浏览器/相册）通过系统分享拉起啦！')
        .fontSize(14)
        .fontColor('#64748B')
        .margin({ bottom: 20 })

      TextArea({ text: this.sharedData })
        .width('100%')
        .height(150)
        .backgroundColor('#F8FAFC')
        .margin({ bottom: 20 })
        .enabled(false)

      Row() {
        Button('取消并退出')
          .backgroundColor('#E2E8F0')
          .fontColor('#475569')
          .width('48%')
          .onClick(() => {
            // 在实际代码中，应该调用 session.terminateSelf()
            // 由于这里是简化演示，可以发个事件或者只是记录日志
            hilog.info(0x0000, 'SharePage', 'User cancelled sharing');
          })

        Button('保存内容')
          .backgroundColor('#10B981')
          .width('48%')
          .onClick(() => {
            hilog.info(0x0000, 'SharePage', 'Content saved');
            // 此处应将数据保存到沙箱，然后终止 session
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
  }
}
