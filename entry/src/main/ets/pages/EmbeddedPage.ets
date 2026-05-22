import { UIExtensionContentSession } from '@kit.AbilityKit';

@Entry
@Component
struct EmbeddedPage {
  @StorageLink('embeddedSession') session: UIExtensionContentSession | undefined = undefined;
  @State payAmount: number = 99.8;

  build() {
    Column() {
      Text('🔒 安全支付控件 (独立进程)')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ bottom: 12 })

      Text('宿主进程无法获取到这里的输入数据，保证安全。')
        .fontSize(10)
        .fontColor('#94A3B8')
        .margin({ bottom: 16 })

      Row() {
        Text('支付金额：')
          .fontSize(14)
          .fontColor('#E2E8F0')
        Text(`¥${this.payAmount}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FBBF24')
      }
      .margin({ bottom: 20 })

      Row() {
        Button('取消支付')
          .backgroundColor('#475569')
          .fontColor('#F8FAFC')
          .width('45%')
          .onClick(() => {
            if (this.session) {
              // 携带数据返回给宿主
              this.session.terminateSelfWithResult({
                resultCode: 0,
                want: {
                  parameters: {
                    'status': 'cancelled'
                  }
                }
              });
            }
          })

        Button('确认支付')
          .backgroundColor('#10B981')
          .width('45%')
          .onClick(() => {
            if (this.session) {
              this.session.terminateSelfWithResult({
                resultCode: 1,
                want: {
                  parameters: {
                    'status': 'success',
                    'amount': this.payAmount
                  }
                }
              });
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#1E293B') // 深色背景以便区分宿主 UI
    .justifyContent(FlexAlign.Center)
  }
}
