@Entry
@Component
struct WidgetCard {
  // 从 FormExtensionAbility 传递过来的数据
  @LocalStorageProp('title') title: string = '鸿蒙学习卡片';
  @LocalStorageProp('content') content: string = '数据加载中...';
  @LocalStorageProp('time') time: string = '--:--';

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
          
        Text('刷新')
          .fontSize(12)
          .fontColor('#3B82F6')
          .backgroundColor('#E0F2FE')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(12)
          .onClick(() => {
            // 给后台 FormExtensionAbility 发送刷新消息
            postCardAction(this, {
              action: 'message',
              params: { msg: 'refresh' }
            });
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 12 })

      Text(this.content)
        .fontSize(14)
        .fontColor('#475569')
        .width('100%')
        .margin({ bottom: 8 })
        
      Text(`最后更新: ${this.time}`)
        .fontSize(10)
        .fontColor('#94A3B8')
        .width('100%')
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .onClick(() => {
      // 点击卡片主体，拉起主应用 (Router 动作)
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: { message: '来自卡片的点击' }
      });
    })
  }
}
