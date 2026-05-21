import { router } from '@kit.ArkUI';

// ============================================================
//  UIAbility 生命周期页
//  知识点：
//  - 生命周期6个阶段：onCreate/onWindowStageCreate/onForeground/
//    onBackground/onWindowStageDestroy/onDestroy
//  - UIAbility 与 UI 的数据同步：AppStorage / LocalStorage / PersistentStorage
//  - 跨端迁移（onContinue）
//  - WindowStage 的 loadContent / getMainWindow
// ============================================================

@Entry
@Component
struct LifecyclePage {
  @StorageLink('lifecycleState') currentState: string = 'onForeground';
  @StorageLink('lifecycleLogs') logs: string[] = [];
  @StorageLink('abilityCreateTime') createTime: number = 0;

  // LocalStorage 演示（用 @State 模拟页面级计数器）
  @State localCounter: number = 0;

  @State showDataSync: boolean = false;
  @State appStorageDemo: string = AppStorage.get<string>('lifecycleState') ?? '';
  @State persistCounter: number = 0;

  private timer: number = -1;

  aboutToAppear(): void {
    // 定时刷新状态
    this.timer = setInterval(() => {
      this.appStorageDemo = AppStorage.get<string>('lifecycleState') ?? '';
    }, 1000);
    // 使用 PersistentStorage 持久化 'counter' Key
    PersistentStorage.persistProp('counter', 0);
    this.persistCounter = AppStorage.get<number>('counter') ?? 0;
  }

  aboutToDisappear(): void {
    clearInterval(this.timer);
  }

  @Builder
  PageHeader(title: string, subtitle: string) {
    Column() {
      Row() {
        Text('←')
          .fontSize(20)
          .fontColor('#94A3B8')
          .margin({ right: 12 })
          .onClick(() => router.back())
        Column() {
          Text(title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
          Text(subtitle)
            .fontSize(11)
            .fontColor('#64748B')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Text('⚡').fontSize(24)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(13)
      .fontWeight(FontWeight.Bold)
      .fontColor('#6366F1')
      .letterSpacing(0.5)
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }

  @Builder
  LifecycleStage(step: number, name: string, desc: string, isActive: boolean) {
    Row() {
      // 步骤圆圈
      Column() {
        Text(String(step))
          .fontSize(12)
          .fontColor(isActive ? '#F4F6F9' : '#64748B')
          .fontWeight(FontWeight.Bold)
      }
      .width(28)
      .height(28)
      .borderRadius(14)
      .backgroundColor(isActive ? '#6366F1' : 'rgba(0,0,0,0.05)')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 12 })

      Column() {
        Text(name)
          .fontSize(13)
          .fontWeight(isActive ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(isActive ? '#818CF8' : '#334155')
        Text(desc)
          .fontSize(10)
          .fontColor('#64748B')
          .margin({ top: 2 })
          .maxLines(2)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (isActive) {
        Text('●')
          .fontSize(8)
          .fontColor('#34D399')
          .animation({ duration: 1000, iterations: -1 })
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor(isActive ? 'rgba(99,102,241,0.12)' : '#FFFFFF')
    .borderRadius(10)
    .border({ width: 1, color: isActive ? 'rgba(99,102,241,0.4)' : 'rgba(0,0,0,0.05)' })
    .margin({ bottom: 6 })
  }

  @Builder
  DataSyncTab() {
    Column() {
      // AppStorage 演示
      Column() {
        Row() {
          Text('🔵')
          Text(' AppStorage（进程级共享）')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
        }
        .margin({ bottom: 8 })
        Text('跨 UIAbility 和 Page 共享，进程内全局可见')
          .fontSize(11)
          .fontColor('#64748B')
          .margin({ bottom: 10 })
        Row() {
          Text('lifecycleState：')
            .fontSize(11)
            .fontColor('#94A3B8')
          Text(this.currentState)
            .fontSize(12)
            .fontColor('#34D399')
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .padding(10)
        .backgroundColor('rgba(52,211,153,0.08)')
        .borderRadius(8)
        .margin({ bottom: 6 })

        Row() {
          Text('abilityCreateTime：')
            .fontSize(11)
            .fontColor('#94A3B8')
          Text(this.createTime > 0 ? new Date(this.createTime).toLocaleTimeString() : '--')
            .fontSize(11)
            .fontColor('#818CF8')
        }
        .width('100%')
        .padding(10)
        .backgroundColor('rgba(99,102,241,0.08)')
        .borderRadius(8)
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 10 })

      // LocalStorage 演示
      Column() {
        Row() {
          Text('🟡')
          Text(' LocalStorage（页面级共享）')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
        }
        .margin({ bottom: 8 })
        Text('同一 UIAbility 内的页面间共享，与 @LocalStorageLink 绑定')
          .fontSize(11)
          .fontColor('#64748B')
          .margin({ bottom: 10 })
        Row() {
          Text('计数器：')
            .fontSize(12)
            .fontColor('#94A3B8')
            .margin({ right: 12 })
          Text(String(this.localCounter))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FBBF24')
            .layoutWeight(1)
          Button('+1')
            .fontSize(13)
            .height(32)
            .backgroundColor('#FBBF2422')
            .fontColor('#FBBF24')
            .borderRadius(8)
            .border({ width: 1, color: '#FBBF2444' })
            .onClick(() => { this.localCounter++; })
        }
        .width('100%')
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 10 })

      // PersistentStorage 演示
      Column() {
        Row() {
          Text('🟢')
          Text(' PersistentStorage（持久化存储）')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
        }
        .margin({ bottom: 8 })
        Text('应用退出后数据仍然保留，重启后可恢复，对应 AppStorage 中的 Key')
          .fontSize(11)
          .fontColor('#64748B')
          .margin({ bottom: 10 })
        Row() {
          Text('持久化计数器：')
            .fontSize(12)
            .fontColor('#94A3B8')
            .margin({ right: 12 })
          Text(String(this.persistCounter))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#34D399')
            .layoutWeight(1)
          Button('+1')
            .fontSize(13)
            .height(32)
            .backgroundColor('#34D39922')
            .fontColor('#34D399')
            .borderRadius(8)
            .border({ width: 1, color: '#34D39944' })
            .onClick(() => {
              this.persistCounter++;
              AppStorage.setOrCreate('counter', this.persistCounter);
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  build() {
    Scroll() {
      Column() {
        this.PageHeader('UIAbility 生命周期', '应用组件的完整生命旅程 & 数据同步')

        // ── 生命周期阶段 ────────────────────────────────────
        this.SectionTitle('📊 生命周期六阶段（当前状态实时高亮）')

        Column() {
          this.LifecycleStage(1, 'onCreate(want, launchParam)', 'UIAbility 实例创建，进行初始化（注册监听器、初始化资源）', this.currentState === 'onCreate')
          Row() {
            Divider().vertical(true).height(16).color('#6366F144').margin({ left: 27, right: 27 })
          }.width('100%')
          this.LifecycleStage(2, 'onWindowStageCreate(windowStage)', 'WindowStage 主窗口创建完成，调用 loadContent 加载页面', this.currentState === 'onWindowStageCreate')
          Row() {
            Divider().vertical(true).height(16).color('#6366F144').margin({ left: 27, right: 27 })
          }.width('100%')
          this.LifecycleStage(3, 'onForeground()', 'UIAbility 进入前台可见状态（重新申请资源）', this.currentState === 'onForeground')
          Row() {
            Divider().vertical(true).height(16).color('#6366F144').margin({ left: 27, right: 27 })
          }.width('100%')
          this.LifecycleStage(4, 'onBackground()', 'UIAbility 进入后台不可见状态（释放可恢复资源）', this.currentState === 'onBackground')
          Row() {
            Divider().vertical(true).height(16).color('#6366F144').margin({ left: 27, right: 27 })
          }.width('100%')
          this.LifecycleStage(5, 'onWindowStageDestroy()', 'WindowStage 即将销毁，释放 UI 资源', this.currentState === 'onWindowStageDestroy')
          Row() {
            Divider().vertical(true).height(16).color('#6366F144').margin({ left: 27, right: 27 })
          }.width('100%')
          this.LifecycleStage(6, 'onDestroy()', 'UIAbility 实例即将销毁，做最终清理', this.currentState === 'onDestroy')
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        // ── 实时日志 ────────────────────────────────────────
        this.SectionTitle('📋 实时生命周期日志')
        Column() {
          ForEach(this.logs.slice().reverse().slice(0, 8), (log: string) => {
            Row() {
              Text('›')
                .fontSize(14)
                .fontColor('#6366F1')
                .margin({ right: 8 })
              Text(log)
                .fontSize(11)
                .fontColor('#334155')
                .layoutWeight(1)
                .maxLines(2)
            }
            .padding({ top: 4, bottom: 4 })
            Divider().color('#FFFFFF')
          })
          if (this.logs.length === 0) {
            Text('日志将在生命周期变化时实时显示...')
              .fontSize(11)
              .fontColor('#94A3B8')
              .padding(16)
          }
        }
        .width('100%')
        .margin({ left: 16, right: 16 })
        .backgroundColor('rgba(0,0,0,0.3)')
        .borderRadius(12)
        .padding(12)
        .border({ width: 1, color: 'rgba(99,102,241,0.2)' })

        // ── 数据同步 ────────────────────────────────────────
        this.SectionTitle('💾 UIAbility 与 UI 数据同步（三种方式）')
        this.DataSyncTab()

        // ── 跨端迁移 ────────────────────────────────────────
        this.SectionTitle('🌉 跨端迁移（onContinue）')
        Column() {
          Text('多端协同：当用户从手机迁移到平板时，onContinue() 被触发，开发者将当前状态序列化到 wantParam，目标设备通过 onCreate 的 launchReason === CONTINUATION 判断并恢复数据。')
            .fontSize(12)
            .fontColor('#94A3B8')
            .lineHeight(18)
            .margin({ bottom: 12 })

          // 代码展示
          Column() {
            Text('// UIAbility.ts')
              .fontSize(10)
              .fontColor('#64748B')
            Text('onContinue(wantParam) {\n  wantParam["pageState"] = getCurrentState();\n  return OnContinueResult.AGREE;\n}')
              .fontSize(11)
              .fontColor('#0284C7')
              .fontFamily('monospace')
              .lineHeight(18)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F8FAFC')
          .borderRadius(8)
        }
        .width('100%')
        .padding(14)
        .margin({ left: 16, right: 16, bottom: 32 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .border({ width: 1, color: 'rgba(0,0,0,0.05)' })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6F9')
  }
}
